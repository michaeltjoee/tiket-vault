---
title: Eagle Eye API logging (webview)
kind: concept
repos: [TIX-REACT-COMMON, TIX-REACT-REMOTE, TIX-FINTECH-NEXT-FE, TIX-NEXT-PAYMENT-FE]
sources:
  - TIX-REACT-COMMON/packages/react-common-eagle-eye/src
  - TIX-REACT-COMMON/packages/react-common-fetch-client/src
  - TIX-REACT-COMMON/packages/react-common-fetch/src
  - TIX-NEXT-PAYMENT-FE/package.json
  - TIX-FINTECH-NEXT-FE/package.json
verified_at:
  TIX-REACT-COMMON: 14597c4e
  TIX-REACT-REMOTE: 281778b
  TIX-FINTECH-NEXT-FE: 5833b842
  TIX-NEXT-PAYMENT-FE: 9e92b20bb
updated: 2026-10-16
status: current
tags: [kind/concept, repo/react-common, repo/react-remote, repo/fintech-fe, repo/payment-fe]
---

# Eagle Eye API logging
> When a tiket web page runs inside the native app, each API call's URL, method, status, timing and correlation id is reported to the app's logger (`logWebApi`), so app-side monitoring covers web screens. Outside a webview it does nothing.

## How it is wired
- [[react-common-eagle-eye]] `EagleEye({ url, method, headers, body, additionalLog, correlationId })` returns `{ start, onFetchSuccess(res), onFetchException(msg) }`.
- Transport, first match wins: Android `window.native.logWebApi`, iOS `webkit.messageHandlers.logWebApi`, then the generic JSI `logWebApi` from [[react-common-jsi]] ([[webview-jsi-bridge]]).
- It is built into [[react-common-fetch-client]] and the legacy [[react-common-fetch]], so apps get it by using those clients. TIX-REACT-REMOTE (reviews, `PassportWrapper`) and TIX-FINTECH-NEXT-FE (gift card) call react-common-fetch-client. Calls made through `@tiket/next` `fetchClient` ([[tiket-next-core]]) don't go through this package. Whether `@tiket/next` reports them some other way can't be checked, because its source is not in the workspace.
- TIX-NEXT-PAYMENT-FE and TIX-FINTECH-NEXT-FE declare `@tiket/react-common-eagle-eye` but import nothing from it directly.

## Gotchas
- "Webview" means the `device_type` cookie is `android` or `ios`, not a user-agent check.
- `correlationId` falls back to the `app_logger_correlation_id` cookie, then `'unknown'`.
- `onFetchSuccess` runs `res.clone().json()`, a second parse for large bodies.
- Debug in a browser by stubbing `window.native = { logWebApi: console.log }` and setting the cookie.

## Where it shows up
Pages that link here:
- TIX-REACT-COMMON: [[react-common-eagle-eye]]
- concepts: [[webview-jsi-bridge]]

## Sources
- TIX-REACT-COMMON `packages/react-common-eagle-eye/src/eagle-eye.ts`, `packages/react-common-fetch-client/src`, `packages/react-common-fetch/src`
- TIX-NEXT-PAYMENT-FE and TIX-FINTECH-NEXT-FE `package.json`; `git grep "@tiket/react-common-eagle-eye"` on both baselines
