/**
 * Sets manifest URLs and writes github-assets-to-upload.txt.
 * - R2 assets (LFS-tracked + files ≥ largeFileSizeThresholdBytes) → R2 URL.
 * - Non-large: if same path+hash in previous manifest, point to previous release URL
 *   only if that URL returns 200 and Content-Length matches expected size; otherwise
 *   point to current release and add to upload list (handles deleted release or wrong file).
 * - New/changed files → current release, add to upload list.
 *
 * Usage: run from repo root; expects dist-patch/manifest.json, optional prev-manifest.json.
 * Env: BASE, PREV_TAG, PATCH_ASSETS_PUBLIC_URL, VERSION, GITHUB_REPOSITORY
 * Optional: FORCE_UPLOAD_ALL_SMALL_ASSETS=1 — upload every non-R2 file to current release (do not point to previous).
 *            Same env is used by upload-lfs-assets.js to skip R2 copy-from-previous (re-upload all R2 assets from Data/).
 */

const fs = require('fs');
const path = require('path');

const FORCE_UPLOAD_ALL = /^1|true|yes$/i.test(String(process.env.FORCE_UPLOAD_ALL_SMALL_ASSETS || ''));

const manifestPath = path.join(process.cwd(), 'dist-patch', 'manifest.json');
const prevManifestPath = path.join(process.cwd(), 'prev-manifest.json');

const BASE = process.env.BASE;
const PREV_TAG = process.env.PREV_TAG;
const GITHUB_REPOSITORY = process.env.GITHUB_REPOSITORY;
const prevBase = PREV_TAG && GITHUB_REPOSITORY
  ? `https://github.com/${GITHUB_REPOSITORY}/releases/download/${PREV_TAG}`
  : null;

/** Extensions that use LFS (from .gitattributes). All LFS files are served from R2. */
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

function loadLargeConfig() {
  const cfgPath = path.join(process.cwd(), 'scripts', 'patch-upload-config.json');
  if (!fs.existsSync(cfgPath)) return { largeFileSizeThresholdBytes: null };
  const cfg = JSON.parse(fs.readFileSync(cfgPath, 'utf8'));
  return { largeFileSizeThresholdBytes: cfg.largeFileSizeThresholdBytes ?? null };
}

/** True if file should be served from R2 (LFS-tracked per .gitattributes or size >= threshold, e.g. 100MB). */
function goesToR2(relativePath, size) {
  const ext = path.extname(relativePath).toLowerCase();
  if (getLfsExtensions().includes(ext)) return true;
  const { largeFileSizeThresholdBytes } = loadLargeConfig();
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

/** HEAD request; returns { ok, contentLength } (contentLength null if missing or invalid). */
async function headSize(url) {
  try {
    const res = await fetch(url, { method: 'HEAD', redirect: 'follow' });
    const cl = res.headers.get('content-length');
    return { ok: res.ok, contentLength: cl != null ? parseInt(cl, 10) : null };
  } catch (e) {
    return { ok: false, contentLength: null };
  }
}

/** Run async tasks with concurrency limit. */
async function runWithLimit(tasks, limit = 5) {
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

async function main() {
  const m = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
  const r2Base = process.env.PATCH_ASSETS_PUBLIC_URL
    ? (process.env.PATCH_ASSETS_PUBLIC_URL + '/patches/' + process.env.VERSION)
    : null;

  let prevMap = null;
  if (prevBase && fs.existsSync(prevManifestPath)) {
    const prev = JSON.parse(fs.readFileSync(prevManifestPath, 'utf8'));
    prevMap = new Map();
    for (const e of prev.files || []) {
      const p = typeof e === 'string' ? e : e.path;
      const h = typeof e === 'object' && e.hash != null ? e.hash : null;
      if (p && h) prevMap.set(p, h);
    }
    const prevManifestUrl = prevBase + '/manifest.json';
    const { ok } = await headSize(prevManifestUrl);
    if (!ok) {
      console.log('Previous release not reachable (' + prevManifestUrl + '); will upload all non-R2 assets to current release.');
      prevMap = null;
    }
  }

  const toUpload = [];
  const candidatesForPrev = []; // { pathEntry, size, assetName, index }

  m.files = m.files.map((f, index) => {
    const size = typeof f === 'object' && f.size != null ? f.size : 0;
    const pathEntry = typeof f === 'string' ? f : f.path;
    const hash = typeof f === 'object' && f.hash != null ? f.hash : null;
    const assetName = toAssetName(pathEntry);

    if (size === 0) {
      return typeof f === 'string' ? { path: f, url: undefined } : { ...f, url: undefined };
    }
    if (r2Base && goesToR2(pathEntry, size)) {
      return typeof f === 'string' ? { path: f, url: r2Base + '/' + assetName } : { ...f, url: r2Base + '/' + assetName };
    }
    if (!FORCE_UPLOAD_ALL && prevMap && prevMap.get(pathEntry) === hash) {
      candidatesForPrev.push({ pathEntry, size, assetName, index });
      return { ...(typeof f === 'string' ? { path: f } : f), url: prevBase + '/' + assetName };
    }
    toUpload.push(assetName);
    return typeof f === 'string' ? { path: f, url: BASE + '/' + assetName } : { ...f, url: BASE + '/' + assetName };
  });

  if (candidatesForPrev.length > 0 && prevBase) {
    const CONCURRENCY = 5;
    const tasks = candidatesForPrev.map((c) => async () => {
      const url = prevBase + '/' + c.assetName;
      const { ok, contentLength } = await headSize(url);
      const sizeMatch = contentLength !== null && contentLength === c.size;
      return { ...c, usePrev: ok && sizeMatch };
    });
    const results = await runWithLimit(tasks, CONCURRENCY);
    let fixed = 0;
    for (const r of results) {
      if (!r.usePrev) {
        const entry = m.files[r.index];
        if (entry && entry.url && entry.url.startsWith(prevBase)) {
          entry.url = BASE + '/' + r.assetName;
          toUpload.push(r.assetName);
          fixed++;
        }
      }
    }
    if (fixed > 0) {
      console.log('Previous release: ' + fixed + ' asset(s) missing or wrong size; will upload fresh copy to current release.');
    }
  }

  if (m.hasOwnProperty('zipUrl')) delete m.zipUrl;
  fs.writeFileSync(manifestPath, JSON.stringify(m, null, 2), 'utf8');
  fs.writeFileSync(
    path.join(process.cwd(), 'dist-patch', 'github-assets-to-upload.txt'),
    toUpload.join('\n') + (toUpload.length ? '\n' : ''),
    'utf8'
  );
  // Per-file: copying (point to previous) vs uploading (current release)
  for (const f of m.files || []) {
    const pathEntry = typeof f === 'string' ? f : f.path;
    const url = typeof f === 'object' && f.url ? f.url : undefined;
    if (!url || (r2Base && url.startsWith(r2Base))) continue;
    if (prevBase && url.startsWith(prevBase)) {
      console.log('Copying ' + pathEntry);
    } else {
      console.log('Uploading ' + pathEntry);
    }
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
