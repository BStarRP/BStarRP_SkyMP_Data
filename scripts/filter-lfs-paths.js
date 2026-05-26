/**
 * Read newline-separated repo paths; write unique LFS-tracked paths that exist in git.
 * Avoids bash word-splitting on paths with spaces (e.g. "9 divines/...").
 *
 * Usage: node scripts/filter-lfs-paths.js <paths.txt>
 * Output: one path per line (stdout)
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
  return [...exts];
}

const tracked = new Set(
  execFileSync('git', ['ls-files'], { encoding: 'utf8', maxBuffer: 256 * 1024 * 1024 })
    .split(/\r?\n/)
    .filter(Boolean)
);

const exts = getLfsExtensions();
const seen = new Set();
const lines = fs.readFileSync(listPath, 'utf8').split(/\r?\n/).map((l) => l.trim()).filter(Boolean);

for (const p of lines) {
  if (!tracked.has(p)) continue;
  if (!exts.includes(path.extname(p).toLowerCase())) continue;
  if (seen.has(p)) continue;
  seen.add(p);
  process.stdout.write(p + '\n');
}
