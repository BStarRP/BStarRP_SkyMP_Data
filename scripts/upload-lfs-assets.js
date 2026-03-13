/**
 * Uploads R2 patch assets to Cloudflare R2: all LFS-tracked files (per .gitattributes)
 * plus any file >= largeFileSizeThresholdBytes (e.g. 100MB) from patch-upload-config.json.
 * - If previous manifest + previous version are provided: copies unchanged files (same path+hash)
 *   from patches/<prevVersion>/ to patches/<version>/; uploads only new/changed from Data/.
 *   Deletes patch folders older than the 5 most recent (keeps last 5 patch versions).
 * - Off-GitHub assets (in manifest but not in Data/): copied from previous if same hash, else skipped
 *   (must be uploaded once via manual script or prior run).
 *
 * Usage:
 *   node scripts/upload-lfs-assets.js Data [--prefix=Data] [--previous-manifest=path] [--previous-version=0.18.30]
 *
 * Env: VERSION, PATCH_ASSETS_BUCKET, PATCH_ASSETS_ACCOUNT_ID, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
 * Optional: FORCE_UPLOAD_ALL_SMALL_ASSETS=1 — upload all R2 assets from Data/ (do not copy from previous on R2).
 */

const fs = require('fs');
const path = require('path');

const FORCE_UPLOAD_ALL = /^1|true|yes$/i.test(String(process.env.FORCE_UPLOAD_ALL_SMALL_ASSETS || ''));
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

const prefix = prefixArg ? prefixArg.slice('--prefix='.length) : 'Data';
const PREVIOUS_MANIFEST_PATH = prevManifestArg ? prevManifestArg.slice('--previous-manifest='.length) : null;
const PREVIOUS_VERSION = prevVersionArg ? prevVersionArg.slice('--previous-version='.length) : null;

const VERSION = process.env.VERSION;
const BUCKET = process.env.PATCH_ASSETS_BUCKET;
const ACCOUNT_ID = process.env.PATCH_ASSETS_ACCOUNT_ID;

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
  if (!fs.existsSync(configPath)) return { largeFileSizeThresholdBytes: null };
  const cfg = JSON.parse(fs.readFileSync(configPath, 'utf8'));
  return { largeFileSizeThresholdBytes: cfg.largeFileSizeThresholdBytes ?? null };
}

/** True if file should be uploaded to R2: LFS-tracked (per .gitattributes) or size >= threshold (e.g. 100MB). */
function goesToR2(relativePath, size) {
  const ext = path.extname(relativePath).toLowerCase();
  if (getLfsExtensions().includes(ext)) return true;
  const { largeFileSizeThresholdBytes } = loadR2Config();
  if (largeFileSizeThresholdBytes != null && size >= largeFileSizeThresholdBytes) return true;
  return false;
}

function toAssetName(pathEntry) {
  return pathEntry
    .replace(/\//g, '_')
    .replace(/[^a-zA-Z0-9_.-]/g, '_')
    .replace(/_+/g, '_')
    .replace(/^_|_$/g, '');
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

const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
const prevManifest = PREVIOUS_MANIFEST_PATH && fs.existsSync(PREVIOUS_MANIFEST_PATH)
  ? JSON.parse(fs.readFileSync(PREVIOUS_MANIFEST_PATH, 'utf8'))
  : null;
const prevMap = prevManifest ? manifestPathHashMap(prevManifest) : null;

if (!prevManifest) {
  console.log('No previous manifest; uploading all R2 assets (no copy-from-previous).');
}

const r2Files = (manifest.files || []).filter((entry) => {
  const pathEntry = typeof entry === 'string' ? entry : entry.path;
  if (!pathEntry.startsWith(prefix + '/')) return false;
  const size = typeof entry === 'object' && entry.size != null ? entry.size : 0;
  if (size === 0) return false;
  const relative = pathEntry.slice(prefix.length + 1);
  return goesToR2(relative, size);
});

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

const KEEP_PATCH_VERSIONS = 5;

/** Run async tasks with a concurrency limit. */
async function runWithLimit(tasks, limit = 10) {
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

    const canCopyFromPrevious = !FORCE_UPLOAD_ALL && newVersion && prevMap && prevMap.get(pathEntry) === hash;

    if (canCopyFromPrevious) {
      const copySourceKey = `patches/${PREVIOUS_VERSION}/${assetName}`;
      try {
        await s3.send(new HeadObjectCommand({ Bucket: BUCKET, Key: copySourceKey }));
      } catch (headErr) {
        if (headErr.name === 'NotFound' || headErr.name === 'NoSuchKey' || headErr.Code === 'NoSuchKey') {
          if (fs.existsSync(src)) {
            await s3.send(
              new PutObjectCommand({
                Bucket: BUCKET,
                Key: destKey,
                Body: fs.createReadStream(src)
              })
            );
            console.log('Uploaded', destKey, '(previous key missing in R2, re-uploaded from local)');
            return 'uploaded';
          }
          console.warn('Skipped (unchanged but key missing in R2 and not in repo):', pathEntry);
          return 'skipped';
        }
        throw headErr;
      }
      await s3.send(
        new CopyObjectCommand({
          Bucket: BUCKET,
          Key: destKey,
          CopySource: `${BUCKET}/${copySourceKey}`
        })
      );
      console.log('Copied', destKey, '(unchanged from previous)');
      return 'copied';
    } else if (fs.existsSync(src)) {
      const expectedSize = typeof entry === 'object' && entry.size != null ? entry.size : 0;
      if (expectedSize > 0) {
        const actualSize = fs.statSync(src).size;
        if (actualSize !== expectedSize) {
          throw new Error(
            pathEntry + ': wrong size (' + actualSize + ' vs expected ' + expectedSize + '). Still an LFS pointer? Ensure "Pull all LFS for R2" runs and working tree is smudged (e.g. git checkout HEAD -- Data/).'
          );
        }
      }
      await s3.send(
        new PutObjectCommand({
          Bucket: BUCKET,
          Key: destKey,
          Body: fs.createReadStream(src)
        })
      );
      console.log('Uploaded', destKey);
      return 'uploaded';
    } else {
      console.warn('Skipped (off-GitHub, not in repo and not in previous manifest with same hash):', pathEntry);
      return 'skipped';
    }
  });

  const concurrency = Math.max(1, parseInt(process.env.R2_CONCURRENCY || '4', 10) || 4);
  const outcomes = await runWithLimit(tasks, concurrency);
  copied = outcomes.filter((o) => o === 'copied').length;
  uploaded = outcomes.filter((o) => o === 'uploaded').length;

  console.log('R2: copied', copied, ', uploaded', uploaded, 'assets (LFS + oversized)');

  // List all patch version prefixes (patches/X.Y.Z/) and delete any older than the 5 most recent
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
    console.log('R2: no patch folders older than the last ' + KEEP_PATCH_VERSIONS + '; nothing to delete');
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
    console.log('R2: deleted ' + totalDeleted + ' objects from ' + toDelete.length + ' old patch folder(s) (kept last ' + KEEP_PATCH_VERSIONS + ' versions)');
  }
}

run().catch((err) => {
  console.error(err);
  process.exit(1);
});
