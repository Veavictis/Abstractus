# Git workflow

## Branches

- `main` is always playable. Never commit straight to it; merge through a pull request.
- Work on short-lived branches named by type:
  - `feature/<name>` new gameplay, scenes, systems
  - `art/<name>` new or updated assets
  - `fix/<name>` bug fixes
  - `chore/<name>` tooling, config, cleanup
- Squash-merge pull requests so `main` stays one commit per change.

## Commits

Short imperative summary, optionally prefixed with the area: `player: add dash`, `art: new title background`.

## Everyday loop

```bash
git switch main && git pull
git switch -c feature/title-screen
# ...work, save in Godot...
git add -A
git commit -m "ui: add title screen"
git push -u origin feature/title-screen
# open a pull request on GitHub, CI runs, merge when green
```

## Large files

Art, audio, fonts and 3D files go through Git LFS automatically (see `.gitattributes`).
Check with `git lfs ls-files` before pushing. GitHub's free LFS quota is 10 GB storage and
bandwidth per month; keep huge working files lean or outside the repo if it gets tight.

## CI

- **CI** (every pull request and push to `main`): `gdlint`/`gdformat` on GDScript, and a headless
  Godot import that fails on script or resource errors.
- **Export builds** (tags `v*` or manual run from the Actions tab): exports Windows and Linux (Steam Deck) builds
  and attaches them as downloadable artifacts.

## Releasing

1. Bump `application/config/version` in Project Settings.
2. `git tag v0.1.0 && git push origin v0.1.0`
3. Download the builds from the workflow run. Steam upload (SteamPipe) gets wired in later.

## Recommended GitHub settings

Settings → Branches → add a rule for `main`: require a pull request and require the `CI` checks to pass.
