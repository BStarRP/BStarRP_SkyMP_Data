# Setup: Create the GitHub repo and push

**I can’t create the repo for you** (that has to be done in your GitHub account). Do this:

## 1. Create the repository on GitHub

1. Go to [github.com/new](https://github.com/new).
2. **Repository name:** `bstar_skymp_patches`
3. **Visibility:** **Public**
4. Optionally add a description: “Patch content for BStar Launcher”.
5. Do **not** add a README, .gitignore, or license (this folder already has them).
6. Click **Create repository**.

## 2. Push this folder as the new repo

From your machine, in a terminal:

```bash
cd path/to/bstar_launcher/bstar_skymp_patches
git init
git add .
git commit -m "Initial patch repo"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/bstar_skymp_patches.git
git push -u origin main
```

Replace `YOUR_USERNAME` with your GitHub username (or `orgname` if the repo is under an organization).

## 3. Point the launcher at this repo

In the **launcher** project `.env`:

```env
PATCH_GITHUB_REPO=YOUR_USERNAME/bstar_skymp_patches
```

Then the launcher’s “Check for updates” will use this public repo’s releases for the patch zip.

## 4. (Optional) Remove patch content from the launcher repo

If you no longer want patch builds in the launcher repo, you can delete the launcher’s `patch-content/` folder and remove or disable the **Build patch** workflow there, so only **bstar_skymp_patches** is used for patches.
