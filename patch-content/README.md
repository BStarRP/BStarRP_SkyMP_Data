# Patch content

Put the files that should be installed under **Data/BStarPatch** here:

- Mods (e.g. `Mod1/`, `Mod2/`)
- SkyrimPlatform compiled output (e.g. `Platform/`)

When you **publish a GitHub Release** (with a tag like `v1.0.0`), the **Build patch** workflow will zip this folder, generate `manifest.json`, and upload the zip as a release asset.

Local build: `node scripts/build-patch.js patch-content 1.0.0`
