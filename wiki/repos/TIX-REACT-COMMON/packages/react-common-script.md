---
title: react-common-script
repo: TIX-REACT-COMMON
kind: package
npm: "@tiket-com/react-common-script"
sources:
  - packages/react-common-script/index.ts
  - packages/react-common-script/src
  - packages/react-common-script/package.json
  - packages/react-common-script/README.md
verified_at: 14597c4e
updated: 2026-10-16
status: current
tags: [repo/react-common, kind/package]
---

# react-common-script
> npx CLI that bumps a consumer repo's `@tiket/react-common-*` dependencies to the latest release of their current major. It is npm-only and has no users in this workspace.

## What it does
`npx --yes @tiket-com/react-common-script@latest --update`, run in a consumer repo, reads `package.json`, finds dependencies whose name contains `@tiket/react-common` (prerelease `0.0.0-*` versions are skipped with a warning), removes them from `package-lock.json`, and runs `npm install <pkg>@<major>` for each (major `0` → `@1`). `--test` widens the match to any name containing `react-common`, `--verbose` prints debug logs, `--help` lists the flags.

## Public API
CLI only. Flags: `--update`, `--test`, `--help`, `--verbose`. Bin name: `update-react-common`.

## Usage
```sh
npx --yes @tiket-com/react-common-script@latest --update --verbose
```

## Depends on
Node built-ins only (`fs`, `child_process`).

## Used by
No consumer in the six workspace repos. All of them use pnpm, which this script does not support.

## Gotchas
- Published under the **`@tiket-com`** scope to the **public npmjs registry** (`publishConfig.registry: https://registry.npmjs.org/`, `access: public`). It is the only package not on GitHub Packages, and it needs `NPM_TOKEN` at release.
- It hard-codes `npm install` and `package-lock.json`. In a pnpm repo it changes nothing useful.
- README notes for old Node/Docker: set `npm config set unsafe-perm true` on Node ≤ 13; `--yes` behaves differently on npm 15.
- Excluded from root Jest projects and from Sonar.

## Sources
- packages/react-common-script/index.ts, src/update.ts, src/utils/*
- packages/react-common-script/package.json, README.md
