/**
 * Builds the patch manifest for the BStar launcher.
 * Writes dist-patch/manifest.json with path, size, hash for all files in Data/ (or <patchDir>).
 * URLs are added by the release workflow. No zip is built; launcher uses incremental download only.
 *
 * Usage:
 *   node scripts/build-patch.js Data [version] [--prefix=Data]
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

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

/** Compute SHA-256 hash of a file (hex string). */
function sha256File(filePath) {
  const buf = fs.readFileSync(filePath);
  return crypto.createHash('sha256').update(buf).digest('hex');
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

const relativeFiles = listFiles(absPatchDir);

// Full manifest: path, size, hash. Hash in parallel (concurrency 8) to speed up.
(async () => {
  const fullManifestEntries = await runWithLimit(
    relativeFiles.map((r) => async () => {
      const fullPath = path.join(absPatchDir, r);
      const stat = fs.statSync(fullPath);
      const hash = sha256File(fullPath);
      return { path: `${prefix}/${r}`, size: stat.size, hash };
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
