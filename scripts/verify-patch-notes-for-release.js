/**
 * Fails if patch-notes.md was not updated for a new version release.
 *
 * Usage:
 *   node scripts/verify-patch-notes-for-release.js <version> <previousVersion> [--prev-changelog=path]
 */

const fs = require('fs');
const path = require('path');
const { stripDuplicateVersion } = require('./changelog-lib');

const argv = process.argv.slice(2);
const version = (argv[0] || '').replace(/^v/i, '');
const previousVersion = (argv[1] || '').replace(/^v/i, '');
const prevArg = argv.find((a) => a.startsWith('--prev-changelog='));
const prevPath = prevArg
  ? path.resolve(process.cwd(), prevArg.slice('--prev-changelog='.length))
  : path.join(process.cwd(), 'prev-changelog.json');

if (!version || !previousVersion) {
  console.error('Usage: node scripts/verify-patch-notes-for-release.js <version> <previousVersion>');
  process.exit(1);
}

if (version === previousVersion) {
  console.log('Same version rebuild; skipping patch-notes change check');
  process.exit(0);
}

const notesPath = path.join(process.cwd(), 'patch-notes.md');
if (!fs.existsSync(notesPath)) {
  console.error('ERROR: patch-notes.md is missing');
  process.exit(1);
}

const currentNotes = stripDuplicateVersion(fs.readFileSync(notesPath, 'utf8').trim());
if (!currentNotes) {
  console.error('ERROR: patch-notes.md is empty — write notes for version', version, 'before releasing');
  process.exit(1);
}

let prevNotes = null;
if (fs.existsSync(prevPath)) {
  const prev = JSON.parse(fs.readFileSync(prevPath, 'utf8'));
  const entry = (prev.releases || []).find((r) => String(r.version).replace(/^v/i, '') === previousVersion);
  if (entry?.notes) prevNotes = stripDuplicateVersion(String(entry.notes).trim());
}

if (prevNotes && prevNotes === currentNotes) {
  console.error(
    'ERROR: patch-notes.md is unchanged from version',
    previousVersion,
    '— update patch-notes.md before releasing',
    version
  );
  process.exit(1);
}

console.log('patch-notes.md looks updated for release', version);
