/**
 * Prepares per-file assets for release upload.
 * Reads manifest.json (path, size, hash), copies each file from patch-content
 * into dist-patch/assets with asset names path.replace(/\//g, '_') for gh release upload.
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

const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
const files = manifest.files || [];
if (!fs.existsSync(assetsDir)) fs.mkdirSync(assetsDir, { recursive: true });

for (const entry of files) {
  const pathEntry = typeof entry === 'string' ? entry : entry.path;
  if (!pathEntry.startsWith(prefix + '/')) continue;
  const relative = pathEntry.slice(prefix.length + 1).replace(/\//g, path.sep);
  const src = path.join(absPatchDir, relative);
  const assetName = pathEntry.replace(/\//g, '_');
  const dest = path.join(assetsDir, assetName);
  if (!fs.existsSync(src)) {
    console.error('Error: missing file', src);
    process.exit(1);
  }
  fs.copyFileSync(src, dest);
}
console.log('Prepared', files.length, 'assets in dist-patch/assets');