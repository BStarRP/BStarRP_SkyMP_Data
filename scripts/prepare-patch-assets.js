/**
 * Prepares per-file assets for release upload.
 * Reads manifest.json (path, size, hash), copies each file from patch-content
 * into dist-patch/assets with asset names sanitized for GitHub uploads:
 * / and whitespace → _, dots in path (not extension) → _, to avoid HTTP 400 Bad Content-Length.
 *
 * Usage:
 *   node scripts/prepare-patch-assets.js <patchDir> [--prefix=Data]
 */

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

/** Sanitize manifest path to GitHub asset name: / and spaces → _, dots (except extension) → _. */
function toAssetName(pathEntry) {
  const s = pathEntry.replace(/\//g, '_').replace(/\s+/g, '_');
  const lastDot = s.lastIndexOf('.');
  if (lastDot <= 0) return s;
  const base = s.slice(0, lastDot).replace(/\./g, '_');
  const ext = s.slice(lastDot);
  return base + ext;
}

const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
const files = manifest.files || [];
if (!fs.existsSync(assetsDir)) fs.mkdirSync(assetsDir, { recursive: true });

for (const entry of files) {
  const pathEntry = typeof entry === 'string' ? entry : entry.path;
  if (!pathEntry.startsWith(prefix + '/')) continue;
  const relative = pathEntry.slice(prefix.length + 1).replace(/\//g, path.sep);
  const src = path.join(absPatchDir, relative);
  const assetName = toAssetName(pathEntry);
  const dest = path.join(assetsDir, assetName);
  if (!fs.existsSync(src)) {
    console.error('Error: missing file', src);
    process.exit(1);
  }
  fs.copyFileSync(src, dest);
}
console.log('Prepared', files.length, 'assets in dist-patch/assets');