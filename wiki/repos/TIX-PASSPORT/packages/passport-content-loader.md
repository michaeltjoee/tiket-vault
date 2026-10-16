---
title: Content Loader
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-content-loader"
sources:
  - packages/content-loader/src
  - packages/content-loader/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Content Loader
> Skeleton placeholders (rect, text, title, circle, thumb, circle with label) with pulse or wave shimmer.

## What it does
It renders a grid of `row × column` placeholder blocks shaped by `type`. `text` doubles the row count to fake two lines per row. Width defaults to 100%. `height` applies to every block. `fillParentHeight` stretches the wrapper to the parent's height.

## Public API
`ContentLoader`, plus type `ContentLoaderProps`. It also accepts `div` props.
| Prop | Values / default |
|---|---|
| `type` (required) | `rect`, `text`, `circle`, `thumb`, `title`, `circleLabel` |
| `animation` (required) | `pulse` or `wave` |
| `row`, `column` | `1`, `1`. Only `column === 2` gets a dedicated two-column layout |
| `width`, `height` | number or string |
| `right` | right-aligns blocks |
| `fillParentHeight` | |

## Usage
```tsx
<ContentLoader type="rect" animation="wave" height={120} />
<ContentLoader type="text" animation="pulse" row={3} />
```

## Depends on
[[passport-utils]], `classnames`.

## Used by
- Through the umbrella `@tiket/passport`: TIX-NEXT-PAYMENT-FE (about 30 files, e.g. `app/payment-link/[method]/confirm/components/HowToPayLoader.tsx`; [[payment-fe-payment-link]]) and TIX-FINTECH-NEXT-FE (about 60 files, e.g. `projects/insurance/claim-center/*/components/Loader`).
- Internal: 17 packages (header, global-popup, global-search, page-module, insurance, product-card, promo-carousel, sidebar, wishlist…).

## Gotchas
- The per-column margin class (`styles.columns`) never applies. The check `columnItem > 1` runs on `undefined` array items. Space multi-column placeholders yourself.

## Sources
- `packages/content-loader/src/ContentLoader.tsx`, `src/ContentLoader.module.scss`
- `packages/content-loader/package.json`
