/**
 * Builds the patch manifest for the BStar launcher.
 * Writes dist-patch/manifest.json with path, size, hash for all files in Data/ (or <patchDir>).
 * URLs are added by the release workflow. No zip is built; launcher uses incremental download only.
 *
 * With --previous-manifest and --previous-tag, reuses path/size/hash from previous manifest
 * for unchanged files (only hashes changed/new files), saving LFS bandwidth when used after
 * a sparse LFS pull.
 *
 * Usage:
 *   node scripts/build-patch.js Data [version] [--prefix=Data]
 *   node scripts/build-patch.js Data 1.2.3 --prefix=Data --previous-manifest=prev-manifest.json --previous-tag=prev-tag.txt
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const { execSync } = require('child_process');

const argv = process.argv.slice(2);
const patchDir = argv[0];
const version = argv[1] && !argv[1].startsWith('--') ? argv[1] : null;
const prefixArg = argv.find((a) => a.startsWith('--prefix='));
const prefix = prefixArg ? prefixArg.slice('--prefix='.length) : 'Data';
const prevManifestArg = argv.find((a) => a.startsWith('--previous-manifest='));
const prevManifestPath = prevManifestArg ? path.resolve(process.cwd(), prevManifestArg.slice('--previous-manifest='.length)) : null;
const prevTagArg = argv.find((a) => a.startsWith('--previous-tag='));
const prevTagFilePath = prevTagArg ? path.resolve(process.cwd(), prevTagArg.slice('--previous-tag='.length)) : null;

if (!patchDir) {
  console.error('Usage: node scripts/build-patch.js <patchDir> [version] [--prefix=Data] [--previous-manifest=path] [--previous-tag=path]');
  process.exit(1);
}

const absPatchDir = path.resolve(process.cwd(), patchDir);
if (!fs.existsSync(absPatchDir) || !fs.statSync(absPatchDir).isDirectory()) {
  console.error('Error: patchDir must be an existing directory:', patchDir);
  process.exit(1);
}

/** List files under dir (relative paths) for manifest. */
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

/** Compute SHA-256 hash of a file (hex string). */
function sha256File(filePath) {
  const buf = fs.readFileSync(filePath);
  return crypto.createHash('sha256').update(buf).digest('hex');
}

const LFS_POINTER_HEADER = 'version https://git-lfs.github.com/spec/v1';

function isLfsPointer(filePath) {
  try {
    const st = fs.statSync(filePath);
    if (st.size === 0) return false;
    const n = Math.min(st.size, 8192);
    const buf = Buffer.allocUnsafe(n);
    const fd = fs.openSync(filePath, 'r');
    fs.readSync(fd, buf, 0, n, 0);
    fs.closeSync(fd);
    let s = buf.toString('utf8');
    if (s.charCodeAt(0) === 0xfeff) s = s.slice(1);
    return s.includes(LFS_POINTER_HEADER) && s.includes('oid sha256:');
  } catch (_) {
    return false;
  }
}

/** Run up to `limit` async tasks at a time. */
async function runWithLimit(tasks, limit = 8) {
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

/** Get set of path entries (prefix/relative) that changed since previous tag. */
function getChangedPathEntries(prevTag, patchDirName) {
  try {
    const out = execSync(
      `git diff --name-only "${prevTag}" HEAD -- "${patchDirName}/"`,
      { encoding: 'utf8', maxBuffer: 10 * 1024 * 1024 }
    );
    const lines = out.split('\n').filter(Boolean);
    return new Set(lines.map((p) => p.replace(/\\/g, '/')));
  } catch (_) {
    return new Set();
  }
}

/** LFS-tracked extensions (from .gitattributes). Unchanged LFS paths may stay pointers on disk — do not hash. */
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

const relativeFiles = listFiles(absPatchDir);
let prevMap = null;
let changedPathEntries = null;

if (prevManifestPath && fs.existsSync(prevManifestPath)) {
  const prev = JSON.parse(fs.readFileSync(prevManifestPath, 'utf8'));
  prevMap = new Map();
  for (const e of prev.files || []) {
    const p = typeof e === 'string' ? e : e.path;
    if (!p) continue;
    const size = typeof e === 'object' && e.size != null ? e.size : 0;
    const hash = typeof e === 'object' && e.hash != null ? e.hash : null;
    prevMap.set(p, { path: p, size, hash });
  }
  if (prevTagFilePath && fs.existsSync(prevTagFilePath)) {
    const prevTag = fs.readFileSync(prevTagFilePath, 'utf8').trim();
    if (prevTag) {
      changedPathEntries = getChangedPathEntries(prevTag, patchDir);
      console.log('Reusing previous manifest for unchanged files; hashing', changedPathEntries.size, 'changed path(s)');
    }
  }
}

(async () => {
  const fullManifestEntries = await runWithLimit(
    relativeFiles.map((r) => async () => {
      const pathEntry = `${prefix}/${r}`;
      const fullPath = path.join(absPatchDir, r);
      // Unchanged files: reuse previous manifest. Unchanged LFS files may still be pointers — do not read disk.
      // Non-LFS: confirm size/hash match the working tree so we never ship a manifest that disagrees with git
      // (e.g. bad previous manifest or diff edge cases); mismatches force a fresh hash and R2 re-upload.
      if (prevMap && changedPathEntries && !changedPathEntries.has(pathEntry)) {
        const prevEntry = prevMap.get(pathEntry);
        if (prevEntry && prevEntry.hash != null) {
          const ext = path.extname(r).toLowerCase();
          if (!getLfsExtensions().includes(ext)) {
            const stat = fs.statSync(fullPath);
            const hash = sha256File(fullPath);
            if (stat.size !== prevEntry.size || hash !== prevEntry.hash) {
              console.warn('Previous manifest out of sync with disk (re-hashing):', pathEntry);
              return { path: pathEntry, size: stat.size, hash };
            }
          }
          return { path: pathEntry, size: prevEntry.size, hash: prevEntry.hash };
        }
      }
      if (isLfsPointer(fullPath)) {
        throw new Error(
          pathEntry +
            ': still an LFS pointer on disk. Run node scripts/pull-lfs-for-path-list.js on changed LFS paths before build-patch (pull + checkout smudge).'
        );
      }
      const stat = fs.statSync(fullPath);
      const hash = sha256File(fullPath);
      return { path: pathEntry, size: stat.size, hash };
    }),
    8
  );
  const fullManifest = version
    ? { version, files: fullManifestEntries }
    : { files: fullManifestEntries };

  const outDir = path.join(process.cwd(), 'dist-patch');
  if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true });

  fs.writeFileSync(
    path.join(outDir, 'manifest.json'),
    JSON.stringify(fullManifest, null, 2),
    'utf8'
  );

  console.log('Created dist-patch/manifest.json with', fullManifestEntries.length, 'files');
})().catch((err) => {
  console.error(err);
  process.exit(1);
});
