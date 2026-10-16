---
title: PriceSummary
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-price-summary"
sources:
  - packages/price-summary/src
  - packages/price-summary/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# PriceSummary
> Data-driven price breakdown: nested line items (up to three levels, expandable with an accordion), an optional slash price, the total, extra rows and a cashback banner.

Part of [[passport-packages]].

## What it does
`summaryList` is a tree:
- **root items** (`PriceSummaryListItem`) with an optional `description` and `content`,
- **parent items** (`PriceSummaryDetailItem`) with `content`,
- **child items** (`PriceSummaryItemBaseWithDot`), shown with a dot.

Items that have content are wrapped in an [[passport-accordion]] unless `withExpandable: false`. `isExpandableDefaultOpen` controls the initial state. Root items are separated by dividers (`dividerVariant`: `dashed` (default), `default` or `none`, settable per item). Below the list come a main divider, then `slashPrice`, `totalPrice` (b1 bold highEmphasis by default), `additionalSummaryList`, and `CashbackBanner` when `cashbackBannerText` is set.

Labels and prices accept a string, a ReactNode, or an object (`{ value, textVariant, textWeight }`). A label can also be `{ origin, destination }`, which renders a route.

## Public API
`PriceSummary`, `PriceSummaryList`, `CashbackBanner` (all in [[passport-umbrella]]), and all types (`PriceSummaryProps`, `PriceSummaryListItem`, `PriceSummaryDetailItem`, `PriceSummaryItemLabel`, `PriceSummaryItemPrice`, `PriceSummaryDividerVariant`, …). `summaryLevel` and `trailingSlot` are marked `@internal`.

## Usage
```tsx
<PriceSummary
  summaryList={[{ label: 'Tiket pesawat', price: 'IDR 1.200.000',
    content: [{ label: { origin: 'CGK', destination: 'DPS' }, price: 'IDR 1.200.000' }] }]}
  slashPrice={{ label: 'Harga normal', price: 'IDR 1.400.000' }}
  totalPrice={{ label: 'Total', price: 'IDR 1.200.000' }}
  cashbackBannerText="Dapat cashback 50.000 tiket points" />
```

## Depends on
[[passport-accordion]], [[passport-divider]], [[passport-design-tokens]] (types), [[passport-typography]], [[passport-utils]], icons.

## Used by
- No internal dependents and no app consumers on baseline. TIX-NEXT-PAYMENT-FE has its own unrelated `components/PriceSummary`.

## Gotchas
- Inside the list, label and price text size is fixed to `b2`, so the object types omit `textSize`. Only `totalPrice.label` can choose `b1` or `b2`.

## Sources
- packages/price-summary/src/PriceSummary.tsx
- packages/price-summary/src/types.ts
- packages/price-summary/src/components/
- packages/price-summary/package.json
