---
title: Banner Carousel
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-banner-carousel"
sources:
  - packages/banner-carousel/src
  - packages/banner-carousel/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Banner Carousel
> Auto-scrolling promo banner carousel used by page-module. It picks a card size from visible-items count and image ratio.

## What it does
`BannerCarousel` is a thin wrapper over `Carousel` from [[passport-page-module-shared]]. It puts `visibleItems` (`{ base, desktop }`) into context and multiplies `base` by 0.96, because Figma's "1.04 visible" is 1 in code. It also sets the auto-scroll interval: 5 s on desktop, and on mobile 3 s for fewer than 2 visible items, 5 s otherwise. `BannerCarouselCard` reads the context and renders `CardWithTextOverlay` or `CardWithTextBottom` with a `small | medium | large` variant from a lookup table.

## Public API
| Export | Notes |
|---|---|
| `BannerCarousel` | `CarouselProps` with `visibleItems: { base, desktop }` and `autoScroll?` |
| `BannerCarouselCard` | `bannerTextVariant: 'BOTTOM_OF_BANNER' \| 'BOTTOM_OVERLAY'` (default overlay) plus card props (`imageRatioX`, `imageRatioY`, `imageRenderer`…) |
| `BannerCarouselProvider`, `useBannerCarousel`, `BannerCarouselContext` | context. Default `visibleItems` is `{2.25, 2.25}` |
| `getCardVariant`, `mobileCardVariantMap`, `desktopCardVariantMap` | key format `"<visibleItems>-<ratioX>-<ratioY>"`. Unknown keys fall back to `small` |
| types `BannerCarouselProps`, `VisibleItemsProp`, `BannerTextVariant`, `CardVariantParamTypes` | |

## Usage
```tsx
<BannerCarousel visibleItems={{ base: 1.04, desktop: 3 }} autoScroll>
  {banners.map((b) => (
    <BannerCarouselCard key={b.id} imageRatioX={5} imageRatioY={2} imageRenderer={…} {...b} />
  ))}
</BannerCarousel>
```

## Depends on
[[passport-page-module-shared]] (Carousel and card components), [[passport-utils]] (`usePassport().breakpoint`). Chips and chips-carousel are devDeps used only in stories.

## Used by
- TIX-FINTECH-NEXT-FE `projects/insurance/standalone/landing/components/MyOrder/components/CarouselDesktop/CarouselDesktop.tsx` (direct dep `^12.4.3`).
- Internal: [[passport-page-module]].

## Gotchas
- The card variant is only correct for the exact `visibleItems`/ratio combinations in the maps, such as mobile `1.04-5-2`. Any other combination silently renders `small`.
- Pass the Figma values (e.g. `base: 1.04`) to `BannerCarousel`. The 0.96 scaling is applied internally, and the context keeps the unscaled values for the variant lookup.
- Not in the umbrella `@tiket/passport`.

## Sources
- `packages/banner-carousel/src/BannerCarousel.tsx`, `src/context.tsx`, `src/utils.ts`, `src/components/BannerCarouselCard/BannerCarouselCard.tsx`
- `packages/banner-carousel/package.json`
