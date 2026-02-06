/**
 * Builds a patch zip and manifest.json for the BStar launcher.
 *
 * Usage:
 *   node scripts/build-patch.js <patchDir> [version] [--prefix=Data/BStarPatch]
 *
 * - patchDir: folder whose contents will be installed under Data/BStarPatch (e.g. ./patch-content)
 * - version: optional tag for the zip name (e.g. 1.0.0) → output patch-1.0.0.zip
 * - --prefix: game-relative path for manifest "files" (default Data/BStarPatch)
 *
 * The zip will contain:
 *   manifest.json at root (with "files" array: prefix + each relative path)
 *   + all files from patchDir (paths relative to patchDir)
 *
 * Example:
 *   node scripts/build-patch.js ./patch-content 1.0.0
 *   → creates dist-patch/patch-1.0.0.zip ready to upload to a GitHub release
 */

const fs = require('fs');
const path = require('path');
const archiver = require('archiver');

const patchDir = process.argv[2];
const version = process.argv[3] && !process.argv[3].startsWith('--') ? process.argv[3] : null;
const prefixArg = process.argv.find((a) => a.startsWith('--prefix='));
const prefix = prefixArg ? prefixArg.slice('--prefix='.length) : 'Data/BStarPatch';

if (!patchDir) {
  console.error('Usage: node scripts/build-patch.js <patchDir> [version] [--prefix=Data/BStarPatch]');
  process.exit(1);
}

const absPatchDir = path.resolve(process.cwd(), patchDir);
if (!fs.existsSync(absPatchDir) || !fs.statSync(absPatchDir).isDirectory()) {
  console.error('Error: patchDir must be an existing directory:', patchDir);
  process.exit(1);
}

/** Recursively list all files under dir; returns paths relative to dir (forward slashes). */
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
const outDir = path.join(process.cwd(), 'dist-patch');
if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true });

const zipName = version ? `patch-${version}.zip` : 'patch.zip';
const zipPath = path.join(outDir, zipName);

const output = fs.createWriteStream(zipPath);
const archive = archiver('zip', { zlib: { level: 9 } });

output.on('close', () => {
  console.log('Created:', zipPath);
  console.log('Manifest files:', manifestFiles.length);
  console.log('Upload this file as a GitHub release asset.');
});

archive.on('error', (err) => {
  console.error('Archive error:', err);
  process.exit(1);
});

archive.pipe(output);

// Add manifest.json at root
archive.append(JSON.stringify(manifest, null, 2), { name: 'manifest.json' });

// Add each file from patchDir with path relative to patchDir (so zip root has those paths)
for (const rel of relativeFiles) {
  const full = path.join(absPatchDir, rel);
  archive.file(full, { name: rel });
}

archive.finalize();
