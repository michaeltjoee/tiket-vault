---
title: Info Banner
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-info-banner"
sources:
  - packages/info-banner/src
  - packages/info-banner/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Info Banner
> An inline message box with an icon, an optional title, content, an action link and a close button. It comes in `general`, `warning` and `alert` variants and collapses when dismissed.

Part of [[passport-packages]].

## What it does
`InfoBanner` is wrapped in a [[passport-collapse]], so closing it animates the height (with `withTransition`). It renders a 44×44 icon: either your element, an image URL, or the variant's default image (also the fallback when the URL errors). Next to it come a bold `b1` title and either `children` or a `b3` `content` with an optional bold `actionText` link. `setBannerBackgroundColor` takes a solid or gradient TDS background token. With a gradient, the text and close icon switch to `invert` and the [[passport-supergraphic]] decoration is hidden. Line clamps (`titleMaxLine`, `contentMaxLine`, `actionTextMaxLine`) are replaced by `truncatedMaxLines` when accessibility mode is on.

## Public API
`InfoBanner`, plus types `InfoBannerProps` (`WithElementProps<InfoBannerOwnProps, 'div'>`), `InfoBannerOwnProps`, `InfoBannerVariant`, and the union parts `ContentProps`, `ActionProps`, `IconProps`.
| Prop | Notes |
|---|---|
| `isOpen` | controlled visibility. If it isn't a boolean, the banner manages its own state and closes on ×. |
| `variant` | `general` (default), `warning`, `alert` |
| `title`, `content` | `content` is a string, or a node (when it's a node, `contentMaxLine` is disallowed) |
| `actionText` + `onClickAction` | must be passed together (union type) |
| `icon` / `iconAlt` | an image URL plus alt text, or a React element |
| `withClose`, `onClose`, `withTransition` | |
| `supergraphicVariant` | top-right [[passport-supergraphic]] |
| `setBannerBackgroundColor` | `SolidAndGradientTDSEnum` from [[passport-design-tokens]] |
| `titleMaxLine`, `contentMaxLine`, `actionTextMaxLine`, `truncatedMaxLines` | line clamps |
| `children` | replaces `content` and the action |

## Usage
```tsx
<InfoBanner
  isOpen
  variant="warning"
  title="Complete your payment"
  content="Your booking will be cancelled in 30 minutes."
  actionText="See details"
  onClickAction={openDetails}
/>
```

## Depends on
[[passport-collapse]], [[passport-supergraphic]], [[passport-design-tokens]] (`computeTDSolidAndGradientBgStyle`, `gradientTDSEnums`), [[passport-typography]], [[passport-icons]], [[passport-utils]] (`usePassport().isAccessibilityOn`). `@tiket/passport-button` is declared but not imported.

## Used by
- TIX-NEXT-PAYMENT-FE: `components/OrderSummary/.../HotelMultiOrder/MultipleOrder` imports the package directly and maps the API `alert.type` to `variant` ([[payment-fe-components]]). [[payment-fe-downpay]] wraps it in `DownPayInfoBanner`, `DownPayConfirmPaymentInfoBanner` and `DownPaySuccessPaymentInfoBanner`.
- TIX-FINTECH-NEXT-FE: `LoginCard` in [[fintech-fe-gift-card]], through the umbrella `@tiket/passport`. `vitest.setup.tsx` mocks the package (`__mocks__/@tiket/passport-info-banner`).
- Internal: [[passport-corporate-interim-module]], [[passport-global-search]], [[passport-kuber-price-dynamic-banner]], and the umbrella `@tiket/passport`.

## Gotchas
- When `children` is set, `content`, `actionText` and `onClickAction` aren't rendered.
- The close button calls `stopPropagation`, so a click handler on the banner doesn't fire when it's dismissed.
- The default variant icons are remote PNGs on `s-light.tiket.photos`, not SVGs from [[passport-icons]].

## Sources
- `packages/info-banner/src/InfoBanner.tsx`, `packages/info-banner/src/components/image/Image.tsx`
- `packages/info-banner/package.json`
