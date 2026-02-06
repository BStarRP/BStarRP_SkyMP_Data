/**
 * Generates manifest.json at repo root for the launcher.
 * The launcher can use the GitHub archive (no .zip asset needed) when manifest.json exists.
 *
 * Usage: node scripts/generate-manifest.js [patchDir] [--prefix=Data]
 */

const fs = require('fs');
const path = require('path');

const patchDir = process.argv[2] || 'patch-content';
const prefixArg = process.argv.find((a) => a.startsWith('--prefix='));
const prefix = prefixArg ? prefixArg.slice('--prefix='.length) : 'Data';

const absPatchDir = path.resolve(process.cwd(), patchDir);
if (!fs.existsSync(absPatchDir) || !fs.statSync(absPatchDir).isDirectory()) {
  console.error('Error: patchDir must be an existing directory:', patchDir);
  process.exit(1);
}

function listFiles(dir, baseDir = dir) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  const files = [];
  for (const e of entries) {
    const full = path.join(dir, e.name);
    const rel = path.relative(baseDir, full).replace(/\\/g, '/');
    if (e.isDirectory()) {
      files.push(...listFiles(full, baseDir));
    } else {
      files.push(rel);
    }
  }
  return files;
}

const relativeFiles = listFiles(absPatchDir);
const manifestFiles = relativeFiles.map((r) => `${prefix}/${r}`);
const manifest = { files: manifestFiles };
const outPath = path.join(process.cwd(), 'manifest.json');

fs.writeFileSync(outPath, JSON.stringify(manifest, null, 2), 'utf8');
console.log('Created manifest.json with', manifestFiles.length, 'files');