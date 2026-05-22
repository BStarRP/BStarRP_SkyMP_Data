/**
 * One-time (or rare) script to build scripts/changelog-seed.json from legacy GitHub releases.
 * Commit the output; CI uses it when prev-changelog.json does not exist yet.
 *
 * Legacy notes per release: patch-notes.md at that tag when present, else GitHub release body.
 *
 * Usage:
 *   node scripts/bootstrap-changelog-seed.js [--out=scripts/changelog-seed.json]
 *
 * Env: GITHUB_REPOSITORY (default BStarRP/BStarRP_SkyMP_Data), GH_TOKEN | GITHUB_TOKEN
 */

const fs = require('fs');
const path = require('path');
const {
  SEED_PATH,
  compareVersions,
  fetchAllGitHubReleases,
  buildLegacyEntriesFromReleases
} = require('./changelog-lib');

const outArg = process.argv.find((a) => a.startsWith('--out='));
const OUT_PATH = outArg
  ? path.resolve(process.cwd(), outArg.slice('--out='.length))
  : SEED_PATH;

async function main() {
  const repo = process.env.GITHUB_REPOSITORY || 'BStarRP/BStarRP_SkyMP_Data';
  console.log('Fetching GitHub releases for', repo, '…');

  const releases = await fetchAllGitHubReleases(repo);
  const { entries, fromTag, fromBody } = buildLegacyEntriesFromReleases(releases, null);

  if (!entries.length) {
    console.error('No legacy release notes found. Check GITHUB_REPOSITORY and API access.');
    process.exit(1);
  }

  const latest = entries[0].version;
  const seed = { latest, releases: entries };

  fs.writeFileSync(OUT_PATH, JSON.stringify(seed, null, 2) + '\n', 'utf8');
  console.log(
    'Wrote',
    path.relative(process.cwd(), OUT_PATH),
    '—',
    entries.length,
    'releases',
    `(latest ${latest}; ${fromTag} from patch-notes.md at tag, ${fromBody} from release body)`
  );
  console.log('Commit this file, then future releases merge prev-changelog.json + patch-notes.md only.');
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
