/**
 * Uploads R2 patch assets to Cloudflare R2: all LFS-tracked files (per .gitattributes)
 * plus any file >= largeFileSizeThresholdBytes (e.g. 100MB) from patch-upload-config.json.
 * - If previous manifest + previous version are provided: copies unchanged files (same path+hash)
 *   from patches/<prevVersion>/ to patches/<version>/; uploads only new/changed from Data/.
 *   Deletes patch folders older than the 3 most recent (keeps last 3 patch versions).
 * - Off-GitHub assets (in manifest but not in Data/): copied from previous if same hash, else skipped
 *   (must be uploaded once via manual script or prior run).
 * - When previous R2 object is missing, local file is missing, or local file is still an LFS pointer: runs
 *   `git checkout HEAD -- <path>` and `git lfs pull --include <path>` as needed, then uploads from disk.
 * - If R2 copy-from-previous succeeds but object size ≠ manifest, replaces the object from the repo (same as above).
 *
 * Usage:
 *   node scripts/upload-lfs-assets.js Data [--prefix=Data] [--previous-manifest=path] [--previous-version=0.18.30] [--only-r2-paths=file.txt]
 *
 * Env: VERSION, PATCH_ASSETS_BUCKET, PATCH_ASSETS_ACCOUNT_ID, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
 * Optional: PATCH_ASSETS_CACHE_CONTROL — R2 Cache-Control (default public, max-age=0, must-revalidate) so CDNs
 *   and browsers do not keep a stale short error body for the same URL after you repair an object.
 * Optional: FORCE_UPLOAD_ALL_SMALL_ASSETS=1 — upload all R2 assets from Data/ (do not copy from previous on R2).
 * Optional: --only-r2-paths=file.txt — one manifest path per line (e.g. Data/foo/bar.esp). Re-uploads only those
 *   from disk (never R2 copy-from-previous). Skips deleting old patches/* folders. Use after verify-r2-vs-manifest.js.
 * Optional: R2_VERIFY_COPY_DEST=1 — after CopyObject, Head the destination too (slower; default off: source Head
 *   already matched manifest size, server-side copy preserves length).
 * Optional: R2_LOG_EACH_COPIED_ASSET=0 — omit per-file "Copied ..." lines (faster CI / smaller logs); summary still prints.
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const { execFileSync } = require('child_process');
const toAssetName = require('./to-asset-name');

const FORCE_UPLOAD_ALL = /^1|true|yes$/i.test(String(process.env.FORCE_UPLOAD_ALL_SMALL_ASSETS || ''));
const VERIFY_COPY_DEST = /^1|true|yes$/i.test(String(process.env.R2_VERIFY_COPY_DEST || ''));
const LOG_EACH_COPIED = !/^0|false|no$/i.test(String(process.env.R2_LOG_EACH_COPIED_ASSET ?? '1'));
const {
  S3Client,
  PutObjectCommand,
  CopyObjectCommand,
  HeadObjectCommand,
  ListObjectsV2Command,
  DeleteObjectsCommand
} = require('@aws-sdk/client-s3');
const { NodeHttpHandler } = require('@smithy/node-http-handler');

const patchDir = process.argv[2];
const prefixArg = process.argv.find((a) => a.startsWith('--prefix='));
const prevManifestArg = process.argv.find((a) => a.startsWith('--previous-manifest='));
const prevVersionArg = process.argv.find((a) => a.startsWith('--previous-version='));
const onlyR2PathsArg = process.argv.find((a) => a.startsWith('--only-r2-paths='));

const prefix = prefixArg ? prefixArg.slice('--prefix='.length) : 'Data';
const PREVIOUS_MANIFEST_PATH = prevManifestArg ? prevManifestArg.slice('--previous-manifest='.length) : null;
const PREVIOUS_VERSION = prevVersionArg ? prevVersionArg.slice('--previous-version='.length) : null;

const VERSION = process.env.VERSION;
const BUCKET = process.env.PATCH_ASSETS_BUCKET;
const ACCOUNT_ID = process.env.PATCH_ASSETS_ACCOUNT_ID;
/** Avoid long-lived caches of wrong/error responses at the public CDN for the same object URL. */
const PATCH_ASSETS_CACHE_CONTROL =
  process.env.PATCH_ASSETS_CACHE_CONTROL || 'public, max-age=0, must-revalidate';

if (!VERSION || !BUCKET || !ACCOUNT_ID) {
  console.error('Error: set env VERSION, PATCH_ASSETS_BUCKET, PATCH_ASSETS_ACCOUNT_ID');
  process.exit(1);
}

if (!patchDir) {
  console.error('Usage: node scripts/upload-lfs-assets.js <patchDir> [--prefix=Data] [--previous-manifest=path] [--previous-version=X.Y.Z]');
  process.exit(1);
}

const absPatchDir = path.resolve(process.cwd(), patchDir);
const manifestPath = path.join(process.cwd(), 'dist-patch', 'manifest.json');

if (!fs.existsSync(manifestPath)) {
  console.error('Error: dist-patch/manifest.json not found. Run build-patch.js first.');
  process.exit(1);
}

/** Extensions that use LFS (from .gitattributes). All LFS files are uploaded to R2. */
function getLfsExtensions() {
  const attrPath = path.join(process.cwd(), '.gitattributes');
  if (!fs.existsSync(attrPath)) return [];
  const lines = fs.readFileSync(attrPath, 'utf8').split(/\r?\n/);
  const exts = new Set();
  for (const line of lines) {
    if (!line.includes('filter=lfs')) continue;
    const pattern = line.split(/\s+/)[0];
    if (pattern && pattern.startsWith('*.')) exts.add(('.' + pattern.slice(2)).toLowerCase());
  }
  return [...exts];
}

function loadR2Config() {
  const configPath = path.join(process.cwd(), 'scripts', 'patch-upload-config.json');
  if (!fs.existsSync(configPath)) return { largeFileSizeThresholdBytes: null, allAssetsToR2: false };
  const cfg = JSON.parse(fs.readFileSync(configPath, 'utf8'));
  return {
    largeFileSizeThresholdBytes: cfg.largeFileSizeThresholdBytes ?? null,
    allAssetsToR2: !!cfg.allAssetsToR2
  };
}

/** True if file should be uploaded to R2: LFS-tracked (per .gitattributes) or size >= threshold (e.g. 100MB). */
function goesToR2(relativePath, size) {
  const ext = path.extname(relativePath).toLowerCase();
  if (getLfsExtensions().includes(ext)) return true;
  const { largeFileSizeThresholdBytes } = loadR2Config();
  if (largeFileSizeThresholdBytes != null && size >= largeFileSizeThresholdBytes) return true;
  return false;
}

function sha256File(filePath) {
  const buf = fs.readFileSync(filePath);
  return crypto.createHash('sha256').update(buf).digest('hex');
}

const LFS_POINTER_HEADER = 'version https://git-lfs.github.com/spec/v1';
/** Scan enough bytes that odd line endings / extension lines still match; real pointers stay tiny. */
const LFS_POINTER_SCAN_BYTES = 8192;

function isLfsPointer(filePath) {
  try {
    const st = fs.statSync(filePath);
    if (st.size === 0) return false;
    const n = Math.min(st.size, LFS_POINTER_SCAN_BYTES);
    const buf = Buffer.allocUnsafe(n);
    const fd = fs.openSync(filePath, 'r');
    fs.readSync(fd, buf, 0, n, 0);
    fs.closeSync(fd);
    let s = buf.toString('utf8');
    if (s.charCodeAt(0) === 0xfeff) s = s.slice(1);
    return s.includes(LFS_POINTER_HEADER) && s.includes('oid sha256:');
  } catch (_) {
    return false;
  }
}

function gitPathFromManifestEntry(pathEntry) {
  return pathEntry.replace(/\\/g, '/');
}

function isLfsTrackedManifestPath(pathEntry) {
  return getLfsExtensions().includes(path.extname(pathEntry).toLowerCase());
}

/**
 * Ensure working tree has real file content: checkout from git if missing, then LFS pull if still pointer or LFS-tracked without smudge.
 */
function materializeFromGit(pathEntry, src) {
  const rel = gitPathFromManifestEntry(pathEntry);
  const cwd = process.cwd();

  if (!fs.existsSync(src)) {
    try {
      console.log('Restoring missing file from git:', rel);
      execFileSync('git', ['checkout', 'HEAD', '--', rel], { cwd, stdio: 'inherit' });
    } catch (e) {
      console.warn('git checkout failed:', rel, e.message);
    }
  }

  if (fs.existsSync(src) && !isLfsPointer(src)) {
    return;
  }

  if (isLfsTrackedManifestPath(pathEntry) || (fs.existsSync(src) && isLfsPointer(src))) {
    try {
      console.log('git lfs pull --include', rel);
      execFileSync('git', ['lfs', 'pull', '--include', rel], { cwd, stdio: 'inherit' });
    } catch (e) {
      console.warn('git lfs pull failed:', rel, e.message);
    }
  }
}

/** Serialize git checkout / lfs pull — concurrent workers must not run lfs in parallel on one repo. */
let materializeChain = Promise.resolve();
function queueMaterialize(pathEntry, src) {
  const job = materializeChain.then(async () => {
    materializeFromGit(pathEntry, src);
  });
  materializeChain = job.catch(() => {});
  return job;
}

/** Build map path -> hash from manifest. */
function manifestPathHashMap(manifest) {
  const map = new Map();
  for (const entry of manifest.files || []) {
    const p = typeof entry === 'string' ? entry : entry.path;
    const h = typeof entry === 'object' && entry.hash != null ? entry.hash : null;
    if (p && h) map.set(p, h);
  }
  return map;
}

const endpoint = `https://${ACCOUNT_ID}.r2.cloudflarestorage.com`;
const s3 = new S3Client({
  region: 'auto',
  endpoint,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
  },
  maxAttempts: Math.max(1, parseInt(process.env.R2_MAX_ATTEMPTS || '6', 10) || 6),
  requestHandler: new NodeHttpHandler({
    connectionTimeout: parseInt(process.env.R2_CONNECTION_TIMEOUT_MS || '60000', 10) || 60000,
    requestTimeout: parseInt(process.env.R2_REQUEST_TIMEOUT_MS || '120000', 10) || 120000
  })
});

/** Fail fast if PutObject did not store the expected byte length (mirrors post-copy HeadObject check). */
async function verifyR2UploadedSize(destKey, expectedSize, pathEntry) {
  if (expectedSize <= 0) return;
  const head = await s3.send(new HeadObjectCommand({ Bucket: BUCKET, Key: destKey }));
  const got = head.ContentLength ?? 0;
  if (got !== expectedSize) {
    throw new Error(
      pathEntry +
        ': after R2 upload, object size is ' +
        got +
        ' (expected ' +
        expectedSize +
        '). Re-run with "Force re-upload ALL assets" or inspect R2.'
    );
  }
}

const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
const prevManifest = PREVIOUS_MANIFEST_PATH && fs.existsSync(PREVIOUS_MANIFEST_PATH)
  ? JSON.parse(fs.readFileSync(PREVIOUS_MANIFEST_PATH, 'utf8'))
  : null;
const prevMap = prevManifest ? manifestPathHashMap(prevManifest) : null;

if (!prevManifest) {
  console.log('No previous manifest; uploading all R2 assets (no copy-from-previous).');
}

const r2Base = process.env.PATCH_ASSETS_PUBLIC_URL && VERSION
  ? (process.env.PATCH_ASSETS_PUBLIC_URL + '/patches/' + VERSION)
  : null;

const { allAssetsToR2 } = loadR2Config();

let onlyR2PathsSet = null;
if (onlyR2PathsArg) {
  const listFile = path.resolve(process.cwd(), onlyR2PathsArg.slice('--only-r2-paths='.length));
  if (!fs.existsSync(listFile)) {
    console.error('Error: --only-r2-paths file not found:', listFile);
    process.exit(1);
  }
  const lines = fs
    .readFileSync(listFile, 'utf8')
    .split(/\r?\n/)
    .map((l) => l.trim().replace(/\\/g, '/'))
    .filter(Boolean);
  onlyR2PathsSet = new Set(lines);
  if (onlyR2PathsSet.size === 0) {
    console.log('R2: --only-r2-paths file is empty; nothing to do');
    process.exit(0);
  }
}

let r2Files = (manifest.files || []).filter((entry) => {
  const pathEntry = typeof entry === 'string' ? entry : entry.path;
  if (!pathEntry.startsWith(prefix + '/')) return false;
  const size = typeof entry === 'object' && entry.size != null ? entry.size : 0;
  if (size === 0) return false;
  const relative = pathEntry.slice(prefix.length + 1);
  if (allAssetsToR2) return true;
  if (goesToR2(relative, size)) return true;
  // Include overflow assets (routed to R2 due to GitHub 1000-asset limit)
  if (r2Base && typeof entry === 'object' && entry.url && entry.url.startsWith(r2Base)) return true;
  return false;
});

const targetedRepair = onlyR2PathsSet != null;

if (onlyR2PathsSet) {
  for (const p of onlyR2PathsSet) {
    const inManifest = (manifest.files || []).some((e) => (typeof e === 'string' ? e : e.path) === p);
    if (!inManifest) {
      console.warn('Warning: --only-r2-paths entry not in manifest (ignored):', p);
    }
  }
  r2Files = r2Files.filter((entry) => {
    const pathEntry = typeof entry === 'string' ? entry : entry.path;
    return onlyR2PathsSet.has(pathEntry);
  });
  if (r2Files.length === 0) {
    console.log('R2: no R2 manifest entries matched --only-r2-paths; nothing to do');
    process.exit(0);
  }
  console.log('R2: targeted repair for', r2Files.length, 'path(s) (no copy-from-previous, no old-folder cleanup)');
}

/** Materialize from git if needed, then PutObject + size verify. `entry` is mutated when manifest size/hash is fixed. */
async function uploadFromLocal(pathEntry, src, destKey, entry, logSuffix) {
  await queueMaterialize(pathEntry, src);
  if (!fs.existsSync(src)) {
    console.warn('Skipped (file not in repo after git restore):', pathEntry);
    return 'skipped';
  }
  if (isLfsPointer(src)) {
    throw new Error(
      pathEntry +
        ': still an LFS pointer after git checkout/lfs pull. Install Git LFS and ensure the object exists for this ref.'
    );
  }
  const actualSize = fs.statSync(src).size;
  let expectedSize = typeof entry === 'object' && entry.size != null ? entry.size : 0;
  if (expectedSize > 0 && actualSize !== expectedSize) {
    const correctHash = sha256File(src);
    entry.size = actualSize;
    entry.hash = correctHash;
    console.log('Fixed manifest size/hash from file:', pathEntry, '(' + expectedSize + ' -> ' + actualSize + ')');
  }
  const uploadSize = fs.statSync(src).size;
  await s3.send(
    new PutObjectCommand({
      Bucket: BUCKET,
      Key: destKey,
      Body: fs.createReadStream(src),
      CacheControl: PATCH_ASSETS_CACHE_CONTROL,
      ContentType: 'application/octet-stream'
    })
  );
  await verifyR2UploadedSize(destKey, uploadSize, pathEntry);
  console.log('Uploaded', destKey + (logSuffix ? ' ' + logSuffix : ''));
  return 'uploaded';
}

/** Parse "X.Y.Z" or "X.Y" to [major, minor, patch] for comparison. */
function parseVersion(v) {
  const parts = String(v).split('.').map((n) => parseInt(n, 10) || 0);
  return [parts[0] ?? 0, parts[1] ?? 0, parts[2] ?? 0];
}

/** Compare two version strings; returns positive if a > b, negative if a < b, 0 if equal. */
function compareVersions(a, b) {
  const va = parseVersion(a);
  const vb = parseVersion(b);
  for (let i = 0; i < 3; i++) {
    if (va[i] !== vb[i]) return va[i] - vb[i];
  }
  return 0;
}

const KEEP_PATCH_VERSIONS = 3;

/** Run async tasks with a concurrency limit. */
  async function runWithLimit(tasks, limit = 16) {
  const results = [];
  let index = 0;
  async function worker() {
    while (index < tasks.length) {
      const i = index++;
      results[i] = await tasks[i]();
    }
  }
  await Promise.all(Array.from({ length: Math.min(limit, tasks.length) }, () => worker()));
  return results;
}

async function run() {
  let copied = 0;
  let uploaded = 0;
  const newVersion = PREVIOUS_VERSION && PREVIOUS_VERSION !== VERSION;

  const tasks = r2Files.map((entry) => async () => {
    const pathEntry = typeof entry === 'string' ? entry : entry.path;
    const hash = typeof entry === 'object' && entry.hash != null ? entry.hash : null;
    const relative = pathEntry.slice(prefix.length + 1).replace(/\//g, path.sep);
    const src = path.join(absPatchDir, relative);
    const assetName = toAssetName(pathEntry);
    const destKey = `patches/${VERSION}/${assetName}`;

    const canCopyFromPrevious =
      !FORCE_UPLOAD_ALL && !targetedRepair && newVersion && prevMap && prevMap.get(pathEntry) === hash;

    if (canCopyFromPrevious) {
      const copySourceKey = `patches/${PREVIOUS_VERSION}/${assetName}`;
      const expectedSize = typeof entry === 'object' && entry.size != null ? entry.size : 0;
      let sourceHead;
      try {
        sourceHead = await s3.send(new HeadObjectCommand({ Bucket: BUCKET, Key: copySourceKey }));
      } catch (headErr) {
        if (headErr.name === 'NotFound' || headErr.name === 'NoSuchKey' || headErr.Code === 'NoSuchKey') {
          return await uploadFromLocal(
            pathEntry,
            src,
            destKey,
            entry,
            '(previous R2 key missing; uploaded from repo)'
          );
        }
        throw headErr;
      }
      const sourceLen = sourceHead.ContentLength ?? 0;
      if (expectedSize > 0 && sourceLen !== expectedSize) {
        console.warn(
          pathEntry +
            ': previous R2 object size ' +
            sourceLen +
            ' != manifest ' +
            expectedSize +
            '; replacing from repo'
        );
        return await uploadFromLocal(pathEntry, src, destKey, entry, '(replaced mismatched previous R2 object)');
      }
      await s3.send(
        new CopyObjectCommand({
          Bucket: BUCKET,
          Key: destKey,
          CopySource: `${BUCKET}/${copySourceKey}`,
          CacheControl: PATCH_ASSETS_CACHE_CONTROL,
          ContentType: 'application/octet-stream'
        })
      );
      if (VERIFY_COPY_DEST && expectedSize > 0) {
        const head = await s3.send(new HeadObjectCommand({ Bucket: BUCKET, Key: destKey }));
        const copiedSize = head.ContentLength ?? 0;
        if (copiedSize !== expectedSize) {
          console.warn(
            pathEntry +
              ': R2 copy dest size ' +
              copiedSize +
              ' != manifest ' +
              expectedSize +
              '; replacing object from repo'
          );
          return await uploadFromLocal(
            pathEntry,
            src,
            destKey,
            entry,
            '(replaced bad R2 copy from repo)'
          );
        }
      }
      if (LOG_EACH_COPIED) {
        console.log('Copied', destKey, '(unchanged from previous, size verified)');
      }
      return 'copied';
    }
    return await uploadFromLocal(pathEntry, src, destKey, entry, '');
  });

  const concurrency = Math.max(1, parseInt(process.env.R2_CONCURRENCY || '12', 10) || 12);
  const outcomes = await runWithLimit(tasks, concurrency);
  copied = outcomes.filter((o) => o === 'copied').length;
  uploaded = outcomes.filter((o) => o === 'uploaded').length;

  console.log('R2: copied', copied, ', uploaded', uploaded, 'assets (LFS + oversized)');

  // Persist manifest in case we fixed any size/hash (file was real on disk after R2 pull but manifest had pointer size)
  fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2), 'utf8');

  if (targetedRepair) {
    return;
  }

  // List all patch version prefixes (patches/X.Y.Z/) and delete any older than the 3 most recent
  let prefixToken = undefined;
  const versionPrefixes = [];
  do {
    const list = await s3.send(
      new ListObjectsV2Command({
        Bucket: BUCKET,
        Prefix: 'patches/',
        Delimiter: '/',
        ContinuationToken: prefixToken
      })
    );
    const prefixes = list.CommonPrefixes || [];
    for (const p of prefixes) {
      const prefix = p.Prefix || '';
      const match = prefix.match(/^patches\/([^/]+)\/$/);
      if (match) versionPrefixes.push(match[1]);
    }
    prefixToken = list.IsTruncated ? list.NextContinuationToken : undefined;
  } while (prefixToken);

  versionPrefixes.sort((a, b) => -compareVersions(a, b)); // newest first
  const toDelete = versionPrefixes.slice(KEEP_PATCH_VERSIONS);
  if (toDelete.length === 0) {
    console.log('R2: no patch folders older than the last ' + KEEP_PATCH_VERSIONS + ' version(s); nothing to delete');
  } else {
    let totalDeleted = 0;
    for (const ver of toDelete) {
      let continuationToken = undefined;
      let deletedCount = 0;
      do {
        const list = await s3.send(
          new ListObjectsV2Command({
            Bucket: BUCKET,
            Prefix: `patches/${ver}/`,
            ContinuationToken: continuationToken
          })
        );
        const keys = (list.Contents || []).map((o) => ({ Key: o.Key }));
        if (keys.length > 0) {
          await s3.send(
            new DeleteObjectsCommand({
              Bucket: BUCKET,
              Delete: { Objects: keys }
            })
          );
          deletedCount += keys.length;
        }
        continuationToken = list.IsTruncated ? list.NextContinuationToken : undefined;
      } while (continuationToken);
      totalDeleted += deletedCount;
      console.log('Deleted patches/' + ver + '/ (' + deletedCount + ' objects)');
    }
    console.log('R2: deleted ' + totalDeleted + ' objects from ' + toDelete.length + ' old patch folder(s) (kept last ' + KEEP_PATCH_VERSIONS + ' version(s))');
  }
}

run().catch((err) => {
  console.error(err);
  process.exit(1);
});
