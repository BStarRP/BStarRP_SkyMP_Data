# Patch manifest format (BStarRP SkyMP Launcher incremental updates)

This document defines how patch releases are built so the **BStarRP SkyMP Launcher** can perform **incremental updates** (download only missing or changed files) instead of always downloading the full zip.

## 1. Release assets required

Each release must include:

- **`patch-<version>.zip`** – Full patch archive. Required as fallback and for first-time installs.
- **`manifest.json`** – A **separate** release asset (upload the file itself, not only inside the zip). The launcher downloads this file by name from the release assets.
- **One release asset per patch file** – Each file that goes into the game (e.g. under `Data/`) must be uploaded as its own asset so it has a direct download URL. Asset names use the path with slashes replaced by underscores (e.g. `Data_Platform_plugins_MpClientPlugin.dll`).

## 2. manifest.json format

The manifest must be valid JSON with this structure:

```json
{
  "version": "0.8.2",
  "files": [
    {
      "path": "Data/Platform/plugins/MpClientPlugin.dll",
      "size": 1234567,
      "hash": "sha256-hex-of-file-contents",
      "url": "https://github.com/owner/repo/releases/download/v0.8.2/Data_Platform_plugins_MpClientPlugin.dll"
    }
  ],
  "zipUrl": "https://github.com/owner/repo/releases/download/v0.8.2/patch-0.8.2.zip"
}
```

| Field    | Type   | Required | Description |
|----------|--------|----------|-------------|
| `version` | string | Yes (for launcher) | Version string matching the release tag (e.g. `"0.8.2"`). |
| `files`   | array  | Yes      | Array of file entries (see below). |
| `zipUrl`  | string | No       | Full URL to the `patch-<version>.zip` asset (fallback when incremental is not used). |

Each entry in **`files`** must have:

| Field  | Type   | Required | Description |
|--------|--------|----------|-------------|
| `path` | string | Yes      | Path relative to the **game root**, using **forward slashes** (e.g. `Data/Platform/plugins/SomeFile.dll`). |
| `size` | number | Yes      | File size in bytes. |
| `hash` | string | Yes      | SHA-256 hash of the file contents, in **hex** (lowercase or uppercase). Optional prefix `sha256:` is allowed. |
| `url`  | string | Yes for incremental | Direct download URL for this file (e.g. the GitHub release asset URL). |

**Critical for incremental:** Every file in `files` must have a non-empty `url`. If any file is missing `url`, the launcher will ignore incremental and download the full zip.

## 3. Patcher behavior

- **No manifest.json** → full zip download only.
- **Manifest without per-file URLs** → full zip download (e.g. using `zipUrl` or the zip asset).
- **Manifest with all files having `url`** → incremental mode: verify each file (size + hash), download only missing or changed files.

## 4. How this repo generates manifest.json

- **build-patch.js** walks the patch directory (`patch-content/`), computes path (relative to game root with `Data/` prefix, forward slashes), size in bytes, and SHA-256 hex of contents. It writes `dist-patch/manifest.json` with `version` and `files` (no URLs at this stage).
- **prepare-patch-assets.js** copies each file into `dist-patch/assets/` with asset names `path.replace(/\//g, '_')` (e.g. `Data/Platform/plugins/x.js` → `Data_Platform_plugins_x.js`).
- The **CI workflow** injects `url` (and `zipUrl`) into the manifest, then uploads `manifest.json` and all files in `dist-patch/assets/` as release assets. Asset URLs are `https://github.com/<owner>/<repo>/releases/download/<tag>/<asset_name>`.

## 5. Release workflow summary

1. Build the patch (same as now).
2. Create the full zip `patch-<version>.zip` and upload it with the release.
3. Upload **each** patch file as a separate release asset (so each has a URL).
4. Generate **manifest.json** with `version`, `files` (path, size, hash, **url** for every file), and optional `zipUrl`.
5. Upload **manifest.json** as a release asset (filename exactly `manifest.json`).

After this, the launcher will fetch `manifest.json`, see that every file has a `url`, and use incremental mode.

---

*This matches the launcher behavior in BStarRP_SkyMP_Launcher (see `docs/PATCH_MANIFEST.md` and `electron/main.ts` there).*
