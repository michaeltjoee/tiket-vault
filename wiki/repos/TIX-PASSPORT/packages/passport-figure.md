---
title: Figure
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-figure"
umbrella: true
sources:
  - packages/figure/src
  - packages/figure/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Figure
> Illustration + title + description + up to two buttons, for empty states, confirmations and the body of [[passport-dialog]].

## What it does
It renders a `<section>` with an optional `image` node, an `h2` title styled h3, a description, and primary and secondary [[passport-button]]s that show when their text is set. The layout is `portrait` (stacked, centered) or `landscape` (image beside text, optionally left-aligned). `variant="fullWidth"` is what Dialog uses. `mode="inverted"` switches the text to the invert colour for dark backgrounds.

## Public API
`Figure`, plus types `FigureProps`, `FigureVariant` (`default | fullWidth`), `Mode` (`default | inverted`).
| Prop | Default |
|---|---|
| `title` (string), `description` (string or JSX) | required |
| `image` | — |
| `primaryButtonText` + `onPrimaryButtonClick` + `isPrimaryButtonLoading` | |
| `secondaryButtonText` + `onSecondaryButtonClick` + `isSecondaryButtonLoading` | |
| `fullWidthButton` | `true` |
| `layout` | `portrait` (or `landscape`) |
| `horizontalAlignment` | `center` (left only in landscape) |
| `variant`, `mode`, `truncatedMaxLines`, `avoidFallbackText` | |
| `titleSize` | **deprecated**, no effect |

## Usage
```tsx
<Figure image={<img src={tds_si_no_result} alt="" />} title="No orders yet" description="Your bookings will appear here." primaryButtonText="Explore" onPrimaryButtonClick={goHome} />
```

## Depends on
[[passport-button]], [[passport-typography]], [[passport-utils]] (deep import of `src/context.module.scss` for accessibility styles).

## Used by
- Through the umbrella `@tiket/passport`: TIX-NEXT-PAYMENT-FE `app/payment-link/[method]/complete/components/Failed/Failed.tsx`, `components/OTP/ErrorPopup/ErrorPopup.tsx` ([[payment-fe-payment-link]], [[payment-fe-components]]). TIX-FINTECH-NEXT-FE `components/NotFound/index.tsx` and claim-center states. TIX-REACT-COMMON `react-common-error-handler` `ErrorRenderer.tsx` ([[react-common-error-handler]]).
- Internal: 7 packages ([[passport-dialog]], [[passport-currency-bottom-sheet]], [[passport-language-and-currency-modal]], [[passport-notification-login]], [[passport-otp-form]], [[passport-refund-method]], [[passport-reseller-finance-module]]).

## Sources
- `packages/figure/src/Figure.tsx`
- `packages/figure/package.json`
