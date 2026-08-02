# BStarRP SkyMP Data

Public repository for **BStarRP SkyMP Launcher** patch content (mods + SkyrimPlatform data). The launcher fetches **`manifest.json`** (and file assets from GitHub Releases / R2 CDN) and installs into the game's `Data` folder.

- **Repo must stay public** so the launcher can read releases without authentication.
- In **BStarRP_SkyMP_Launcher** set in `.env`: `PATCH_GITHUB_REPO=YourOrg/BStarRP_SkyMP_Data`

## Releasing a patch

### Channels

| Branch | Channel | GitHub release | CDN folder | Discord |
|--------|---------|----------------|------------|---------|
| `main` | **prod** | `vX.Y.Z` (Latest) | `patches/X.Y.Z/` | yes |
| `dev` | **dev** | `vX.Y.Z-dev` (prerelease) + floating tag `dev` | `patches/X.Y.Z-dev/` | no |

**Prod** (unchanged): keep using `/releases/latest/download/...` in server settings:

```json
"patchManifestUrl": "https://github.com/BStarRP/BStarRP_SkyMP_Data/releases/latest/download/manifest.json",
"changelogUrl": "https://github.com/BStarRP/BStarRP_SkyMP_Data/releases/latest/download/changelog.json"
```

**Dev** (set once on bstarrpdev / Mereth Roleplay DEV — does not affect prod latest):

```json
"patchManifestUrl": "https://github.com/BStarRP/BStarRP_SkyMP_Data/releases/download/dev/manifest.json",
"changelogUrl": "https://github.com/BStarRP/BStarRP_SkyMP_Data/releases/download/dev/changelog.json"
```

Pushing `Data/` changes to `dev` publishes a `-dev` patch. Merging `dev` → `main` (or pushing updates on `main`) publishes an official prod patch the same way as before.

**Prod version promote:** if `dev` has already shipped ahead (e.g. `0.67.19-dev`), the next prod release becomes **`0.67.19`** (not stuck at `0.67.17`). When that happens, unchanged files are copied from `patches/0.67.19-dev/` → `patches/0.67.19/` (hash-matched); only real diffs upload from `main`.

**Option A – Automatic (recommended):**  
Push changes to `Data/` on `main` or `dev` using [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) in your commit messages. The **Auto release on patch change** workflow sets the version from your commits.

- `fix: description` → PATCH (e.g. 1.0.0 → 1.0.1, or on `dev` → 1.0.1-dev)
- `feat: description` → MINOR (e.g. 1.0.0 → 1.1.0)
- `BREAKING CHANGE:` in body or `type!: description` → MAJOR (e.g. 1.0.0 → 2.0.0)

**Option B – Manual:**  
1. Put your content in **`Data/`** (mods, Platform output, etc.).
2. Commit and push to `main` or `dev`.
3. Actions → **Auto release on patch change** → Run workflow (select branch). Optionally set "Create release version" (on `dev`, `-dev` is appended if missing).

## Local build

```bash
npm ci
node scripts/build-patch.js Data 1.0.0
# → dist-patch/manifest.json
```

## Launcher requirements

The launcher uses **`manifest.json`** from the release (prod: `/releases/latest/...`, dev: `/releases/download/dev/...`). File URLs inside the manifest point at GitHub release assets and/or the R2 CDN (`patches/<version>/...`).
