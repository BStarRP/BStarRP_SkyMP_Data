# Instructions for the patch release workflow (incremental updates)

When building a patch release for the BStarRP SkyMP Launcher, follow these steps so the launcher can do **incremental updates** (download only missing or changed files) instead of always downloading the full zip.

## 1. Release assets required

Each release must include:

- **`patch-<version>.zip`** – Full patch archive (same as today). Required as fallback and for first-time installs.
- **`manifest.json`** – A **separate** release asset (upload the file itself, do not only keep it inside the zip). The launcher downloads this file by name from the release assets.
- **One release asset per patch file** (for incremental) – Each file that goes into the game (e.g. under `Data/`) should be uploaded as its own asset so it has a direct download URL. Asset names can be the path with slashes replaced by underscores (e.g. `Data_Platform_plugins_MpClientPlugin.dll`) to avoid path issues.

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

- **`version`** (required): Version string matching the release tag (e.g. `"0.8.2"`).
- **`files`** (required): Array of objects, one per patch file.
- **`zipUrl`** (optional): Full URL to the `patch-<version>.zip` asset (fallback when incremental is not used).

Each entry in **`files`** must have:

| Field   | Type   | Required | Description |
|--------|--------|----------|-------------|
| `path` | string | Yes      | Path relative to the **game root**, using **forward slashes** (e.g. `Data/Platform/plugins/SomeFile.dll`). |
| `size` | number | Yes      | File size in bytes. |
| `hash` | string | Yes      | SHA-256 hash of the file contents, in **hex** (lowercase or uppercase). Optional prefix `sha256:` is allowed. |
| `url`  | string | Yes for incremental | Direct download URL for this file (e.g. the GitHub release asset URL). |

**Critical for incremental:** Every file in `files` must have a non-empty `url`. If any file is missing `url`, the launcher will ignore incremental and download the full zip.

## 3. How to generate manifest.json

- Walk the patch output directory (e.g. the folder that becomes the contents of `Data/` in the zip).
- For each file: compute path (relative to game root, forward slashes), size in bytes, and SHA-256 hex of contents.
- Set `url` to the exact URL where that file will be downloadable (e.g. `https://github.com/<owner>/<repo>/releases/download/v<version>/<asset-name>`). Asset names on GitHub often use underscores instead of slashes (e.g. `Data_Platform_plugins_File.dll`).
- Output JSON with `version`, `files`, and optionally `zipUrl`.
- Upload **manifest.json** as a release asset with the **exact** filename `manifest.json` (the launcher looks for an asset named `manifest.json`).

## 4. Release workflow summary

1. Build the patch (same as now).
2. Create the full zip `patch-<version>.zip` and upload it.
3. Upload **each** patch file as a separate release asset (so each has a URL), or host them elsewhere and use those URLs.
4. Generate **manifest.json** with `version`, `files` (path, size, hash, **url** for every file), and optional `zipUrl`.
5. Upload **manifest.json** as a release asset (filename exactly `manifest.json`).

After this, the launcher will fetch `manifest.json`, see that every file has a `url`, and use incremental mode: it will only download files that are missing or whose size/hash do not match the manifest.

---

*This matches the launcher behavior in BStarRP_SkyMP_Launcher (see `docs/PATCH_MANIFEST.md` and `electron/main.ts`).*

**Example manifest (this repo):**  
https://github.com/BStarRP/BStarRP_SkyMP_Data/releases/download/v0.10.0/manifest.json

---

## Troubleshooting: 404 on incremental file download

If the launcher shows **"Download failed: 404"** for a file (e.g. `Data/Interface/CombatAlertOverlayMenu.swf`), that file is listed in the release `manifest.json` with a `url`, but the corresponding asset was **not** uploaded to the release.

**Common cause:** The file was removed from `Data/` (or never added) but the release manifest still lists it—e.g. the manifest was built when the file existed, or the root `manifest.json` is stale.

**Fix:**

1. **Restore the file in the repo**  
   The file must exist under `Data/` so the workflow can include it in the manifest and upload it as an asset. For example, for `Data/Interface/CombatAlertOverlayMenu.swf` you need `Data/Interface/CombatAlertOverlayMenu.swf`.  
   If the file is in an existing patch zip (e.g. `patch-0.10.0.zip`), extract it and add it to `Data/Interface/`.

2. **Update the release assets**  
   - Commit the restored file and push, **or**  
   - Run the **"Auto release on patch change"** workflow manually (Actions → workflow_dispatch). That rebuilds from current `Data/`, uploads the full manifest and all per-file assets (including the restored file), and fixes the 404.

3. **Keep the root manifest in sync (optional)**  
   If you use the root `manifest.json`, regenerate it from current `Data/`:  
   `node scripts/generate-manifest.js`

**Rule:** Every file listed in the release manifest must exist as a release asset; the workflow only uploads files that exist in `Data/`.
