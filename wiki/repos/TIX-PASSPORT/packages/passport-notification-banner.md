---
title: NotificationBanner
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-notification-banner"
sources:
  - packages/notification-banner/src
  - packages/notification-banner/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# NotificationBanner
> Inline info, success, warning or alert banner with an icon, optional title, text or custom content, an action link, and a close or right icon.

Part of [[passport-packages]].

## What it does
It renders a colored banner whose prefix icon depends on `variant`. Open state can be controlled (`isOpen`) or uncontrolled (always starts open). Closing collapses it through [[passport-collapse]], animated when `withTransition` is set. Content can be a string, with optional `actionText` and `onClickAction` and a line clamp, or arbitrary React nodes.

## Public API
`NotificationBanner` (also in [[passport-umbrella]]); types `NotificationBannerProps`, `NotificationBannerVariant`, `NotificationBannerType`, `ContentProps`.

| Prop | Default | Notes |
|---|---|---|
| `variant` | `'general'` | `general` (info icon), `success`, `warning`, `alert` |
| `type` | `'sectional'` | `'fullwidth'` for edge-to-edge |
| `title` | | |
| `content` | required | string, or ReactNode (then `actionText`/`contentMaxLine`/`onClickAction` are `never`) |
| `actionText`, `onClickAction`, `contentMaxLine` | `0` | string-content only. Line clamp via `-webkit-line-clamp` |
| `isOpen`, `withTransition`, `withClose`, `onClose` | uncontrolled, `false`, `false` | |
| `rightIcon`, `onClickRightIcon` | | replaces the close button |
| `truncatedMaxLines` | | clamp used only when the accessibility mode in `usePassport()` is on |
| `contentTextVariant` | | `lowEmphasis` / `highEmphasis` |

## Usage
```tsx
<NotificationBanner variant="warning" title="Pembayaran tertunda"
  content="Selesaikan pembayaran dalam 1 jam." actionText="Lihat detail"
  onClickAction={openDetail} withClose />
```

## Depends on
[[passport-collapse]], [[passport-typography]], [[passport-utils]], [[passport-button]], icons.

## Used by
- Inside TIX-PASSPORT: 7 packages: corporate-interim-module, currency-bottom-sheet, header, kuber-price-dynamic-banner, [[passport-language-and-currency-modal]], [[passport-refund-method]], [[passport-wishlist]].
- TIX-NEXT-PAYMENT-FE (3 files via `@tiket/passport`): `app/downpay/components/DownPayInstallment/components/DownPayInstallmentPicker.tsx`, `components/CardComponent/components/CardFormContent/CardFormContent.tsx`, `components/CardComponentV2/components/CardFormContentFields/CardFormContentFields.tsx`.
- TIX-FINTECH-NEXT-FE (12 files across `projects/insurance/claim-center/**` and `projects/refund/**`, e.g. `projects/refund/refund-method/index.tsx`). It also imports the types from `@tiket/passport/types/notification-banner`.

## Gotchas
- `src/NotificationBannerWithButton.tsx` (an illustration plus CTA variant) exists and has stories, but it is **not exported** from the package entry.

## Sources
- packages/notification-banner/src/NotificationBanner.tsx
- packages/notification-banner/src/NotificationBannerWithButton.tsx
- packages/notification-banner/src/index.ts
- packages/notification-banner/package.json
