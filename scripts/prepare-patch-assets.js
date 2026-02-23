/**
 * Prepares per-file assets for release upload.
 * Reads manifest.json (path, size, hash), copies each file from patch-content
 * into dist-patch/assets. Asset names = first 16 hex chars of SHA-256(path) + extension,
 * to avoid HTTP 400 Bad Content-Length from GitHub with path-derived names.
 *
 * Usage:
 *   node scripts/prepare-patch-assets.js <patchDir> [--prefix=Data]
 */

const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

const patchDir = process.argv[2];
const prefixArg = process.argv.find((a) => a.startsWith('--prefix='));
const prefix = prefixArg ? prefixArg.slice('--prefix='.length) : 'Data';

if (!patchDir) {
  console.error('Usage: node scripts/prepare-patch-assets.js <patchDir> [--prefix=Data]');
  process.exit(1);
}

const absPatchDir = path.resolve(process.cwd(), patchDir);
const manifestPath = path.join(process.cwd(), 'dist-patch', 'manifest.json');
const assetsDir = path.join(process.cwd(), 'dist-patch', 'assets');

if (!fs.existsSync(manifestPath)) {
  console.error('Error: dist-patch/manifest.json not found. Run build-patch.js first.');
  process.exit(1);
}

/** Deterministic safe asset name: SHA-256(path) first 16 hex chars + extension (avoids GitHub 400). */
function toAssetName(pathEntry) {
  const h = crypto.createHash('sha256').update(pathEntry, 'utf8').digest('hex').slice(0, 16);
  const lastDot = pathEntry.lastIndexOf('.');
  const ext = lastDot > 0 ? pathEntry.slice(lastDot) : '';
  return h + ext;
}

const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
const files = manifest.files || [];
if (!fs.existsSync(assetsDir)) fs.mkdirSync(assetsDir, { recursive: true });

let copied = 0;
for (const entry of files) {
  const pathEntry = typeof entry === 'string' ? entry : entry.path;
  if (!pathEntry.startsWith(prefix + '/')) continue;
  const relative = pathEntry.slice(prefix.length + 1).replace(/\//g, path.sep);
  const src = path.join(absPatchDir, relative);
  if (!fs.existsSync(src)) {
    console.error('Error: missing file', src);
    process.exit(1);
  }
  const size = typeof entry === 'object' && entry.size != null ? entry.size : fs.statSync(src).size;
  if (size === 0) continue; // skip 0-byte files (GitHub upload API returns 400 Bad Content-Length)
  const assetName = toAssetName(pathEntry);
  const dest = path.join(assetsDir, assetName);
  fs.copyFileSync(src, dest);
  copied++;
}
console.log('Prepared', copied, 'assets in dist-patch/assets (0-byte files skipped)');