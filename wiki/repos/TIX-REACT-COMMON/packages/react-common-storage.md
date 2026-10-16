---
title: react-common-storage
repo: TIX-REACT-COMMON
kind: package
npm: "@tiket/react-common-storage"
sources:
  - packages/react-common-storage/src
  - packages/react-common-storage/source/index.html
  - packages/react-common-storage/package.json
verified_at: 14597c4e
updated: 2026-10-16
status: current
tags: [repo/react-common, kind/package]
---

# react-common-storage
> `get`/`set` for a key-value store shared across all `*.tiket.com` subdomains. It uses a hidden iframe's `localStorage`, with a cookie fallback on Safari/iOS.

## What it does
On first use it appends a hidden iframe (`#tiket-com-localstorage-iframe`) that points at `storage[.<env>].tiket.com/storage/index.html?version=2.0`; the page source is in `source/index.html`. It waits for the iframe's `'tiketStorageIframeReady'` message, then exchanges `GET_LOCALSTORAGE` / `SET_LOCALSTORAGE` `postMessage`s, checking the response origin. Values are JSON-encoded. `get` waits for pending `set`s of the same key (internal queue) before it reads. On Safari, or when the `device_type` cookie is `ios`, it reads and writes a `shared_storage_<key>` cookie on `.tiket.com` (1-year expiry) instead, to avoid ITP-partitioned iframe storage. See [[cross-subdomain-storage]].

## Public API
- `get(key: string): Promise<SharedStorageValue>` (`null` on miss/timeout)
- `set(key: string, value: SharedStorageValue): Promise<void>` (always resolves, even on failure)
- types `SharedStorageValue` (`string | Object | null | number`), `IncomingMessageEvent`

## Usage
```ts
// TIX-NEXT-PAYMENT-FE lib/helpers/unm.ts
import { get } from '@tiket/react-common-storage';
const tiketAnalytic = await get(TIKET_ANALYTIC_KEY); // 'tiket-com-analytic', written by core-attributes
```

## Depends on
[[react-common-env]] (selects the iframe host: development → `storage.pegasus`, staging → `storage.gatotkaca`, production and preprod → `storage.tiket.com`).

## Used by
- Internal: [[react-common-core-attributes]] (core attributes under `tiket-com-analytic`), [[react-common-analytic]] (bundled in).
- TIX-NEXT-PAYMENT-FE: `lib/helpers/unm.ts` and smart_pay page tests ([[payment-fe-components]]).
- TIX-FINTECH-NEXT-FE: `projects/refund/shared/lib/helpers/unm.ts`.

## Gotchas
- **Client only.** `getSource()` returns `''` on the server, and `new URL('')` throws.
- `get` and `set` time out after **2 s** (`RESPONSE_TIMEOUT`) and only `console.log` the failure: `get` resolves `null`, `set` resolves silently. Callers can't tell a miss from a failure.
- Safari/iOS and other browsers use **different stores** (cookie vs iframe localStorage), so a value written on one isn't visible on the other. Cookie storage also adds the value to every request header on `.tiket.com`.
- Preprod uses the **production** storage iframe (TODO in code). `window.process.LOCAL_STORAGE` overrides the iframe URL for local dev.
- Unknown environments, including `local`, fall back to the staging iframe.

## Sources
- packages/react-common-storage/src/{index,get,set,getIframe,getSource,utils,setCookie,constants,types}.ts
- packages/react-common-storage/source/index.html, package.json
