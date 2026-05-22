/**
 * Shared changelog helpers for build-changelog.js and bootstrap-changelog-seed.js.
 */

const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');

const SEED_PATH = path.join(__dirname, 'changelog-seed.json');

function stripDuplicateVersion(s) {
  return String(s || '')
    .replace(/^#?\s*Patch\s+[\d.]+\s*\n?/i, '')
    .trimStart();
}

function parseVersionParts(v) {
  const m = String(v).replace(/^v/i, '').match(/^(\d+)\.(\d+)\.(\d+)/);
  if (!m) return [0, 0, 0];
  return [Number(m[1]), Number(m[2]), Number(m[3])];
}

function compareVersions(a, b) {
  const pa = parseVersionParts(a);
  const pb = parseVersionParts(b);
  for (let i = 0; i < 3; i++) {
    if (pa[i] !== pb[i]) return pb[i] - pa[i];
  }
  return 0;
}

function normalizeReleaseEntry(entry) {
  if (!entry || !entry.version) return null;
  const version = String(entry.version).replace(/^v/i, '');
  const notes = stripDuplicateVersion(String(entry.notes || '').trim());
  if (!notes) return null;
  const out = { version, notes };
  if (entry.date) out.date = String(entry.date).slice(0, 10);
  return out;
}

function mergeChangelog(previous, currentVersion, currentNotes, currentDate) {
  const map = new Map();
  const currentVer = String(currentVersion).replace(/^v/i, '');

  for (const raw of previous?.releases || []) {
    const entry = normalizeReleaseEntry(raw);
    if (!entry || entry.version === currentVer) continue;
    map.set(entry.version, entry);
  }

  const current = normalizeReleaseEntry({
    version: currentVersion,
    date: currentDate,
    notes: currentNotes
  });

  if (current) {
    map.set(current.version, current);
  }

  const releases = [...map.values()].sort((a, b) => compareVersions(a.version, b.version));
  return {
    latest: currentVersion,
    releases
  };
}

function readPatchNotesAtTag(tag) {
  const ref = String(tag || '').startsWith('v') ? tag : `v${tag}`;
  try {
    const content = execFileSync('git', ['show', `${ref}:patch-notes.md`], {
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'ignore']
    }).trim();
    if (!content) return null;
    return stripDuplicateVersion(content);
  } catch (_) {
    return null;
  }
}

function gitTagDate(tag) {
  const ref = String(tag || '').startsWith('v') ? tag : `v${tag}`;
  try {
    const iso = execFileSync('git', ['log', '-1', '--format=%cI', ref], {
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'ignore']
    }).trim();
    return iso ? iso.slice(0, 10) : undefined;
  } catch (_) {
    return undefined;
  }
}

function listVersionTags() {
  try {
    const out = execFileSync('git', ['tag', '-l', 'v*'], {
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'ignore']
    });
    return out
      .split(/\r?\n/)
      .map((t) => t.trim())
      .filter(Boolean)
      .sort((a, b) => compareVersions(a.replace(/^v/i, ''), b.replace(/^v/i, '')));
  } catch (_) {
    return [];
  }
}

async function fetchJsonWithRetry(url, options, label, attempts = 3) {
  let lastErr;
  for (let i = 1; i <= attempts; i++) {
    try {
      const res = await fetch(url, options);
      if (res.ok) return res.json();
      if (res.status === 404) return null;
      if (res.status >= 500 && i < attempts) {
        await new Promise((r) => setTimeout(r, 2000 * i));
        continue;
      }
      throw new Error(`${label} HTTP ${res.status}`);
    } catch (err) {
      lastErr = err;
      if (i < attempts) await new Promise((r) => setTimeout(r, 2000 * i));
    }
  }
  throw lastErr;
}

function githubAuthHeaders() {
  const token = process.env.GH_TOKEN || process.env.GITHUB_TOKEN;
  const headers = {
    Accept: 'application/vnd.github+json',
    'X-GitHub-Api-Version': '2022-11-28',
    'User-Agent': 'BStarRP-SkyMP-Data-changelog-bootstrap'
  };
  if (token) headers.Authorization = `Bearer ${token}`;
  return headers;
}

async function fetchReleaseByTag(repo, tag) {
  const tagName = String(tag || '').startsWith('v') ? tag : `v${tag}`;
  const url = `https://api.github.com/repos/${repo}/releases/tags/${encodeURIComponent(tagName)}`;
  return fetchJsonWithRetry(url, { headers: githubAuthHeaders() }, `release ${tagName}`, 2);
}

async function fetchAllGitHubReleases(repo) {
  try {
    const releases = [];
    let page = 1;

    while (true) {
      const url = `https://api.github.com/repos/${repo}/releases?per_page=100&page=${page}`;
      const batch = await fetchJsonWithRetry(
        url,
        { headers: githubAuthHeaders() },
        `GitHub releases page ${page}`,
        2
      );
      if (!batch || !batch.length) break;
      releases.push(...batch);
      if (batch.length < 100) break;
      page++;
    }

    if (releases.length) return releases;
  } catch (err) {
    console.warn('Paginated releases list failed:', err.message);
  }

  console.log('Falling back to per-tag release lookup (slower but more reliable)…');
  const tags = listVersionTags();
  const releases = [];
  for (let i = 0; i < tags.length; i++) {
    const tag = tags[i];
    try {
      const release = await fetchReleaseByTag(repo, tag);
      if (release && !release.draft && !release.prerelease) releases.push(release);
    } catch (err) {
      console.warn('Skip', tag + ':', err.message);
    }
    if (i > 0 && i % 5 === 0) await new Promise((r) => setTimeout(r, 1000));
  }
  return releases;
}

/**
 * Build legacy release entries from GitHub releases + patch-notes.md at tags.
 * @param {string|null} excludeVersion - skip this version (current release uses patch-notes.md)
 */
function buildLegacyEntriesFromReleases(releases, excludeVersion) {
  const exclude = excludeVersion ? String(excludeVersion).replace(/^v/i, '') : null;
  let fromTag = 0;
  let fromBody = 0;

  const entries = releases
    .filter((r) => !r.draft && !r.prerelease)
    .map((r) => {
      const version = String(r.tag_name || '').replace(/^v/i, '');
      if (!version || version === exclude) return null;

      const date = r.published_at ? r.published_at.slice(0, 10) : gitTagDate(r.tag_name);
      const tagNotes = readPatchNotesAtTag(r.tag_name);
      const bodyNotes = stripDuplicateVersion(String(r.body || '').trim());
      // Legacy: release body is what was published for that version; tag patch-notes.md is often stale/copied.
      const notes = bodyNotes || tagNotes;
      if (!notes) return null;

      if (bodyNotes) fromBody++;
      else fromTag++;

      return { version, date, notes };
    })
    .filter(Boolean);

  entries.sort((a, b) => compareVersions(a.version, b.version));
  return { entries, fromTag, fromBody };
}

function loadChangelogJson(filePath) {
  if (!filePath || !fs.existsSync(filePath)) return null;
  const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  if (!Array.isArray(data.releases)) data.releases = [];
  return data;
}

function loadSeedChangelog() {
  const data = loadChangelogJson(SEED_PATH);
  if (data?.releases?.length) {
    console.log('Loaded committed seed:', SEED_PATH, `(${data.releases.length} releases)`);
  }
  return data;
}

function loadPreviousChangelog(explicitPath) {
  const candidates = [
    explicitPath,
    path.join(process.cwd(), 'prev-changelog.json')
  ].filter(Boolean);

  for (const filePath of candidates) {
    const data = loadChangelogJson(filePath);
    if (data?.releases?.length) {
      console.log('Loaded previous changelog:', filePath, `(${data.releases.length} releases)`);
      return data;
    }
  }
  return null;
}

function loadHistoryBase(explicitPrevPath) {
  const prev = loadPreviousChangelog(explicitPrevPath);
  if (prev?.releases?.length) return prev;

  const seed = loadSeedChangelog();
  if (seed?.releases?.length) return seed;

  console.warn(
    'No prev-changelog.json or scripts/changelog-seed.json with releases; output will only include the current version.'
  );
  console.warn('Run: node scripts/bootstrap-changelog-seed.js  (once) and commit scripts/changelog-seed.json');
  return { releases: [] };
}

module.exports = {
  SEED_PATH,
  stripDuplicateVersion,
  compareVersions,
  normalizeReleaseEntry,
  mergeChangelog,
  readPatchNotesAtTag,
  gitTagDate,
  listVersionTags,
  fetchAllGitHubReleases,
  buildLegacyEntriesFromReleases,
  loadHistoryBase,
  loadSeedChangelog,
  loadPreviousChangelog
};
