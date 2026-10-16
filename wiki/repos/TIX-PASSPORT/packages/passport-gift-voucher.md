---
title: Gift Voucher
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-gift-voucher"
umbrella: true
sources:
  - packages/gift-voucher/src
  - packages/gift-voucher/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Gift Voucher
> Composable "ticket stub" voucher card (header / content / perforated divider / footer) with helpers for title, link, voucher code, CTA button and expiry countdown.

## What it does
`GiftVoucher` is the layout shell: a header and optional content on top, a notched dashed divider, and a footer below. You fill the slots with the helpers. `GiftVoucherHeader` (content plus an optional right-side link), `GiftVoucherTitle`, and `GiftVoucherFooter` (footer text with an optional red [[passport-countdown]], plus a `longButton` action row with a voucher-code box and a button, or a `shortButton` inline button). `GiftVoucherList` is a list container. The package holds no data or state.

## Public API
| Export | Key props |
|---|---|
| `GiftVoucher` | `header`, `children`, `footer`, `className`, `headerClassName`, `contentClassName`, `footerClassName` |
| `GiftVoucherHeader` | `children`, `link?: { href, text, variant: 'blue' \| 'black' }` |
| `GiftVoucherTitle` | title text block |
| `GiftVoucherFooter` | `children`, `countdown?: CountdownProps` (no colour or variant overrides), `button?: ButtonProps` (variant primary/secondary/tertiary, no `size`), `variant: 'longButton' \| 'shortButton'`, `voucherCode?` |
| `GiftVoucherList` | `children` |
Types: `GiftVoucherProps`, `GiftVoucherHeaderProps`, `GiftVoucherFooterProps`, `ButtonVariant`, `ButtonSizeVariant`, `LinkVariant`, …

## Usage
```tsx
<GiftVoucher
  header={<GiftVoucherHeader link={{ href: '/tnc', text: 'T&C' }}><GiftVoucherTitle>Disc. 10% Hotel</GiftVoucherTitle></GiftVoucherHeader>}
  footer={<GiftVoucherFooter voucherCode="HOTEL10" button={{ children: 'Copy', variant: 'secondary', onClick: copy }} />}
/>
```

## Depends on
[[passport-button]], [[passport-countdown]], [[passport-typography]], [[passport-utils]], [[passport-design-tokens]] (runtime dep).

## Used by
- Through the umbrella `@tiket/passport`: TIX-NEXT-PAYMENT-FE `app/payment/components/PromoSuggestionCard/PromoSuggestionCard.tsx` ([[payment-fe-payment]]).
- Internal: [[passport-global-popup]], [[passport-kuber-price-dynamic-banner]], [[passport-mission-landing-page]].

## Gotchas
- `package.json` describes it as "Passport Voucher Card Component", the same description as [[passport-voucher-card]]. They're different packages. This one is the slot-based voucher shell.

## Sources
- `packages/gift-voucher/src/GiftVoucher.tsx`, `src/GiftVoucherFooter.tsx`, `src/GiftVoucherHeader.tsx`, `src/GiftVoucherList.tsx`, `src/GiftVoucherTitle.tsx`
- `packages/gift-voucher/package.json`
