# BStar SkyMP Patches

Public repository for **BStar Launcher** patch content (mods + SkyrimPlatform data). The launcher fetches the latest release and installs the zip into the game’s `Data/BStarPatch` folder.

- **Repo must stay public** so the launcher can read releases without authentication.
- Set in the launcher’s `.env`: `PATCH_GITHUB_REPO=YOUR_USERNAME/bstar_skymp_patches`

## Releasing a patch

1. Put your content in **`patch-content/`** (mods, Platform output, etc.).
2. Commit and push.
3. On GitHub: **Releases → Create a new release** with a tag (e.g. `v1.0.0`), then publish.
4. The **Build patch** workflow runs and attaches `patch-1.0.0.zip` to the release.
5. Launcher users get it via **Check for updates**.

## Local build

```bash
npm ci
node scripts/build-patch.js patch-content 1.0.0
# → dist-patch/patch-1.0.0.zip
```

## Zip format

The zip contains:

- **`manifest.json`** at root with a `files` array (paths relative to game root).
- All files from `patch-content/` (merged into `Data/BStarPatch` by the launcher).

The build script generates the manifest automatically.
