---
title: LoadingWithIllustration
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-loading"
sources:
  - packages/loading/src
  - packages/loading/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# LoadingWithIllustration
> Full-screen blocking loader with the looping "T-man" video and localized title/description, rendered in a portal.

Part of [[passport-packages]].

## What it does
Mounting it locks page scroll (`usePreventScroll`) and portals a centered card over the page with an autoplaying, muted, looping MP4 (`src/assets/loading-tman-white.mp4`), a title and a description. Default copy comes from the `PassportProvider` locale: en "Relax and take a breath", id "Tunggu sebentar ya". Remove it from the tree to dismiss it, since there is no `isOpen` prop.

## Public API
`LoadingWithIllustration` (also in [[passport-umbrella]]).

| Prop | Notes |
|---|---|
| `title`, `description` | `undefined` uses the default copy. `''` hides the section |
| `thumbnail` | video poster. Defaults to a 1×1 white PNG data URL, which hides the Android WebView "play" poster |
| `truncatedMaxLines` | sets `--max-truncate-line` on the title and description |
| `className` | |

## Usage
```tsx
{isProcessing && <LoadingWithIllustration description="" />}
```

## Depends on
[[passport-portal]], [[passport-typography]], [[passport-utils]] (also deep-imports `@tiket/passport-utils/src/context.module.scss` for accessibility styles).

## Used by
- Inside TIX-PASSPORT: [[passport-reseller-finance-module]]. [[passport-otp-unm]] lists it only as a devDependency.
- TIX-NEXT-PAYMENT-FE via `@tiket/passport`: `pages/payment/[type]/complete/components/SuccessV2/SuccessV2.tsx`, `pages/payment/providers/PaymentPersistenceStatusProvider/PaymentPersistenceStatusProvider.tsx`, app-router `SuccessV2`.
- TIX-FINTECH-NEXT-FE: `app/gift-card/redeem/[code]/components/RedeemPageClientComponent/RedeemPageClientComponent.tsx`.

## Gotchas
- The video is referenced with `new URL('./assets/…mp4', import.meta.url)`. The consumer's bundler must handle asset URLs, and `sideEffects` keeps `*.mp4`.
- `'use client'` only. Portal and scroll lock need the DOM.

## Sources
- packages/loading/src/LoadingWithIllustration.tsx
- packages/loading/src/constants.ts
- packages/loading/package.json
