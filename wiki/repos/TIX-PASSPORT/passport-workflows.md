---
title: TIX-PASSPORT workflows
repo: TIX-PASSPORT
kind: workflows
sources:
  - .github/workflows
  - .husky
  - .changeset/config.json
  - .lintstagedrc
  - .commitlintrc
  - docs/publishing.md
  - docs/dependency-management.md
  - docs/testing.md
  - scripts/ci
  - CONTRIBUTING.md
  - package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/workflows]
---

# TIX-PASSPORT workflows

> PR to `main` with a changeset. Optionally label the PR for an alpha snapshot, and changesets publishes on merge through a "Version Packages" PR.

## Local dev
1. Install with pnpm 10 and test with the repo-pinned bun. The global versions break both: [[passport-local-tooling]].
2. Run `npm run dev` for Storybook at `http://local.tiket.com:6006`. Stories are `packages/*/**/*.stories.tsx` and `*.mdx`.
3. For a new package, run `npm run create:component my-thing`. It creates `@tiket/passport-my-thing` with a `MyThing` component, an SCSS module and a story. Then add it to `packages/passport/index.js` and `types/` if it should be in the umbrella.
4. Add deps from inside the package dir: `pnpm add @tiket/passport-button` for a runtime dep, `-D` for a types-only or story-only dep, and `-w` for the root (`docs/dependency-management.md`).

## Git hooks (husky)
| Hook | Runs |
|---|---|
| `pre-commit` | `lint-staged`: eslint --fix on ts/tsx, prettier, and stylelint --fix on scss |
| `commit-msg` | commitlint with `config-conventional` (`feat(PLAT-123): …`, `fix:`, `chore:`) |
| `pre-push` | `npm test && npm run check-all`. This is the full suite plus tsc, so pushes are slow |

## CI (`.github/workflows`)
| Workflow | Trigger | Does |
|---|---|---|
| `ci.yml` | PR → `main` | `pnpm install`, `npm test && npm run check-all` |
| `chromatic.yml` | every push | publishes Storybook to Chromatic (`--exit-zero-on-changes`) |
| `prerelease.yml` | PR opened/synced/labeled, gated on a label | alpha snapshot publish (below) |
| `release.yml` | push to `main` | `changesets/action`: opens or updates the Version Packages PR, or publishes |

All workflows use Node 24 and pnpm 10, with registry `npm.pkg.github.com` for scope `@tiket`. Install authenticates with a personal token secret `RYANDI_GITHUB_TOKEN_DELETE_SOON`, a known TODO tracked in issue #738.

## Changesets
- Every PR needs a `.changeset/*.md` (`npx changeset`). changeset-bot checks this.
- `fixed: [["@tiket/passport*"]]` bumps **every** package to the same version on any release, even packages that didn't change. See [[changesets-fixed-versioning]].
- `updateInternalDependencies: patch` and `onlyUpdatePeerDependentsWhenOutOfRange: true`.
- The changelog uses `@changesets/changelog-github` with PR links. `baseBranch: main`, `access: restricted`.

## Prerelease (alpha snapshot)
Add the PR label **`Automate Pre-Release`** (`docs/publishing.md`). See [[prerelease-flow]].
1. `npx changeset version --snapshot "alpha-<PR#>"` produces versions `0.0.0-alpha-<PR#>-<YYYYMMDDHHMMSS>` for packages that have changesets, plus their dependents.
2. `pnpm run build`, then `scripts/ci/snapshots.js` reads the changed `package.json` files and writes `version.md` (a table) and `tempversion.txt`.
3. `pnpm publish -r --tag alpha-<PR#> --no-git-checks` publishes under a dist-tag, never `latest`.
4. A bot comment ("New pre-release was generated.") is created or replaced with the version table. Every push to the PR publishes a new timestamped snapshot.

With the second label **`Auto Install Pre-Release in React Remote`**, a follow-up job clones TIX-REACT-REMOTE, checks out its `prerelease` branch, and runs `scripts/ci/update-passport-in-remote.js <version>`. That script sets **every** `@tiket/passport*` dependency to the snapshot version, then the job runs `npm install`, commits "chore: update passport prerelease …", runs `npm version prerelease`, and pushes with tags. See [[react-remote-workflows]].

Downstream repos sometimes stay pinned to a snapshot. TIX-REACT-COMMON's `react-common-remote`, `react-common-error-handler` and `react-common-utilities` depend on `0.0.0-alpha-3045-…` builds on the baseline.

## Release
1. Merge to `main`. `release.yml` runs `changesets/action`, which opens or updates the **"Version Packages"** PR from branch `changeset-release/main`. It authenticates with a GitHub App token (`APP_ID`, `APP_PRIVATE_KEY`).
2. Merging that PR runs the action again, and it publishes with `npm run release` (`npm run build && changeset publish`).
3. Cadence is high: `main` alternates feature PRs with "Version Packages (#NNNN)" commits, and there were 58 commits since 2026-09-01.

## Branches
`main` is the baseline and the only CI target. `origin/develop` exists but no workflow targets it. Feature branches are `feat/…`, `fix/…`, `chore/…`. The `backup/*prerelease*` branches are old scratch branches.

## Sources
- `.github/workflows/{ci,chromatic,prerelease,release}.yml`
- `.husky/{pre-commit,commit-msg,pre-push}`, `.lintstagedrc`, `.commitlintrc`
- `.changeset/config.json`, `docs/publishing.md`, `docs/dependency-management.md`, `docs/testing.md`, `CONTRIBUTING.md`
- `scripts/ci/snapshots.js`, `scripts/ci/update-passport-in-remote.js`
- TIX-REACT-COMMON `packages/react-common-remote/package.json` (14597c4e)
