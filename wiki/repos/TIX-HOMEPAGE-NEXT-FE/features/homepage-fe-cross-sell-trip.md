---
title: Cross-sell trip offer and prize (/cross-sell-trip/**)
repo: TIX-HOMEPAGE-NEXT-FE
kind: feature
sources:
  - pages/cross-sell-trip
  - lib/services/cross-sell-trip.ts
  - lib/constants/cross-sell-trip.ts
  - lib/types/entities/cross-sell-trip.ts
  - components/LottiePlayer
verified_at: 408983f6
updated: 2026-10-16
status: current
tags: [repo/homepage-fe, kind/feature]
---

# Cross-sell trip offer and prize (/cross-sell-trip/**)
> The "Trip View" cross-sell campaign (added in 4.6.0). The offer page shows a trip's progress and a `CROSS_SELL_LANDING_PAGE` page-module feed. The prize page claims or shows the reward. Both are login-only, and the data comes from `tix-xsell-engine`.

## What it does
- **Offer** `/cross-sell-trip?tripId=…`: hero with animation and trip progress (stamps), payload buttons, and the cross-sell page modules (products to complete the trip). Desktop uses the remote header. Mobile uses `CrossSellTripMobileHeader` (auto-hiding, back, T&C link). Remote footer at the end.
- **Prize** `/cross-sell-trip/prize?tripId=…&doClaim=true|false`: with `doClaim=true` it POSTs the claim. Otherwise it reads the trip status. Then it shows a Lottie/animated prize hero, trip stamps and result buttons. Some non-success codes (`NON_PNV`, `OUT_OF_QUOTA`, `SYSTEM_ERROR`, `CLAIM_TIMEOUT`) still carry hero content and render the normal UI (`PRIZE_PAYLOAD_ERROR_CODES`). Anything else falls back to an error view. `noindex, nofollow`, title "Trip View".
- Buttons (`utils/button.ts`): a button without a URL, or with URL `BACK`, calls `navigateBack()`. Otherwise it calls `navigateReplace(withForwardParams(url))`.

## Routes & entry points
- `pages/cross-sell-trip/index.page.tsx` and `pages/cross-sell-trip/prize/index.page.tsx`. Both `getLayout`s: `AuthProvider` → `WebViewWrapper` → `CrossSellTripIntlProvider`.
- `getServerSideProps` **redirects guests** to `/login?ref={encoded https://host + url}` (`permanent: false`). The host falls back to `NEXT_PUBLIC_NON_PREFIXED_HOSTNAME`.
- Offer SSR: `getAbTestOnServer` + `getReactRemoteProps(getRemoteModules(sessionData))` in parallel (`header` `layoutVariantCode: '001'`, `footer`). `recommendationVersion` comes from `NEO_POLARIS_EXPERIMENT`. No `dataLayer` prop.
- Prize SSR: remote props without footer (`{ withFooter: false }`), failures swallowed with `.catch(() => ({}))`. `doClaim` is normalised to `'true' | 'false'`.
- `tripId` is taken from the query unvalidated (`parseTripId`). The backend answers `DATA_NOT_EXIST` for a bad id.

## Data & services
`lib/services/cross-sell-trip.ts` + `lib/constants/cross-sell-trip.ts`. All calls are `cache: 'no-store'` with `X-Account-Id`:
| Function | Endpoint | Hook / query key |
|---|---|---|
| `getTripStatus` | `GET /tix-xsell-engine/cross-sell/trip-view/status?tripId` | `useTripStatus` → `['cross-sell-trip','trip-status',tripId,isWebView,currency,locale]` |
| `postClaim` | `POST /tix-xsell-engine/cross-sell/trip-view/claims` `{ tripId }` | `useClaim` (a **query**, `retry: 0`, `staleTime: Infinity`) |
| `getCrossSellTripPageModule` | `GET /tix-home/v2/page-modules-full?pageModuleCode=CROSS_SELL_LANDING_PAGE&tripId` (`platform` header) | `useCrossSellTripPageModule` |
- `usePrizePage` enables exactly one of claim or status, depending on `doClaim`. `prize/utils/prizeDataNormalizer.ts` maps either response to the prize UI.
- `CrossSellTripPageModule` renders `PageModule` from [[passport-page-module]] with `coreFetcher`, `getCriticalImageModuleIndexes` and `screenName: 'offerLandingPage'`, `screenOwner: 'crossSell'`. Skeleton: `PageModuleLoading` (`Carousel` from [[passport-page-module-shared]]).
- Copy: `pages/cross-sell-trip/i18n/` (own provider and test utils).

## Key components
Offer (`pages/cross-sell-trip/components/`): `OffersContent`, `OffersHero` (+ `OffersHeroAnimation`), `OffersLoading`, `TripProgress`, `PayloadButtons`, `CrossSellTripPageModule`, `PageModuleLoading`, `CrossSellTripMobileHeader` ([[passport-header]] types).
Prize (`pages/cross-sell-trip/prize/components/`): `PrizeContent` (uses `RemoteHeader` on desktop), `PrizeHero`, `PrizeAnimation` (+ `PrizeAnimationLottie` via `components/LottiePlayer`), `TripStamps`.
Shared: `SEOPageHead`, `WebViewWrapper`, `Image`, `PageModuleImageRenderer`, `LottiePlayer` ([[homepage-fe-components]]).

## Tracking
`trackers.ts` files: `trackOfferLandingPageImpression` (offer, screen `offerLandingPage`), `trackClaimPrizePageImpression` / `impressionLandingPage` (prize, screen `claimPrizeLandingPage`), `impressionLandingPageSuccess`, `impressionErrorSystem`, `impressionErrorVerification`, `clickReturnToTripView`, `clickTnC`. Category and label are `crossSellSection`, owner `crossSell` (`lib/config.ts`).

## Tests
16 specs: page and `getSsrProps` specs for offer and prize, components, `usePrizePage`, and `utils/button`, `remote`, `route`.

## Gotchas
- `recommendationVersion` reaches the `PageModule` prop, but `useCrossSellTripPageModule` never passes it to `getCrossSellTripPageModule`, so the page-modules request goes out without it.
- `isWebView`, `currency` and `locale` are part of the query keys but are not sent to the backend. They only split the cache.
- The claim is a `useQuery` with infinite stale time, so it runs once per key per session. A remount with the same key won't re-POST.
- `vitest.setup.ts` registers no route for `/cross-sell-trip` (the routes are static, so the parser doesn't need one).

## Sources
- `pages/cross-sell-trip/index.page.tsx`, `trackers.ts`, `components/**`, `hooks/*`, `i18n/*`, `utils/*`, `__tests__/*`
- `pages/cross-sell-trip/prize/index.page.tsx`, `trackers.ts`, `components/**`, `hooks/usePrizePage.ts`, `utils/prizeDataNormalizer.ts`, `__tests__/*`
- `lib/services/cross-sell-trip.ts`, `lib/constants/cross-sell-trip.ts`, `lib/types/entities/cross-sell-trip.ts`, `lib/config.ts`
- `components/LottiePlayer/LottiePlayer.tsx`, `CHANGELOG.md` (4.6.0)
