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

function loadLargeConfig() {
  const configPath = path.join(process.cwd(), 'scripts', 'patch-upload-config.json');
  if (!fs.existsSync(configPath)) return { largeExtensions: [], largeFileSizeThresholdBytes: null };
  const cfg = JSON.parse(fs.readFileSync(configPath, 'utf8'));
  return {
    largeExtensions: Array.isArray(cfg.largeExtensions) ? cfg.largeExtensions : [],
    largeFileSizeThresholdBytes: cfg.largeFileSizeThresholdBytes ?? null
  };
}

function isLarge(relativePath, size) {
  const { largeExtensions, largeFileSizeThresholdBytes } = loadLargeConfig();
  const ext = path.extname(relativePath).toLowerCase();
  if (largeExtensions.includes(ext)) return true;
  if (largeFileSizeThresholdBytes != null && size >= largeFileSizeThresholdBytes) return true;
  return false;
}

/** Asset name = path with slashes replaced by underscores, sanitized for filesystem and URLs. */
function toAssetName(pathEntry) {
  return pathEntry
    .replace(/\//g, '_')
    .replace(/[^a-zA-Z0-9_.-]/g, '_')
    .replace(/_+/g, '_')
    .replace(/^_|_$/g, '');
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
  if (isLarge(relative, size)) continue; // large files go to R2, not GitHub
  const assetName = toAssetName(pathEntry);
  const dest = path.join(assetsDir, assetName);
  fs.copyFileSync(src, dest);
  copied++;
}
console.log('Prepared', copied, 'assets in dist-patch/assets (0-byte and large files skipped)');
