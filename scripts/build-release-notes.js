/**
 * Build release-notes.md for GitHub / Discord / manifest.
 *
 * Summary rules:
 *   - Dev / direct prod: commit description (full body, all paragraphs) writes
 *     the Summary. Subject is never used. No body ⇒ no Summary (do not repeat
 *     the previous release's Summary).
 *   - If the resolved Summary text matches the previous update's Summary, omit
 *     it and ship without a Summary section.
 *   - Prod promote (dev→main merge): last -dev Summary goes to production when
 *     it differs from the last prod Summary (Changes still roll up / organize
 *     from all -dev entries since last prod).
 *
 * Changes:
 *   - Dev: flat list (no category headings / sorting).
 *   - Prod: organized alphabetically
 *     (Added→Fixed→Improved→Removed→Reworked→Updated→Other) when prefixes exist;
 *     otherwise flat.
 *
 * Usage:
 *   node scripts/build-release-notes.js \
 *     --channel=prod|dev \
 *     --version=X.Y.Z[-dev] \
 *     --latest-prod-version=X.Y.Z \
 *     [--previous-tag=vX.Y.Z] \
 *     [--previous-version=X.Y.Z] \
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
const CHANGE_CATEGORIES = ['Added', 'Fixed', 'Improved', 'Removed', 'Reworked', 'Updated'];

/**
 * Classify a bullet: "Fixed foo" / "fixed: foo" → { category, text, display }.
 * Unknown prefixes land in Other (kept, not dropped).
 */
function classifyBullet(raw) {
  const cleaned = String(raw || '').replace(/\s+/g, ' ').trim();
  const m = cleaned.match(/^(Added|Improved|Updated|Reworked|Fixed|Removed)\b[:\s-]*(.*)$/i);
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
 * Dedupe, group alphabetically (Added → Fixed → Improved → Removed → Reworked → Updated → Other),
 * sort alphabetically within each group.
 */
function organizeBullets(bullets) {
  const deduped = dedupeBullets(bullets);
  const buckets = {
    Added: [],
    Fixed: [],
    Improved: [],
    Removed: [],
    Reworked: [],
    Updated: [],
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
  const parts = ['# Patch notes', ''];
  const summaryText = String(summary || '').trim();
  if (summaryText) {
    parts.push('**Summary**', '', summaryText, '');
  }
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

  // Prod: alphabetical categories, then Other for unprefixed.
  // If NOTHING has a known prefix, stay flat — no ### Other / empty category headings.
  const byCat = {
    Added: [],
    Fixed: [],
    Improved: [],
    Removed: [],
    Reworked: [],
    Updated: [],
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

/** Normalize summary text for compare / output; keep paragraph breaks. */
function normalizeSummary(text) {
  return String(text || '')
    .replace(/\r\n/g, '\n')
    .replace(/[ \t]+\n/g, '\n')
    .replace(/\n{3,}/g, '\n\n')
    .trim();
}

/**
 * Summary from the newest commit *description* (body) in previousTag..HEAD.
 * Never uses the subject line — if no body exists, returns ''.
 * Keeps full body including paragraph line breaks (does not truncate at first blank line).
 * Skips merges; prefers non-chore commits.
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
    if (!subject || !body) continue;
    candidates.push({ subject, body });
  }

  function bodySummary(c) {
    // Full commit description — preserve paragraph breaks
    return normalizeSummary(c.body);
  }

  // Newest first: prefer non-chore with a body, then any commit with a body
  const nonChore = candidates.filter((c) => !/^chore(\([^)]*\))?!?:/i.test(c.subject));
  for (const c of nonChore) {
    const s = bodySummary(c);
    if (s) return s;
  }
  for (const c of candidates) {
    const s = bodySummary(c);
    if (s) return s;
  }
  return '';
}

/** Pull **Summary** text from a specific changelog.json release entry. */
function getSummaryFromChangelogVersion(changelog, version) {
  if (!changelog || !version) return { summary: '', version: '' };
  const want = String(version).replace(/^v/i, '');
  if (!want || want === '0.0.0') return { summary: '', version: '' };
  const entry = (changelog.releases || []).find(
    (r) => String(r.version).replace(/^v/i, '') === want
  );
  if (!entry?.notes) return { summary: '', version: want };
  const summary = parsePatchNotesFile(entry.notes).summary;
  return { summary, version: String(entry.version).replace(/^v/i, '') };
}

/**
 * Resolve Summary:
 *   1) commit description (when provided / preferred)
 *   2) on promote: last -dev Summary from changelog
 *   3) patch-notes.md **Summary** (legacy fallback)
 * Does not reuse the previous update's Summary for ordinary releases.
 */
function resolveSummary(opts) {
  const {
    commitSummary = '',
    carriedSummary = '',
    carriedVersion = '',
    fileSummary = '',
    preferCarried = false
  } = opts;

  if (preferCarried) {
    if (carriedSummary) {
      return {
        summary: normalizeSummary(carriedSummary),
        source: `carried from ${carriedVersion || 'previous release'}`
      };
    }
    if (commitSummary) {
      return { summary: normalizeSummary(commitSummary), source: 'commit description' };
    }
  } else if (commitSummary) {
    return { summary: normalizeSummary(commitSummary), source: 'commit description' };
  }
  if (fileSummary) {
    return { summary: normalizeSummary(fileSummary), source: 'patch-notes.md' };
  }
  return { summary: '', source: 'empty' };
}

/**
 * Drop Summary when it matches the previous update (avoid repeating the same blurb).
 * @returns {{ summary: string, source: string }}
 */
function dropDuplicateSummary(resolved, previousSummary) {
  const summary = normalizeSummary(resolved.summary);
  const prev = normalizeSummary(previousSummary);
  if (summary && prev && summary === prev) {
    return {
      summary: '',
      source: `omitted (same as previous update; was ${resolved.source})`
    };
  }
  return { summary, source: resolved.source };
}

const CHANNEL = (argValue('channel') || 'prod').toLowerCase();
const VERSION = argValue('version').replace(/^v/i, '');
const LATEST_PROD = argValue('latest-prod-version').replace(/^v/i, '');
const PREVIOUS_TAG = argValue('previous-tag') || process.env.PREVIOUS_TAG || '';
const PREVIOUS_VERSION = (
  argValue('previous-version') ||
  process.env.PREVIOUS_VERSION ||
  PREVIOUS_TAG ||
  ''
).replace(/^v/i, '');
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

let changelog = null;
if (fs.existsSync(DEV_CHANGELOG)) {
  changelog = JSON.parse(fs.readFileSync(DEV_CHANGELOG, 'utf8'));
}

// Commit description range: on promote, scan since last *prod* (previous_tag is often the -dev tip).
const summarySinceTag =
  CHANNEL === 'prod' && PROMOTED && LATEST_PROD
    ? `v${String(LATEST_PROD).replace(/^v/i, '')}`
    : PREVIOUS_TAG;
const commitSummary = extractSummaryFromCommits(summarySinceTag);
const previousCarried = getSummaryFromChangelogVersion(changelog, PREVIOUS_VERSION);
// On promote, dedupe against last *prod* Summary (prod players may not have seen -dev).
const lastProdSummary =
  CHANNEL === 'prod' && PROMOTED && LATEST_PROD
    ? getSummaryFromChangelogVersion(changelog, LATEST_PROD).summary
    : '';
const previousSummaryForDedupe = lastProdSummary || previousCarried.summary;

let outText;
let mode;

if (CHANNEL === 'prod' && PROMOTED) {
  mode = 'promote-rollup';
  const sinceProd = LATEST_PROD || '0.0.0';
  const collected = changelog
    ? collectDevBulletsSinceProd(changelog, sinceProd)
    : { releases: [], bullets: [], latestSummary: '', latestSummaryVersion: '' };

  // On merge: last -dev Summary wins when it is new vs last prod.
  const { summary, source: summarySource } = dropDuplicateSummary(
    resolveSummary({
      commitSummary,
      carriedSummary: collected.latestSummary,
      carriedVersion: collected.latestSummaryVersion
        ? `${collected.latestSummaryVersion} (last -dev)`
        : '',
      fileSummary: parsedFile.summary,
      preferCarried: true
    }),
    previousSummaryForDedupe
  );

  const bullets = collected.bullets.length ? collected.bullets : parsedFile.bullets;

  outText = formatNotes(summary, bullets, { organize: true });
  console.log(
    `Promote rollup: ${collected.releases.length} -dev release(s) since prod ${sinceProd}; ` +
      `${organizeBullets(bullets).length} change bullet(s) organized; summary from ${summarySource}`
  );
  if (!summary) {
    console.log('No summary — omitting **Summary** section from prod notes');
  }
  if (!collected.bullets.length) {
    console.warn(
      'Warning: no -dev changelog bullets to roll up; using ## Changes from patch-notes.md (if any).'
    );
  }
} else if (CHANNEL === 'prod') {
  mode = 'prod-organize';
  // Direct prod push (no -dev promote): organize Changes; Summary from commit description only
  if (!parsedFile.bullets.length) {
    console.error('ERROR: patch-notes.md needs ## Changes bullets for', VERSION);
    process.exit(1);
  }
  const { summary, source: summarySource } = dropDuplicateSummary(
    resolveSummary({
      commitSummary,
      fileSummary: parsedFile.summary,
      preferCarried: false
    }),
    previousSummaryForDedupe
  );
  outText = formatNotes(summary, parsedFile.bullets, { organize: true });
  console.log(
    `Prod organize: ${organizeBullets(parsedFile.bullets).length} change bullet(s); summary from ${summarySource}`
  );
  if (!summary) {
    console.log('No summary — omitting **Summary** section');
  }
} else {
  mode = 'dev-flat';
  // Dev: flat Changes; Summary from commit description only (never repeat previous)
  if (!parsedFile.bullets.length) {
    console.error('ERROR: patch-notes.md needs ## Changes bullets for', VERSION);
    process.exit(1);
  }
  const { summary, source: summarySource } = dropDuplicateSummary(
    resolveSummary({
      commitSummary,
      fileSummary: parsedFile.summary,
      preferCarried: false
    }),
    previousSummaryForDedupe
  );
  outText = formatNotes(summary, parsedFile.bullets, { organize: false });
  console.log(
    `Dev flat list: ${dedupeBullets(parsedFile.bullets).length} change bullet(s); summary from ${summarySource}`
  );
  if (!summary) {
    console.log('No summary — omitting **Summary** section');
  }
}
fs.writeFileSync(OUT, outText.endsWith('\n') ? outText : outText + '\n', 'utf8');
console.log('Wrote', path.relative(process.cwd(), OUT), `(mode=${mode})`);
