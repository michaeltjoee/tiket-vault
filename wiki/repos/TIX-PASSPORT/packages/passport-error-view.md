---
title: Error View
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-error-view"
sources:
  - packages/error-view/src
  - packages/error-view/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Error View
> Standard error state with an illustration, localized title, description and buttons, in full-screen or inline layout.

## What it does
`variant` picks a default illustration from [[passport-assets]] and default en/id copy from `constants.ts`. Any `title`, `description` or button text prop overrides those defaults. Buttons render when there's text or a click handler. `offline-mode` has a secondary "Reload" plus a primary "Settings". `low-urgency` is a compact warning layout with a small button, no secondary button, and an optional inverted button.

| Variant | Image | Default copy (en) |
|---|---|---|
| `generic` | `tds_si_error_unknown` | "Sorry, there is a problem" + Reload |
| `server` | `tds_si_error_server` | "Please wait. Improvements are being made" + Reload |
| `offline-mode` | `tds_si_error_no_internet_connection` | "You need an internet connection" + Settings / Reload |
| `offline-mode-without-settings` | same | same + Reload only |
| `low-urgency` | `tds_mi_warning_sign` | "Sorry, there is a problem" + small Reload |

## Public API
`ErrorView`, plus types `ErrorViewProps`, `Variant`, `VariantUIProps`.
| Prop | Default | Notes |
|---|---|---|
| `variant` (required) | | |
| `isFullScreen` | `true` | `false` gives the inline layout used inside sheets and cards |
| `title`, `description` | variant copy | string or element |
| `primaryButtonText`, `onClickPrimaryButton`, `isPrimaryButtonLoading` | | |
| `secondaryButtonText`, `onClickSecondaryButton`, `isSecondaryButtonLoading` | | |
| `showImage`, `imageRenderer({ src, alt })` | `true`, `<img>` | swap in `next/image` |
| `isFullWidthButton`, `buttonVariant` | | `buttonVariant` only applies to `low-urgency` |
| `avoidFallbackText` | `false` | skip the default button labels |
| `truncatedMaxLines`, `className` | | |

## Usage
```tsx
<ErrorView variant="generic" isFullScreen={false} onClickPrimaryButton={refetch} />
```

## Depends on
[[passport-assets]], [[passport-button]], [[passport-typography]], [[passport-utils]] (`locale`, `isAccessibilityOn`).

## Used by
- Through the umbrella `@tiket/passport`: TIX-NEXT-PAYMENT-FE `components/ErrorBoundary/ErrorBoundary.tsx` and the `components/OrderSummary/components/*V4` sections ([[payment-fe-components]]). TIX-FINTECH-NEXT-FE `app/error.page.tsx`, `components/ErrorBoundary/index.tsx` and claim-center pages ([[fintech-fe-components]]). TIX-REACT-COMMON `packages/react-common-error-handler/src/components/ErrorRenderer/ErrorRenderer.tsx` ([[react-common-error-handler]]).
- Internal: 7 packages ([[passport-bottom-sheet-multi-account]], [[passport-corporate-interim-module]], [[passport-currency-bottom-sheet]], [[passport-global-popup]], [[passport-global-search]], [[passport-language-and-currency-modal]], [[passport-reseller-finance-module]]).

## Gotchas
- With `avoidFallbackText` and no explicit text, the button text becomes the boolean `true`, so an **empty** button still renders. Pass `primaryButtonText={null}` and no handler to hide it.
- Default copy has no `onClick`. Without `onClickPrimaryButton` the "Reload" button does nothing.

## Sources
- `packages/error-view/src/ErrorView.tsx`, `src/constants.ts`, `src/types.tsx`
- `packages/error-view/package.json`
