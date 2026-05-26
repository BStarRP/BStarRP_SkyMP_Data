/**
 * Pulls LFS content only for paths that are in the upload list and still LFS pointers.
 * After sparse checkout we only pulled changed files; set-manifest-urls may add more
 * assets to the upload list (e.g. previous release missing/wrong). We must pull those
 * before prepare-patch-assets or we would copy pointer files to the release.
 *
 * Usage: run from repo root after set-manifest-urls.js.
 * Reads: dist-patch/manifest.json, dist-patch/github-assets-to-upload.txt
 * Writes: nothing (runs git lfs pull --include for pointer paths)
 */

const fs = require('fs');
const path = require('path');
const toAssetName = require('./to-asset-name');
const { execFileSync } = require('child_process');
const { toGitPathspec } = require('./git-pathspec');

const manifestPath = path.join(process.cwd(), 'dist-patch', 'manifest.json');
const uploadListPath = path.join(process.cwd(), 'dist-patch', 'github-assets-to-upload.txt');

const LFS_POINTER_HEADER = 'version https://git-lfs.github.com/spec/v1';
const prefix = 'Data';

function isLfsPointer(filePath) {
  try {
    const buf = Buffer.allocUnsafe(256);
    const fd = fs.openSync(filePath, 'r');
    const n = fs.readSync(fd, buf, 0, 256, 0);
    fs.closeSync(fd);
    const head = buf.slice(0, n).toString('utf8');
    return head.includes(LFS_POINTER_HEADER) && head.includes('oid sha256:');
  } catch (_) {
    return false;
  }
}

if (!fs.existsSync(manifestPath) || !fs.existsSync(uploadListPath)) {
  process.exit(0);
}

const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
const pathToAsset = new Map();
for (const e of manifest.files || []) {
  const p = typeof e === 'string' ? e : e.path;
  if (p) pathToAsset.set(toAssetName(p), p);
}

const uploadNames = fs.readFileSync(uploadListPath, 'utf8').split(/\r?\n/).map((s) => s.trim()).filter(Boolean);
const toPull = [];
for (const assetName of uploadNames) {
  const pathEntry = pathToAsset.get(assetName);
  if (!pathEntry || !pathEntry.startsWith(prefix + '/')) continue;
  const relative = pathEntry.slice(prefix.length + 1).replace(/\//g, path.sep);
  const fullPath = path.join(process.cwd(), prefix, relative);
  if (!fs.existsSync(fullPath)) continue;
  if (isLfsPointer(fullPath)) {
    toPull.push(pathEntry.replace(/\\/g, '/'));
  }
}

if (toPull.length === 0) {
  console.log('No LFS pointers in upload list; nothing to pull');
  process.exit(0);
}

console.log('Pulling LFS for', toPull.length, 'asset(s) in upload list that are still pointers');
// Per-file: pull (fetch to .git/lfs) then restore from index to trigger smudge and write real content.
// "git lfs checkout" can leave pointers in place on some versions; "git checkout -- path" re-applies the smudge filter.
const BATCH = 50;
for (let i = 0; i < toPull.length; i += BATCH) {
  const chunk = toPull.slice(i, i + BATCH);
  const pullArgs = ['lfs', 'pull'];
  for (const p of chunk) {
    pullArgs.push('--include', toGitPathspec(p));
  }
  try {
    execFileSync('git', pullArgs, { stdio: 'inherit', maxBuffer: 50 * 1024 * 1024 });
    for (const p of chunk) {
      execFileSync('git', ['checkout', 'HEAD', '--', toGitPathspec(p)], {
        stdio: 'pipe',
        maxBuffer: 10 * 1024 * 1024
      });
    }
  } catch (e) {
    console.error('git lfs pull / checkout failed (batch', Math.floor(i / BATCH) + 1, '):', e.message);
    process.exit(1);
  }
}
console.log('Pulled and checked out', toPull.length, 'path(s)');
