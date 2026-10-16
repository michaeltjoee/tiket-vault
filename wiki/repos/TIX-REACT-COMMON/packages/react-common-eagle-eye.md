---
title: react-common-eagle-eye
repo: TIX-REACT-COMMON
kind: package
npm: "@tiket/react-common-eagle-eye"
sources:
  - packages/react-common-eagle-eye/src
  - packages/react-common-eagle-eye/index.ts
  - packages/react-common-eagle-eye/package.json
  - packages/react-common-eagle-eye/README.md
verified_at: 14597c4e
updated: 2026-10-16
status: current
tags: [repo/react-common, kind/package]
---

# react-common-eagle-eye
> Logs per-request fetch metrics (URI, sizes, status, duration, business code) to the native app's "Eagle Eye" logger when running inside the tiket app webview.

## What it does
`EagleEye({ url, method, headers, body, additionalLog, correlationId })` returns `{ start, onFetchSuccess(res), onFetchException(msg) }`. Wrap a fetch with it: call `start()` before, `onFetchSuccess` for any response (including 4xx/5xx), `onFetchException` only when fetch throws. Outside a webview it returns no-ops. It picks the transport in this order: Android `window.native.logWebApi`, iOS `webkit.messageHandlers.logWebApi`, else `logWebApi` from [[react-common-jsi]]. It is already built into [[react-common-fetch-client]] and [[react-common-fetch]], so app code rarely calls it directly. See [[eagle-eye-logging]].

## Public API
| Export | Notes |
|---|---|
| `default` (`EagleEye`) | **default export only** (`index.ts`: `export { EagleEye as default }`) |
| `EagleEyeArg` | `url` (full, with query), `method` (default `GET`), `headers`, `body`, `additionalLog`, `correlationId`, `gql`, `gqlDataExtractor`, `gqlSkipLoggingForQuery` |
| `EagleEyeReturn` | `start()`, `onFetchSuccess(res): Promise<void>`, `onFetchException(msg)` |

Logged payload: `uri`, `query`, `method`, `reqPayloadSize` (query + body + headers bytes), `respPayloadSize`, `respCode` (`-1` on exception), `respTime` ms, `businessCode`/`businessMsg` (from JSON body `code`/`message`), `exception`, `correlationId`.

## Usage
```ts
import EagleEye from '@tiket/react-common-eagle-eye';
const ee = EagleEye({ url, method: 'POST', headers, body });
ee.start();
try {
  const res = await fetch(url, { method, headers, body: JSON.stringify(body) });
  ee.onFetchSuccess(res);
  return res;
} catch (e) {
  ee.onFetchException(e instanceof Error ? e.message : '');
  throw e;
}
```

## Depends on
- [[react-common-jsi]] (`logWebApi`, `LogWebApiParams`)

## Used by
- [[react-common-fetch-client]], [[react-common-fetch]] (bundled in).
- TIX-NEXT-PAYMENT-FE and TIX-FINTECH-NEXT-FE: listed in `package.json`, no direct import on baseline.

## Gotchas
- "Webview" means the `device_type` cookie is `android` or `ios`, not a user-agent check.
- `gql`, `gqlDataExtractor` and `gqlSkipLoggingForQuery` are typed but **not used** in `eagle-eye.ts` on this baseline.
- `correlationId` falls back to the `app_logger_correlation_id` cookie, then `'unknown'`.
- A relative URL on the server (or a malformed URL) returns no-ops silently.
- `onFetchSuccess` reads `res.clone().json()`, so huge bodies cost a second parse.
- Debug outside the app by stubbing `window.native = { logWebApi: console.log }` (README).

## Sources
- packages/react-common-eagle-eye/index.ts, src/{eagle-eye,utils,types,constants}.ts
- packages/react-common-eagle-eye/README.md, package.json
