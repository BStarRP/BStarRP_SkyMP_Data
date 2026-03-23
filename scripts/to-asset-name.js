/**
 * Flat filename for manifest path → R2 / GitHub release asset name.
 *
 * IMPORTANT: Do not collapse runs of underscores. Replacing `/` with `_` can produce
 * `Lib__collections` (Lib + / + _collections). Collapsing `_+` merged that with
 * `Lib_collections` and caused different files to share one R2 key (wrong bytes vs manifest).
 */
function toAssetName(pathEntry) {
  return String(pathEntry)
    .replace(/\\/g, '/')
    .replace(/\//g, '_')
    .replace(/[^a-zA-Z0-9_.-]/g, '_')
    .replace(/^_|_$/g, '');
}

module.exports = toAssetName;
