---
title: PromoCarousel
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-promo-carousel"
sources:
  - packages/promo-carousel/src
  - packages/promo-carousel/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# PromoCarousel
> The building blocks of the `PROMO_CAROUSEL` page module: a section layout (icon, title, CTA, chips, background), a keen-slider carousel with slide bars, promo image cards, and a loading skeleton.

Part of [[passport-packages]].

## What it does
- `PromoCarouselLayout` (forwardRef `<section>`) is the module shell. It has `icon` (required), `title`, `description`, `ctaText`/`ctaUrl`/`onCtaClick`, `chips`, `backgroundColor`/`backgroundImage`, `theme: 'DARK'|'LIGHT'`, a layout `variant`, `moduleId` and `carouselContainerRef`. It uses its own layout, so [[passport-page-module]]'s `pageModuleLayoutContainerClassName` doesn't apply to it.
- `PromoCarousel` is a keen-slider carousel with `visibleItems: { base, large, xxlarge }`, `isLoading`, and slide-bar navigation. A `ResizePlugin` works around a Chrome visible-items bug. With `enableContainerQueries` it reflows on the nearest query container: CSS before hydration, a ResizeObserver after.
- `PromoCard` is an image card (`image`, `imgAlt`, `title`, `subtext`, `url`, `isCritical`, `imageRenderer`, `onClick`).
- `PromoCarouselLoading` and `PromoCarouselLoadingNavigators` are skeletons.
- `PromoCarouselProvider` / `PromoCarouselContext` hold `{ shouldInvert }`, which switches slide bars to inverted colors on dark backgrounds.

## Public API
`PromoCarouselLayout`, `PromoCarousel`, `PromoCard`, `PromoCarouselLoading`, `PromoCarouselLoadingNavigators`, `PromoCarouselProvider`, `PromoCarouselContext`, and the types `PromoCarouselProps`, `PromoCardProps`, `VisibleItemsType`. [[passport-umbrella]] re-exports `PromoCarouselLayout`, `PromoCarousel` and `PromoCard`.

## Usage
```tsx
<PromoCarouselLayout icon={iconUrl} title="Promo spesial" ctaText="Lihat semua" ctaUrl="/promo">
  <PromoCarousel visibleItems={{ base: 1, large: 2, xxlarge: 3 }}>
    {promos.map((p) => <PromoCard key={p.id} image={p.img} imgAlt={p.title} url={p.url} />)}
  </PromoCarousel>
</PromoCarouselLayout>
```

## Depends on
[[passport-page-module-shared]], [[passport-button]], [[passport-container]], [[passport-content-loader]], [[passport-image]], [[passport-typography]], [[passport-utils]], icons. External: `keen-slider`.

## Used by
- Inside TIX-PASSPORT: [[passport-page-module]] (the `PROMO_CAROUSEL` module), [[passport-page-module-shared]] (the `PromoCardProps` type for `promoCarouselImageRenderer`).
- No consumers in the other workspace repos. TIX-NEXT-PAYMENT-FE's `PromoCard` is its own component in `app/payment/components`.

## Gotchas
- Don't confuse its `PromoCard` with the `PromoCard` in [[passport-pricing-promo]], which is a promo-code card. Both packages export the same name.

## Sources
- packages/promo-carousel/src/index.ts
- packages/promo-carousel/src/components/promo-carousel/PromoCarousel.tsx
- packages/promo-carousel/src/components/promo-carousel-layout/PromoCarouselLayout.tsx
- packages/promo-carousel/src/components/promo-card/PromoCard.tsx
- packages/promo-carousel/src/context.tsx
- packages/promo-carousel/package.json
