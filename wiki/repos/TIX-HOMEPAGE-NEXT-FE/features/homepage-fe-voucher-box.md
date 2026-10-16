---
title: Voucher box (/voucher-box)
repo: TIX-HOMEPAGE-NEXT-FE
kind: feature
sources:
  - pages/voucher-box
  - lib/services/voucher-box.ts
  - lib/tracker/voucher-box.ts
  - lib/types/entities/voucher-box.ts
  - context/CurrencyTicker
verified_at: 408983f6
updated: 2026-10-16
status: current
tags: [repo/homepage-fe, kind/feature]
---

# Voucher box (/voucher-box)
> A logged-in user's gift vouchers (GV) from `tix-promotion-page` cross-sell, with filter, sort and "new" badges. A `VOUCHER_BOX` page-module area sits above the list. Guests get a login prompt.

## What it does
- Logged-in users see the `VOUCHER_BOX` page-module section and their voucher list (tabs per product type, filter and sort bottom sheets, voucher code cards with copy). Vouchers are flagged "new" until viewed: viewed codes are stored per account in `localStorage` (`GV_CARD_VIEWED`), and a voucher is also no longer new after 7 days.
- Mobile with vouchers loaded: pull-to-refresh (`rmc-pull-to-refresh`) refetches both queries, but only while `<main>` isn't scrolled.
- Desktop: a `Banner` on top and a remote footer.
- Non-IDR users get a dismissible currency notice (`CurrencyTickerProvider`) when they have no vouchers.
- Guests: `NeedLoginState`. No data is fetched (both queries have `enabled: isLogin`).
- `/voucher-box/all` is the same page: `pages/voucher-box/all/index.page.tsx` re-exports `default` and `getServerSideProps` from `../index.page`.

## Routes & entry points
- `pages/voucher-box/index.page.tsx`, plus the `all/` alias.
- `getServerSideProps` awaits `getAbTestOnServer` (→ `recommendationVersion` from `NEO_POLARIS_EXPERIMENT`), **then** `getReactRemoteProps(getRemoteModules(sessionData))` (`header` `layoutVariantCode: '001'`, `footer`). The two run sequentially, not in parallel as on home. `dataLayer: { screenName: 'voucherBox', screenOwner: 'discovery' }`.
- `getLayout`: `VoucherBoxI18nProvider` (dictionary chosen from `middlewareData.locale`) → `CurrencyTickerProvider`.
- Header: `components/Header` with title "Voucher Box", `skipRemote` in webviews, `showOnFallback`. Mounts `RemoteGlobalPopup` and `RemoteGoogleOneTap`.

## Data & services
`lib/services/voucher-box.ts`:
- `getVoucherBox`: `GET /tix-promotion-page/cross-sell/voucher-box?generatedGvSize=100&showClaimedGv=true&claimedGvSize=100&filter&sortBy` with `X-Account-Id`, `X-Channel-Id`, `X-Currency`, `X-Loyalty-Level`, `X-Username`. Normalised by `normalizeVoucherBoxData`. Query key `['voucherBox', sortBy, filter]`.
- `getPageModule`: `GET /tix-home/v2/page-modules-full?pageModuleCode=VOUCHER_BOX` (+ `recommendationVersion`, UTM), `cache: 'no-store'`, `platform` sent as a header. Query key `['pageModule']`.
- `VoucherBoxPageModule` renders `PageModule` from [[passport-page-module]] with `coreFetcher` and the shared image renderers. `DATA_NOT_EXIST` counts as "no modules", not an error. Its loading and error states are `LoadingGVSection` (skeleton built from [[passport-voucher-card]]) and `ErrorViewGVSection` (`AsyncChipsLoadError` from [[passport-page-module-shared]]).
- Copy: `pages/voucher-box/i18n/` (own `createI18n`, provider and test utils).

## Key components
`pages/voucher-box/components/`: `VoucherBoxContent` (tabs, list, filter/sort, utils), `VoucherCodeCard`, `PassportVoucherCard` (a local voucher-card look-alike with hole images, not the Passport package), `VoucherFilterOptions`, `VoucherSortOptions`, `ProductTypesBottomSheetContent`, `SubtitleText`, `Banner`, `EmptyVoucherState`, `NeedLoginState`, `ErrorViewVoucherBox`, `ErrorViewGVSection`, `LoadingVoucherBox`, `LoadingGVSection`, `PlaceholderCard`, `VoucherBoxPageModule`.
Shared: `Header`, `WebViewWrapper`, `Loading`, `Image`, `PageModuleImageRenderer` ([[homepage-fe-components]]).

## Tracking
`lib/tracker/voucher-box.ts` (`eventLabel: 'voucherBox'`): `needLoginPageView`, `hasVouchersPageView` (page area, product-type status, tab, total, `multicurrency`, UTM), `pageView`, and `voucherBox/clickButton`. The page view fires once, after both initial fetches finish. UTM fields default `utmExternal` to `DEFAULT_UTM_EXTERNAL`.

## Tests
18 specs under `pages/voucher-box/` (components, utils, page, `getSsrProps`).

## Gotchas
- The page waits for both the page-module and voucher queries before it calls the first load done (`isFetching` transitions tracked with `usePrevious`). The code comments say both must load together.
- `getVoucherBox`/`getPageModule` fall back to `window.navigator.userAgent` when there's no request, so they are browser-only in practice.
- Pull-to-refresh is replaced by a plain `div` when `NODE_ENV === 'test'`.
- The voucher-box entry point on the promo list comes from a different endpoint (`/tix-promotion-page/cross-sell/voucher-box/entry-points`, [[homepage-fe-promo]]).

## Sources
- `pages/voucher-box/index.page.tsx`, `pages/voucher-box/all/index.page.tsx`
- `pages/voucher-box/components/**`, `pages/voucher-box/i18n/*`, `pages/voucher-box/utils.ts`, `types.ts`, `assets/*`, `__tests__/*`
- `lib/services/voucher-box.ts`, `lib/tracker/voucher-box.ts`, `lib/types/entities/voucher-box.ts`
- `context/CurrencyTicker/index.tsx`
