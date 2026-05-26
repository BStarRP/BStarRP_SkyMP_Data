/**
 * Git pathspec magic for paths that must match literally.
 * Without :(literal), brackets/spaces in paths (e.g. "9 divines/", "[HF]") can break --include.
 */

function toGitPathspec(rel) {
  const p = String(rel).replace(/\\/g, '/');
  if (/[[\]*?]/.test(p)) return `:(literal)${p}`;
  return p;
}

module.exports = { toGitPathspec };
