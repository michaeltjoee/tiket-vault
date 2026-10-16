---
title: Central error handling (CEH)
kind: concept
repos: [TIX-REACT-COMMON, TIX-FINTECH-NEXT-FE, TIX-PASSPORT, TIX-REACT-REMOTE]
sources:
  - TIX-REACT-COMMON/packages/react-common-fetch-client/src/client/cehHelper.ts
  - TIX-REACT-COMMON/packages/react-common-error-handler/src
  - TIX-FINTECH-NEXT-FE/app/gift-card/checkout/hooks/useCentralError.tsx
  - TIX-FINTECH-NEXT-FE/app/gift-card/components/ErrorHandlerProvider
  - TIX-PASSPORT/packages/currency-bottom-sheet/src
verified_at:
  TIX-REACT-COMMON: 14597c4e
  TIX-FINTECH-NEXT-FE: 5833b842
  TIX-PASSPORT: 7a33010aca
  TIX-REACT-REMOTE: 281778b
updated: 2026-10-16
status: current
tags: [kind/concept, repo/react-common, repo/fintech-fe, repo/passport, repo/react-remote]
---

# Central error handling (CEH)
> Backends can return an `errorData` payload that says how the FE should show an error (bottom sheet, snackbar, banner, embedded view) and which actions to offer. [[react-common-fetch-client]] normalises it, and one mounted `CommonErrorHandler` from [[react-common-error-handler]] renders the critical ones, so apps don't each write error UI for the same codes.

## Flow
1. The app mounts `<CommonErrorHandler />` once. It creates `ERROR-EVENT-<uuid>`, stores it in `window.ceh.errorEvent` and listens for that `CustomEvent`.
2. A call goes through `fetchClient(url, { isMigrated: true, isCritical })`. With `isMigrated`, non-2xx responses and `code: BUSINESS_ERROR` become a `CEHErrorResponse` (`cehHelper.ts`). Without it you get the raw `Response`.
3. When `isCritical` is set and the `errorData` can be handled centrally (no `extraData`, supported actions, `uiType` not `BANNER`/`EMBEDDEDVIEW`), fetch-client dispatches the event and its promise waits.
4. `CommonErrorHandler` renders `BOTTOMSHEET` or `SNACKBAR`. The chosen action (reload, back, redirect with forwarded params) resolves the pending fetch with `isHandledCentrally: true`.
5. Everything else returns to the caller as a formatted `CEHErrorResponse`. The caller renders it itself, for example with `<CentralErrorExtension />`.

SSR responses can be passed as `ssrAPIResponse`. A client event wins over it.

## Who uses it
- **TIX-FINTECH-NEXT-FE**: the only consumer of react-common-error-handler, in gift card (`ErrorHandlerProvider`, `useCentralError`). See [[fintech-fe-gift-card]].
- **TIX-PASSPORT**: [[passport-currency-bottom-sheet]] sends `isCritical: true, isMigrated: true` in its `RequestInit`. This only takes effect when the host's [[passport-custom-fetch]] is react-common-fetch-client, as in TIX-REACT-REMOTE.
- TIX-NEXT-PAYMENT-FE does not use CEH on its baseline.

## Gotchas
- `useUpdateErrorEventOnNavigation` patches `window.history.pushState` and rotates the event name on every soft navigation. Read `window.ceh.errorEvent` at dispatch time, never cache it. `replaceState` and `popstate` don't rotate it.
- With no `CommonErrorHandler` mounted, nothing is dispatched and critical errors fall back to the caller.
- A second `CommonErrorHandler` overwrites `window.ceh.errorEvent`.
- Technical errors without `errorData` default to `BANNER`, which `CommonErrorHandler` does not render.
- react-common-error-handler declares a `./server` export, but `src/server.ts` is missing on `master`.

## Where it shows up
Pages that link here:
- TIX-REACT-COMMON: [[react-common-error-handler]], [[react-common-fetch-client]]
- concepts: [[passport-custom-fetch]]

## Sources
- TIX-REACT-COMMON `packages/react-common-fetch-client/src/client/cehHelper.ts`, `packages/react-common-error-handler/src/components/CommonErrorHandler/CommonErrorHandler.tsx`, `packages/react-common-error-handler/src/hooks/useUpdateErrorEventOnNavigation.ts`
- TIX-FINTECH-NEXT-FE `app/gift-card/checkout/hooks/useCentralError.tsx`, `app/gift-card/components/ErrorHandlerProvider/ErrorHandlerProvider.tsx`
- TIX-PASSPORT `packages/currency-bottom-sheet/src` (`isMigrated`)
