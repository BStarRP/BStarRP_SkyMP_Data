/**
 * git lfs pull --include for each path in a newline-separated list that is LFS-tracked,
 * then git checkout to smudge pointers into real files (pull alone often leaves ~130B pointers on disk).
 * Usage: node scripts/pull-lfs-for-path-list.js <paths.txt>
 */

const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');
const { toGitPathspec } = require('./git-pathspec');

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

const listPath = process.argv[2];
if (!listPath || !fs.existsSync(listPath)) {
  process.exit(0);
}

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
  return exts;
}

const tracked = new Set(
  execFileSync('git', ['ls-files'], { encoding: 'utf8', maxBuffer: 256 * 1024 * 1024 })
    .split(/\r?\n/)
    .filter(Boolean)
);

const lines = fs.readFileSync(listPath, 'utf8').split(/\n/).map((l) => l.trim()).filter(Boolean);
const exts = getLfsExtensions();
const lfsPaths = lines.filter((p) => exts.has(path.extname(p).toLowerCase()) && tracked.has(p));

const skipped = lines.filter((p) => exts.has(path.extname(p).toLowerCase()) && !tracked.has(p));
if (skipped.length > 0) {
  console.warn('Skipping', skipped.length, 'path(s) not in git index (often bash word-split artifacts), e.g.:');
  skipped.slice(0, 5).forEach((p) => console.warn('  ', p));
}

if (lfsPaths.length === 0) {
  console.log('pull-lfs-for-path-list: no LFS extensions in list');
  process.exit(0);
}

const BATCH = 50;
for (let i = 0; i < lfsPaths.length; i += BATCH) {
  const chunk = lfsPaths.slice(i, i + BATCH);
  const pullArgs = ['lfs', 'pull'];
  for (const p of chunk) {
    pullArgs.push('--include', toGitPathspec(p));
  }
  const batchNum = Math.floor(i / BATCH) + 1;
  console.log('git lfs pull', chunk.length, 'path(s) (batch', batchNum, ')');
  execFileSync('git', pullArgs, { stdio: 'inherit', cwd: process.cwd() });

  const checkoutArgs = ['checkout', 'HEAD', '--'];
  for (const p of chunk) {
    checkoutArgs.push(toGitPathspec(p));
  }
  console.log('git checkout (smudge)', chunk.length, 'path(s) (batch', batchNum, ')');
  execFileSync('git', checkoutArgs, { stdio: 'inherit', cwd: process.cwd(), maxBuffer: 64 * 1024 * 1024 });
}

const stillPointers = lfsPaths.filter((p) => {
  const full = path.join(process.cwd(), p);
  return fs.existsSync(full) && isLfsPointer(full);
});
if (stillPointers.length > 0) {
  console.error('LFS pull finished but', stillPointers.length, 'path(s) are still pointers, e.g.:');
  stillPointers.slice(0, 10).forEach((p) => console.error('  ', p));
  process.exit(1);
}
console.log('Pulled and smudged', lfsPaths.length, 'LFS path(s)');
