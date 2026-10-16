---
title: Banner Grid
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-banner-grid"
sources:
  - packages/banner-grid/src
  - packages/banner-grid/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Banner Grid
> CSS-grid layout of promo banner cards with separate mobile and desktop rows and columns, used by page-module and global-popup.

## What it does
`BannerGrid` sets `--grid-{row,column}-{mobile,desktop}` CSS variables and provides the grid config through context. `BannerCard` reads it and renders `CardWithTextOverlay` from [[passport-page-module-shared]]. It looks up the card variant (`xxsmall`…`large`) and the `<img sizes>` value from tables keyed by `"row-column-ratioX-ratioY"`.

## Public API
| Export | Notes |
|---|---|
| `BannerGrid` | `grid: { mobile: {row,column}, desktop: {row,column} }`, `enableContainerQueries?` |
| `BannerCard` | `CardWithTextOverlayProps` (`imageRatioX/Y`, `imageRenderer`, `canAppendDeeplink`, `disableNavigation`, `isExpandCollapse`, `isCriticalImage`…) |
| `BannerGridProvider`, `useBannerGrid`, `BannerGridContext` | default 1×1 |
| `getCardVariant`, `getCardImageSizeFromMobileVariant`, `mobileCardVariantMap`, `desktopCardVariantMap`, `imageSizeMap` | lookup helpers |
| types `BannerGridProps`, `GridType`, `GridConfig`, `CardVariantParamTypes` | |

## Usage
```tsx
<BannerGrid grid={{ mobile: { row: 2, column: 2 }, desktop: { row: 1, column: 4 } }}>
  {items.map((b) => <BannerCard key={b.id} imageRatioX={1} imageRatioY={1} {...b} />)}
</BannerGrid>
```

## Depends on
[[passport-page-module-shared]], [[passport-utils]]. Chips and chips-carousel are devDeps used only in stories.

## Used by
- No direct imports in other repos.
- Internal: [[passport-global-popup]], [[passport-page-module]].

## Gotchas
- A 1×1 grid always gives a `large` card with a free-form ratio. Any other combination that isn't in the maps falls back to `small`, and `sizes` falls back to `100vw`.
- `enableContainerQueries` makes the grid reflow on container width. It needs an ancestor with the `container-root` class (e.g. the page-module `Layout`) and falls back to viewport media queries through `@supports`.
- The default `imageRenderer` is a plain `<img>`, with `loading="eager"` only when `isCriticalImage`.
- Not in the umbrella `@tiket/passport`.

## Sources
- `packages/banner-grid/src/BannerGrid.tsx`, `src/context.tsx`, `src/utils.ts`, `src/types.ts`, `src/Components/BannerCard/BannerCard.tsx`
- `packages/banner-grid/package.json`
