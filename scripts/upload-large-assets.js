/**
 * Uploads large patch assets to Cloudflare R2.
 * - If previous manifest + previous version are provided: copies unchanged files (same path+hash)
 *   from patches/<prevVersion>/ to patches/<version>/; uploads only new/changed from Data/.
 *   Then deletes the previous version prefix to save space.
 * - Off-GitHub assets (in manifest but not in Data/): copied from previous if same hash, else skipped
 *   (must be uploaded once via manual script or prior run).
 *
 * Usage:
 *   node scripts/upload-large-assets.js Data [--prefix=Data] [--previous-manifest=path] [--previous-version=0.18.30]
 *
 * Env: VERSION, PATCH_ASSETS_BUCKET, PATCH_ASSETS_ACCOUNT_ID, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
 */

const fs = require('fs');
const path = require('path');
const {
  S3Client,
  PutObjectCommand,
  CopyObjectCommand,
  ListObjectsV2Command,
  DeleteObjectsCommand
} = require('@aws-sdk/client-s3');

const patchDir = process.argv[2];
const prefixArg = process.argv.find((a) => a.startsWith('--prefix='));
const prevManifestArg = process.argv.find((a) => a.startsWith('--previous-manifest='));
const prevVersionArg = process.argv.find((a) => a.startsWith('--previous-version='));

const prefix = prefixArg ? prefixArg.slice('--prefix='.length) : 'Data';
const PREVIOUS_MANIFEST_PATH = prevManifestArg ? prevManifestArg.slice('--previous-manifest='.length) : null;
const PREVIOUS_VERSION = prevVersionArg ? prevVersionArg.slice('--previous-version='.length) : null;

const VERSION = process.env.VERSION;
const BUCKET = process.env.PATCH_ASSETS_BUCKET;
const ACCOUNT_ID = process.env.PATCH_ASSETS_ACCOUNT_ID;

if (!VERSION || !BUCKET || !ACCOUNT_ID) {
  console.error('Error: set env VERSION, PATCH_ASSETS_BUCKET, PATCH_ASSETS_ACCOUNT_ID');
  process.exit(1);
}

if (!patchDir) {
  console.error('Usage: node scripts/upload-large-assets.js <patchDir> [--prefix=Data] [--previous-manifest=path] [--previous-version=X.Y.Z]');
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

/** Build map path -> hash from manifest. */
function manifestPathHashMap(manifest) {
  const map = new Map();
  for (const entry of manifest.files || []) {
    const p = typeof entry === 'string' ? entry : entry.path;
    const h = typeof entry === 'object' && entry.hash != null ? entry.hash : null;
    if (p && h) map.set(p, h);
  }
  return map;
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
const prevManifest = PREVIOUS_MANIFEST_PATH && fs.existsSync(PREVIOUS_MANIFEST_PATH)
  ? JSON.parse(fs.readFileSync(PREVIOUS_MANIFEST_PATH, 'utf8'))
  : null;
const prevMap = prevManifest ? manifestPathHashMap(prevManifest) : null;

const largeFiles = (manifest.files || []).filter((entry) => {
  const pathEntry = typeof entry === 'string' ? entry : entry.path;
  if (!pathEntry.startsWith(prefix + '/')) return false;
  const size = typeof entry === 'object' && entry.size != null ? entry.size : 0;
  if (size === 0) return false;
  const relative = pathEntry.slice(prefix.length + 1);
  return isLarge(relative, size);
});

async function run() {
  let copied = 0;
  let uploaded = 0;
  const newVersion = PREVIOUS_VERSION && PREVIOUS_VERSION !== VERSION;

  for (const entry of largeFiles) {
    const pathEntry = typeof entry === 'string' ? entry : entry.path;
    const hash = typeof entry === 'object' && entry.hash != null ? entry.hash : null;
    const relative = pathEntry.slice(prefix.length + 1).replace(/\//g, path.sep);
    const src = path.join(absPatchDir, relative);
    const assetName = toAssetName(pathEntry);
    const destKey = `patches/${VERSION}/${assetName}`;

    const canCopyFromPrevious = newVersion && prevMap && prevMap.get(pathEntry) === hash;

    if (canCopyFromPrevious) {
      const copySource = `${BUCKET}/patches/${PREVIOUS_VERSION}/${assetName}`;
      await s3.send(
        new CopyObjectCommand({
          Bucket: BUCKET,
          Key: destKey,
          CopySource: copySource
        })
      );
      copied++;
      console.log('Copied', destKey, '(unchanged from previous)');
    } else if (fs.existsSync(src)) {
      const body = fs.readFileSync(src);
      await s3.send(
        new PutObjectCommand({
          Bucket: BUCKET,
          Key: destKey,
          Body: body
        })
      );
      uploaded++;
      console.log('Uploaded', destKey);
    } else {
      console.warn('Skipped (off-GitHub, not in repo and not in previous manifest with same hash):', pathEntry);
    }
  }

  console.log('R2: copied', copied, ', uploaded', uploaded, 'large assets');

  if (newVersion && PREVIOUS_VERSION) {
    let continuationToken = undefined;
    let deletedCount = 0;
    do {
      const list = await s3.send(
        new ListObjectsV2Command({
          Bucket: BUCKET,
          Prefix: `patches/${PREVIOUS_VERSION}/`,
          ContinuationToken: continuationToken
        })
      );
      const keys = (list.Contents || []).map((o) => ({ Key: o.Key }));
      if (keys.length > 0) {
        await s3.send(
          new DeleteObjectsCommand({
            Bucket: BUCKET,
            Delete: { Objects: keys }
          })
        );
        deletedCount += keys.length;
      }
      continuationToken = list.IsTruncated ? list.NextContinuationToken : undefined;
    } while (continuationToken);
    console.log('Deleted previous patch folder patches/' + PREVIOUS_VERSION + '/ (' + deletedCount + ' objects)');
  }
}

run().catch((err) => {
  console.error(err);
  process.exit(1);
});
