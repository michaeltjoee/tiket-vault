---
title: react-common-gatekeeper
repo: TIX-REACT-COMMON
kind: package
npm: "@tiket/react-common-gatekeeper"
sources:
  - packages/react-common-gatekeeper/src
  - packages/react-common-gatekeeper/package.json
  - packages/react-common-gatekeeper/README.md
  - packages/react-common-gatekeeper/docker
verified_at: 14597c4e
updated: 2026-10-16
status: current
tags: [repo/react-common, kind/package]
---

# react-common-gatekeeper
> `tix-gatekeeper` Node CLI that runs a repo's Test, Build and Sonar Quality Gate stages in Jenkins and reports each as a GitHub check run on the commit.

## What it does
`tix-gatekeeper -s prepare` marks every stage as a queued GitHub check. `tix-gatekeeper` (default `-s scan`) then runs each stage, collects stdout as the check description, and posts the conclusion. The stages are defined in `src/config.ts`: `npm run test`, `npm run build`, and a SonarQube scan through `sonarqube-scanner` 4.7.0.2747, whose conclusion comes from the Sonar quality gate status. Stages run only when `CHANGE_BRANCH` is a primary branch (`master|main|develop`) or `CHANGE_TARGET` is one. Sonar runs a **branch** analysis when the source branch is primary, otherwise a **PR** analysis. GitHub auth uses a GitHub App (`GITHUB_APP_ID`, `GITHUB_APP_INSTALLATION_ID`, `GITHUB_APP_PRIVATE_KEY`, PEM or base64). See [[gatekeeper-ci]].

## Public API (CLI)
| Command | Does |
|---|---|
| `tix-gatekeeper -s prepare` | set all stages to queued |
| `tix-gatekeeper [-s scan]` | run stages and report |
| `tix-gatekeeper sonar branch -b <branch>` | standalone branch scan |
| `tix-gatekeeper sonar pr -b <src> -n <pr#> -t <target>` | standalone PR scan |

Inputs: `sonar-project.properties` in `cwd` (`sonar.host.url`, `sonar.login`, `sonar.projectKey`), plus Jenkins env `CHANGE_BRANCH`, `CHANGE_TARGET`, `CHANGE_ID`, `BUILD_URL`. Per-project `sources`/`exclusions` live in `src/sonar/projects/<projectKey>.ts` (32 FE repos, including `tix-next-payment-fe`, `tix-fintech-next-fe`, `tix-react-remote`, `tix-react-common`).

## Usage
```sh
# TIX-REACT-COMMON Jenkinsfile.dev
npm install -g @tiket/react-common-gatekeeper@latest
tix-gatekeeper -s prepare
pnpm install --no-frozen-lockfile
tix-gatekeeper
```

## Depends on
`@octokit/auth-app`, `commander`, `sonarqube-scanner`, `node-fetch` 3 (kept external in the esbuild CJS bundle), `markdown-table`, `color-support`. No internal deps. Docker images for Sonar 8/9 are in `docker/`.

## Used by
Not imported as a library. It is installed globally in `Jenkinsfile.dev`: TIX-REACT-COMMON (`npm i -g …@latest`), [[react-remote-workflows|TIX-REACT-REMOTE]] (`pnpm add -g …@latest`), and [[payment-fe-workflows|TIX-NEXT-PAYMENT-FE]] and [[fintech-fe-workflows|TIX-FINTECH-NEXT-FE]], both **pinned to `3.0.1`** while the current version is 4.0.4. Payment-fe also mentions it in `.github/workflows/prerelease.yml`. TIX-PASSPORT and TIX-GTM-EXTRAS don't use it.

## Gotchas
- TIX-REACT-COMMON and TIX-REACT-REMOTE install **`@latest`**, so a gatekeeper release changes their CI at once. This repo's own PRs run the last published gatekeeper, not the PR's code. Payment-fe and fintech-fe stay on 3.0.1 until someone bumps them.
- Stages run `npm run test`/`npm run build` (not pnpm). The repo's `test`/`build` scripts must work through npm.
- A project key missing from `src/sonar/projects/index.ts` gets empty `sources`/`exclusions`, which overrides what `sonar-project.properties` says. Add new repos there.
- `getConfig` splits each properties line on `=` and keeps only the second part, so a value that contains `=` is truncated.
- In `sonar pr`, `sonar.pullrequest.base` is set to the **source** branch (`options.branch`), not `--target`. The `scan` stage sets it correctly from `CHANGE_TARGET`.
- README: branch analysis does not run on merge. To refresh the main branch's Sonar status, open a PR from main to the release branch.

## Sources
- packages/react-common-gatekeeper/src/{index,config}.ts, src/pipeline/*, src/sonar/{getConfig,getProjectConfig}.ts, src/sonar/projects/*, src/github/updateStatus.ts
- packages/react-common-gatekeeper/README.md, package.json, docker/*
- Jenkinsfile.dev (this repo and consumers)
