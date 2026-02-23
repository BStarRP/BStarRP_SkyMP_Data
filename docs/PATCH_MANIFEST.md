# Patch manifest format

The patcher can use a `manifest.json` release asset to verify patch files (size + SHA-256) and to download only missing or changed files (incremental mode) when each file has a `url`.

## Manifest schema

- **version** (optional): Patch version string (e.g. `"1.2.3"`).
- **files**: Array of file entries. Each entry:
  - **path** (required): Relative path under the game root, e.g. `Data/Platform/plugins/skymp5-client.js`. Used for verification and install location.
  - **size** (required): File size in bytes.
  - **hash** (required): SHA-256 hash of the file (hex string).
  - **url** (optional): Direct download URL for this file. When present for all files, the patcher uses incremental download (only missing or changed files).
- **zipUrl** (optional): URL of the full patch zip. Used as fallback when incremental is not available or when the patcher chooses full zip.

## Patcher behavior

- **No manifest.json** → unchanged: full zip download only.
- **Manifest without per-file URLs** → full zip download (e.g. using `zipUrl` or the zip asset).
- **Manifest with all files having `url`** → incremental mode: verify each file (size + hash), download only missing or changed files, show progress per file.

## Release build (this repo)

1. **Generate manifest**: `scripts/build-patch.js` produces `dist-patch/manifest.json` with `version`, `files` (path, size, hash). No URLs at this stage.
2. **Per-file assets**: `scripts/prepare-patch-assets.js` copies each patch file into `dist-patch/assets/` with asset names derived from path (e.g. `Data/Platform/plugins/x.js` → `Data_Platform_plugins_x.js`).
3. **Release**: The CI workflow creates the release with the patch zip, uploads each file in `dist-patch/assets/` as a release asset, injects `url` (and `zipUrl`) into the manifest, and uploads `manifest.json` as a release asset.
4. **Fallback**: The patch zip remains attached so launchers without manifest support still get the full zip.

Asset URLs follow:  
`https://github.com/<owner>/<repo>/releases/download/<tag>/<asset_name>`  
where `<asset_name>` is the path with `/` replaced by `_`.

For full step-by-step instructions so releases work with the launcher’s incremental update flow, see **[INCREMENTAL_RELEASE_INSTRUCTIONS.md](INCREMENTAL_RELEASE_INSTRUCTIONS.md)**.
