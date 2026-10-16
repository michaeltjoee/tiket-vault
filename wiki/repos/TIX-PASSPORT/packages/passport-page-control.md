---
title: PageControl
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-page-control"
umbrella: true
sources:
  - packages/page-control/src
  - packages/page-control/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# PageControl
> Carousel pagination dots (1-based `current`), with an inverted color mode for dark backgrounds.

Part of [[passport-packages]].

## What it does
It renders one `<button>` per page, and `onChange(page)` fires on click. Only the `dots` variant is implemented. `counter` and `linear` are in the type but render `null` (there is a `TODO` in the source).

## Public API
`PageControl` (also in [[passport-umbrella]]).

| Prop | Notes |
|---|---|
| `current` | 1-based, default `1` |
| `total` | number of dots |
| `variant` | required. Only `'dots'` renders |
| `mode` | `'default'` or `'inverted'` |
| `onChange(page)` | |
| `ariaLabelGenerator(page, total)` | aria-label per dot. Without it the buttons have no accessible name |

## Usage
```tsx
<PageControl variant="dots" current={slide + 1} total={banners.length}
  onChange={(p) => slider.moveToIdx(p - 1)} />
```

## Depends on
[[passport-utils]] (types).

## Used by
- Inside TIX-PASSPORT: [[passport-global-search]], [[passport-gradient-banner]].
- TIX-NEXT-PAYMENT-FE: `pages/payment/[type]/complete/components/SuccessV2/SuccessV2.tsx`. TIX-FINTECH-NEXT-FE: `projects/insurance/standalone/landing/components/MyOrder/components/CarouselMobile/CarouselMobile.tsx` (both via `@tiket/passport`).

## Gotchas
- `variant="counter"` or `"linear"` type-checks but renders an empty `div`.

## Sources
- packages/page-control/src/PageControl.tsx
- packages/page-control/package.json
