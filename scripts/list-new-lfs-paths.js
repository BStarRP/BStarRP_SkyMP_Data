/**
 * Lists paths under Data/ that are LFS-tracked (per .gitattributes) and not in the
 * previous manifest. Used by the release workflow to pull LFS for "new" files so they
 * get real content before manifest build and R2 upload.
 *
 * Usage: node scripts/list-new-lfs-paths.js [prev-manifest.json]
 * Output: one path per line (Data/...)
 */

const fs = require('fs');
const path = require('path');

const prevManifestPath = path.resolve(process.cwd(), process.argv[2] || 'prev-manifest.json');
const dataDir = path.join(process.cwd(), 'Data');
const prefix = 'Data';

if (!fs.existsSync(prevManifestPath)) {
  process.exit(0);
}
if (!fs.existsSync(dataDir) || !fs.statSync(dataDir).isDirectory()) {
  process.exit(0);
}

const prev = JSON.parse(fs.readFileSync(prevManifestPath, 'utf8'));
const prevPaths = new Set((prev.files || []).map((e) => (typeof e === 'string' ? e : e.path)).filter(Boolean));

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

function listFiles(dir, baseDir = dir) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  const files = [];
  for (const e of entries) {
    const full = path.join(dir, e.name);
    const rel = path.relative(baseDir, full).replace(/\\/g, '/');
    if (rel.startsWith('..') || path.isAbsolute(rel)) continue;
    if (e.isDirectory()) {
      files.push(...listFiles(full, baseDir));
    } else if (e.isFile()) {
      files.push(rel);
    }
  }
  return files;
}

const lfsExts = getLfsExtensions();
const relativeFiles = listFiles(dataDir);
const newLfsPaths = relativeFiles.filter((r) => {
  const pathEntry = `${prefix}/${r}`;
  if (prevPaths.has(pathEntry)) return false; // already in previous
  const ext = path.extname(r).toLowerCase();
  return lfsExts.includes(ext);
}).map((r) => `${prefix}/${r}`);

newLfsPaths.forEach((p) => console.log(p));
