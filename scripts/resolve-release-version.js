/**
 * Resolve release channel + version/tag for auto-release.
 *
 * Channels:
 *   prod (main) — tags vX.Y.Z, CDN patches/X.Y.Z/, GitHub latest
 *   dev  (dev)  — tags vX.Y.Z-dev, CDN patches/X.Y.Z-dev/, GitHub prerelease + floating "dev-latest" tag
 *                 (not "dev" — that collides with branch refs/heads/dev and breaks Desktop pushes)
 *
 * Prod alignment (merge-up / promote):
 *   version = max(
 *     conventionalBump(lastProd),
 *     stripDev(latestDevTag),
 *     bump(latestDevTag) when HEAD has fix/feat/breaking since that -dev tag
 *   ).
 *   Same SHA on main+dev therefore shares one X.Y.Z (prod vX.Y.Z, -dev vX.Y.Z-dev).
 *   Without bumping the -dev base, a concurrent -dev job can land one patch ahead
 *   (prod v0.78.12 vs v0.78.13-dev) and Discord never sees a matching prod tag.
 *   When the new prod version matches that -dev base, previous assets/manifest come from
 *   the latest -dev release (R2 copy patches/X.Y.Z-dev/ → patches/X.Y.Z/). Otherwise
 *   previous stays at last prod.
 *
 * Dev alignment (merge-down / catch-up):
 *   version = max(devBumpOrTip, latestProd as -dev). When catching up to prod, previous
 *   assets copy from the prod release (patches/X.Y.Z/ → patches/X.Y.Z-dev/).
 *
 * Usage:
 *   node scripts/resolve-release-version.js --channel=prod|dev \
 *     [--bump=none|patch|minor|major] \
 *     [--override=X.Y.Z|-dev] \
 *     [--prev-for-assets=X.Y.Z|-dev]
 *
 * Prints KEY=value lines (also appends to $GITHUB_OUTPUT when set).
 */

const { execSync } = require('child_process');
const fs = require('fs');

const argv = process.argv.slice(2);

function argValue(name) {
  const prefix = `--${name}=`;
  const hit = argv.find((a) => a.startsWith(prefix));
  return hit ? hit.slice(prefix.length).trim() : '';
}

const CHANNEL = (argValue('channel') || process.env.RELEASE_CHANNEL || 'prod').toLowerCase();
const BUMP = (argValue('bump') || process.env.BUMP || 'none').toLowerCase();
const OVERRIDE = (argValue('override') || '').replace(/^v/i, '');
const PREV_FOR_ASSETS = (argValue('prev-for-assets') || '').replace(/^v/i, '');

if (CHANNEL !== 'prod' && CHANNEL !== 'dev') {
  console.error('Error: --channel must be prod or dev, got:', CHANNEL);
  process.exit(1);
}

function listTags() {
  try {
    return execSync('git tag -l', { encoding: 'utf8' })
      .split(/\r?\n/)
      .map((t) => t.trim())
      .filter(Boolean);
  } catch (_) {
    return [];
  }
}

/** Tags from origin (helps when a concurrent -dev release just created a tag). */
function listRemoteTags() {
  try {
    return execSync('git ls-remote --tags --refs origin', { encoding: 'utf8' })
      .split(/\r?\n/)
      .map((line) => {
        const m = String(line).match(/refs\/tags\/(\S+)/);
        return m ? m[1].trim() : '';
      })
      .filter(Boolean);
  } catch (_) {
    return [];
  }
}

function tagsPointingAtHead() {
  try {
    return execSync('git tag --points-at HEAD', { encoding: 'utf8' })
      .split(/\r?\n/)
      .map((t) => t.trim())
      .filter(Boolean);
  } catch (_) {
    return [];
  }
}

/**
 * Commit subject often carries the intended tip version (e.g. "fix: v0.67.23").
 * Used as a promote floor when the -dev tag races with a main merge.
 */
function versionHintFromHeadSubject() {
  try {
    const subject = execSync('git log -1 --format=%s', { encoding: 'utf8' }).trim();
    const m = subject.match(/\bv?(\d+\.\d+\.\d+)(?:-dev(?:\.\d+)?)?\b/i);
    return m ? m[1] : '';
  } catch (_) {
    return '';
  }
}

function maxVersionTag(a, b) {
  if (!a) return b || null;
  if (!b) return a || null;
  return compareXYZ(a, b) >= 0 ? a : b;
}

/** True for vX.Y.Z-dev or X.Y.Z-dev.N (channel tags). Floating "dev" is not a version tag. */
function isDevVersion(v) {
  const s = String(v).replace(/^v/i, '');
  return /^\d+\.\d+\.\d+-dev(\.\d+)?$/i.test(s);
}

/** True for pure vX.Y.Z prod tags. */
function isProdVersion(v) {
  const s = String(v).replace(/^v/i, '');
  return /^\d+\.\d+\.\d+$/.test(s);
}

function parseXYZ(v) {
  const m = String(v).replace(/^v/i, '').match(/^(\d+)\.(\d+)\.(\d+)/);
  if (!m) return null;
  return { major: Number(m[1]), minor: Number(m[2]), patch: Number(m[3]) };
}

function compareXYZ(a, b) {
  const pa = typeof a === 'object' && a ? a : parseXYZ(a);
  const pb = typeof b === 'object' && b ? b : parseXYZ(b);
  if (!pa && !pb) return 0;
  if (!pa) return -1;
  if (!pb) return 1;
  if (pa.major !== pb.major) return pa.major - pb.major;
  if (pa.minor !== pb.minor) return pa.minor - pb.minor;
  return pa.patch - pb.patch;
}

function sameXYZ(a, b) {
  return compareXYZ(a, b) === 0 && parseXYZ(a) && parseXYZ(b);
}

function formatVersion(xyz, channel) {
  const base = `${xyz.major}.${xyz.minor}.${xyz.patch}`;
  return channel === 'dev' ? `${base}-dev` : base;
}

function toTag(version) {
  const v = String(version).replace(/^v/i, '');
  return `v${v}`;
}

function stripDevSuffix(v) {
  const xyz = parseXYZ(v);
  return xyz ? formatVersion(xyz, 'prod') : String(v).replace(/^v/i, '');
}

function normalizeOverride(raw, channel) {
  if (!raw) return '';
  let v = String(raw).replace(/^v/i, '').trim();
  if (channel === 'dev') {
    if (v === 'dev') return '';
    if (!isDevVersion(v)) {
      const xyz = parseXYZ(v);
      if (!xyz) {
        console.error('Error: invalid override version:', raw);
        process.exit(1);
      }
      v = formatVersion(xyz, 'dev');
    }
  } else if (isDevVersion(v)) {
    console.error('Error: prod override must be X.Y.Z (no -dev):', raw);
    process.exit(1);
  } else if (!isProdVersion(v)) {
    const xyz = parseXYZ(v);
    if (!xyz) {
      console.error('Error: invalid override version:', raw);
      process.exit(1);
    }
    v = formatVersion(xyz, 'prod');
  }
  return v;
}

function bumpXYZ(xyz, bump) {
  switch (bump) {
    case 'major':
      return { major: xyz.major + 1, minor: 0, patch: 0 };
    case 'minor':
      return { major: xyz.major, minor: xyz.minor + 1, patch: 0 };
    case 'patch':
      return { major: xyz.major, minor: xyz.minor, patch: xyz.patch + 1 };
    case 'none':
      return { ...xyz };
    default:
      return { major: xyz.major, minor: xyz.minor, patch: xyz.patch + 1 };
  }
}

/** Same rules as auto-release.yml "Determine version bump from commits". */
function conventionalBumpFromRange(fromRef) {
  const ref = String(fromRef || '').trim();
  if (!ref) return 'none';
  let log = '';
  try {
    log = execSync(`git log --format=%s%n%b ${ref}..HEAD`, {
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'ignore']
    });
  } catch (_) {
    return 'none';
  }
  let bump = 'none';
  if (/^fix(\([^)]*\))?:/m.test(log)) bump = 'patch';
  if (/^feat(\([^)]*\))?:/m.test(log)) bump = 'minor';
  if (/BREAKING CHANGE/i.test(log)) bump = 'major';
  else if (/^[a-z]+!.*:/m.test(log)) bump = 'major';
  return bump;
}

/** Raise chosenXYZ to the -dev tip, then one more bump if HEAD is ahead of that tag. */
function alignToDevChannel(chosenXYZ, latestDevTag) {
  if (!latestDevTag) {
    return { xyz: chosenXYZ, promoted: false };
  }
  const devBase = parseXYZ(latestDevTag);
  if (!devBase) {
    return { xyz: chosenXYZ, promoted: false };
  }
  let xyz = chosenXYZ;
  let promoted = false;
  if (compareXYZ(devBase, xyz) >= 0) {
    xyz = { ...devBase };
    promoted = true;
  }
  const devRangeBump = conventionalBumpFromRange(latestDevTag);
  if (devRangeBump !== 'none') {
    const bumpedDev = bumpXYZ(devBase, devRangeBump);
    if (compareXYZ(bumpedDev, xyz) > 0) {
      xyz = bumpedDev;
      promoted = true;
      console.log(
        `Prod promote: HEAD is ahead of ${latestDevTag}; raising to ${formatVersion(bumpedDev, 'prod')} so prod matches concurrent -dev`
      );
    }
  }
  return { xyz, promoted };
}

function latestMatching(tags, predicate) {
  const matched = tags.filter(predicate);
  matched.sort((a, b) => compareXYZ(b.replace(/^v/i, ''), a.replace(/^v/i, '')));
  return matched[0] || null;
}

/**
 * Prefer latest -dev as asset previous when its X.Y.Z base matches the new prod version.
 * Falls back to last prod. Never overrides an explicit --prev-for-assets.
 */
function chooseProdPrevious(newProdVersion, latestDevTag, latestProdTag, explicitPrev) {
  if (explicitPrev) {
    const previousVersion = String(explicitPrev).replace(/^v/i, '');
    return {
      previousTag: toTag(previousVersion),
      previousVersion,
      assetSource: 'explicit'
    };
  }
  if (latestDevTag && sameXYZ(newProdVersion, latestDevTag)) {
    const previousVersion = String(latestDevTag).replace(/^v/i, '');
    return {
      previousTag: latestDevTag.startsWith('v') ? latestDevTag : toTag(previousVersion),
      previousVersion,
      assetSource: 'dev'
    };
  }
  const previousTag = latestProdTag || 'v0.0.0';
  const previousVersion = String(previousTag).replace(/^v/i, '');
  return { previousTag, previousVersion, assetSource: 'prod' };
}

const tags = [...new Set([...listTags(), ...listRemoteTags()])];
const latestProdTag = latestMatching(tags, (t) => isProdVersion(t));
// Prefer the newest -dev overall, and never ignore a -dev tag already on HEAD
// (merge-to-main often races the concurrent -dev release tag publish).
let latestDevTag = latestMatching(tags, (t) => isDevVersion(t));
const headDevTag = latestMatching(tagsPointingAtHead(), (t) => isDevVersion(t));
latestDevTag = maxVersionTag(latestDevTag, headDevTag);

const channelLatestTag =
  CHANNEL === 'dev' ? latestDevTag || latestProdTag || 'v0.0.0' : latestProdTag || 'v0.0.0';

const channelLatestVersion = String(channelLatestTag).replace(/^v/i, '');

let previousTag = channelLatestTag;
let previousVersion = channelLatestVersion;
let assetSource = CHANNEL === 'dev' ? 'channel' : 'prod';
let promotedFromDev = 'false';
let syncedFromProd = 'false';

let version;
let tag;

const override = normalizeOverride(OVERRIDE, CHANNEL);
if (override) {
  version = override;
  tag = toTag(version);

  if (CHANNEL === 'prod') {
    const chosen = chooseProdPrevious(version, latestDevTag, latestProdTag, PREV_FOR_ASSETS);
    previousTag = chosen.previousTag;
    previousVersion = chosen.previousVersion;
    assetSource = chosen.assetSource;
    if (assetSource === 'dev') promotedFromDev = 'true';
  } else if (PREV_FOR_ASSETS) {
    previousVersion = String(PREV_FOR_ASSETS).replace(/^v/i, '');
    previousTag = toTag(previousVersion);
    assetSource = 'explicit';
  } else if (CHANNEL === 'dev' && latestProdTag && sameXYZ(version, latestProdTag)) {
    previousTag = latestProdTag.startsWith('v') ? latestProdTag : toTag(String(latestProdTag).replace(/^v/i, ''));
    previousVersion = String(latestProdTag).replace(/^v/i, '');
    assetSource = 'prod';
    syncedFromProd = 'true';
  }
} else if (CHANNEL === 'prod') {
  // Conventional bump from last prod, then promote to at least stripDev(latest -dev),
  // including a further bump when HEAD is ahead of that -dev tag (same-SHA race).
  // bump=none still promotes when -dev is already ahead of last prod.
  const prodBase = parseXYZ(latestProdTag || 'v0.0.0') || { major: 0, minor: 0, patch: 0 };
  let chosenXYZ = BUMP === 'none' ? { ...prodBase } : bumpXYZ(prodBase, BUMP);
  const aligned = alignToDevChannel(chosenXYZ, latestDevTag);
  chosenXYZ = aligned.xyz;
  if (aligned.promoted) promotedFromDev = 'true';
  const hintXYZ = parseXYZ(versionHintFromHeadSubject());
  if (hintXYZ && compareXYZ(hintXYZ, chosenXYZ) > 0) {
    chosenXYZ = hintXYZ;
    promotedFromDev = 'true';
    console.log(
      `Prod promote: HEAD subject version hint ${formatVersion(hintXYZ, 'prod')} raises tip above tag scan`
    );
  }
  const raisedAboveProd = compareXYZ(chosenXYZ, prodBase) > 0;
  version = formatVersion(chosenXYZ, 'prod');
  tag = toTag(version);

  if (!raisedAboveProd && BUMP === 'none') {
    // True rebuild of the current prod tip — keep previous at last prod so Discord does not re-post.
    if (PREV_FOR_ASSETS) {
      previousVersion = String(PREV_FOR_ASSETS).replace(/^v/i, '');
      previousTag = toTag(previousVersion);
      assetSource = 'explicit';
    }
  } else {
    const promoteDevTag =
      latestDevTag && sameXYZ(version, latestDevTag)
        ? latestDevTag
        : headDevTag && sameXYZ(version, headDevTag)
          ? headDevTag
          : latestDevTag;
    const chosen = chooseProdPrevious(version, promoteDevTag, latestProdTag, PREV_FOR_ASSETS);
    previousTag = chosen.previousTag;
    previousVersion = chosen.previousVersion;
    assetSource = chosen.assetSource;
    if (assetSource === 'dev') promotedFromDev = 'true';
  }
} else {
  // Dev channel: bump/rebuild tip, then sync up to at least latest prod (merge-down).
  const baseXYZ =
    parseXYZ(latestDevTag ? latestDevTag : channelLatestVersion) ||
    parseXYZ(latestProdTag || 'v0.0.0') ||
    { major: 0, minor: 0, patch: 0 };
  let chosenXYZ = BUMP === 'none' ? { ...baseXYZ } : bumpXYZ(baseXYZ, BUMP);

  if (latestProdTag) {
    const prodXYZ = parseXYZ(latestProdTag);
    if (prodXYZ && compareXYZ(prodXYZ, chosenXYZ) >= 0) {
      chosenXYZ = { ...prodXYZ };
      syncedFromProd = 'true';
    }
  }

  const hintXYZ = parseXYZ(versionHintFromHeadSubject());
  if (hintXYZ && compareXYZ(hintXYZ, chosenXYZ) > 0) {
    chosenXYZ = { ...hintXYZ };
    console.log(
      `Dev sync: HEAD subject version hint ${formatVersion(hintXYZ, 'dev')} raises tip above tag scan`
    );
  }

  version = formatVersion(chosenXYZ, 'dev');
  tag = toTag(version);

  if (PREV_FOR_ASSETS) {
    previousVersion = String(PREV_FOR_ASSETS).replace(/^v/i, '');
    previousTag = toTag(previousVersion);
    assetSource = 'explicit';
  } else if (syncedFromProd === 'true' && latestProdTag && sameXYZ(version, latestProdTag)) {
    previousTag = latestProdTag.startsWith('v') ? latestProdTag : toTag(String(latestProdTag).replace(/^v/i, ''));
    previousVersion = String(latestProdTag).replace(/^v/i, '');
    assetSource = 'prod';
    console.log(`Dev sync: aligning ${version} to prod ${previousVersion}; assets from prod`);
  } else if (!latestDevTag && latestProdTag) {
    // First-ever -dev release: seed from latest prod
    previousTag = latestProdTag;
    previousVersion = String(latestProdTag).replace(/^v/i, '');
    assetSource = 'prod';
    syncedFromProd = 'true';
  } else {
    previousTag = channelLatestTag;
    previousVersion = channelLatestVersion;
    assetSource = 'channel';
  }
}

const floatingTag = CHANNEL === 'dev' ? 'dev-latest' : '';
const isPrerelease = CHANNEL === 'dev' ? 'true' : 'false';
const makeLatest = CHANNEL === 'prod' ? 'true' : 'false';

const lines = {
  channel: CHANNEL,
  version,
  tag,
  previous_tag: previousTag,
  previous_version: previousVersion,
  floating_tag: floatingTag,
  is_prerelease: isPrerelease,
  make_latest: makeLatest,
  latest_prod_tag: latestProdTag || '',
  latest_dev_tag: latestDevTag || '',
  promoted_from_dev: promotedFromDev,
  synced_from_prod: syncedFromProd,
  asset_source: assetSource
};

function emit(key, value) {
  const line = `${key}=${value}`;
  console.log(line);
  if (process.env.GITHUB_OUTPUT) {
    fs.appendFileSync(process.env.GITHUB_OUTPUT, `${line}\n`, 'utf8');
  }
}

for (const [k, v] of Object.entries(lines)) {
  emit(k, v);
}
