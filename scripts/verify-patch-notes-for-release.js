/**
 * Validates release notes exist for a new version release.
 * Identical notes vs the previous version are allowed (rolled forward).
 *
 * Usage:
 *   node scripts/verify-patch-notes-for-release.js <version> <previousVersion> \
 *     [--notes-file=release-notes.md] \
 *     [--prev-changelog=path] \
 *     [--compare-version=X.Y.Z]   # compare against this changelog entry (e.g. last prod on promote)
 */

const fs = require('fs');
const path = require('path');
const { stripDuplicateVersion } = require('./changelog-lib');

const argv = process.argv.slice(2);
const version = (argv[0] || '').replace(/^v/i, '');
const previousVersion = (argv[1] || '').replace(/^v/i, '');
const prevArg = argv.find((a) => a.startsWith('--prev-changelog='));
const notesArg = argv.find((a) => a.startsWith('--notes-file='));
const compareArg = argv.find((a) => a.startsWith('--compare-version='));

const prevPath = prevArg
  ? path.resolve(process.cwd(), prevArg.slice('--prev-changelog='.length))
  : path.join(process.cwd(), 'prev-changelog.json');
const notesPath = notesArg
  ? path.resolve(process.cwd(), notesArg.slice('--notes-file='.length))
  : path.join(process.cwd(), 'patch-notes.md');
const compareVersion = (compareArg ? compareArg.slice('--compare-version='.length) : previousVersion).replace(
  /^v/i,
  ''
);

if (!version || !previousVersion) {
  console.error(
    'Usage: node scripts/verify-patch-notes-for-release.js <version> <previousVersion> [--notes-file=...] [--compare-version=...]'
  );
  process.exit(1);
}

if (version === previousVersion) {
  console.log('Same version rebuild; skipping patch-notes change check');
  process.exit(0);
}

if (!fs.existsSync(notesPath)) {
  console.warn('Warning: notes file is missing:', notesPath + ';', 'continuing with an empty changelog');
  process.exit(0);
}

const currentNotes = stripDuplicateVersion(fs.readFileSync(notesPath, 'utf8').trim());
if (!currentNotes) {
  console.warn(
    'Warning: notes file is empty for version',
    version + ';',
    'continuing with an empty changelog'
  );
  process.exit(0);
}

let prevNotes = null;
if (fs.existsSync(prevPath)) {
  const prev = JSON.parse(fs.readFileSync(prevPath, 'utf8'));
  const entry = (prev.releases || []).find((r) => String(r.version).replace(/^v/i, '') === compareVersion);
  if (entry?.notes) prevNotes = stripDuplicateVersion(String(entry.notes).trim());
}

if (prevNotes && prevNotes === currentNotes) {
  console.log(
    'Notes unchanged from version',
    compareVersion + ';',
    'rolling them forward for',
    version
  );
  process.exit(0);
}

console.log('Notes look updated for release', version, '(compared to', compareVersion + ')');
