---
title: Promo list, detail and preview (/promo/**)
repo: TIX-HOMEPAGE-NEXT-FE
kind: feature
sources:
  - pages/promo
  - context/Promo
  - context/DeviceContext
  - components/Layout
  - lib/services/promo
  - lib/tracker/Promo.ts
  - lib/tracker/PromoDetail.ts
  - lib/types/entities/promo-detail
verified_at: 408983f6
updated: 2026-10-16
status: current
tags: [repo/homepage-fe, kind/feature]
---

# Promo list, detail and preview (/promo/**)
> tiket.com's promo pages. The list has category tabs and sub-chips plus a voucher-box entry point. The detail page renders `tix-promotion-page` modules and promo-code cards. The preview renders a CMS draft. All of it is fetched in the browser, and only bots get server-side meta.

## What it does
- **List** `/promo` and `/promo/{category}`: tabs from the promo-list response, sub-category chips (`?sub=`), promo cards, a voucher-box entry point (links to [[homepage-fe-voucher-box]]), and a non-IDR currency notice (`MultiCurrencyPopup`, dismissal remembered in `localStorage` per `currency:accountId`). An unknown category rewrites the URL back to `/promo` with `history.replaceState`.
- **Detail** `/promo/{category}/{slug}`: hero image, info box (period, platform, loyalty), dynamic modules (`IMAGE_GENERAL`, `IMAGE_GRID`, `SHOWCASE_INVENTORY`, `SHOWCASE_BRAND`, `SHOWCASE_AREA`, `CTA`, `ADDITIONAL_INFO`, `COUNTDOWN`), promo-code tabs with copyable cards and quota status, breadcrumbs (desktop) and social links. Special states: `PLATFORM_UNAVAILABLE` (platform-specific CTA modal), `PROMO_ENDED` and `PROMO_NOT_FOUND` (`PromoEndedOrNotFound`), generic `ErrorView`.
- **Preview** `/promo/preview/{slug}`: the same `RevampedPromoDetailContent` fed by the admin preview endpoint, inside `Layout isPreview` (`noindex, nofollow`).

## Routes & entry points
- `pages/promo/[[...category]]/index.page.tsx`: optional catch-all. `getServerSideProps` fetches only remote props (`header` sticky `layoutVariantCode: '001'`, `footer`). `dataLayer.screenName: 'promoList'`.
- `pages/promo/[category]/[slug]/index.page.tsx`: `getServerSideProps` runs `getReactRemoteProps` and, **for bots only**, `getPromoDetail` to fill `promoMetadata` (title/description for SEO). `dataLayer.screenName: 'promoDetail'`.
- `pages/promo/preview/[slug]/index.page.tsx`: remote props + loyalty level (default `LV0`). The client fetches with `useQuery(['promoPreview', slug])`.
- All three use `getLayout` → `PromoIntlProvider` → `PromoProvider` (`context/Promo`) → `components/Layout` (`PromoHeader` + `SEOPageHead` or noindex head + `RemoteFooter isCritical`). The detail page also wraps in `DeviceProvider` (`context/DeviceContext`, viewport → `isDesktop`/`platform`).
- Every route mounts `RemoteGlobalPopup` and `RemoteGoogleOneTap` directly from [[react-common-remote]] (no SSR guard, `isNewURLStructure={false}`).

## Data & services
`lib/services/promo/index.ts` (all relative gateway paths):
| Function | Endpoint |
|---|---|
| `getPromoList` | `GET /tix-promotion-page/promos` |
| `getVoucherBoxEntryPoint` | `GET /tix-promotion-page/cross-sell/voucher-box/entry-points` |
| `getPromoDetail` | `GET /tix-promotion-page/promos/{slug}` (with `windowSize` `MOBILE`/`TABLET`/`DESKTOP_SMALL`/`DESKTOP`, loyalty, webview) |
| `getInventoryDetail` | `GET /tix-promotion-page/promos/{id}/modules` |
| `getPromoCodeCategory` | `GET /tix-promotion-page/promos/{id}/promo-codes` |
| `getPromoHeroBanner` | `GET /tix-home/v2/hero-banners` |
| `getPromoPreview` | `GET /tix-promotion-page/admin/promos/{slug}/preview` |
- `PromoProvider` fetches the list and hero banner with React Query (`isPromoList` = pathname `'/promo/[[...category]]'`), normalises tabs and categories (`pages/promo/utils/service.ts`) and exposes `isPromoDetailError` (drives `PromoHeader`).
- **The detail page fetches in a `useEffect`, not React Query.** The initial `windowSize` comes from `window.innerWidth` breakpoints 600/840/960.
- Countdown and date helpers: `pages/promo/utils/timer.ts`, `date.ts`. Quota status: `component/PromoCodeCardList/hooks/useGetQuotaStatus.ts`.
- Copy: `pages/promo/i18n/` (own provider and `useI18n`, also used by `components/Layout`).

## Key components
- List: `ResponsiveTabComponent`/`TabComponent`, `PromoBody`, `VoucherComponent` (voucher-box entry, gif asset), `MultiCurrencyPopUp`, `PromoHeader` (remote header), `Footer` (mobile heading text with the active tab name), `Loader`, `LoaderDesktop`.
- Detail: `RevampedPromoDetailContent`, `Module` (switch on module type, each child via `next/dynamic`), `PromoInfoBox` (mobile/desktop), `PromoCodeCardList`/`PromoCodeCard`/`PromoCode`/`PromoQuota`/`SeeMorePromoCodes`/`PromoCodeEmptyState`, `ShowcaseInventory`/`InventoryCard(Mobile)`/`FlightInventory` (`Carousel`/`Layout` from [[passport-page-module-shared]]), `ShowcaseBrand`, `ShowcaseArea`, `ImageGeneral`, `ImageGrid`, `ImageRendererOverride`, `CountdownModule`, `CTA`, `AdditionalInfo`, `SeeAllCollapse`, `PromoVoucher(Mobile)`, `SocialMedia`, `PromoDetailBreadcrumbs` ([[passport-breadcrumb]]), `PromoEndedOrNotFound`, `PromoNotAvailableInSpecificPlatform`, `LoadingPromoDetail`.
- Passport: [[passport-product-card]], [[passport-chips-carousel]], [[passport-image]], [[passport-error-view]], [[passport-icons]], [[passport-utils]] (`useIntersected`, `usePrevious`), core `Tabs`/`Text`/`Container`/`NotificationBanner`.
- Shared: `components/Layout`, `components/Image`, `components/WebViewWrapper`, `components/SEOPageHead` ([[homepage-fe-components]]).

## Tracking
`lib/tracker/Promo.ts`: `pageVisit`, `promoListParentCategory`, `promoListSubCategory`, `promoListCards`, `voucherBox`. `lib/tracker/PromoDetail.ts`: `pageVisit` (`promoDetailOnVisit`, and `promoDetailEmptyStateOnVisit` with the status code), `promoDetail`, `promoDetailCodeTab`, `promoDetailCodeCard` (impression/copy), `promoDetailModuleContent`. Plus `AnalyticsEventHandler` with `promoList` / `promoDetail` screen names. See [[gtm-datalayer-tracking]].

## Tests
45 specs under `pages/promo/` (every detail component, list components, utils, `getSsrProps` and page specs for list, detail and preview).

## Gotchas
- **Promo detail does not use [[passport-page-module]].** Its modules come from `tix-promotion-page` and render through the local `Module` switch. Only `InventoryCardMobile` imports a page-module type.
- In the detail `getServerSideProps`, a rejected `getReactRemoteProps` is **rethrown** (500 → `_error`), while a failed promo fetch is ignored. Home/destination/explore swallow remote failures.
- Webview header offset: `topOffset` starts at 32 px and drops to 0 after mount when the legacy webview uses the app header (`hideToolbar=false`). The code calls this a workaround for styles not applied on the first webview render.
- The preview page returns an empty `<div>` on the server, because `RevampedPromoDetailContent` needs `window.matchMedia`.
- `PromoProvider` keys its list behaviour off the literal pathname `'/promo/[[...category]]'`.

## Sources
- `pages/promo/[[...category]]/index.page.tsx`, `components/LoaderDesktop/*`
- `pages/promo/[category]/[slug]/index.page.tsx`, `component/**`, `types.ts`, `utils.ts`
- `pages/promo/preview/[slug]/index.page.tsx`
- `pages/promo/components/**`, `pages/promo/i18n/*`, `pages/promo/utils/*`, `pages/promo/assets/*`, `pages/promo/__tests__/*`
- `context/Promo/index.tsx`, `context/DeviceContext/index.tsx`, `components/Layout/Layout.tsx`
- `lib/services/promo/index.ts`, `lib/tracker/Promo.ts`, `lib/tracker/PromoDetail.ts`, `lib/config.ts` (`PROMO_DETAIL_EMPTY_STATE_CODE`)
