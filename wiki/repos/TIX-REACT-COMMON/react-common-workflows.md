---
title: TIX-REACT-COMMON workflows
repo: TIX-REACT-COMMON
kind: workflows
sources:
  - CONTRIBUTING.md
  - package.json
  - .changeset/config.json
  - .github/workflows
  - .github/pull_request_template.md
  - Jenkinsfile.dev
  - .husky
  - .commitlintrc
  - .lintstagedrc
  - .npmrc
  - scripts/ci
  - sonar-project.properties
  - .cursor
verified_at: 14597c4e
updated: 2026-10-16
status: current
tags: [repo/react-common, kind/workflows]
---

# TIX-REACT-COMMON workflows
> Feature branch → PR to `master` with a changeset → alpha snapshot on every PR push → "chore: release packages" PR → publish on merge.

## Branching
- Default/base branch is **`master`** (`.changeset/config.json` `baseBranch`, release workflow trigger). There is also a `prerelease` branch that the release workflow **hard-resets** to master after every successful publish, so nothing should live only there. Compare [[prerelease-flow]].
- PR titles must be semantic (`amannn/action-semantic-pull-request`); commits are checked by commitlint (`@commitlint/config-conventional`) in the husky `commit-msg` hook. `pre-commit` runs lint-staged (eslint --fix, prettier).
- PRs idle 180 days get marked stale and closed 15 days later (`removeStalePr.yml`, Mondays 12:30).

## Local dev
1. Node 24.14.1, `corepack enable` (pnpm 10.28.2 from `packageManager`). See [[passport-local-tooling]].
2. `.npmrc` reads `${GITHUB_TOKEN}` for `@tiket` on GitHub Packages and `${NPM_TOKEN}` for npmjs; export both before `pnpm install`.
3. Verdaccio is expected for publishing locally to test a package in a consumer app (CONTRIBUTING.md).
4. `pnpm test` = root Jest projects (see [[react-common-architecture]]) + each package's own `test` script (empty for most; `fetch` runs its own Jest).

## Release ([[changesets-fixed-versioning|changesets]], independent versions)
1. `pnpm exec changeset` in the PR. `fixed` and `linked` are empty, so each package versions alone; dependents get a patch bump.
2. **Pre-release** (`prerelease.yml`, on every `pull_request` and manual dispatch): if `.changeset/` holds more than the 2 default files, runs `changeset version --snapshot alpha-<PR#>`, `pnpm build`, `changeset publish --tag alpha`, then `scripts/ci/snapshots.js` builds a version table from modified package.json files and posts it as a PR comment. Versions look like `0.0.0-alpha-<PR#>-<timestamp>`.
3. **Cleanup** (`pr_closed.yml`): on PR close, `scripts/ci/delete-prerelease.ts <PR#>` deletes every `0.0.0-alpha-<PR#>` version of every package from the GitHub Packages org API.
4. **Release** (`release.yml`, push to master): `changesets/action` opens or updates the "chore: release packages" PR; merging it runs `pnpm run publish` (`pnpm build && changeset publish`) using a GitHub App token, then resets `prerelease`. The old "delete older versions" job is commented out.

## CI on Jenkins (`Jenkinsfile.dev`)
Runs in a Node 24 alpine pod (8 CPU / 55Gi). It installs `@tiket/react-common-gatekeeper@latest` globally from GitHub Packages and runs `tix-gatekeeper -s prepare` then `tix-gatekeeper` with GitHub App credentials. So the gatekeeper used in this repo's own CI is the **latest published** version, not the one in the PR. See [[react-common-gatekeeper]].
- Sonar project key `tix-react-common` (`sonar-project.properties`). It excludes many files from coverage (openapi, push-notif, script, most of remote's Remote* components, analytic internals). The file also contains a committed Sonar login token.

## Agent docs in repo
`.cursor/skills/contribute-ab-test/` and `.cursor/skills/contribute-analytic/` (SKILL.md + reference.md) describe how to add AB tests and analytic events; `.cursor/agents/` has analytics-debugger, analytics-perf-guardian and mixpanel-sdk-upgrader prompts. Read them in place.

## Sources
- .changeset/config.json, .github/workflows/{prerelease,release,pr_closed,pr_lint,removeStalePr}.yml
- scripts/ci/snapshots.js, scripts/ci/delete-prerelease.ts
- Jenkinsfile.dev, sonar-project.properties
- .husky/*, .commitlintrc, .lintstagedrc, .npmrc, CONTRIBUTING.md
- .cursor/skills/*, .cursor/agents/*
