---
title: Voucher Card
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-voucher-card"
umbrella: true
sources:
  - packages/voucher-card/src
  - packages/voucher-card/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Voucher Card
> A coupon-shaped container: a rounded card with semicircular "ticket" cut-outs on the left and right edges, a solid or gradient token background, and a drop-shadow elevation.

Part of [[passport-packages]].

## What it does
`VoucherCard` renders two `div`s. The outer one carries the size class and a `filter: drop-shadow(...)` elevation (a drop-shadow follows the masked shape, which `box-shadow` wouldn't). The inner one carries the background and padding and is masked with SVG cut-outs. The cut-outs are inline data-URL SVGs whose size scales with `sizeVariant`: small 12×20, medium 18×30, large 24×40. Padding defaults per size: small 16/8, medium 24/12, large 32/16 px (x/y). There's no content structure. Put whatever you need in `children`.

## Public API
`VoucherCard` (forwardRef to the outer `div`); type `VoucherCardProps`.
| Prop | Notes |
|---|---|
| `sizeVariant` | `small`, `medium`, `large` (required) |
| `color` | `SolidAndGradientToken` from [[passport-design-tokens]], default `N0` (white) |
| `elevation` | `0`, `1` (default), `2` |
| `padding` | overrides the size's default padding |
| `onClick` | adds a pointer cursor. It's on the inner `div`, with no keyboard handler |
| `className` | goes to the **inner** card |
| rest (e.g. `data-testid`) | goes to the outer `div` |

## Usage
```tsx
<VoucherCard sizeVariant="small" className={styles.card} ref={ref} data-testid="promo-code-grid-card" onClick={open}>
  <PromoCodeContent … />
</VoucherCard>
```
(adapted from `packages/global-popup/src/components/Combination/modules/PromoCode/PromoCodeCard.tsx`)

## Depends on
[[passport-design-tokens]] (`computeSolidAndGradientBgStyle`, SCSS mixins). `@tiket/passport-utils` is declared.

## Used by
- No importers in the other repos.
- Internal: [[passport-global-popup]] (promo-code and voucher cards), [[passport-page-module]], and the umbrella `@tiket/passport`.

## Gotchas
- The cut-out mask only applies in browsers that pass `@supports (grid-template-rows: subgrid)`, used as a proxy for iOS 16+ where masks render correctly. Older browsers get a plain rounded card.
- `className` styles the inner card, but `ref` and the other props land on the outer wrapper.
- `onClick` gives no keyboard access. Wrap the card in a button or link if it must be focusable.

## Sources
- `packages/voucher-card/src/VoucherCard.tsx`, `packages/voucher-card/src/VoucherCard.module.scss`
- `packages/voucher-card/package.json`
