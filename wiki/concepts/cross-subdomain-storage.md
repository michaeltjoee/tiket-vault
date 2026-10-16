---
title: Cross-subdomain storage
kind: concept
repos: [TIX-REACT-COMMON, TIX-NEXT-PAYMENT-FE, TIX-FINTECH-NEXT-FE]
sources:
  - TIX-REACT-COMMON/packages/react-common-storage
  - TIX-REACT-COMMON/packages/react-common-core-attributes/src/constants.ts
  - TIX-NEXT-PAYMENT-FE/lib/helpers/unm.ts
  - TIX-FINTECH-NEXT-FE/projects/refund/shared/lib/helpers/unm.ts
verified_at:
  TIX-REACT-COMMON: 14597c4e
  TIX-NEXT-PAYMENT-FE: 9e92b20bb
  TIX-FINTECH-NEXT-FE: 5833b842
updated: 2026-10-16
status: current
tags: [kind/concept, repo/react-common, repo/payment-fe, repo/fintech-fe]
---

# Cross-subdomain storage
> tiket apps live on many hosts (`www`, `payment-*`, `m.`…), and each host has its own `localStorage`. [[react-common-storage]] gives them one shared key-value store through a hidden iframe on `storage[.<env>].tiket.com`, with a cookie fallback where browsers partition iframe storage.

## How it works
- First use appends `#tiket-com-localstorage-iframe` pointing at `storage[.<env>].tiket.com/storage/index.html?version=2.0`. The environment comes from [[tiket-environments]].
- After the iframe posts `tiketStorageIframeReady`, `get`/`set` travel as `GET_LOCALSTORAGE`/`SET_LOCALSTORAGE` messages. Values are JSON, and a `get` waits for pending `set`s of the same key.
- On Safari, or when the `device_type` cookie is `ios`, it uses a `shared_storage_<key>` cookie on `.tiket.com` (1-year expiry) instead, because ITP partitions iframe storage.

## Known keys
| Key | Writer | Readers |
|---|---|---|
| `tiket-com-analytic` | [[react-common-core-attributes]] | TIX-NEXT-PAYMENT-FE `lib/helpers/unm.ts`, TIX-FINTECH-NEXT-FE `projects/refund/shared/lib/helpers/unm.ts` (device id for UNM/fraud headers). See [[analytics-core-attributes]]. |

## Gotchas
- Client only. On the server `getSource()` returns `''` and `new URL('')` throws.
- `get` and `set` time out after 2 s and only `console.log` the failure. A miss and a failure both come back as `null`.
- Safari/iOS and other browsers use different stores, so a value written in one is not visible in the other. The cookie variant also adds the value to every request header on `.tiket.com`.
- Preprod uses the production iframe, and `local` falls back to the staging iframe. `window.process.LOCAL_STORAGE` overrides the iframe URL for local development.

## Where it shows up
Pages that link here:
- TIX-REACT-COMMON: [[react-common-storage]]
- concepts: [[analytics-core-attributes]], [[tiket-environments]]

## Sources
- TIX-REACT-COMMON `packages/react-common-storage/{src,source/index.html}`, `packages/react-common-core-attributes/src/constants.ts`
- TIX-NEXT-PAYMENT-FE `lib/helpers/unm.ts`; TIX-FINTECH-NEXT-FE `projects/refund/shared/lib/helpers/unm.ts`
