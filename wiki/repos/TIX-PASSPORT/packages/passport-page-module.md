---
title: PageModule
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-page-module"
sources:
  - packages/page-module/src
  - packages/page-module/index.ts
  - packages/page-module/package.json
  - packages/page-module/README.md
  - packages/page-module/CONTRIBUTING.md
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# PageModule
> Renders a CMS-driven list of "page modules" (banners, product carousels, promo codes, tabbing, floating button…) returned by `tix-home` page-modules-full. It is the main merchandising surface on homepage, vertical landing and order-complete pages.

Part of [[passport-packages]].

## What it does
- `data: Module[]` comes from the backend. `getInitialData` calls `${baseUrl}/tix-home/v2/page-modules-full?...`, but any source of the same array works. `filterEmptyModules` drops empty entries.
- `PageModuleSwitch` maps each module's `templateCode` to a module component. Supported templates: `PROMO_CAROUSEL`, `BANNER_GRID`, `BANNER_CAROUSEL_V2`, `BANNER_NUDGE`, `TEXT_WITH_IMAGE`, `INTERNAL_LINK`, `FLASH_SALE`, `IMAGE_WITH_CHIPS`, `IMAGE_WITH_CHIPS_GRID`, `IMAGE_WITH_CHIPS_LOCATION` (flight location-based), `HIGHLIGHT_DISCOVER_ARTICLE`, `HIGHLIGHT_DISCOVER_PRODUCT`, `CLAIMED_GV`, `GV_SECTION`, `RECENT_WIDGET`, `PROMO_CODE_GRID`, `PROMO_CODE_CAROUSEL`, `TABBING`, `FLOATING_BUTTON`, `DYNAMIC_WIDGET`.
- **Async modules** fetch their own data on the client through `asyncModulesFactory` (a suspend/preload cache over React Query). They use `clientSideServiceEndpoint` and the optional custom `fetch` from [[passport-page-module-shared]]. `TABBING` passes a `tabId` to child async modules.
- `aboveTheFoldIndex` (default 3) and `criticalImageModuleIndexes` mark modules that are critical for rendering and image priority.

## Public API
| Export | Notes |
|---|---|
| `PageModule` | `'use client'` entry ("Next.js v12" in its docstring; pages router or client components). It builds its own `QueryClient` (`retry:false`, no refetch on focus) and wraps the view in Rollout, AccomProductSprite ([[passport-product-card]]), ImageRenderers, ClientFetch, PageModule, `QrPopupProvider` ([[passport-qr-popup]]) and AsyncModules providers |
| `PageModuleServerComponent` | async RSC entry that also fetches initial data (`GetInitialDataArgs`: `baseUrl`, `pageModuleCode`, `pageModuleType`, `fetch`, `sessionAccessToken`, …) |
| `getInitialData`, `useInitialDataQuery` | server fetch / client React Query hook |
| `PageModuleProvider`, `PageModuleClientFetchProvider`, `PageModuleImageRenderersProvider`, image-renderer types, `PAGEMODULE_BACKGROUND_PRESET` | re-exported from [[passport-page-module-shared]] |
| `types/*`, `utils/*` | `Module` and per-template module types (e.g. `BannerGridModule`, `ProductCardData`) |

Main props: `data`, `locale`, `accountId`, `currency`, `loyaltyLevel`, `username` (session), fetch params (`orderId`, `publicId`, `referenceId`, `latitude`/`longitude`, `level`, `destinationName`, `curatedId`, `isNotificationActive`, `variant`, `tripId`, `recommendationVersion`, `partner`/`partnerId`), `screenName`/`screenOwner` (tracking), `baseUrlForLinks` (prefix for relative BE links on other subdomains), `additionalGtmVariables` (spread first into every dataLayer push), `fetch`, `clientSideServiceEndpoint`, `*ImageRenderer`, `carouselVisibleItems`, `pageModuleLayoutContainerClassName`, `tabbingModuleStickyMobileOffset`, `forceRender` (default true), `enableContainerQueries`, `experiments` / `isBot` (forwarded as experiment query params), `isNewGvVariant`, `onFirstModuleAppear`.

## Usage
From the README (pages router):
```tsx
<PageModule data={pageModuleData} locale="id" screenName="home" screenOwner="discovery"
  accountId={1234} currency="IDR" loyaltyLevel="LV0" username="GUEST"
  clientSideServiceEndpoint="https://gatotkaca.tiket.com" />
```
App router: `const json = await getInitialData(...)`, then render inside a client wrapper around `PageModuleProvider`, because RSC can't pass renderer functions across the boundary. The README shows a `next/image` renderer example.

## Depends on
[[passport-page-module-shared]], [[passport-product-card]], [[passport-promo-carousel]], [[passport-promo-code-popup]], [[passport-qr-popup]], [[passport-voucher-card]], [[passport-seo]], [[passport-search-box]], [[passport-tabs]], [[passport-snackbar]], [[passport-modal]], banner-carousel, banner-grid, highlight-discover, chips, dialog, bottom-sheet and others. External: `keen-slider`, `react-intersection-observer`, `@tiket/react-common-utilities`, `@tiket/react-common-ab-test` (types). Peers: `dayjs`, `react`, `react-dom`, `@tanstack/react-query`, `uuid`.

## Used by
- Inside TIX-PASSPORT: [[passport-global-popup]], [[passport-global-search]], [[passport-page-module-collapse]], [[passport-page-module-shared]] (types), [[passport-product-card]] (circular, see [[page-module-next-poc]]).
- TIX-NEXT-PAYMENT-FE (`^8.11.1`): order-complete success pages, `app/payment-link/[method]/complete/components/SuccessPageModule/SuccessPageModule.tsx` with `app/payment-link/hooks/usePageModuleData.ts` / `lib/services/pageModule.ts`, and `pages/payment/[type]/complete/components/Success/components/MobileScreen/index.tsx`. See [[payment-fe-payment-link]].
- TIX-FINTECH-NEXT-FE (`^12.4.3`): gift-card landing (`lib/services/home.ts`, `app/gift-card/landing/types`), insurance claim-center landing (`projects/insurance/claim-center/landing/components/PageModuleSection`) and standalone insurance landing.

## Gotchas
- `src/` is published (`files: ["dist","src"]`). The `slim/` entry (`SlimPageModuleProvider`/`SlimPageModuleView`, without `AccomProductSpriteProvider`) is not exported from the root, so it can only be reached through deep imports. Never mix root (`dist`) and `src` imports in one app, because that duplicates contexts. See [[page-module-next-poc]].
- Pass a custom `fetch` (e.g. the Next starter's lib fetch) or async modules cannot retry on an expired token. For CORS cases (TTD Live) the custom fetch must send `Origin` and `credentials: 'include'`.
- `baseUrlForLinks` is skipped for links that already start with `http`.
- `pageModuleLayoutContainerClassName` doesn't affect floating-button, highlight-discover-*, internal-link, promo-carousel, tabbing or text-with-image, because they use their own layouts.
- Local dev needs https Storybook (`npm run dev:https`, `https://local.tiket.com:6007`) because of gateway cookies (CONTRIBUTING.md).

## Sources
- packages/page-module/src/PageModule.tsx
- packages/page-module/src/PageModuleServerComponent.tsx
- packages/page-module/src/PageModuleSwitch.tsx
- packages/page-module/src/async-modules/factory.ts
- packages/page-module/src/services/initial-data.ts
- packages/page-module/src/slim/SlimPageModuleProvider.tsx
- packages/page-module/src/index.ts
- packages/page-module/README.md
- packages/page-module/CONTRIBUTING.md
- packages/page-module/package.json
