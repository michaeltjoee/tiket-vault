---
title: Bottom App Bar
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-bottom-app-bar"
umbrella: true
sources:
  - packages/bottom-app-bar/src
  - packages/bottom-app-bar/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Bottom App Bar
> Mobile bottom action bar container with an optional upper strip (labels, info) and a main CTA row.

## What it does
These are layout-only wrappers. `BottomAppBar` adds padding for `--safe-area-bottom`, and optional shadow and top radius. `BottomAppBarUpper` is a plain slot. `BottomAppBarMain` lays out the CTA content. The bar does **not** position itself. Make it sticky or fixed in the consumer.

## Public API
| Export | Props |
|---|---|
| `BottomAppBar` | `children`, `withShadow?`, `withRadius?`, `className?`, `style?` |
| `BottomAppBarUpper` | `children`, `className?`, `style?` |
| `BottomAppBarMain` | `children`, `className?`, `style?` |
Types: `BottomAppBarProps`, `BottomAppBarUpperProps`, `BottomAppBarMainProps`.

## Usage
```tsx
<BottomAppBar withShadow>
  <BottomAppBarUpper><Label color="lpg_gradient">Low Price Guarantee</Label></BottomAppBarUpper>
  <BottomAppBarMain><Button fullWidth>Continue</Button></BottomAppBarMain>
</BottomAppBar>
```

## Depends on
[[passport-utils]], `classnames`. Tokens come from [[passport-design-tokens]] in SCSS.

## Used by
- Through the umbrella `@tiket/passport`: TIX-NEXT-PAYMENT-FE `app/payment/components/PromoTnCModal/PromoTnCModalView.tsx` ([[payment-fe-payment]]) and TIX-FINTECH-NEXT-FE `projects/insurance/…/SelectBankAccountForm.tsx` and `OrderDetails.tsx`.
- Internal: [[passport-gift-voucher-claim-widget]], [[passport-page-module]], [[passport-promo-code-popup]], [[passport-wishlist]].

## Gotchas
- The root renders `data-disable-a11y="true"`. On mobile, `design-tokens/a11y-support.css` then pins font-size variables to px inside the bar, so text in it ignores the OS large-text setting. See [[passport-design-tokens]].

## Sources
- `packages/bottom-app-bar/src/BottomAppBar.tsx`, `src/__tests__/BottomAppBar.spec.tsx`
- `packages/design-tokens/a11y-support.css`
- `packages/bottom-app-bar/package.json`
