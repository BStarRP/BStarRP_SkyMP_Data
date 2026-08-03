# BStarRP SkyMP Data

Public repository for **BStarRP SkyMP Launcher** patch content (mods + SkyrimPlatform data). The launcher fetches **`manifest.json`** (and file assets from GitHub Releases / R2 CDN) and installs into the game's `Data` folder.

- **Repo must stay public** so the launcher can read releases without authentication.
- In **BStarRP_SkyMP_Launcher** set in `.env`: `PATCH_GITHUB_REPO=YourOrg/BStarRP_SkyMP_Data`

## Releasing a patch

### Channels

| Branch | Channel | GitHub release | CDN folder | Discord |
|--------|---------|----------------|------------|---------|
| `main` | **prod** | `vX.Y.Z` (Latest) | `patches/X.Y.Z/` | yes |
| `dev` | **dev** | `vX.Y.Z-dev` (prerelease) + floating tag `dev-latest` | `patches/X.Y.Z-dev/` | no |

**Prod** (unchanged): keep using `/releases/latest/download/...` in server settings:

```json
"patchManifestUrl": "https://github.com/BStarRP/BStarRP_SkyMP_Data/releases/latest/download/manifest.json",
"changelogUrl": "https://github.com/BStarRP/BStarRP_SkyMP_Data/releases/latest/download/changelog.json"
```

**Dev** (set once on bstarrpdev / Mereth Roleplay DEV — does not affect prod latest).

Floating tag is `dev-latest` (not `dev`) so it never collides with the `dev` branch — that collision caused `src refspec dev matches more than one` and broke Desktop pushes / the floating release.

```json
"patchManifestUrl": "https://github.com/BStarRP/BStarRP_SkyMP_Data/releases/download/dev-latest/manifest.json",
"changelogUrl": "https://github.com/BStarRP/BStarRP_SkyMP_Data/releases/download/dev-latest/changelog.json"
```

Pushing `Data/` changes to `dev` publishes a `-dev` patch. Merging `dev` → `main` (or pushing updates on `main`) publishes an official prod patch the same way as before.

**Prod version promote:** if `dev` has already shipped ahead (e.g. `0.67.19-dev`), the next prod release becomes **`0.67.19`** (not stuck at `0.67.17`). When that happens, unchanged files are copied from `patches/0.67.19-dev/` → `patches/0.67.19/` (hash-matched); only real diffs upload from `main`.

**Patch notes:**
- **`dev`:** flat `## Changes` list (no category headings). **Summary** = commit description (body). If the commit has no description, the previous `-dev` Summary is carried forward.
- **`main` (promote):** rolls up Changes from all `-dev` releases since last prod; if any `Added`/`Fixed`/`Improved`/`Removed`/`Reworked`/`Updated` prefixes exist, group those alphabetically and put the rest under **Other**. If none of those prefixes exist, keep a flat list. **Summary** = last `-dev` Summary (carried to production on merge).
- **`main` (direct):** organize Changes the same way; Summary from commit description, else carry previous prod Summary.
- Prefer starting bullets with `Added` / `Fixed` / `Improved` / `Removed` / `Reworked` / `Updated` so prod can group them.
- **Discord:** only on **prod** when the version actually bumps.

### Example

**Commit** (Summary = body only; subject is never used — no body ⇒ carry previous Summary):
```text
fix: hunting and report polish

Hunting XP fixes and /report command for tonight's test pass.
```

**`patch-notes.md` on `dev`:**
```markdown
# Patch notes

## Changes
- Fixed mudcrab giving XP equivalent to giant for hunting
- Updated hunting/taming skill, moved skeever to t1
- Improved mining feedback when a node is depleted
- Added a /report command (or insert key) for staff reports
- Updated mining XP to scale based on tier/nodes
```

**What `dev` ships** (flat):
```markdown
# Patch notes

**Summary**
Hunting XP fixes and /report command for tonight's test pass.

## Changes
- Fixed mudcrab giving XP equivalent to giant for hunting
- Updated hunting/taming skill, moved skeever to t1
- Improved mining feedback when a node is depleted
- Added a /report command (or insert key) for staff reports
- Updated mining XP to scale based on tier/nodes
```

**What `main` ships after merge** (rolled up + organized):
```markdown
# Patch notes

**Summary**
Hunting XP fixes and /report command for tonight's test pass.

## Changes

### Added
- Added a /report command (or insert key) for staff reports

### Fixed
- Fixed mudcrab giving XP equivalent to giant for hunting

### Improved
- Improved mining feedback when a node is depleted

### Updated
- Updated hunting/taming skill, moved skeever to t1
- Updated mining XP to scale based on tier/nodes
```

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

The launcher uses **`manifest.json`** from the release (prod: `/releases/latest/...`, dev: `/releases/download/dev-latest/...`). File URLs inside the manifest point at GitHub release assets and/or the R2 CDN (`patches/<version>/...`).
