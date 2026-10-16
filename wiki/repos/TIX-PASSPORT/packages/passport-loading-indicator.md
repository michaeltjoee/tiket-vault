---
title: LoadingIndicator
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-loading-indicator"
umbrella: true
sources:
  - packages/loading-indicator/src
  - packages/loading-indicator/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# LoadingIndicator
> Propless animated three-dot SVG spinner that inherits `currentColor`.

Part of [[passport-packages]].

## What it does
Renders a 120×120 viewBox SVG with two dots and a stroked ring, animated in CSS. It has no props: size it with the parent's width and height, and color it with the parent's `color`. It is the standard inline spinner (for example the loading state in [[passport-button]]).

## Public API
`LoadingIndicator` (also in [[passport-umbrella]]). No props, and `className` is not accepted.

## Usage
```tsx
<span style={{ width: 24, height: 24, color: 'var(--blue)' }}>
  <LoadingIndicator />
</span>
```

## Depends on
[[passport-utils]] (declared only).

## Used by
- Inside TIX-PASSPORT: 15 packages, including button, button-slider, header, phone-verification and refund-method.
- TIX-NEXT-PAYMENT-FE (~19 files, e.g. `app/payment-link/components/PaymentLinkLoadingOverlay/PaymentLinkLoadingOverlay.tsx`) and TIX-FINTECH-NEXT-FE (~6, e.g. `projects/refund/shared/components/LoadingFullPage/index.tsx`), both via `@tiket/passport`.

## Gotchas
- With no wrapper size, the SVG grows to fill its container.

## Sources
- packages/loading-indicator/src/LoadingIndicator.tsx
- packages/loading-indicator/package.json
