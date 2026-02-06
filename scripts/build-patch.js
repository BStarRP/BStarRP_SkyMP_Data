/**
 * Builds a patch zip for the BStar launcher.
 * Contains ONLY: manifest.json + contents of patch-content/ at zip root.
 * No patch-content folder wrapper, no repo files.
 *
 * Usage:
 *   node scripts/build-patch.js <patchDir> [version] [--prefix=Data]
 */

const fs = require('fs');
const path = require('path');
const archiver = require('archiver');

const patchDir = process.argv[2];
const version = process.argv[3] && !process.argv[3].startsWith('--') ? process.argv[3] : null;
const prefixArg = process.argv.find((a) => a.startsWith('--prefix='));
const prefix = prefixArg ? prefixArg.slice('--prefix='.length) : 'Data';

if (!patchDir) {
  console.error('Usage: node scripts/build-patch.js <patchDir> [version] [--prefix=Data]');
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

const relativeFiles = listFiles(absPatchDir);
const manifestFiles = relativeFiles.map((r) => `${prefix}/${r}`);
const manifest = { files: manifestFiles };

const outDir = path.join(process.cwd(), 'dist-patch');
if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true });

const zipName = version ? `patch-${version}.zip` : 'patch.zip';
const zipPath = path.join(outDir, zipName);

const output = fs.createWriteStream(zipPath);
const archive = archiver('zip', { zlib: { level: 9 } });

output.on('close', () => {
  console.log('Created:', zipPath);
  console.log('Files in zip:', manifestFiles.length);
});

archive.on('error', (err) => {
  console.error('Archive error:', err);
  process.exit(1);
});

archive.pipe(output);

// 1. Add manifest.json at zip root
archive.append(JSON.stringify(manifest, null, 2), { name: 'manifest.json' });

// 2. Add ONLY patch-content contents at zip root (false = no parent folder)
archive.directory(absPatchDir, false);

archive.finalize();
