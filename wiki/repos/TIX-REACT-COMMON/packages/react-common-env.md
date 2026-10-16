---
title: react-common-env
repo: TIX-REACT-COMMON
kind: package
npm: "@tiket/react-common-env"
sources:
  - packages/react-common-env/src
  - packages/react-common-env/package.json
verified_at: 14597c4e
updated: 2026-10-16
status: current
tags: [repo/react-common, kind/package]
---

# react-common-env
> `getEnvironment()`: tells which tiket environment the browser is on from `location.origin`.

## What it does
Returns one of `'production' | 'staging' | 'preprod' | 'development' | 'local'`. On the client it caches the answer in `window.process.NODE_ENV` and returns that cached value on later calls. Host mapping: `pegasus.tiket` → development, `preprod.tiket` → preprod, `gatotkaca.tiket` → staging, `local.tiket.com` / `dev.tiket.com` → local, anything else → production. See [[tiket-environments]].

## Public API
- `getEnvironment(): Env`
- types `Env`, `ExtendedWindow`

## Usage
```ts
import { getEnvironment } from '@tiket/react-common-env';
const debug = getEnvironment() !== 'production';
```

## Depends on
Nothing.

## Used by
- Internal: [[react-common-ab-test]], [[react-common-analytic]], [[react-common-core-attributes]], [[react-common-push-notif]], [[react-common-storage]].
- No direct import in the other workspace repos on baseline.

## Gotchas
- **Server side always returns `'staging'`**, even in production. Don't use it in SSR; [[react-common-ab-test]] uses `NEXT_PUBLIC_AB_TEST_ENV` on the server for this reason.
- If something already set `window.process.NODE_ENV` (e.g. a bundler shim setting `'development'`), that value wins over the domain.
- Unknown hosts (preview URLs, localhost) are treated as production.

## Sources
- packages/react-common-env/src/getEnvironment.ts, package.json
