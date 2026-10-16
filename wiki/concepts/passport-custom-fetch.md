---
title: Passport customFetch (host-provided fetch)
kind: concept
repos: [TIX-PASSPORT, TIX-REACT-REMOTE, TIX-NEXT-PAYMENT-FE, TIX-FINTECH-NEXT-FE, TIX-HOMEPAGE-NEXT-FE, TIX-GROWTH-NEXT-FE]
sources:
  - TIX-PASSPORT/packages/utils/src/context.tsx
  - TIX-PASSPORT/packages/corporate-interim-module/src/utils/common.ts
  - TIX-REACT-REMOTE/src/components/wrapper/PassportWrapper/index.tsx
  - TIX-NEXT-PAYMENT-FE/lib/helpers/coreFetcher.ts
  - TIX-NEXT-PAYMENT-FE/components/providers/AppProvider.tsx
  - TIX-FINTECH-NEXT-FE/lib/fetch/fetch.ts
  - TIX-FINTECH-NEXT-FE/components/providers/AppProvider.tsx
  - TIX-HOMEPAGE-NEXT-FE/lib/fetch/fetch.ts
  - TIX-HOMEPAGE-NEXT-FE/components/providers/AppProvider.tsx
  - TIX-GROWTH-NEXT-FE/components/providers/AppProvider.tsx
  - TIX-GROWTH-NEXT-FE/pages/affiliate/c/hooks/usePageModule.tsx
verified_at:
  TIX-PASSPORT: 7a33010aca
  TIX-REACT-REMOTE: 281778b
  TIX-NEXT-PAYMENT-FE: 9e92b20bb
  TIX-FINTECH-NEXT-FE: 5833b842
  TIX-HOMEPAGE-NEXT-FE: 408983f6
  TIX-GROWTH-NEXT-FE: d4162e3
updated: 2026-10-16
status: current
tags: [kind/concept, repo/passport, repo/react-remote, repo/payment-fe, repo/fintech-fe, repo/homepage-fe, repo/growth-fe]
---

# Passport customFetch
> Passport widgets that call tiket APIs don't own auth, headers or gateway routing. The host app passes its own `fetch` as `customFetch` on `PassportProvider`, and each widget switches between relative URLs (with `customFetch`) and `<endpoint>/ms-gateway/...` URLs (without it).

## Contract
- `PassportContextValue.customFetch?: typeof fetch` in [[passport-utils]]. Widgets read it with `usePassport()`.
- 19 packages carry their own copy of `getFinalApiUrl`, and the signatures vary. The [[passport-corporate-interim-module]] one, `getFinalApiUrl(apiUrl, clientSideServiceEndpoint?, customFetch?)`, returns `apiUrl` unchanged when `customFetch` is set, and otherwise `${clientSideServiceEndpoint || ''}/ms-gateway${apiUrl}`, called with plain `fetch`.
- 24 packages use `customFetch` on `7a33010aca`, among them [[passport-header]], [[passport-global-popup]], [[passport-global-search]], [[passport-page-module]], [[passport-wishlist]], [[passport-insurance]], [[passport-corporate-interim-module]], [[passport-currency-bottom-sheet]], [[passport-bottom-sheet-multi-account]], [[passport-manage-order]], [[passport-image-upload]] and [[passport-pricing-promo]].

## What hosts pass
Every host that passes one adapts its gateway client to the `fetch` signature (normalise `string | URL | Request` to a URL string, then add `credentials: 'include'`):

| Host | `customFetch` wraps | Effect |
|---|---|---|
| TIX-REACT-REMOTE `PassportWrapper` | `fetchClient` from [[react-common-fetch-client]] | gateway routing, mandatory headers, token refresh, [[central-error-handling]] when a widget passes `isMigrated`/`isCritical` |
| TIX-NEXT-PAYMENT-FE `AppProvider` | `fetchClient` from `@tiket/next/client` ([[tiket-next-core]]) | same, plus `sendStandardizedLogData` ([[structured-diagnostic-logging]]) |
| TIX-FINTECH-NEXT-FE `AppProvider` | `apiFetch` from `@tiket/next/fetch`, with `locale` | URLs listed in `NEXT_PUBLIC_THIRD_PARTY_URL` bypass it and use plain `fetch` |
| TIX-HOMEPAGE-NEXT-FE `AppProvider` | `coreFetcher({ locale })` over `apiFetch` from `@tiket/next/fetch` (`lib/fetch/fetch.ts`) | guest token created by default. The same adapter is passed as `PageModule` `fetch` on home, explore, voucher box and cross-sell trip, but not on destination ([[homepage-fe-architecture]]) |
| TIX-GROWTH-NEXT-FE `AppProvider` | nothing: no `customFetch` | widgets take the `/ms-gateway` path. The co-brand page calls `getInitialData({ baseUrl: '/ms-gateway' })` and renders `PageModule` with `clientSideServiceEndpoint={NEXT_PUBLIC_HOME_PAGE}` and no `fetch` ([[growth-fe-affiliate]]) |

## Gotchas
- `RequestInit` extras are only meaningful to the host client. [[passport-currency-bottom-sheet]] sends `isCritical: true, isMigrated: true`, which react-common-fetch-client understands and plain `fetch` ignores.
- Not every widget follows the pattern. [[passport-generic-facilities]] always fetches `window.location.origin + /ms-gateway` with `credentials: 'include'`, and [[passport-bottom-sheet-multi-account]] builds its own headers.
- Without `customFetch` in Storybook or tests, calls go to `/ms-gateway/...`, which is what the msw handlers in `mocks/services/` match.
- Headers in the fallback path come from `getCommonHeaders` in [[react-common-utilities]], a runtime dependency on TIX-REACT-COMMON.

## Where it shows up
Pages that link here:
- TIX-HOMEPAGE-NEXT-FE: [[homepage-fe-app-shell]], [[homepage-fe-architecture]]
- TIX-PASSPORT: [[passport-bottom-sheet-multi-account]], [[passport-corporate-interim-module]], [[passport-currency-bottom-sheet]], [[passport-generic-facilities]], [[passport-global-popup]]
- concepts: [[central-error-handling]], [[structured-diagnostic-logging]], [[tiket-next-core]]
- entities: [[tix-image-service]], [[tix-insurance-core]], [[tix-wishlist-core]]
- howto: [[add-new-passport-package]]

## Sources
- TIX-PASSPORT `packages/utils/src/context.tsx`, `packages/*/src/utils/common.ts` (`getFinalApiUrl`); `git grep -l customFetch origin/main -- 'packages/*/src/**'`
- TIX-REACT-REMOTE `src/components/wrapper/PassportWrapper/index.tsx`
- TIX-NEXT-PAYMENT-FE `lib/helpers/coreFetcher.ts`, `components/providers/AppProvider.tsx`
- TIX-FINTECH-NEXT-FE `lib/fetch/fetch.ts`, `components/providers/AppProvider.tsx`
- TIX-HOMEPAGE-NEXT-FE `lib/fetch/fetch.ts`, `components/providers/AppProvider.tsx`, `pages/home/components/HomePageModule/index.tsx`
- TIX-GROWTH-NEXT-FE `components/providers/AppProvider.tsx`, `pages/affiliate/c/hooks/usePageModule.tsx`, `pages/affiliate/c/[slug].page.tsx`
