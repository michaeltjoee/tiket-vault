---
title: Highlight Discover
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-highlight-discover"
sources:
  - packages/highlight-discover/src
  - packages/highlight-discover/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Highlight Discover
> Building blocks for the "Highlight Discover" page-module sections: a layout, a mobile carousel with a cross-fading hero image, a two-up desktop article carousel, and article/product cards.

Part of [[passport-packages]].

## What it does
These are presentational pieces with no data fetching. [[passport-page-module]] assembles them in its `highlight-discover-article` and `highlight-discover-product` modules. `HighlightDiscoverLayout` wraps the page-module `Layout` from [[passport-page-module-shared]] and picks the layout variant from the background image or colour. `HighlightDiscoverMobileCarousel` is a looping [[keen-slider]] of cards over a full-bleed image. When the slide changes, the image of the next slide fades in over 350 ms, and the image links to `links[current]` with forwarded params. `HighlightDiscoverArticleDesktopCarousel` shows two centred slides with prev/next buttons. Clicking a dimmed neighbour slide navigates to it.

## Public API
| Export | Key props |
|---|---|
| `HighlightDiscoverLayout` (forwardRef, memo) | `title`, `label`, `description`, `icon`, `backgroundColor`, `backgroundUrl`, `theme` (`DARK`/`LIGHT`), `moduleId`, `pageModuleLayoutContainerClassName` |
| `HighlightDiscoverMobileCarousel` | `images: {src, alt}[]`, `links: string[]`, `children` (slides), `onClick(index)`, `imageRenderer`, `isCritical` |
| `HighlightDiscoverArticleDesktopCarousel` / `…CarouselItem` | `children[]`, `onClickNext(index)`, `onClickPrev(index)` |
| `HighlightDiscoverArticleCard` | `title`, `description`, `buttonTitle`, `url`, `className` |
| `HighlightDiscoverProductCard` | `href`, `children` (a plain `<a>`) |
| `HighlightDiscoverProductName`, `…ProductInfo`, `…ProductInfoReviews`, `…ProductPrice`, `…ProductPriceUnavailable` | product card text slots. `ProductPrice` takes `infoBeforePrice`, slash price and price strings that are already formatted |
Type: `HighlightDiscoverMobileCarouselProps`, which [[passport-page-module-shared]] uses to type its image-renderer context.

## Usage
```tsx
<HighlightDiscoverLayout title={title} description={subtitle} backgroundUrl={bg}>
  <HighlightDiscoverMobileCarousel images={images} links={links} isCritical={isAboveFold}>
    {items.map((item) => <HighlightDiscoverArticleCard key={item.id} {...item} />)}
  </HighlightDiscoverMobileCarousel>
</HighlightDiscoverLayout>
```

## Depends on
[[passport-button]], [[passport-icons]], [[passport-image]], [[passport-page-module-shared]], [[passport-typography]], [[passport-utils]] (`constructFullUrl`, `useForwardParams`, `useIntersected`, `usePassportEnvironment`); `keen-slider`.

## Used by
- Internal only: [[passport-page-module]] (runtime). [[passport-page-module-shared]] lists it as a devDependency for a type import. No other repo imports it directly. It reaches apps through the page module.

## Gotchas
- With exactly two children the mobile carousel renders the slides twice so the loop looks full, and folds the index back into 0..1.
- With `isCritical`, the first and current images load eagerly. Neighbouring images are preloaded with `<link rel="preload">` only after the carousel scrolls into view.
- Pass `imageRenderer` to swap `<img>` for a framework image (e.g. `next/image`). The default renderer lazy-loads non-critical images.

## Sources
- `packages/highlight-discover/src/components/layout/HighlightDiscoverLayout.tsx`
- `packages/highlight-discover/src/components/mobile-carousel/HighlightDiscoverMobileCarousel.tsx`
- `packages/highlight-discover/src/components/article-desktop-carousel/HighlightDiscoverArticleDesktopCarousel.tsx`
- `packages/highlight-discover/src/components/article-card/HighlightDiscoverArticleCard.tsx`, `packages/highlight-discover/src/components/product-card/`
- `packages/highlight-discover/package.json`
