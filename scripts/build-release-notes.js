/**
 * Build release-notes.md for GitHub / Discord / manifest.
 *
 * Modes:
 *   - Dev push: Summary from latest commit description; Changes as a flat list
 *     (no category headings / sorting).
 *   - Prod (promote or direct): Summary from latest -dev (promote) or commit;
 *     Changes organized Added→Updated→Reworked→Fixed. Category headings only when
 *     bullets use those prefixes — otherwise stays a flat list.
 *
 * Usage:
 *   node scripts/build-release-notes.js \
 *     --channel=prod|dev \
 *     --version=X.Y.Z[-dev] \
 *     --latest-prod-version=X.Y.Z \
 *     [--previous-tag=vX.Y.Z] \
 *     [--promoted-from-dev=true] \
 *     [--dev-changelog=prev-changelog.json] \
 *     [--notes-file=patch-notes.md] \
 *     [--out=release-notes.md]
 */

const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');
const { stripDuplicateVersion } = require('./changelog-lib');

const argv = process.argv.slice(2);

function argValue(name, fallback = '') {
  const prefix = `--${name}=`;
  const hit = argv.find((a) => a.startsWith(prefix));
  return hit ? hit.slice(prefix.length).trim() : fallback;
}

function isTruthy(v) {
  return /^(1|true|yes)$/i.test(String(v || ''));
}

function isDevVersion(v) {
  return /^\d+\.\d+\.\d+-dev(\.\d+)?$/i.test(String(v).replace(/^v/i, ''));
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

/** Split patch-notes.md into { summary, changesBody, raw }. */
function parsePatchNotesFile(text) {
  const raw = stripDuplicateVersion(String(text || '').trim());
  if (!raw) return { summary: '', changesBody: '', bullets: [], raw: '' };

  let summary = '';
  const summaryMatch = raw.match(/\*\*Summary\*\*\s*\n+([\s\S]*?)(?=\n##\s|\n#\s|$)/i);
  if (summaryMatch) {
    summary = summaryMatch[1].trim();
  }

  let changesBody = '';
  const changesMatch = raw.match(/##\s*Changes\s*\n([\s\S]*)/i);
  if (changesMatch) {
    changesBody = changesMatch[1].trim();
  } else {
    // No ## Changes heading — treat non-summary body as changes
    changesBody = raw
      .replace(/\*\*Summary\*\*\s*\n+[\s\S]*?(?=\n##\s|\n#\s|$)/i, '')
      .trim();
  }

  const bullets = extractBullets(changesBody);
  return { summary, changesBody, bullets, raw };
}

function extractBullets(text) {
  const lines = String(text || '').split(/\r?\n/);
  const bullets = [];
  for (const line of lines) {
    const m = line.match(/^\s*[-*]\s+(.+)$/);
    if (m) bullets.push(m[1].trim());
  }
  return bullets;
}

function dedupeBullets(bullets) {
  const seen = new Set();
  const out = [];
  for (const b of bullets) {
    const key = b.replace(/\s+/g, ' ').trim().toLowerCase();
    if (!key || seen.has(key)) continue;
    seen.add(key);
    out.push(b.replace(/\s+/g, ' ').trim());
  }
  return out;
}

/** Preferred player-facing order. */
const CHANGE_CATEGORIES = ['Added', 'Updated', 'Reworked', 'Fixed'];

/**
 * Classify a bullet: "Fixed foo" / "fixed: foo" → { category, text, display }.
 * Unknown prefixes land in Other (kept, not dropped).
 */
function classifyBullet(raw) {
  const cleaned = String(raw || '').replace(/\s+/g, ' ').trim();
  const m = cleaned.match(/^(Added|Updated|Reworked|Fixed)\b[:\s-]*(.*)$/i);
  if (m) {
    const category = CHANGE_CATEGORIES.find((c) => c.toLowerCase() === m[1].toLowerCase());
    const rest = (m[2] || '').trim();
    // Normalize display: "Fixed foo" (canonical capitalisation)
    const display = rest ? `${category} ${rest}` : category;
    return { category, rest: rest.toLowerCase(), display };
  }
  return { category: 'Other', rest: cleaned.toLowerCase(), display: cleaned };
}

/**
 * Dedupe, group by Added → Updated → Reworked → Fixed → Other,
 * sort alphabetically within each group.
 */
function organizeBullets(bullets) {
  const deduped = dedupeBullets(bullets);
  const buckets = {
    Added: [],
    Updated: [],
    Reworked: [],
    Fixed: [],
    Other: []
  };
  for (const b of deduped) {
    const c = classifyBullet(b);
    buckets[c.category].push(c);
  }
  const ordered = [];
  for (const cat of [...CHANGE_CATEGORIES, 'Other']) {
    buckets[cat].sort((a, b) => a.rest.localeCompare(b.rest));
    for (const item of buckets[cat]) ordered.push(item.display);
  }
  return ordered;
}

/**
 * @param {string} summary
 * @param {string[]} bullets
 * @param {{ organize?: boolean }} [opts]
 *   organize=false → flat list (dev). organize=true → category sort; headings only if prefixes exist.
 */
function formatNotes(summary, bullets, opts = {}) {
  const organize = !!opts.organize;
  const list = organize ? organizeBullets(bullets) : dedupeBullets(bullets);
  const parts = ['# Patch notes', '', '**Summary**', ''];
  parts.push(summary || '', '');
  parts.push('## Changes');
  if (!list.length) {
    parts.push('- (no changes listed)', '');
    return parts.join('\n');
  }

  if (!organize) {
    for (const b of list) parts.push(`- ${b}`);
    parts.push('');
    return parts.join('\n');
  }

  // Prod: Added → Updated → Reworked → Fixed, then Other for unprefixed bullets.
  // If NOTHING has a known prefix, stay flat — no ### Other / empty category headings.
  const byCat = {
    Added: [],
    Updated: [],
    Reworked: [],
    Fixed: [],
    Other: []
  };
  for (const b of list) {
    byCat[classifyBullet(b).category].push(b);
  }
  const hasCats = CHANGE_CATEGORIES.some((c) => byCat[c].length > 0);
  if (!hasCats) {
    for (const b of list) parts.push(`- ${b}`);
    parts.push('');
    return parts.join('\n');
  }
  for (const cat of CHANGE_CATEGORIES) {
    if (!byCat[cat].length) continue;
    parts.push('', `### ${cat}`);
    for (const b of byCat[cat]) parts.push(`- ${b}`);
  }
  if (byCat.Other.length) {
    parts.push('', '### Other');
    for (const b of byCat.Other) parts.push(`- ${b}`);
  }
  parts.push('');
  return parts.join('\n');
}

/**
 * Collect -dev changelog entries newer than last prod (by X.Y.Z base).
 * Oldest-first for bullets; newest summary wins on promote.
 */
function collectDevBulletsSinceProd(changelog, latestProdVersion) {
  const prodXYZ = parseXYZ(latestProdVersion) || { major: 0, minor: 0, patch: 0 };
  const releases = (changelog?.releases || [])
    .filter((r) => isDevVersion(r.version))
    .filter((r) => compareXYZ(r.version, prodXYZ) > 0)
    .sort((a, b) => compareXYZ(a.version, b.version)); // oldest first

  const bullets = [];
  let latestSummary = '';
  let latestSummaryVersion = '';
  for (const r of releases) {
    const parsed = parsePatchNotesFile(r.notes || '');
    const fromEntry = parsed.bullets.length ? parsed.bullets : extractBullets(parsed.raw);
    bullets.push(...fromEntry);
    if (parsed.summary) {
      latestSummary = parsed.summary;
      latestSummaryVersion = String(r.version);
    }
  }
  return {
    releases,
    bullets: dedupeBullets(bullets),
    latestSummary,
    latestSummaryVersion
  };
}

/**
 * Summary from the newest commit in previousTag..HEAD.
 * Prefers commit body (description); falls back to subject minus conventional type.
 * Skips merges and pure chore: commits when a better candidate exists.
 */
function extractSummaryFromCommits(previousTag) {
  const range =
    previousTag && previousTag !== 'v0.0.0' && previousTag !== '0.0.0'
      ? `${previousTag}..HEAD`
      : 'HEAD';
  let raw = '';
  try {
    raw = execFileSync(
      'git',
      ['log', range, '--format=%s%x00%b%x00', '--no-merges', '-n', '30'],
      { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] }
    );
  } catch (_) {
    return '';
  }

  const chunks = raw.split('\0').map((s) => s.trim());
  // format yields: s, b, s, b, ... (trailing empty)
  const candidates = [];
  for (let i = 0; i + 1 < chunks.length; i += 2) {
    const subject = chunks[i] || '';
    const body = (chunks[i + 1] || '').trim();
    if (!subject) continue;
    candidates.push({ subject, body });
  }

  function fromCommit(c) {
    if (c.body) {
      // First paragraph of the description
      return c.body
        .split(/\n\s*\n/)[0]
        .replace(/\s+/g, ' ')
        .trim();
    }
    return c.subject.replace(/^[a-z]+(\([^)]*\))?!?:\s*/i, '').trim();
  }

  // Newest first: prefer non-chore with a body, then any non-chore, then anything
  const nonChore = candidates.filter((c) => !/^chore(\([^)]*\))?!?:/i.test(c.subject));
  for (const c of nonChore) {
    if (c.body) {
      const s = fromCommit(c);
      if (s) return s;
    }
  }
  for (const c of nonChore) {
    const s = fromCommit(c);
    if (s) return s;
  }
  for (const c of candidates) {
    const s = fromCommit(c);
    if (s) return s;
  }
  return '';
}

const CHANNEL = (argValue('channel') || 'prod').toLowerCase();
const VERSION = argValue('version').replace(/^v/i, '');
const LATEST_PROD = argValue('latest-prod-version').replace(/^v/i, '');
const PREVIOUS_TAG = argValue('previous-tag') || process.env.PREVIOUS_TAG || '';
const PROMOTED = isTruthy(argValue('promoted-from-dev') || process.env.PROMOTED_FROM_DEV);
const NOTES_FILE = path.resolve(process.cwd(), argValue('notes-file', 'patch-notes.md'));
const DEV_CHANGELOG = path.resolve(
  process.cwd(),
  argValue('dev-changelog', 'prev-changelog.json')
);
const OUT = path.resolve(process.cwd(), argValue('out', 'release-notes.md'));

if (!VERSION) {
  console.error('Error: --version is required');
  process.exit(1);
}

const fileText = fs.existsSync(NOTES_FILE) ? fs.readFileSync(NOTES_FILE, 'utf8') : '';
const parsedFile = parsePatchNotesFile(fileText);

// On promote, look at commits since last *prod* so we pick the final tip commit before/at merge
// (previous_tag is often the -dev asset tip, which is the wrong range for summary).
const summarySinceTag =
  CHANNEL === 'prod' && PROMOTED && LATEST_PROD
    ? `v${String(LATEST_PROD).replace(/^v/i, '')}`
    : PREVIOUS_TAG;
const commitSummary = extractSummaryFromCommits(summarySinceTag);

let outText;
let mode;

if (CHANNEL === 'prod' && PROMOTED) {
  mode = 'promote-rollup';
  let changelog = null;
  if (fs.existsSync(DEV_CHANGELOG)) {
    changelog = JSON.parse(fs.readFileSync(DEV_CHANGELOG, 'utf8'));
  }

  const sinceProd = LATEST_PROD || '0.0.0';
  const collected = changelog
    ? collectDevBulletsSinceProd(changelog, sinceProd)
    : { releases: [], bullets: [], latestSummary: '', latestSummaryVersion: '' };

  // Summary on merge: final commit description before merge (since last prod), then last -dev summary
  const summary = commitSummary || collected.latestSummary || parsedFile.summary;
  const summarySource = commitSummary
    ? 'final commit description before merge'
    : collected.latestSummary
      ? `latest -dev (${collected.latestSummaryVersion})`
      : parsedFile.summary
        ? 'patch-notes.md'
        : 'empty';

  const bullets = collected.bullets.length ? collected.bullets : parsedFile.bullets;

  outText = formatNotes(summary, bullets, { organize: true });
  console.log(
    `Promote rollup: ${collected.releases.length} -dev release(s) since prod ${sinceProd}; ` +
      `${organizeBullets(bullets).length} change bullet(s) organized; summary from ${summarySource}`
  );
  if (!summary) {
    console.warn(
      'Warning: no summary found from -dev releases or commits — add a commit description on the last -dev ship.'
    );
  }
  if (!collected.bullets.length) {
    console.warn(
      'Warning: no -dev changelog bullets to roll up; using ## Changes from patch-notes.md (if any).'
    );
  }
} else if (CHANNEL === 'prod') {
  mode = 'prod-organize';
  // Direct prod push (no -dev promote): organize Changes; Summary from commit
  if (!parsedFile.bullets.length) {
    console.error('ERROR: patch-notes.md needs ## Changes bullets for', VERSION);
    process.exit(1);
  }
  const summary = commitSummary || parsedFile.summary;
  const summarySource = commitSummary ? 'commit description' : parsedFile.summary ? 'patch-notes.md' : 'empty';
  outText = formatNotes(summary, parsedFile.bullets, { organize: true });
  console.log(
    `Prod organize: ${organizeBullets(parsedFile.bullets).length} change bullet(s); summary from ${summarySource}`
  );
  if (!summary) {
    console.warn(
      'Warning: no commit description found — use a body under your conventional commit, e.g.\n' +
        '  fix: hunting xp\n\n  Hunting XP and report command polish for tonight\'s test.'
    );
  }
} else {
  mode = 'dev-flat';
  // Dev: flat Changes list only; Summary from commit description
  if (!parsedFile.bullets.length) {
    console.error('ERROR: patch-notes.md needs ## Changes bullets for', VERSION);
    process.exit(1);
  }
  const summary = commitSummary || parsedFile.summary;
  const summarySource = commitSummary ? 'commit description' : parsedFile.summary ? 'patch-notes.md' : 'empty';
  outText = formatNotes(summary, parsedFile.bullets, { organize: false });
  console.log(
    `Dev flat list: ${dedupeBullets(parsedFile.bullets).length} change bullet(s); summary from ${summarySource}`
  );
  if (!summary) {
    console.warn(
      'Warning: no commit description found — use a body under your conventional commit, e.g.\n' +
        '  fix: hunting xp\n\n  Hunting XP and report command polish for tonight\'s test.'
    );
  }
}
fs.writeFileSync(OUT, outText.endsWith('\n') ? outText : outText + '\n', 'utf8');
console.log('Wrote', path.relative(process.cwd(), OUT), `(mode=${mode})`);
