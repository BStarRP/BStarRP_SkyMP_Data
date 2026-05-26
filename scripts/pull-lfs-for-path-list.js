/**
 * Materialize LFS files listed in a newline-separated path file.
 * actions/checkout with lfs:false leaves GIT_LFS_SKIP_SMUDGE=1 and pointer files on disk.
 *
 * Strategy: fetch ALL LFS objects for HEAD once, then checkout listed paths (plain paths —
 * do NOT use git :(literal) pathspec; git-lfs does not understand it).
 *
 * Usage: node scripts/pull-lfs-for-path-list.js <paths.txt>
 */

const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');
const { toGitPathspec } = require('./git-pathspec');

delete process.env.GIT_LFS_SKIP_SMUDGE;
process.env.GIT_LFS_SKIP_SMUDGE = '0';

const LFS_POINTER_HEADER = 'version https://git-lfs.github.com/spec/v1';
const REMOTE = process.env.GIT_LFS_REMOTE || 'origin';
const BATCH = Math.max(1, parseInt(process.env.LFS_PULL_BATCH_SIZE || '50', 10) || 50);

function gitPath(rel) {
  return String(rel).replace(/\\/g, '/');
}

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

function runGit(args) {
  execFileSync('git', args, {
    stdio: 'inherit',
    cwd: process.cwd(),
    maxBuffer: 256 * 1024 * 1024
  });
}

function checkoutBatch(chunk, batchNum) {
  const args = ['lfs', 'checkout'];
  for (const p of chunk) args.push(gitPath(p));
  console.log('git lfs checkout', chunk.length, 'path(s) (batch', batchNum, ')');
  runGit(args);
}

function hasBracketPath(p) {
  return /[[\]]/.test(gitPath(p));
}

/** git-lfs treats [ ] as globs in --include/checkout; use git smudge after fetch instead. */
function smudgeViaGitCheckout(p) {
  const spec = toGitPathspec(gitPath(p));
  console.log('git checkout HEAD --', spec);
  runGit(['checkout', 'HEAD', '--', spec]);
}

function pullOnePath(p) {
  if (hasBracketPath(p)) {
    smudgeViaGitCheckout(p);
    return;
  }
  const rel = gitPath(p);
  console.log('git lfs pull --include', rel);
  runGit(['lfs', 'pull', '--include', rel]);
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
const lfsPaths = lines.filter((p) => exts.includes(path.extname(p).toLowerCase()) && tracked.has(p));

const skipped = lines.filter((p) => exts.includes(path.extname(p).toLowerCase()) && !tracked.has(p));
if (skipped.length > 0) {
  console.warn('Skipping', skipped.length, 'path(s) not in git index, e.g.:');
  skipped.slice(0, 5).forEach((p) => console.warn('  ', p));
}

if (lfsPaths.length === 0) {
  console.log('pull-lfs-for-path-list: no LFS paths to materialize');
  process.exit(0);
}

const head = execFileSync('git', ['rev-parse', 'HEAD'], { encoding: 'utf8' }).trim();
console.log('Fetching all LFS objects for', head, 'from', REMOTE, '(then checkout', lfsPaths.length, 'path(s))');
runGit(['lfs', 'fetch', REMOTE, head]);

const lfsCheckoutPaths = lfsPaths.filter((p) => !hasBracketPath(p));
const gitCheckoutPaths = lfsPaths.filter((p) => hasBracketPath(p));

for (let i = 0; i < lfsCheckoutPaths.length; i += BATCH) {
  const chunk = lfsCheckoutPaths.slice(i, i + BATCH);
  checkoutBatch(chunk, Math.floor(i / BATCH) + 1);
}

if (gitCheckoutPaths.length > 0) {
  console.log('git checkout (literal pathspec) for', gitCheckoutPaths.length, 'path(s) with [ ] in name');
  for (let i = 0; i < gitCheckoutPaths.length; i += BATCH) {
    const chunk = gitCheckoutPaths.slice(i, i + BATCH);
    const args = ['checkout', 'HEAD', '--'];
    for (const p of chunk) args.push(toGitPathspec(gitPath(p)));
    console.log('git checkout', chunk.length, 'bracket path(s) (batch', Math.floor(i / BATCH) + 1, ')');
    runGit(args);
  }
}

let stillPointers = lfsPaths.filter((p) => {
  const full = path.join(process.cwd(), p);
  return fs.existsSync(full) && isLfsPointer(full);
});

if (stillPointers.length > 0) {
  console.log('Retrying', stillPointers.length, 'path(s) (git checkout for [ ], else lfs pull)');
  const retry = stillPointers;
  stillPointers = [];
  for (let i = 0; i < retry.length; i++) {
    const p = retry[i];
    try {
      pullOnePath(p);
    } catch (e) {
      console.warn('pull failed for', p, ':', e.message || e);
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
