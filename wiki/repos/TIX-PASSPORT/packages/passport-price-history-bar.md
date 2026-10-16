---
title: PriceHistoryBar
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-price-history-bar"
sources:
  - packages/price-history-bar/src
  - packages/price-history-bar/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# PriceHistoryBar
> A three-band "Good Deal / Average / Expensive" price gauge with an arrow marking where the current price falls, plus info text and a clickable current-price chip.

Part of [[passport-packages]].

## What it does
It is presentational. The caller decides the level (`priceVariant`), and the component places an arrow at a fixed position inside fixed-width bands (`PRICE_BANDS`: low flex 1, medium flex 0.5, high flex 1). `LOWEST`/`LOW` go in the green band, `MEDIUM` in the yellow band, and `HIGH`/`HIGHEST` in the orange band, with `LOWEST`/`HIGHEST` near the outer edges. Optional `topContent` and `bottomContent` slots wrap the bar, and the container can take a solid token background and an elevation.

## Public API
`PriceHistoryBar`; types `PriceHistoryBarProps`, `SolidColorToken`. Not in [[passport-umbrella]].

| Prop | Notes |
|---|---|
| `priceVariant: PriceVariant` | `lowest`/`low`/`medium`/`high`/`highest` |
| `infoText`, `priceDisplayText` | required strings (e.g. "Tertinggi: IDR 5.500.000", "IDR 1.500.000") |
| `priceDisplayIcon` | `information` (default) / `chevron_right` / `none` |
| `onPriceDisplayClick` | click on the price chip |
| `topContent`, `bottomContent` | ReactNode slots |
| `infoTextMaxLines`, `elevation` (default 1), `setConatinerBackgroundColor` (sic), `className` | |

## Usage
```tsx
import { PriceHistoryBar } from '@tiket/passport-price-history-bar';
import { PriceVariant } from '@tiket/passport-price-history-bar/src/constants';

<PriceHistoryBar priceVariant={PriceVariant.LOW} infoText="Tertinggi: IDR 5.500.000"
  priceDisplayText="IDR 1.500.000" onPriceDisplayClick={openHistory} />
```

## Depends on
[[passport-design-tokens]] (`solidColorTokens`, `computeSolidAndGradientBgStyle`), [[passport-typography]], [[passport-utils]], icons. [[passport-snackbar]] is listed but used only in stories.

## Used by
- Inside TIX-PASSPORT: [[passport-kuber-price-dynamic-banner]] (`src/factories/PriceHistoryBannerItem.tsx`, `src/mappers/PriceHistoryBannerMapper.ts`).
- No consumers in the other workspace repos.

## Gotchas
- **The enums `PriceVariant`, `PriceDisplayIcon` and `Elevation` are not exported from the package entry.** kuber-price-dynamic-banner deep-imports them from `@tiket/passport-price-history-bar/src/constants`. TS string enums don't accept plain string literals, so consumers need that deep import.
- The prop name is misspelled: `setConatinerBackgroundColor`.

## Sources
- packages/price-history-bar/src/PriceHistoryBar.tsx
- packages/price-history-bar/src/constants.ts
- packages/price-history-bar/package.json
- packages/kuber-price-dynamic-banner/src/mappers/PriceHistoryBannerMapper.ts
