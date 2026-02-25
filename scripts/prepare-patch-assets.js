/**
 * Prepares per-file assets for release upload.
 * Reads manifest.json (path, size, hash), copies each file from Data (or <patchDir>)
 * into dist-patch/assets. Asset names = path with slashes replaced by underscores
 * (e.g. Data/Platform/plugins/MpClientPlugin.dll → Data_Platform_plugins_MpClientPlugin.dll),
 * matching the filenames in the manifest URLs for incremental downloads.
 *
 * Usage:
 *   node scripts/prepare-patch-assets.js Data [--prefix=Data]
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

/** Asset name = path with slashes replaced by underscores (matches manifest URL filenames). */
function toAssetName(pathEntry) {
  return pathEntry.replace(/\//g, '_');
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
