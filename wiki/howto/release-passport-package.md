---
title: Release a Passport package
repo: TIX-PASSPORT
kind: howto
sources:
  - .changeset/config.json
  - .github/workflows/ci.yml
  - .github/workflows/prerelease.yml
  - .github/workflows/release.yml
  - docs/publishing.md
  - package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/howto]
---

# Release a Passport package
> Merge a PR with a changeset to `main`, then merge the "Version Packages" PR that changesets opens. Every `@tiket/passport*` package is published at the same new version. Then bump the consumers.

## Before you start
- Install and test with pnpm 10 and the repo's bun ([[passport-local-tooling]]).
- Release cadence is high, and `main` alternates feature PRs with "Version Packages (#NNNN)" commits. Rebase on `origin/main` before you open the PR.

## Steps
1. **Branch** from `main`: `feat/PLAT-123-…`, `fix/…` or `chore/…`. Commits must pass commitlint (`feat(PLAT-123): …`).
2. **Change the code** and add or update specs (`packages/<pkg>/src/**/__tests__/*.spec.tsx`, `@/test-utils`; see [[run-tests-per-repo]]).
3. **Add a changeset:** `npx changeset`, select the package(s) and the bump type, and write a summary. It becomes the CHANGELOG entry. Because of the `fixed` group, the bump type applies to **every** package's version ([[changesets-fixed-versioning]]).
4. **Push.** The `pre-push` hook runs `npm test && npm run check-all` (full suite plus tsc, eslint and stylelint), so expect a slow push.
5. **Open a PR to `main`.** `ci.yml` runs the same checks, Chromatic publishes Storybook, and changeset-bot flags a missing changeset.
6. **Optional, test in a consumer:** add the label `Automate Pre-Release`. The bot comments `0.0.0-alpha-<PR#>-<timestamp>` versions under dist-tag `alpha-<PR#>`, and a new one appears on every push. Add `Auto Install Pre-Release in React Remote` to push the snapshot to TIX-REACT-REMOTE's `prerelease` branch. See [[prerelease-flow]].
7. **Merge** after review. `release.yml` (`changesets/action`) opens or updates the **"Version Packages"** PR from `changeset-release/main`.
8. **Merge "Version Packages".** The workflow runs again and publishes with `npm run release` (`npm run build && changeset publish`) to `npm.pkg.github.com`.

## After the release
- **TIX-REACT-REMOTE** pins every `@tiket/passport*` dep to one exact version. Bump all of them together, run `pnpm install`, and bump the service version with `npm version` ([[react-remote-workflows]]). Header, footer and other remote widgets on every app only change after this deploy ([[module-federation]]).
- **TIX-FINTECH-NEXT-FE** (`^12.x`) and **TIX-NEXT-PAYMENT-FE** (`^8.11.1`, four majors behind) take a minor or patch on the next install. A major needs an explicit bump. payment-fe's unit tests mock `@tiket/passport`, so a new export may also need the mock updated ([[payment-fe-workflows]]).

## Gotchas
- Every package that isn't `private` is published by any release, even an experiment. Keep experimental packages off `main` ([[page-module-next-poc]]).
- The install token in CI is a personal secret (`RYANDI_GITHUB_TOKEN_DELETE_SOON`, issue #738). If installs start failing with 401 in CI, check that first.
- Snapshot versions don't follow the fixed group. Install exactly the versions in the bot's table.

## Sources
- `.changeset/config.json`, `.github/workflows/{ci,chromatic,prerelease,release}.yml`, `docs/publishing.md`, `package.json` (`release`), `.husky/pre-push`
- [[passport-workflows]]
