/**
 * Git pathspec magic for paths that must match literally.
 * Without :(literal), brackets in filenames (e.g. BasketBraidedBread[HF].nif) are treated as globs.
 */

function toGitPathspec(rel) {
  const p = String(rel).replace(/\\/g, '/');
  if (/[[\]*?]/.test(p)) return `:(literal)${p}`;
  return p;
}

module.exports = { toGitPathspec };
