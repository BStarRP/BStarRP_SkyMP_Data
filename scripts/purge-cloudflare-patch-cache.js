/**
 * Optional: purge Cloudflare edge cache for one patch version prefix after R2 uploads.
 * R2 origin is updated immediately; a CDN in front may still serve old bytes until purged or revalidated.
 *
 * Requires API token with Cache Purge permission for the zone.
 * Prefix purge may require a paid Cloudflare plan — if the API errors, use a Cache Rule:
 *   "Bypass cache" for URI Path contains `/patches/` (or your public hostname + path).
 *
 * Usage:
 *   VERSION=0.31.0 node scripts/purge-cloudflare-patch-cache.js
 *
 * Env: CLOUDFLARE_ZONE_ID, CLOUDFLARE_API_TOKEN, PATCH_ASSETS_PUBLIC_URL, VERSION
 * If any required var is missing, exits 0 (no-op) so CI does not fail when purge is not configured.
 */

const zone = process.env.CLOUDFLARE_ZONE_ID;
const token = process.env.CLOUDFLARE_API_TOKEN;
const base = (process.env.PATCH_ASSETS_PUBLIC_URL || '').replace(/\/$/, '');
const ver = process.env.VERSION;

if (!zone || !token || !base || !ver) {
  console.log(
    'purge-cloudflare-patch-cache: skipping (set CLOUDFLARE_ZONE_ID, CLOUDFLARE_API_TOKEN, PATCH_ASSETS_PUBLIC_URL, VERSION to enable)'
  );
  process.exit(0);
}

const prefix = `${base}/patches/${ver}/`;

(async () => {
  const res = await fetch(`https://api.cloudflare.com/client/v4/zones/${zone}/purge_cache`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ prefixes: [prefix] })
  });
  const j = await res.json().catch(() => ({}));
  if (!j.success) {
    console.error('Cloudflare purge failed:', res.status, JSON.stringify(j.errors || j));
    console.error(
      'If prefix purge is not available on your plan, add a Cache Rule to bypass cache for /patches/* instead.'
    );
    process.exit(1);
  }
  console.log('Cloudflare cache purged for prefix:', prefix);
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
