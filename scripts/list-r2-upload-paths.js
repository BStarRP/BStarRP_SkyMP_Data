/**
 * Lists Data/ paths that will be uploaded to R2 from local (not copied from previous).
 * Used by the workflow to pull LFS for those paths immediately before R2 upload so we
 * never upload pointer files.
 *
 * Usage: node scripts/list-r2-upload-paths.js [--previous-manifest=path] [--previous-version=X.Y.Z]
 * Output: one path per line (Data/...)
 */

const fs = require('fs');
const path = require('path');

const prefix = 'Data';
const prevManifestArg = process.argv.find((a) => a.startsWith('--previous-manifest='));
const prevVersionArg = process.argv.find((a) => a.startsWith('--previous-version='));
const PREVIOUS_MANIFEST_PATH = prevManifestArg ? prevManifestArg.slice('--previous-manifest='.length) : null;
const PREVIOUS_VERSION = prevVersionArg ? prevVersionArg.slice('--previous-version='.length) : null;
const VERSION = process.env.VERSION;

const manifestPath = path.join(process.cwd(), 'dist-patch', 'manifest.json');
if (!fs.existsSync(manifestPath)) process.exit(0);

const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
const absPatchDir = path.resolve(process.cwd(), prefix);

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

let prevMap = null;
if (PREVIOUS_MANIFEST_PATH && fs.existsSync(PREVIOUS_MANIFEST_PATH) && PREVIOUS_VERSION && VERSION && PREVIOUS_VERSION !== VERSION) {
  const prev = JSON.parse(fs.readFileSync(PREVIOUS_MANIFEST_PATH, 'utf8'));
  prevMap = new Map();
  for (const e of prev.files || []) {
    const p = typeof e === 'string' ? e : e.path;
    const h = typeof e === 'object' && e.hash != null ? e.hash : null;
    if (p && h) prevMap.set(p, h);
  }
}

const { allAssetsToR2 } = loadR2Config();

const r2Files = (manifest.files || []).filter((entry) => {
  const pathEntry = typeof entry === 'string' ? entry : entry.path;
  if (!pathEntry.startsWith(prefix + '/')) return false;
  const size = typeof entry === 'object' && entry.size != null ? entry.size : 0;
  if (size === 0) return false;
  const relative = pathEntry.slice(prefix.length + 1);
  if (allAssetsToR2) return true;
  return goesToR2(relative, size);
});

const toPull = [];
for (const entry of r2Files) {
  const pathEntry = typeof entry === 'string' ? entry : entry.path;
  const hash = typeof entry === 'object' && entry.hash != null ? entry.hash : null;
  const canCopy = prevMap && prevMap.get(pathEntry) === hash;
  if (canCopy) continue;
  const relative = pathEntry.slice(prefix.length + 1).replace(/\//g, path.sep);
  const src = path.join(absPatchDir, relative);
  if (fs.existsSync(src)) toPull.push(pathEntry);
}

toPull.forEach((p) => console.log(p));
