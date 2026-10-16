---
title: react-common-fetch-client
repo: TIX-REACT-COMMON
kind: package
npm: "@tiket/react-common-fetch-client"
sources:
  - packages/react-common-fetch-client/src
  - packages/react-common-fetch-client/package.json
  - packages/react-common-fetch-client/build.js
verified_at: 14597c4e
updated: 2026-10-16
status: current
tags: [repo/react-common, kind/package]
---

# react-common-fetch-client
> Client-side `fetch` wrapper for tiket APIs: builds the gateway URL, adds mandatory headers, renews tokens, retries, logs to Eagle Eye and the app logger, and turns errors into Central Error Handling (CEH) responses.

## What it does
`fetchClient(endpoint, options)` resolves the URL first. Absolute URLs pass through. `/api/...` becomes `<origin>/<basePrefixForApp>/api/...`, and anything else becomes `<origin>/<apiGateway ?? 'ms-gateway'><endpoint>`, with `options.params` appended. It adds the mandatory headers (language, currency, country, `X-Correlation-ID` request id, client channel/OS/platform, forwarded `tag_*` query params, webview cookie headers, opt-in Cloudflare geo headers). On 401 it calls `/api/refresh-token`, or `/api/create-token` for guests, and retries once. On 400/413/431/5xx it clears cookies and retries once. 422/429 are never retried. With `isMigrated: true`, non-2xx responses and `code: BUSINESS_ERROR` are normalised into a `CEHErrorResponse`. Central handling (`checkIfErrorWillBeHandledCentrally`) happens only when `isCritical: true` and not `isRetryFromCEH`, and the `errorData` is either missing or has a valid non-`EMBEDDEDVIEW`/`BANNER` `uiType`, no `extraData`, and only supported actions. In that case it dispatches a `CustomEvent` on `window.ceh.errorEvent` for [[react-common-error-handler]] and waits for the user's action. This is the successor of [[react-common-fetch]]. See [[central-error-handling]].

## Public API
| Export | Notes |
|---|---|
| `fetchClient(endpoint, options?: FetchClientOptions)` | `RequestInit` plus `apiGateway`, `params`, `timeout`, `shouldCreateGuestToken`, `shouldSkipAuth`, `shouldDisableEagleEye`, `shouldIncludeGeoLocationHeaders`, log controls (`shouldDisableSuccessLogs`, `shouldRemoveApiResponseFromLogs`, `filterOut*`, `sendStandardizedLogData`, `maxQueueSizeForLogs`), CEH (`isMigrated`, `isCritical`, `isRetryFromCEH`, `onCompleteApiCall`, `fallbackTechErrorUiType`, `replaceBackWithDismiss`, `dismissActionText`, `customTrackingData`, `vertical`/`screenName`/`screenOwner`) |
| CEH helpers | `getCentralizedErrorConfig`, `sanitizeBusinessError`, `sanitizeTechnicalError`, `handleCatchError`, `handleCriticalError`, `checkIfErrorWillBeHandledCentrally`, `checkIfActionsAreSupported`, `createFormattedErrorResponse`, `generateRequestId` |
| CEH types/enums | `CEHErrorResponse`, `CEHErrorDataType`, `CEHActionObject`, `CEHErrorEventDetails`, `CEHUIConfig`, `CEHTrackerDataType`, `CEHUiType`, `CEHActionStyle`, `CEHActionType`, `CEHActionValue`, `CEHErrorCode`, `CEHErrorType` |
| runtime config | `setFetchClientConfig({ basePrefixForApp?, postLogPath? })`, `getBasePrefixForApp()`, `getPostLogPath()` |
| misc | `getParamsToForward`, `getCookie`, `isNetworkRelatedError`, `COOKIE_USER_LANG` |
| deep import | `@tiket/react-common-fetch-client/src/logger` (`createLogger`), used by [[react-common-core-attributes]] |

## Usage
```ts
// TIX-REACT-REMOTE src/utils/header/useNotificationCount.ts
import { fetchClient } from '@tiket/react-common-fetch-client';
const res = await fetchClient('/tix-inbox/userInbox/unreadCount', {
  headers: { 'Accept-Language': lang, lang, 'X-Account-Id': String(accountId ?? 0) },
}); // → <origin>/ms-gateway/tix-inbox/userInbox/unreadCount
```

## Depends on
- [[react-common-eagle-eye]], [[react-common-utilities]] (`getClientChannel/OS/Platform`). Both are **bundled** into `dist` (esbuild, only react external).
- Next.js API routes on the host app: `/api/refresh-token`, `/api/create-token`, `/api/<postLogPath>` (default `post-log`).

## Used by
- Internal: [[react-common-core-attributes]], [[react-common-error-handler]], [[react-common-navigator-permission]], [[react-common-push-notif]], [[react-common-remote]].
- TIX-REACT-REMOTE (pinned 3.2.0): [[react-remote-reviews]] (`getReviews.ts`), [[react-remote-wrapper]] (`PassportWrapper`), header `useNotificationCount`.
- TIX-FINTECH-NEXT-FE: gift-card checkout containers, `useCentralError`, `ErrorHandlerProvider`, `SSRErrorBoundary` ([[fintech-fe-gift-card]]).
- TIX-NEXT-PAYMENT-FE: test files only.

## Gotchas
- **Client only** ("Fetch wrapper for client side only"): it reads `window.location` for URLs and headers.
- `basePrefixForApp` is resolved at **call time**, in this order: `setFetchClientConfig` store → `window.__TIX_REMOTE_CONFIG__` → `NEXT_PUBLIC_BASE_PREFIX_FOR_APP` → `'homepage-v4'`. This exists because a [[module-federation]] remote would otherwise inline its own build-time `NEXT_PUBLIC_*`. If the host never sets it, `/api/*` calls go to `homepage-v4`.
- CEH conversion happens only with `isMigrated: true`. Without it you get the raw `Response`.
- When CEH handles the error centrally, the promise waits until the user acts in the bottom sheet or snackbar. With no `CommonErrorHandler` mounted (no `window.ceh.errorEvent`), nothing is dispatched.
- Non-critical calls are never handled centrally: you get a formatted `CEHErrorResponse` back and must render it yourself (e.g. with `CentralErrorExtension`). Technical errors without `errorData` default to `BANNER` (`fallbackTechErrorUiType` overrides it), and `CommonErrorHandler` does not render banners.
- `X-Country-Code` is `IDN` on the legacy URL structure, but `X-Country-Id` always uses the detected country.
- No README in the package.

## Sources
- packages/react-common-fetch-client/src/index.ts, src/config.ts
- packages/react-common-fetch-client/src/client/{fetchClient,types,constants,helper,getFinalFetchURL,mandatoryFetchHeaders,cehHelper}.ts
- packages/react-common-fetch-client/src/logger/engine.ts, package.json, build.js
