---
title: react-common-jsi
repo: TIX-REACT-COMMON
kind: package
npm: "@tiket/react-common-jsi"
sources:
  - packages/react-common-jsi/src
  - packages/react-common-jsi/package.json
  - packages/react-common-jsi/README.md
verified_at: 14597c4e
updated: 2026-10-16
status: current
tags: [repo/react-common, kind/package]
---

# react-common-jsi
> Typed wrapper around the tiket app's "generic JSI" bridge, used by web pages inside the native webview to call native commands.

## What it does
Every call sends a JSON `{ command, request: { requestId, ... } }` to `window.generic.callGenericNativeJSI` (Android) or `window.webkit.messageHandlers.callGenericNativeJSI.postMessage` (iOS). Fire-and-forget commands (`trackAnalyticEvent`, `onNavigationStart`, `onPageRendered`, `logWebApi`, `handleActionSendContent`, `userVerificationComplete`) just send. Request/response commands store `{ resolve, reject }` in `window.jsiPromise[requestId]` and listen for a `CustomEvent` named after the `requestId`. The native app dispatches that event with `{ requestId, response | error }`. Outside a webview, calls silently do nothing. See [[webview-jsi-bridge]].

## Public API
| Export | Kind | Notes |
|---|---|---|
| `useGetAuthenticatedUserDetails()` | hook → `() => Promise<JSIUserAuthenticationDetailsData>` | `{ isLogin, accountId, username, firstname, lastname, loginMedia, verifiedPhoneNumber, tixPoint, loyaltyLevel }`; errors `{ message, statusCode: -6xx }` |
| `useGetLocation()` | hook → `({ isFineLocationRequired? }) => Promise<GetLocationResponseData>` | iOS webview only; dual-response listener can skip a first (permission) response |
| `PageRenderPerformanceMarker` | component | `{ respCode, message?, customFields? }`; sends `onPageRendered` once per mount |
| `trackAnalyticEvent`, `onNavigationStart({ url })`, `logWebApi(params)`, `getAuthenticatedUserDetailsForAnalytics`, `handleActionSendContent`, `userVerificationComplete` | functions | |
| `callGenericJSI(requestId, payload)`, `jsiResponseHandler` | low-level helpers | |
| types `LogWebApiParams`, `GetLocationResponseData` | | |

## Usage
```tsx
import { useGetAuthenticatedUserDetails, PageRenderPerformanceMarker } from '@tiket/react-common-jsi';

const getUser = useGetAuthenticatedUserDetails();
useEffect(() => { getUser().then(setUser).catch(() => setStatus('error')); }, [getUser]);

return <PageRenderPerformanceMarker respCode={200} />; // respCode of the page's critical API
```

## Depends on
`uuid` only (for `requestId`s). React is imported by the hooks and component but is not declared as a peer dependency (it is external in the esbuild build).

## Used by
- Internal: [[react-common-eagle-eye]] (`logWebApi`), [[react-common-analytic]] (webview event forwarding, bundled in), [[react-common-core-attributes]], [[react-common-navigator-permission]] (bundled in).
- No direct import in the other workspace repos on baseline (TIX-NEXT-PAYMENT-FE only mentions it in a `.cursor` skill).

## Gotchas
- iOS can dispatch the response before a listener registered in `useEffect` exists. That is why the hook registers the listener inside the call itself with a fresh `requestId`. Keep that pattern if you add commands.
- The hooks remove pending listeners and `jsiPromise` entries on unmount. The bare functions don't, so a promise can stay pending forever if native never answers. There is no timeout.
- Webview detection elsewhere uses the `device_type` cookie (`android`/`ios`); here a call just no-ops if no bridge object exists.
- Several consumers **bundle** their own copy (esbuild, not external), so `window.jsiPromise` is the shared state, not module state.

## Sources
- packages/react-common-jsi/src/{index,constants,util}.ts, src/helpers/*, src/hooks/*, src/jsi/*, src/components/PageRenderPerformanceMarker.tsx
- packages/react-common-jsi/README.md, package.json
