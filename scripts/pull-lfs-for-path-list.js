/**
 * git lfs pull --include for each path in a newline-separated list that is LFS-tracked.
 * Usage: node scripts/pull-lfs-for-path-list.js <paths.txt>
 */

const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');

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

const lines = fs.readFileSync(listPath, 'utf8').split(/\n/).map((l) => l.trim()).filter(Boolean);
const exts = getLfsExtensions();
const lfsPaths = lines.filter((p) => exts.has(path.extname(p).toLowerCase()));

if (lfsPaths.length === 0) {
  console.log('pull-lfs-for-path-list: no LFS extensions in list');
  process.exit(0);
}

const BATCH = 50;
for (let i = 0; i < lfsPaths.length; i += BATCH) {
  const chunk = lfsPaths.slice(i, i + BATCH);
  const args = ['lfs', 'pull'];
  for (const p of chunk) {
    args.push('--include', p);
  }
  console.log('git lfs pull', chunk.length, 'path(s) (batch', Math.floor(i / BATCH) + 1, ')');
  execFileSync('git', args, { stdio: 'inherit', cwd: process.cwd() });
}
