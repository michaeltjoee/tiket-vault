---
title: Gatekeeper CI (tix-gatekeeper on Jenkins)
kind: concept
repos: [TIX-REACT-COMMON, TIX-REACT-REMOTE, TIX-NEXT-PAYMENT-FE, TIX-FINTECH-NEXT-FE, TIX-HOMEPAGE-NEXT-FE, TIX-GROWTH-NEXT-FE]
sources:
  - TIX-REACT-COMMON/packages/react-common-gatekeeper
  - TIX-REACT-COMMON/Jenkinsfile.dev
  - TIX-REACT-REMOTE/Jenkinsfile.dev
  - TIX-NEXT-PAYMENT-FE/Jenkinsfile.dev
  - TIX-FINTECH-NEXT-FE/Jenkinsfile.dev
  - TIX-HOMEPAGE-NEXT-FE/Jenkinsfile.dev
  - TIX-GROWTH-NEXT-FE/Jenkinsfile.dev
verified_at:
  TIX-REACT-COMMON: 14597c4e
  TIX-REACT-REMOTE: 281778b
  TIX-NEXT-PAYMENT-FE: 9e92b20bb
  TIX-FINTECH-NEXT-FE: 5833b842
  TIX-HOMEPAGE-NEXT-FE: 408983f6
  TIX-GROWTH-NEXT-FE: d4162e3
updated: 2026-10-16
status: current
tags: [kind/concept, repo/react-common, repo/react-remote, repo/payment-fe, repo/fintech-fe, repo/homepage-fe, repo/growth-fe]
---

# Gatekeeper CI
> The PR merge gate for the app repos is Jenkins running `tix-gatekeeper` from [[react-common-gatekeeper]]. It runs test, build and SonarQube stages and reports each one as a GitHub check through a GitHub App. TIX-PASSPORT and TIX-GTM-EXTRAS don't use it.

## Per repo
| Repo | Gatekeeper version in `Jenkinsfile.dev` | Sonar project |
|---|---|---|
| TIX-REACT-COMMON | `@latest` | `tix-react-common` |
| TIX-REACT-REMOTE | `@latest` | `tix-react-remote` |
| TIX-NEXT-PAYMENT-FE | `3.0.1` | `tix-next-payment-fe` |
| TIX-FINTECH-NEXT-FE | `3.0.1` | `tix-fintech-next-fe` |
| TIX-HOMEPAGE-NEXT-FE | `3.0.1` | `tix-homepage-next-fe` |
| TIX-GROWTH-NEXT-FE | `3.0.1` | `tix-growth-next-fe` |

The latest published version is 4.0.4. TIX-PASSPORT gates on GitHub Actions (`ci.yml`: tests plus `check-all`) and has no Sonar. TIX-GTM-EXTRAS has no CI at all ([[passport-workflows]], [[gtm-extras-workflows]]).

## How it runs
1. `tix-gatekeeper -s prepare` marks every stage as a queued check.
2. `tix-gatekeeper` runs `npm run test`, `npm run build` and a Sonar scan, then posts each conclusion. Sonar's conclusion is the quality gate.
3. Stages run only when the source or target branch is `master`, `main` or `develop`. A PR from a primary branch gets a branch analysis, other PRs a PR analysis (new code only).

## Where coverage is enforced
Sonar `sources` and `exclusions` for every repo are hard-coded in TIX-REACT-COMMON `packages/react-common-gatekeeper/src/sonar/projects/<key>.ts` (32 repos). They override the repo's own `sonar-project.properties`. Changing exclusions in an app alone does not change what Gatekeeper measures. For example payment-fe's entry also excludes `lib/types/**` ([[payment-fe-workflows]]). Per-repo thresholds are in [[run-tests-per-repo]].

## Gotchas
- `@latest` means a gatekeeper release changes CI for react-common and react-remote at once, and react-common's own PRs run the last published gatekeeper, not the PR's code.
- Stages call `npm run`, so a repo's `test` and `build` scripts must work under npm.
- A project key missing from `src/sonar/projects/index.ts` gets empty `sources`/`exclusions`.
- `sonar-project.properties` in react-common and react-remote contains a committed Sonar login token.
- Jenkins skips PRs titled `Version Packages` in payment-fe, fintech-fe, homepage-fe and growth-fe.
- `sonar-project.properties` in homepage-fe and growth-fe also contains a committed `sonar.login` token ([[growth-fe-workflows]]).

## Where it shows up
Pages that link here:
- TIX-GROWTH-NEXT-FE: [[growth-fe-overview]], [[growth-fe-workflows]]
- TIX-HOMEPAGE-NEXT-FE: [[homepage-fe-overview]], [[homepage-fe-workflows]]
- TIX-REACT-COMMON: [[react-common-gatekeeper]]
- howto: [[run-tests-per-repo]]

## Sources
- TIX-REACT-COMMON `packages/react-common-gatekeeper/{README.md,package.json,src/config.ts,src/sonar/projects/}`
- `Jenkinsfile.dev` in TIX-REACT-COMMON, TIX-REACT-REMOTE, TIX-NEXT-PAYMENT-FE, TIX-FINTECH-NEXT-FE, TIX-HOMEPAGE-NEXT-FE and TIX-GROWTH-NEXT-FE
- TIX-HOMEPAGE-NEXT-FE and TIX-GROWTH-NEXT-FE `sonar-project.properties`
- TIX-PASSPORT `.github/workflows/ci.yml`
