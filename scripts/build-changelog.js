/**
 * Builds dist-patch/changelog.json for the launcher news UI.
 *
 * History (first match):
 *   1. prev-changelog.json — downloaded from the previous GitHub release (normal path)
 *   2. scripts/changelog-seed.json — committed legacy history (first changelog-enabled release)
 *
 * Current version: always from patch-notes.md
 *
 * Usage:
 *   node scripts/build-changelog.js [version] [--notes-file=path] [--previous-changelog=path] [--release-date=YYYY-MM-DD]
 *
 * Env: VERSION
 */

const fs = require('fs');
const path = require('path');
const { stripDuplicateVersion, mergeChangelog, loadHistoryBase } = require('./changelog-lib');

const argv = process.argv.slice(2);
const versionArg = argv.find((a) => !a.startsWith('--'));
const notesFileArg = argv.find((a) => a.startsWith('--notes-file='));
const prevChangelogArg = argv.find((a) => a.startsWith('--previous-changelog='));
const releaseDateArg = argv.find((a) => a.startsWith('--release-date='));
const outArg = argv.find((a) => a.startsWith('--out='));

const VERSION = (versionArg || process.env.VERSION || '').replace(/^v/i, '');
const NOTES_FILE = notesFileArg ? notesFileArg.slice('--notes-file='.length) : null;
const PREVIOUS_CHANGELOG_PATH = prevChangelogArg
  ? path.resolve(process.cwd(), prevChangelogArg.slice('--previous-changelog='.length))
  : null;
const RELEASE_DATE = releaseDateArg ? releaseDateArg.slice('--release-date='.length) : null;
const OUT_PATH = outArg
  ? path.resolve(process.cwd(), outArg.slice('--out='.length))
  : path.join(process.cwd(), 'dist-patch', 'changelog.json');

if (!VERSION) {
  console.error('Error: set VERSION env or pass version as first argument');
  process.exit(1);
}

function readCurrentNotes() {
  const rel = NOTES_FILE || 'patch-notes.md';
  const p = path.resolve(process.cwd(), rel);
  if (!fs.existsSync(p)) {
    console.warn('Warning: patch-notes.md not found; current version will have empty notes');
    return '';
  }
  const content = fs.readFileSync(p, 'utf8').trim();
  if (!content) {
    console.warn('Warning: patch-notes.md is empty');
    return '';
  }
  return stripDuplicateVersion(content);
}

async function main() {
  const currentNotes = readCurrentNotes();
  const currentDate = RELEASE_DATE || new Date().toISOString().slice(0, 10);
  const history = loadHistoryBase(PREVIOUS_CHANGELOG_PATH);
  const changelog = mergeChangelog(history, VERSION, currentNotes, currentDate);

  const outDir = path.dirname(OUT_PATH);
  if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true });
  fs.writeFileSync(OUT_PATH, JSON.stringify(changelog, null, 2) + '\n', 'utf8');

  console.log(
    'Created',
    path.relative(process.cwd(), OUT_PATH),
    '— latest:',
    changelog.latest,
    'releases:',
    changelog.releases.length
  );
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
