/**
 * Fetch then checkout LFS objects for paths in a newline-separated list.
 * actions/checkout with lfs:false sets GIT_LFS_SKIP_SMUDGE=1; we clear it for checkout.
 *
 * Usage: node scripts/pull-lfs-for-path-list.js <paths.txt>
 */

const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');
const { toGitLfsInclude } = require('./git-pathspec');

delete process.env.GIT_LFS_SKIP_SMUDGE;
process.env.GIT_LFS_SKIP_SMUDGE = '0';

const LFS_POINTER_HEADER = 'version https://git-lfs.github.com/spec/v1';
const REMOTE = process.env.GIT_LFS_REMOTE || 'origin';
const BATCH = Math.max(1, parseInt(process.env.LFS_PULL_BATCH_SIZE || '50', 10) || 50);

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

function runGit(args, label) {
  execFileSync('git', args, {
    stdio: 'inherit',
    cwd: process.cwd(),
    maxBuffer: 256 * 1024 * 1024
  });
}

function fetchBatch(chunk, batchNum) {
  const args = ['lfs', 'fetch', REMOTE];
  for (const p of chunk) args.push('--include', toGitLfsInclude(p));
  console.log('git lfs fetch', chunk.length, 'path(s) (batch', batchNum, ')');
  runGit(args, 'fetch');
}

function checkoutBatch(chunk, batchNum) {
  const args = ['lfs', 'checkout'];
  for (const p of chunk) args.push(toGitLfsInclude(p));
  console.log('git lfs checkout', chunk.length, 'path(s) (batch', batchNum, ')');
  runGit(args, 'checkout');
}

function materializePath(p) {
  fetchBatch([p], 'retry');
  checkoutBatch([p], 'retry');
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
  return [...exts];
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
  console.warn('Skipping', skipped.length, 'path(s) not in git index, e.g.:');
  skipped.slice(0, 5).forEach((p) => console.warn('  ', p));
}

if (lfsPaths.length === 0) {
  console.log('pull-lfs-for-path-list: no LFS paths to materialize');
  process.exit(0);
}

console.log('Materializing', lfsPaths.length, 'LFS path(s) (fetch then checkout, batch', BATCH, ')');

for (let i = 0; i < lfsPaths.length; i += BATCH) {
  const chunk = lfsPaths.slice(i, i + BATCH);
  const batchNum = Math.floor(i / BATCH) + 1;
  fetchBatch(chunk, batchNum);
  checkoutBatch(chunk, batchNum);
}

let stillPointers = lfsPaths.filter((p) => {
  const full = path.join(process.cwd(), p);
  return fs.existsSync(full) && isLfsPointer(full);
});

if (stillPointers.length > 0) {
  console.log('Retrying', stillPointers.length, 'path(s) still pointer (per-path fetch+checkout)');
  const retry = stillPointers;
  stillPointers = [];
  for (let i = 0; i < retry.length; i++) {
    const p = retry[i];
    try {
      materializePath(p);
    } catch (e) {
      console.warn('Retry failed for', p, ':', e.message || e);
      stillPointers.push(p);
      continue;
    }
    const full = path.join(process.cwd(), p);
    if (fs.existsSync(full) && isLfsPointer(full)) stillPointers.push(p);
    if ((i + 1) % 100 === 0) console.log('Retry progress:', i + 1, '/', retry.length);
  }
}

if (stillPointers.length > 0) {
  console.error('LFS materialize failed:', stillPointers.length, 'path(s) still pointers, e.g.:');
  stillPointers.slice(0, 15).forEach((p) => console.error('  ', p));
  process.exit(1);
}

console.log('Pulled and smudged', lfsPaths.length, 'LFS path(s)');
