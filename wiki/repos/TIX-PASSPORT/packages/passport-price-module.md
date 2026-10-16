---
title: PriceModule
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-price-module"
umbrella: true
sources:
  - packages/price-module/src
  - packages/price-module/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# PriceModule
> Compound price block (label(s), slash price, final price with an optional loyalty-tier icon, description) used on product cards. It is the slot-based v1. See [[passport-price-module-v2]] for the prop-based TDS redesign.

Part of [[passport-packages]].

## What it does
`PriceModule` is a container that lays out the slots you pass in and shares `align` with its subcomponents through `PriceModuleContext`. `loyaltyLevel` 1–4 puts a Silver, Gold, Platinum or Diamond icon before the final price. `PriceModuleLabelContainer` is a keen-slider carousel, so several labels can rotate in a narrow card.

## Public API
All are also in [[passport-umbrella]]:
- `PriceModule`: `finalPrice` (required ReactNode), `label`, `slashPrice`, `description`, `loyaltyLevel?: 1|2|3|4`, `align` (`'right'` default | `'left'`), `maxContainerWidth` (default **160** px, set as inline `maxWidth`), `withElevation`, `withRadius`, `withBgColor` (default true), plus any `div` props.
- Slot components: `PriceModuleLabel`, `PriceModuleLabelContainer`, `PriceModuleSlashPrice`, `PriceModuleFinalPrice`, `PriceModuleDescription`.

## Usage
From `PriceModule.stories.tsx`:
```tsx
<PriceModule align="right" loyaltyLevel={1}
  slashPrice={<PriceModuleSlashPrice>IDR 3.000.000</PriceModuleSlashPrice>}
  finalPrice={<PriceModuleFinalPrice>IDR 2.700.000</PriceModuleFinalPrice>}
  description={<PriceModuleDescription>/room/night</PriceModuleDescription>} />
```

## Depends on
[[passport-design-tokens]], [[passport-typography]], [[passport-utils]], icons. External: `keen-slider` (label carousel).

## Used by
- Inside TIX-PASSPORT: [[passport-product-card]].
- No direct consumers in the other workspace repos.

## Gotchas
- The default `maxContainerWidth` of 160 px clamps the block. Pass a larger value, or `Infinity`, for wide layouts.
- `PriceModuleLabelContainer` works around keen-slider issue #398 (slider instance typing). See the comment in its source.

## Sources
- packages/price-module/src/PriceModule.tsx
- packages/price-module/src/PriceModuleContext.tsx
- packages/price-module/src/components/
- packages/price-module/src/PriceModule.stories.tsx
- packages/price-module/package.json
