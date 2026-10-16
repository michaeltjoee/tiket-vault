---
title: Prerelease flow
kind: concept
repos: [TIX-PASSPORT, TIX-REACT-COMMON, TIX-REACT-REMOTE, TIX-NEXT-PAYMENT-FE, TIX-FINTECH-NEXT-FE, TIX-GTM-EXTRAS]
sources:
  - TIX-PASSPORT/.github/workflows/prerelease.yml
  - TIX-PASSPORT/scripts/ci
  - TIX-PASSPORT/docs/publishing.md
  - TIX-REACT-COMMON/.github/workflows/prerelease.yml
  - TIX-REACT-COMMON/.github/workflows/pr_closed.yml
  - TIX-NEXT-PAYMENT-FE/.github/workflows/prerelease.yml
  - TIX-NEXT-PAYMENT-FE/README.md
  - TIX-FINTECH-NEXT-FE/.github/workflows/prerelease.yml
  - TIX-REACT-REMOTE/package.json
verified_at:
  TIX-PASSPORT: 7a33010aca
  TIX-REACT-COMMON: 14597c4e
  TIX-REACT-REMOTE: 281778b
  TIX-NEXT-PAYMENT-FE: 9e92b20bb
  TIX-FINTECH-NEXT-FE: 5833b842
  TIX-GTM-EXTRAS: 98478af
updated: 2026-10-16
status: current
tags: [kind/concept, repo/passport, repo/react-common, repo/react-remote, repo/payment-fe, repo/fintech-fe, repo/gtm-extras]
---

# Prerelease flow
> "Prerelease" means two different things in this workspace. Libraries publish **npm snapshot versions** from a PR. Apps push a **prerelease git tag** that Jenkins deploys to staging. Most apps also keep a long-lived `prerelease` branch.

## Libraries: npm snapshots
| | TIX-PASSPORT | TIX-REACT-COMMON |
|---|---|---|
| Trigger | PR label **`Automate Pre-Release`** | every PR push, if `.changeset/` holds more than the 2 default files |
| Version | `0.0.0-alpha-<PR#>-<YYYYMMDDHHMMSS>` | `0.0.0-alpha-<PR#>-<timestamp>` |
| dist-tag | `alpha-<PR#>` | `alpha` |
| Feedback | bot comment with a version table (`scripts/ci/snapshots.js`), replaced on every push | same script name, same comment pattern |
| Cleanup | none | `pr_closed.yml` deletes every `0.0.0-alpha-<PR#>` version from GitHub Packages |
| Extra | label **`Auto Install Pre-Release in React Remote`** pushes the snapshot to TIX-REACT-REMOTE's `prerelease` branch | release hard-resets the `prerelease` branch to `master` |

Only packages with changesets, plus their dependents, get a snapshot. Because Passport snapshots are not `fixed`, install the exact versions from the comment table. Snapshots can leak into baselines: TIX-REACT-COMMON's react-common-remote, error-handler and utilities depend on a `0.0.0-alpha-3045-…` Passport build ([[passport-workflows]]).

## Apps: prerelease tags
TIX-NEXT-PAYMENT-FE and TIX-FINTECH-NEXT-FE share the same `prerelease.yml`:
- It runs on `pull_request` (opened, synchronize, reopened, labeled) when the PR has the label **`Automate Pre-Release`**, or on `workflow_dispatch`.
- `anothrNick/github-tag-action` pushes `vX.Y.Z-<suffix>.N`. The bump is patch, or minor if a commit contains `feat:`. The suffix is `alpha`, `beta` with label `Automate Beta Version`, or `rc` with label `Automate RC Version`.
- A comment marked `<!-- Prerelease Version -->` reports the tag. Jenkins deploys the tag to staging.

TIX-REACT-REMOTE has no workflow. Its prerelease versions (`v2.0.29-0` … `-2`) come from `npm version prerelease`, run by hand or by Passport's auto-install job. TIX-GTM-EXTRAS uses a `release` branch and `npm version` (see [[gtm-extras-workflows]]).

## The `prerelease` branch
payment-fe, fintech-fe and react-remote keep a long-lived `origin/prerelease` that runs ahead of `main` (15, 3 and 42 commits on 2026-10-16). Work is squashed onto it one commit per PR, and a `prerelease` → `main` PR collects it. A labelled `prerelease` → `main` PR gets a new tag on every push. payment-fe's README still describes this as "push to `origin/prerelease` → automatic tag → trigger Jenkins". The procedure is in [[prerelease-squash-merge]].

TIX-PASSPORT has no `prerelease` branch, only old `backup/*prerelease*` branches. In TIX-REACT-COMMON the branch is reset after each release, so nothing should live only there.

## Where it shows up
Pages that link here:
- TIX-FINTECH-NEXT-FE: [[fintech-fe-workflows]]
- TIX-NEXT-PAYMENT-FE: [[payment-fe-workflows]]
- TIX-PASSPORT: [[passport-page-module-shared]], [[passport-workflows]]
- TIX-REACT-COMMON: [[react-common-workflows]]
- TIX-REACT-REMOTE: [[react-remote-workflows]]
- concepts: [[changesets-fixed-versioning]], [[module-federation]]
- howto: [[prerelease-squash-merge]], [[release-passport-package]]

## Sources
- TIX-PASSPORT `.github/workflows/prerelease.yml`, `scripts/ci/snapshots.js`, `scripts/ci/update-passport-in-remote.js`, `docs/publishing.md`
- TIX-REACT-COMMON `.github/workflows/{prerelease,release,pr_closed}.yml`, `scripts/ci/delete-prerelease.ts`
- TIX-NEXT-PAYMENT-FE and TIX-FINTECH-NEXT-FE `.github/workflows/prerelease.yml`; payment-fe `README.md` (Deployment)
- TIX-REACT-REMOTE git tags and `git log origin/main..origin/prerelease`
- TIX-GTM-EXTRAS `README.md`
