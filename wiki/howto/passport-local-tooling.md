---
title: TIX-PASSPORT local tooling (pnpm 10 + repo bun)
repo: TIX-PASSPORT
kind: howto
sources:
  - package.json
  - pnpm-workspace.yaml
  - bunfig.toml
  - scripts/scaffolds/createUIComponentPackage.mjs
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/howto]
---

# TIX-PASSPORT local tooling

> The global pnpm and bun on this machine silently break installs and tests. Use the versions pinned for the repo.

## Install
`npx pnpm@10 install`. CI uses pnpm 10. The machine's global pnpm 9.15 ignores `overrides` in `pnpm-workspace.yaml`, rewrites `pnpm-lock.yaml`, and downgrades happy-dom and msw.

## Test
`./node_modules/.bin/bun test`. The repo pins bun `1.3.6` as a devDependency. The global bun 1.2.5 fails every spec with `Export named 'HTTPParser' not found in module 'http'`.

## tsconfig gotcha
Bun resolves the `@/` alias from the **nearest** `tsconfig.json`. A package-level `tsconfig.json` therefore breaks `@/test-utils` imports. Give package-specific configs a different name, for example `tsconfig.consumer.json`.

## Scripts that call pnpm themselves
`package.json` has no `packageManager` field, only a Volta pin for Node 24.14.1, so nothing forces pnpm 10. `npm run create:component` (`scripts/scaffolds/createUIComponentPackage.mjs`) runs `pnpm add` and `pnpm i` with whatever `pnpm` is on `PATH`, which is the global 9.15. Put pnpm 10 first on `PATH` before you scaffold, or run `npx pnpm@10 install` afterwards and check the `pnpm-lock.yaml` diff ([[add-new-passport-package]]).

## HTTPS Storybook
`npm run dev:https` needs `local.tiket.com.pem` and `local.tiket.com-key.pem` in the repo root ([[local-https-certs]]).

Related: [[passport-workflows]], [[run-tests-per-repo]], [[page-module-next-poc]]

## Sources
- `package.json` (devDependencies.bun, `volta`, `create:component`, `dev:https`)
- `pnpm-workspace.yaml` (overrides)
- `scripts/scaffolds/createUIComponentPackage.mjs`
- Migrated from Claude memory `passport-tooling-versions` (2026-10-14)
