---
title: PriceModuleV2
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-price-module-v2"
umbrella: true
sources:
  - packages/price-module-v2/src
  - packages/price-module-v2/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# PriceModuleV2
> Prop-driven price block from the TDS "Arta – Price Module V2" spec: price context, slash price and discount %, main price, unit texts, contexts and a tier or chevron icon.

Part of [[passport-packages]].

## What it does
It takes plain strings instead of slot components (compare [[passport-price-module]] v1) and renders the Figma structure: `priceContext` ("Start from"), slash price with a diagonal strike-through plus `slashPricePercentage`, `mainPrice`, `trailingUnit` ("/pax"), `additionalUnit` ("/room/night", the only slot that also accepts a ReactNode), and `primaryContext`/`secondaryContext`. `variant` sets the layout density for image-based (cards) or schedule-based (flight/train rows) products.

## Public API
`PriceModuleV2` (also in [[passport-umbrella]]); types `PriceModuleV2Props`, `MainPriceTextProps`, `PriceModuleV2IconType`.

| Prop | Notes |
|---|---|
| `mainPrice` | required string |
| `mainPriceProps` | `{ size: 'h3'|'b1'|'b2', variant: 'price'|'highEmphasis'|'lowEmphasis' }` |
| `slashPrice`, `slashPricePercentage` | either one shows the slash row |
| `priceContext`, `trailingUnit`, `additionalUnit`, `primaryContext`, `secondaryContext` | |
| `iconType` | `tierDiamond`/`tierPlatinum`/`tierGold`/`tierSilver`/`chevronDown`, always size `xs` |
| `onClickIcon` | makes the icon clickable |
| `align` | `'left'` (default) / `'right'` |
| `variant` | `'imageBased'` (default) / `'scheduleBased'` |

## Usage
```tsx
<PriceModuleV2 priceContext="Mulai dari" slashPrice="IDR 1.200.000" slashPricePercentage="10%"
  mainPrice="IDR 1.080.000" trailingUnit="/pax" iconType="tierGold" align="right" />
```

## Depends on
[[passport-typography]], [[passport-utils]], icons.

## Used by
- No internal dependents and no consumers in the other workspace repos on baseline. It is reached only through `@tiket/passport`.

## Gotchas
- The file has no `'use client'` directive, but `PriceModuleV2Icon` has one.
- Unit tests live in `src/__tests__/PriceModuleV2.spec.tsx` and `src/PriceModuleV2Icon/__tests__/`.

## Sources
- packages/price-module-v2/src/PriceModuleV2.tsx
- packages/price-module-v2/src/PriceModuleV2Icon/PriceModuleV2Icon.tsx
- packages/price-module-v2/package.json
