---
title: Changesets and fixed versioning
kind: concept
repos: [TIX-PASSPORT, TIX-REACT-COMMON, TIX-NEXT-PAYMENT-FE, TIX-FINTECH-NEXT-FE, TIX-REACT-REMOTE]
sources:
  - TIX-PASSPORT/.changeset/config.json
  - TIX-PASSPORT/.github/workflows/release.yml
  - TIX-REACT-COMMON/.changeset/config.json
  - TIX-NEXT-PAYMENT-FE/.changeset/config.json
  - TIX-NEXT-PAYMENT-FE/.github/workflows/release.yml
  - TIX-FINTECH-NEXT-FE/.changeset/config.json
  - TIX-FINTECH-NEXT-FE/.changeset/changelog.cjs
  - TIX-REACT-REMOTE/package.json
verified_at:
  TIX-PASSPORT: 7a33010aca
  TIX-REACT-COMMON: 14597c4e
  TIX-NEXT-PAYMENT-FE: 9e92b20bb
  TIX-FINTECH-NEXT-FE: 5833b842
  TIX-REACT-REMOTE: 281778b
updated: 2026-10-16
status: current
tags: [kind/concept, repo/passport, repo/react-common, repo/payment-fe, repo/fintech-fe, repo/react-remote]
---

# Changesets and fixed versioning
> Four of the six repos version with changesets, and they use it three different ways. Only Passport uses a `fixed` group, so every `@tiket/passport*` package always has the same version.

## Per repo
| Repo | `fixed` | Publishes to npm | Release PR title | What merging the release PR does |
|---|---|---|---|---|
| TIX-PASSPORT | `[["@tiket/passport*"]]` | yes, GitHub Packages, about 130 packages | "Version Packages" | `npm run release` = `build && changeset publish` |
| TIX-REACT-COMMON | `[]` (independent) | yes, GitHub Packages, about 18 packages | "chore: release packages" | `pnpm build && changeset publish`, then hard-reset `prerelease` to `master` |
| TIX-NEXT-PAYMENT-FE | `[]`, one private app | no | "Version Packages" | `changeset publish && changeset tag` creates the `vX.Y.Z` tag that Jenkins deploys |
| TIX-FINTECH-NEXT-FE | `[]`, one private app | no | "Version Packages" | same as payment-fe. A custom `.changeset/changelog.cjs` adds Jira links |
| TIX-REACT-REMOTE | no changesets | no | — | `npm version` in the PR |
| TIX-GTM-EXTRAS | no changesets | no | — | `npm version` on a `release` branch |

All four changesets repos run `changesets/action` on push to the base branch, use `updateInternalDependencies: patch` and `access: restricted`, and authenticate with a GitHub App token. Jenkins in payment-fe and fintech-fe skips PRs titled `Version Packages`.

## What `fixed` means for Passport
- Any release bumps **every** Passport package to the same version, including packages with no changes (12.8.1 at `7a33010aca`). Most "Version Packages" commits touch about 130 `package.json` and `CHANGELOG.md` files.
- Consumers can pin one version for everything. TIX-REACT-REMOTE pins all nine `@tiket/passport*` deps to exactly `12.4.2`, and its history is mostly `chore: bump @tiket/passport to X` commits. TIX-FINTECH-NEXT-FE uses `^12.4.3` everywhere and TIX-NEXT-PAYMENT-FE uses `^8.11.1`.
- A mixed install, for example the umbrella [[passport-umbrella]] at one version and a sub-package at another, creates nested `node_modules` copies. That is the source of the "Global CSS cannot be imported from within node_modules" error in Next ([[passport-overview]]).
- Any package that is not `private` is published by the next release, even an experiment. That is why the [[page-module-next-poc]] branch must never reach `main`.
- `onlyUpdatePeerDependentsWhenOutOfRange: true` avoids peer-dependency cascades, which matter less when all versions move together.

## What independent versioning means for react-common
Each package versions alone. A dependent gets a patch bump when a dependency changes. Consumers mix versions freely: react-remote pins exact versions (analytic 5.0.6, fetch-client 3.2.0), while the apps use caret ranges.

## Prereleases
Snapshot and tag prereleases sit on top of this. See [[prerelease-flow]].

## Where it shows up
Pages that link here:
- TIX-FINTECH-NEXT-FE: [[fintech-fe-workflows]]
- TIX-NEXT-PAYMENT-FE: [[payment-fe-workflows]]
- TIX-PASSPORT: [[passport-overview]], [[passport-packages]], [[passport-umbrella]], [[passport-workflows]]
- TIX-REACT-COMMON: [[react-common-overview]], [[react-common-workflows]]
- TIX-REACT-REMOTE: [[react-remote-overview]]
- concepts: [[module-federation]]
- decisions: [[page-module-next-poc]]
- howto: [[add-new-passport-package]], [[release-passport-package]]

## Sources
- TIX-PASSPORT `.changeset/config.json`, `.github/workflows/release.yml`, `package.json` (`release`)
- TIX-REACT-COMMON `.changeset/config.json`, `.github/workflows/release.yml`
- TIX-NEXT-PAYMENT-FE and TIX-FINTECH-NEXT-FE `.changeset/config.json`, `.github/workflows/release.yml`, `Jenkinsfile.dev`; fintech `.changeset/changelog.cjs`
- TIX-REACT-REMOTE `package.json` and `git log origin/main`
- TIX-GTM-EXTRAS `README.md`
