/**
 * Uploads large patch assets (e.g. .bsa, .esp) to Cloudflare R2.
 * Reads manifest + patch-upload-config.json; uploads each "large" file from Data/
 * to s3://bucket/patches/VERSION/Data_Mods_foo.bsa.
 * Requires env: VERSION, PATCH_ASSETS_BUCKET, PATCH_ASSETS_ACCOUNT_ID,
 *   AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY.
 *
 * Usage: node scripts/upload-large-assets.js Data [--prefix=Data]
 */

const fs = require('fs');
const path = require('path');
const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');

const patchDir = process.argv[2];
const prefixArg = process.argv.find((a) => a.startsWith('--prefix='));
const prefix = prefixArg ? prefixArg.slice('--prefix='.length) : 'Data';

const VERSION = process.env.VERSION;
const BUCKET = process.env.PATCH_ASSETS_BUCKET;
const ACCOUNT_ID = process.env.PATCH_ASSETS_ACCOUNT_ID;

if (!VERSION || !BUCKET || !ACCOUNT_ID) {
  console.error('Error: set env VERSION, PATCH_ASSETS_BUCKET, PATCH_ASSETS_ACCOUNT_ID');
  process.exit(1);
}

if (!patchDir) {
  console.error('Usage: node scripts/upload-large-assets.js <patchDir> [--prefix=Data]');
  process.exit(1);
}

const absPatchDir = path.resolve(process.cwd(), patchDir);
const manifestPath = path.join(process.cwd(), 'dist-patch', 'manifest.json');

if (!fs.existsSync(manifestPath)) {
  console.error('Error: dist-patch/manifest.json not found. Run build-patch.js first.');
  process.exit(1);
}

function loadLargeConfig() {
  const configPath = path.join(process.cwd(), 'scripts', 'patch-upload-config.json');
  if (!fs.existsSync(configPath)) return { largeExtensions: [], largeFileSizeThresholdBytes: null };
  const cfg = JSON.parse(fs.readFileSync(configPath, 'utf8'));
  return {
    largeExtensions: Array.isArray(cfg.largeExtensions) ? cfg.largeExtensions : [],
    largeFileSizeThresholdBytes: cfg.largeFileSizeThresholdBytes ?? null
  };
}

function isLarge(relativePath, size) {
  const { largeExtensions, largeFileSizeThresholdBytes } = loadLargeConfig();
  const ext = path.extname(relativePath).toLowerCase();
  if (largeExtensions.includes(ext)) return true;
  if (largeFileSizeThresholdBytes != null && size >= largeFileSizeThresholdBytes) return true;
  return false;
}

function toAssetName(pathEntry) {
  return pathEntry
    .replace(/\//g, '_')
    .replace(/[^a-zA-Z0-9_.-]/g, '_')
    .replace(/_+/g, '_')
    .replace(/^_|_$/g, '');
}

const endpoint = `https://${ACCOUNT_ID}.r2.cloudflarestorage.com`;
const s3 = new S3Client({
  region: 'auto',
  endpoint,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
  }
});

const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
const files = manifest.files || [];

const toUpload = files.filter((entry) => {
  const pathEntry = typeof entry === 'string' ? entry : entry.path;
  if (!pathEntry.startsWith(prefix + '/')) return false;
  const size = typeof entry === 'object' && entry.size != null ? entry.size : 0;
  if (size === 0) return false;
  const relative = pathEntry.slice(prefix.length + 1);
  return isLarge(relative, size);
});

async function run() {
  let uploaded = 0;
  for (const entry of toUpload) {
    const pathEntry = typeof entry === 'string' ? entry : entry.path;
    const relative = pathEntry.slice(prefix.length + 1).replace(/\//g, path.sep);
    const src = path.join(absPatchDir, relative);
    if (!fs.existsSync(src)) {
      console.error('Error: missing file', src);
      process.exit(1);
    }
    const key = `patches/${VERSION}/${toAssetName(pathEntry)}`;
    const body = fs.readFileSync(src);
    await s3.send(
      new PutObjectCommand({
        Bucket: BUCKET,
        Key: key,
        Body: body
      })
    );
    uploaded++;
    console.log('Uploaded', key);
  }
  console.log('Uploaded', uploaded, 'large assets to R2');
}

run().catch((err) => {
  console.error(err);
  process.exit(1);
});
