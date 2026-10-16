---
title: PageModule shared
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-page-module-shared"
sources:
  - packages/page-module-shared/src
  - packages/page-module-shared/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# PageModule shared
> The shared layer under [[passport-page-module]]: React contexts, the section layout, carousels, the overlay and bottom-text cards, and helpers used by page-module and its module packages (banner-carousel, banner-grid, product-card, promo-carousel…).

Part of [[passport-packages]].

## What it does
This package exists so module packages can share contexts and building blocks without importing `@tiket/passport-page-module` at runtime. All contexts live here, so every package that reads them gets the same context instance. This is why the [[page-module-next-poc]] keeps it as a direct dependency. It imports page-module, product-card, promo-carousel and highlight-discover **for types only**.

## Public API
**Contexts and providers**
| Export | Purpose |
|---|---|
| `PageModuleContext`, `PageModuleProvider`, `usePageModule` | `locale` (default `'id'`), `accountId`, `currency`, `loyaltyLevel`, `username`, `aboveTheFoldIndex`, `criticalImageModuleIndexes`, and fetch params (`orderId`, `publicId`, `referenceId`, `latitude`/`longitude`, `level`, `destinationName`, `curatedId`, `variant`, …). Type `CarouselVisibleItems` |
| `PageModuleClientFetchProvider`, `usePageModuleClientFetch` | `clientSideServiceEndpoint` (e.g. `https://gatotkaca.tiket.com`, or `''` for relative) and an optional `fetch`. **Without a custom `fetch`, PageModule can't retry on an expired token** |
| `PageModuleImageRenderersContext`, `PageModuleImageRenderersProvider` | per-module `imageRenderer` overrides (bannerCarouselV2, bannerGrid, imageWithChips(Grid), highlightDiscover product/article, textWithImage, promoCarousel, logo), e.g. to plug in `next/image` |
| `PageModuleRolloutProvider`, `usePageModuleRollout` | A/B flag `isNewGvVariant` |
| `PageModuleTabbingMetadataProvider`, `PageModuleSwitchMetadataContext` | per-module `{ module, index, tabId, parentTabbingModuleId, sectionId }` for tabbing modules |

**Components:** `Carousel`, `CarouselWithFixedWidthItems`, `GenericCarousel`, `Layout` (section shell with title, countdown, background image or color, and `defaultImageRenderer`), `CardWithTextOverlay` (`CardVariant` xxsmall…large), `CardWithTextBottom`, `AsyncChipsLoadError`, `LoyaltyBadge`.

**Helpers:** `useImage` (falls back to the `tds_ph_image_1_1` placeholder on error), `validateImageSource`, `getSectionId`, `getLayoutVariant`, `determineLayoutVariantFromBackgroundColor`, `appendCurrentUrlToDeepLinkParams`, `getCustomRibbonLabelStyle`, `DATA_NO_BOTTOM_DIVIDER`, `DEFAULT_ABOVE_THE_FOLD_INDEX = 3`, `PAGEMODULE_BACKGROUND_PRESET = 'auto_optimize_webp'`.

Not re-exported by [[passport-umbrella]].

## Usage
```tsx
<PageModuleClientFetchProvider clientSideServiceEndpoint="" fetch={authFetch}>
  <PageModuleProvider locale="id" accountId={id} currency="IDR" loyaltyLevel={null} username="">
    <Carousel visibleItems={{ base: 2, large: 4 }}>{cards}</Carousel>
  </PageModuleProvider>
</PageModuleClientFetchProvider>
```

## Depends on
[[passport-button]], [[passport-container]], [[passport-countdown]], [[passport-image]], [[passport-label]], [[passport-typography]], [[passport-utils]], assets, icons; [[passport-page-module]] (types only, which makes the dependency circular).

## Used by
- Inside TIX-PASSPORT: 12 packages, including [[passport-page-module]], [[passport-product-card]], [[passport-promo-carousel]], [[passport-promo-code-popup]], [[passport-review-widget]], [[passport-wishlist]], banner-carousel, banner-grid and highlight-discover.
- TIX-FINTECH-NEXT-FE: only a comment in `app/gift-card/checkout/components/GiftCardCarousel/GiftCardCarousel.tsx` that refers to its `Carousel`.
- TIX-NEXT-PAYMENT-FE: pinned at an alpha prerelease version in `.cursor/skills/migrate-tiket-packages/SKILL.md` (see [[prerelease-flow]]).

## Gotchas
- Import contexts from this package, never from a page-module `src/` deep path in an app. Mixing `dist` and `src` copies creates duplicate React contexts. See [[page-module-next-poc]].
- `PageModuleImageRenderersContext`'s default value omits `logoImageRenderer`. That is harmless, since it is `undefined` either way.

## Sources
- packages/page-module-shared/src/index.ts
- packages/page-module-shared/src/contexts/
- packages/page-module-shared/src/utils.ts
- packages/page-module-shared/src/constants/config.ts
- packages/page-module-shared/src/hooks/useImage.ts
- packages/page-module-shared/package.json
