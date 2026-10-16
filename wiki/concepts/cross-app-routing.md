---
title: Cross-app routing (C.A.R)
kind: concept
repos: [TIX-REACT-COMMON, TIX-PASSPORT, TIX-FINTECH-NEXT-FE]
sources:
  - TIX-REACT-COMMON/packages/react-common-navigator-permission/src
  - TIX-PASSPORT/packages/manage-order/src
  - TIX-FINTECH-NEXT-FE/app/(external)/gift-card/order/components/ShareLink/ShareLink.tsx
verified_at:
  TIX-REACT-COMMON: 14597c4e
  TIX-PASSPORT: 7a33010aca
  TIX-FINTECH-NEXT-FE: 5833b842
updated: 2026-10-16
status: current
tags: [kind/concept, repo/react-common, repo/passport, repo/fintech-fe]
---

# Cross-app routing (C.A.R)
> To use a native capability (contact picker, calendar, maps, share) from a webview, a page navigates to a special "car request" URL. The app intercepts it, runs the native flow, and returns the result in a query parameter plus a `window.handleResponse` call. [[react-common-navigator-permission]] implements it, with browser APIs as the fallback outside the app.

## Flow
1. The webview check is the `device_type` cookie (`android`/`ios`). Outside the app the package uses the Contact Picker API, `navigator.share`, a Google Calendar link, `navigator.geolocation` or a Google Maps URL instead.
2. In the app it redirects to a generated car-request URL. Request field names are generic and mapped per platform by the GTM tag "Cross App Routing Properties Map" ([[gtm-datalayer-tracking]]).
3. The app appends the result to the original URL and calls `window.handleResponse`, which resolves the promise. `CARWebview` swaps in its own `handleResponse` and restores the previous one afterwards.

## Users
- [[passport-manage-order]] uses `addToCalendar`.
- TIX-FINTECH-NEXT-FE gift card uses `ContactPicker` and `shareFilesWithContent` ([[fintech-fe-gift-card]]).

## Gotchas
- The webview really navigates away and back. Component state that is not persisted can be lost.
- Android share uses JSI ([[webview-jsi-bridge]]). iOS share uses `navigator.share`.
- Shared files are downloaded with `fetchClient`, so their URLs must be reachable from the browser and follow fetch-client's URL rules.
- Every function returns `undefined` on the server.

## Where it shows up
Pages that link here:
- TIX-REACT-COMMON: [[react-common-navigator-permission]]
- concepts: [[webview-jsi-bridge]]

## Sources
- TIX-REACT-COMMON `packages/react-common-navigator-permission/src`
- TIX-PASSPORT `packages/manage-order/src`; TIX-FINTECH-NEXT-FE `app/(external)/gift-card/order/components/ShareLink/ShareLink.tsx`
- `git grep "from '@tiket/react-common-navigator-permission'"` on both baselines
