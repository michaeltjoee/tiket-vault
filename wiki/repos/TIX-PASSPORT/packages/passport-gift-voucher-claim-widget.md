---
title: Gift Voucher Claim Widget
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-gift-voucher-claim-widget"
sources:
  - packages/gift-voucher-claim-widget/src
  - packages/gift-voucher-claim-widget/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Gift Voucher Claim Widget
> Cross-sell section ("claim these vouchers") for booking forms. It shows a carousel of claimable vouchers with T&C and a Claim button, and tracks impressions and claims.

## What it does
It renders a card with a section icon, title, subtitle, an optional coloured ribbon, and voucher cards. The layout is a desktop carousel or a mobile vertical list. The voucher list and claimed state are **fully controlled**: you pass `vouchers` and `claimedVoucherIds`, and `onClaim(id)` must make the API call and update `claimedVoucherIds`. The T&C opens in a modal or bottom sheet that has its own claim button. Claim feedback uses [[passport-snackbar]]. On mobile, `stickyComponentBelowSnackbarHeight` lifts the snackbar above a sticky footer. It renders nothing when `vouchers` is empty.

## Public API
`GiftVoucherClaimWidget`, plus type `GiftVoucherClaimWidgetProps`.
| Prop | Notes |
|---|---|
| `icon`, `title`, `subtitle`, `topColor` | section header and background |
| `ribbon: { text, color, textColor, foldColor, lang }` | BE-driven custom-colour [[passport-label]] ribbon |
| `vouchers: { id, icon, title, verticalTitle, superGraphicImage, tnc: { buttonText, content }, additional? }[]` | |
| `claimedVoucherIds`, `onClaim(voucherId)` | controlled |
| `vertical`, `screenName`, `additionalGtmVariables` | GTM |
| `stickyComponentBelowSnackbarHeight` | mobile only |

## Usage
```tsx
<GiftVoucherClaimWidget {...sectionFromApi} claimedVoucherIds={claimed}
  onClaim={async (id) => { await claimVoucher(id); setClaimed((c) => [...c, id]); }}
  vertical="TTD" screenName="bookingForm" />
```

## Tracking
`eventCategory: crossSellVoucher`. Impression (`claimSection`) fires once when the card intersects the viewport (`useIntersected`), with `eventValue` = voucher titles joined by `;`. Click events cover `claimSection` and `claimVoucher`, with `eventLabel` = `vertical`.

## Depends on
[[passport-card]], [[passport-label]], [[passport-bottom-sheet]], [[passport-modal]], [[passport-bottom-app-bar]], [[passport-button]], [[passport-collapse]], [[passport-snackbar]], [[passport-supergraphic]], [[passport-assets]], [[passport-icons]], [[passport-typography]], [[passport-utils]].

## Used by
- No direct imports in other repos on their baselines. It's available through the umbrella. Booking-form apps outside this workspace (TTD, etc.) are the target. The response shape is documented on Confluence "Gift Voucher Cross Sell - Booking Form - TTD" (linked in `types.ts`).
- Internal: none.

## Sources
- `packages/gift-voucher-claim-widget/src/GiftVoucherClaimWidget.tsx`, `src/types.ts`, `src/GiftVoucherClaimWidget.trackers.ts`
- `packages/gift-voucher-claim-widget/package.json`
