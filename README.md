# BStarRP SkyMP Data

Public repository for **BStarRP SkyMP Launcher** patch content (mods + SkyrimPlatform data). The launcher fetches the latest release and installs the zip directly into the game’s `Data` folder.

- **Repo must stay public** so the launcher can read releases without authentication.
- In **BStarRP_SkyMP_Launcher** set in `.env`: `PATCH_GITHUB_REPO=YourOrg/BStarRP_SkyMP_Data`

## Releasing a patch

**Option A – Automatic (recommended):**  
Push changes to `patch-content/` on `main`. The **Auto release on patch change** workflow creates a new release with an incremented version (e.g. `v1.0.0` → `v1.0.1`), then **Build patch** attaches the zip.

**Option B – Manual:**  
1. Put your content in **`patch-content/`** (mods, Platform output, etc.).
2. Commit and push.
3. On GitHub: **Releases → Create a new release** with a tag (e.g. `v1.0.0`), then publish.
4. The **Build patch** workflow runs and attaches `patch-1.0.0.zip` to the release.

Launcher users get updates via **Check for updates**.

## Local build

```bash
npm ci
node scripts/build-patch.js patch-content 1.0.0
# → dist-patch/patch-1.0.0.zip
```

## Zip format

The zip contains:

- **`manifest.json`** at root with a `files` array (paths relative to game root).
- All files from `patch-content/` (merged into `Data` by the launcher).

The build script generates the manifest automatically.
