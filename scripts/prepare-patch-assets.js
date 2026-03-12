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
const fsp = fs.promises;

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

/** Run up to `limit` async tasks at a time. */
async function runWithLimit(tasks, limit = 20) {
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

const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
const files = manifest.files || [];
if (!fs.existsSync(assetsDir)) fs.mkdirSync(assetsDir, { recursive: true });

const toCopy = [];
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
  if (size === 0) continue;
  if (isLarge(relative, size)) continue;
  toCopy.push({ src, dest: path.join(assetsDir, toAssetName(pathEntry)) });
}

(async () => {
  await runWithLimit(toCopy.map(({ src, dest }) => () => fsp.copyFile(src, dest)), 20);
  console.log('Prepared', toCopy.length, 'assets in dist-patch/assets (0-byte and large files skipped)');
})().catch((err) => {
  console.error(err);
  process.exit(1);
});
