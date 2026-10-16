---
title: Webview JSI bridge (native app interface)
kind: concept
repos: [TIX-REACT-COMMON, TIX-PASSPORT, TIX-NEXT-PAYMENT-FE, TIX-FINTECH-NEXT-FE, TIX-HOMEPAGE-NEXT-FE]
sources:
  - TIX-REACT-COMMON/packages/react-common-jsi/src
  - TIX-REACT-COMMON/packages/react-common-eagle-eye/src
  - TIX-REACT-COMMON/packages/react-common-navigator-permission/src
  - TIX-PASSPORT/packages/manage-order/src/hooks/useJSI.ts
  - TIX-PASSPORT/packages/header/src/components/mobile/MobileBackButton.tsx
  - TIX-PASSPORT/packages/utils/src/context.tsx
  - TIX-NEXT-PAYMENT-FE/lib/jsi.ts
  - TIX-FINTECH-NEXT-FE/lib/jsi/index.ts
  - TIX-HOMEPAGE-NEXT-FE/lib/utils/webview.ts
  - TIX-HOMEPAGE-NEXT-FE/pages/_offline.page.tsx
  - TIX-HOMEPAGE-NEXT-FE/pages/destination/[slug]/components/HeaderMobile/webview.ts
verified_at:
  TIX-REACT-COMMON: 14597c4e
  TIX-PASSPORT: 7a33010aca
  TIX-NEXT-PAYMENT-FE: 9e92b20bb
  TIX-FINTECH-NEXT-FE: 5833b842
  TIX-HOMEPAGE-NEXT-FE: 408983f6
updated: 2026-10-16
status: current
tags: [kind/concept, repo/react-common, repo/passport, repo/payment-fe, repo/fintech-fe, repo/homepage-fe]
---

# Webview JSI bridge
> Web pages that run inside the tiket Android and iOS apps talk to native code through JavaScript-interface (JSI) objects that the app injects. There are two styles, a generic request/response channel and older per-command handlers, and each repo has its own copy of the call code.

## Detecting a webview
The usual test is the **`device_type` cookie** (`android` or `ios`), used by [[react-common-eagle-eye]], [[react-common-navigator-permission]], [[passport-utils]] (font scaling) and others. [[react-common-utilities]] adds `getWebViewEnv*`. fintech-fe insurance also distinguishes legacy and client webviews (`getIsClientLegacyWebview`) and honours `?hideToolbar=true` to hide the FE header ([[fintech-fe-insurance-claim]]). A bridge call outside a webview is a no-op.

## Style 1: generic JSI ([[react-common-jsi]])
- Send `{ command, request: { requestId, ... } }` to `window.generic.callGenericNativeJSI` (Android) or `window.webkit.messageHandlers.callGenericNativeJSI.postMessage` (iOS).
- Fire-and-forget commands: `trackAnalyticEvent`, `onNavigationStart`, `onPageRendered`, `logWebApi`, `handleActionSendContent`, `userVerificationComplete`.
- Request/response: the caller stores `{ resolve, reject }` in `window.jsiPromise[requestId]` and listens for a `CustomEvent` named after the `requestId`, which the app dispatches.
- Used by react-common analytic, core-attributes, eagle-eye ([[eagle-eye-logging]]) and navigator-permission.

## Style 2: per-command handlers
`window.native.<cmd>()` on Android and `window.webkit.messageHandlers.<cmd>.postMessage(...)` on iOS. Examples: `backOrClose` ([[passport-header]] `MobileBackButton`, payment-fe `lib/jsi.ts`, fintech-fe `lib/jsi/index.ts`), `forceExternal` (open a URL in the external browser), `closeWebView` ([[passport-manage-order]] `useJSI`), and `logWebApi` (eagle-eye's first choice). [[passport-phone-verification]] has its own close-webview and app-details helpers. TIX-HOMEPAGE-NEXT-FE calls `setTitle` from `components/Header` and treats a page that has a `setTitle` handler as a legacy webview (`getIsClientLegacyWebview` in `lib/utils/webview.ts`). It also calls `backOrClose` on Android only in `pages/_offline.page.tsx`, and `closeWebView` in the destination mobile header ([[homepage-fe-architecture]]).

## Related mechanisms
- Cross-app routing redirects the webview to a URL that the app intercepts, instead of calling JSI ([[cross-app-routing]]).
- Some pages expose callbacks for the app to call, for example fintech refund's `window.refreshRefundPage`/`hasPopup`/`closePopup` ([[fintech-fe-refund]]). payment-fe has `NEXT_PUBLIC_WEBVIEW_BRIDGE_MOCKING` to fake the bridge locally ([[payment-fe-workflows]]).

## Gotchas
- iOS can dispatch a response before a listener registered in `useEffect` exists. react-common-jsi registers the listener inside the call with a fresh `requestId`. Keep that pattern.
- No timeout: the bare functions leave a promise pending forever if native never answers.
- Several packages bundle their own copy of react-common-jsi. The shared state is `window.jsiPromise`, not module state.
- The copies in each repo drift. Check the target app version before relying on a command.

## Where it shows up
Pages that link here:
- TIX-HOMEPAGE-NEXT-FE: [[homepage-fe-app-shell]], [[homepage-fe-architecture]]
- TIX-REACT-COMMON: [[react-common-jsi]], [[react-common-navigator-permission]]
- concepts: [[analytics-core-attributes]], [[cross-app-routing]], [[eagle-eye-logging]], [[passport-accessibility-font-scaling]]

## Sources
- TIX-REACT-COMMON `packages/react-common-jsi/src`, `packages/react-common-eagle-eye/src/eagle-eye.ts`, `packages/react-common-navigator-permission/src`
- TIX-PASSPORT `packages/manage-order/src/{hooks/useJSI.ts,utils/webview.ts}`, `packages/header/src/components/mobile/MobileBackButton.tsx`, `packages/phone-verification/src/{contexts/app-details.tsx,utils/close-webview.ts}`
- TIX-NEXT-PAYMENT-FE `lib/jsi.ts`; TIX-FINTECH-NEXT-FE `lib/jsi/index.ts`, `projects/insurance/shared/lib/hooks/useHideToolbar.ts`
- TIX-HOMEPAGE-NEXT-FE `lib/utils/webview.ts`, `components/Header/index.tsx`, `pages/_offline.page.tsx`, `pages/destination/[slug]/components/HeaderMobile/webview.ts`
