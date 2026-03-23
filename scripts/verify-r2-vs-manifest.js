/**
 * HEAD each R2 object for manifest entries that should live on R2; no full downloads.
 * Writes manifest paths that are missing or whose Content-Length != manifest size
 * (same check the launcher uses). Use with upload-lfs-assets.js --only-r2-paths=...
 *
 * Usage:
 *   node scripts/verify-r2-vs-manifest.js [--manifest=dist-patch/manifest.json] [--prefix=Data] [--out=dist-patch/r2-repair-paths.txt]
 *
 * Env: VERSION, PATCH_ASSETS_BUCKET, PATCH_ASSETS_ACCOUNT_ID, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
 * Optional: PATCH_ASSETS_PUBLIC_URL, R2_CONCURRENCY
 * Optional: R2_VERIFY_PUBLIC_HEAD=1 — after S3 HEAD succeeds, also HEAD the manifest `url` (or built URL).
 *   Catches CDN/cache serving wrong Content-Length while R2 API is correct (launcher fails on a new file each time).
 *
 * Keep filter logic in sync with scripts/upload-lfs-assets.js (r2Files).
 */

const fs = require('fs');
const path = require('path');
const toAssetName = require('./to-asset-name');
const {
  S3Client,
  HeadObjectCommand
} = require('@aws-sdk/client-s3');
const { NodeHttpHandler } = require('@smithy/node-http-handler');

const manifestArg = process.argv.find((a) => a.startsWith('--manifest='));
const prefixArg = process.argv.find((a) => a.startsWith('--prefix='));
const outArg = process.argv.find((a) => a.startsWith('--out='));

const manifestPath = path.resolve(
  process.cwd(),
  manifestArg ? manifestArg.slice('--manifest='.length) : path.join('dist-patch', 'manifest.json')
);
const prefix = prefixArg ? prefixArg.slice('--prefix='.length) : 'Data';
const outPath = outArg ? path.resolve(process.cwd(), outArg.slice('--out='.length)) : null;

const VERSION = process.env.VERSION;
const BUCKET = process.env.PATCH_ASSETS_BUCKET;
const ACCOUNT_ID = process.env.PATCH_ASSETS_ACCOUNT_ID;

if (!VERSION || !BUCKET || !ACCOUNT_ID) {
  console.error('Error: set env VERSION, PATCH_ASSETS_BUCKET, PATCH_ASSETS_ACCOUNT_ID');
  process.exit(1);
}

if (!fs.existsSync(manifestPath)) {
  console.error('Error: manifest not found:', manifestPath);
  process.exit(1);
}

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

function goesToR2(relativePath, size) {
  const ext = path.extname(relativePath).toLowerCase();
  if (getLfsExtensions().includes(ext)) return true;
  const { largeFileSizeThresholdBytes } = loadR2Config();
  if (largeFileSizeThresholdBytes != null && size >= largeFileSizeThresholdBytes) return true;
  return false;
}

const r2Base =
  process.env.PATCH_ASSETS_PUBLIC_URL && VERSION
    ? process.env.PATCH_ASSETS_PUBLIC_URL + '/patches/' + VERSION
    : null;

const { allAssetsToR2 } = loadR2Config();
const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));

const r2Files = (manifest.files || []).filter((entry) => {
  const pathEntry = typeof entry === 'string' ? entry : entry.path;
  if (!pathEntry.startsWith(prefix + '/')) return false;
  const size = typeof entry === 'object' && entry.size != null ? entry.size : 0;
  if (size === 0) return false;
  const relative = pathEntry.slice(prefix.length + 1);
  if (allAssetsToR2) return true;
  if (goesToR2(relative, size)) return true;
  if (r2Base && typeof entry === 'object' && entry.url && entry.url.startsWith(r2Base)) return true;
  return false;
});

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
    requestTimeout: parseInt(process.env.R2_REQUEST_TIMEOUT_MS || '600000', 10) || 600000,
    throwOnRequestTimeout: false
  })
});

async function runWithLimit(tasks, limit) {
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

function publicUrlForEntry(entry, assetName) {
  if (typeof entry === 'object' && entry.url && /^https?:\/\//i.test(String(entry.url))) {
    return String(entry.url);
  }
  if (r2Base) {
    return r2Base + '/' + assetName;
  }
  return null;
}

const VERIFY_PUBLIC_HEAD = /^1|true|yes$/i.test(String(process.env.R2_VERIFY_PUBLIC_HEAD || ''));

/** Same edge the launcher hits; compares Content-Length to manifest when present. */
async function headPublicUrl(url, expectedSize) {
  const ac = new AbortController();
  const ms = Math.max(5000, parseInt(process.env.R2_PUBLIC_HEAD_TIMEOUT_MS || '90000', 10) || 90000);
  const to = setTimeout(() => ac.abort(), ms);
  try {
    const res = await fetch(url, { method: 'HEAD', redirect: 'follow', signal: ac.signal });
    clearTimeout(to);
    if (!res.ok) {
      return { match: false, detail: 'HTTP ' + res.status };
    }
    const cl = res.headers.get('content-length');
    if (cl == null || cl === '') {
      return { match: true, detail: 'no Content-Length (skipped compare)' };
    }
    const len = parseInt(cl, 10);
    if (len !== expectedSize) {
      return { match: false, detail: 'Content-Length ' + len + ' != manifest ' + expectedSize };
    }
    return { match: true, detail: 'ok' };
  } catch (e) {
    clearTimeout(to);
    return { match: false, detail: String(e.message || e) };
  }
}

(async () => {
  if (VERIFY_PUBLIC_HEAD && !r2Base && !process.env.PATCH_ASSETS_PUBLIC_URL) {
    console.warn('R2_VERIFY_PUBLIC_HEAD is set but PATCH_ASSETS_PUBLIC_URL is missing; public check may be limited');
  }

  const concurrency = Math.max(1, parseInt(process.env.R2_CONCURRENCY || '16', 10) || 16);
  const repair = [];

  const tasks = r2Files.map((entry) => async () => {
    const pathEntry = typeof entry === 'string' ? entry : entry.path;
    const expectedSize = typeof entry === 'object' && entry.size != null ? entry.size : 0;
    const assetName = toAssetName(pathEntry);
    const key = `patches/${VERSION}/${assetName}`;

    if (expectedSize <= 0) return { pathEntry, ok: true, reason: 'skip-no-size' };

    try {
      const head = await s3.send(new HeadObjectCommand({ Bucket: BUCKET, Key: key }));
      const got = head.ContentLength ?? 0;
      if (got !== expectedSize) {
        console.warn(pathEntry + ': R2 S3 API size ' + got + ' != manifest ' + expectedSize + ' (key ' + key + ')');
        return { pathEntry, ok: false, reason: 'size-mismatch' };
      }
    } catch (e) {
      if (e.name === 'NotFound' || e.name === 'NoSuchKey' || e.Code === 'NoSuchKey') {
        console.warn(pathEntry + ': missing in R2 (' + key + ')');
        return { pathEntry, ok: false, reason: 'missing' };
      }
      throw e;
    }

    if (VERIFY_PUBLIC_HEAD) {
      const pubUrl = publicUrlForEntry(entry, assetName);
      if (pubUrl) {
        const pub = await headPublicUrl(pubUrl, expectedSize);
        if (!pub.match) {
          console.warn(
            pathEntry + ': S3 OK but public URL differs from manifest — ' + pub.detail + '\n  ' + pubUrl
          );
          return { pathEntry, ok: false, reason: 'public-mismatch' };
        }
      }
    }

    return { pathEntry, ok: true, reason: 'ok' };
  });

  const results = await runWithLimit(tasks, concurrency);
  for (const r of results) {
    if (r && !r.ok && r.pathEntry) repair.push(r.pathEntry);
  }

  const unique = [...new Set(repair)].sort();
  if (outPath) {
    const dir = path.dirname(outPath);
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    fs.writeFileSync(outPath, unique.join('\n') + (unique.length ? '\n' : ''), 'utf8');
    console.log('Wrote', outPath, '(' + unique.length + ' path(s))');
  }

  console.log(
    'R2 audit: ' +
      r2Files.length +
      ' object(s) checked, ' +
      unique.length +
      ' need repair' +
      (VERIFY_PUBLIC_HEAD ? ' (S3 HEAD + public URL HEAD)' : ' (S3 API HEAD only)')
  );
  if (unique.length > 0 && process.env.PATCH_ASSETS_PUBLIC_URL) {
    console.log(
      'Tip: Purge CDN cache for',
      process.env.PATCH_ASSETS_PUBLIC_URL + '/patches/' + VERSION + '/',
      'if the launcher still fails after re-upload — stale edge responses often look like a different file each run.'
    );
  }
})().catch((err) => {
  console.error(err);
  process.exit(1);
});
