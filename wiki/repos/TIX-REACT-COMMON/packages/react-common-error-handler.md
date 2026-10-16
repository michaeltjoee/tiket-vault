---
title: react-common-error-handler
repo: TIX-REACT-COMMON
kind: package
npm: "@tiket/react-common-error-handler"
sources:
  - packages/react-common-error-handler/src
  - packages/react-common-error-handler/package.json
  - packages/react-common-error-handler/README.md
verified_at: 14597c4e
updated: 2026-10-16
status: current
tags: [repo/react-common, kind/package]
---

# react-common-error-handler
> UI half of the Central Error Handling (CEH) system: renders the bottom sheet or snackbar that the backend's error payload asks for, for errors raised through [[react-common-fetch-client]].

## What it does
`<CommonErrorHandler />` is mounted once per app. It generates a unique event name (`ERROR-EVENT-<uuid>`), stores it on `window.ceh.errorEvent`, and listens for that `CustomEvent`. [[react-common-fetch-client]] dispatches to it when an API error carries CEH `errorData`. Only `uiType` `BOTTOMSHEET` and `SNACKBAR` are rendered, from either a client event or the `ssrAPIResponse` prop (client wins). Actions (primary/secondary buttons) run standard handlers (reload, back, redirect with forwarded params) and resolve the fetch-client's pending promise with `isHandledCentrally: true`. `<CentralErrorExtension />` renders the same UI for an error response you already hold, with your own `onClick`. See [[central-error-handling]].

## Public API
| Export | Props |
|---|---|
| `CommonErrorHandler` | `ssrAPIResponse?: CEHErrorResponse` |
| `CentralErrorExtension` | `errorResponse: CEHErrorResponse`, `onClick(action, isHandled, uiType)`, `handleUiFallback?()` (called when `uiType` is not a known `CEHUiType`) |
| types `CommonErrorHandlerProps`, `CentralErrorExtensionProps` | |

Only `components/` is exported from `src/index.ts`; utils (`generateErrorEventName`, `showErrorSnackbar`, action handlers) and `useUpdateErrorEventOnNavigation` are internal. The CEH types (`CEHErrorResponse`, `CEHUiType`, `CEHActionObject`…) come from [[react-common-fetch-client]].

## Usage
```tsx
import { CommonErrorHandler } from '@tiket/react-common-error-handler';
import type { CEHErrorResponse } from '@tiket/react-common-fetch-client';

export function App({ ssrErrorResponse }: { ssrErrorResponse?: CEHErrorResponse }) {
  return <><CommonErrorHandler ssrAPIResponse={ssrErrorResponse} />{/* app */}</>;
}
```

## Depends on
- [[react-common-fetch-client]] (CEH types and event contract), `uuid`
- Imported but **not declared** as dependencies: `@tiket/passport` (`snackbar`, devDependency only) and [[react-common-utilities]] (`useForwardParams`). The consumer must install both. See [[passport-overview]].
- Peer: `next` ^16 (`next/head` in `PreloadAssets`), React 19

## Used by
- TIX-FINTECH-NEXT-FE: `app/gift-card/components/ErrorHandlerProvider/ErrorHandlerProvider.tsx` (`CommonErrorHandler`), `app/gift-card/checkout/hooks/useCentralError.tsx` (`CentralErrorExtension`). See [[fintech-fe-gift-card]].
- TIX-NEXT-PAYMENT-FE: only mocked in `vitest.setup.tsx`.

## Gotchas
- `package.json` declares a `./server` export, but **`src/server.ts` does not exist** on master. Importing `@tiket/react-common-error-handler/server` fails.
- It monkey-patches `window.history.pushState` to rotate the event name on every soft navigation (to drop stale listeners). Code that dispatches CEH events must read `window.ceh.errorEvent` at dispatch time, not cache it. `replaceState` and back/forward (`popstate`) don't rotate the name.
- Mount exactly one `CommonErrorHandler`; a second one overwrites `window.ceh.errorEvent`.
- `PreloadAssets` uses `next/head`, which has no effect in the App Router.
- Tests mock `@tiket/passport` (see README and [[react-common-architecture]]).

## Sources
- packages/react-common-error-handler/src/components/{CommonErrorHandler,CentralErrorExtension,RenderErrorUI,PreloadAssets}/*
- packages/react-common-error-handler/src/hooks/useUpdateErrorEventOnNavigation.ts, src/utils/errorEvent.ts, src/index.ts
- packages/react-common-error-handler/package.json, README.md
