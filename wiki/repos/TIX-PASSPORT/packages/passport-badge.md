---
title: Badge
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-badge"
sources:
  - packages/badge/src
  - packages/badge/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Badge
> Notification dot or count pill, either overlaid on a child element or inline.

## What it does
Wraps `children` in a `span` and renders a `Notif` pill. With children, the pill is absolutely positioned (`top-end` or `top`). Without children it renders inline. Empty or undefined `content` gives a plain dot. Red badges with content shimmer by default.

## Public API
`Badge`, plus types `BadgeProps`, `BadgeOwnProps`, `Color` (`green | red | grey`), `Placement` (`top-end | top`), `Content` (`string | number | JSX.Element`).
| Prop | Default | Notes |
|---|---|---|
| `color` | `red` | |
| `content` | — | empty means dot. Pass `<Text openTypeFeature="caseSensitiveForms">+99</Text>` to align `+` |
| `placement` | `top-end` | ignored when there are no children |
| `isNotifShown` | `true` | hide when the count is 0 |
| `isShimmer` | `true` | only affects red pills with content |
Rest props go to the wrapping `span` (`WithElementProps<…, 'span'>`).

## Usage
```tsx
<Badge content={3}><IconBell /></Badge>
<Badge color="green" content="New" />   // inline
```

## Depends on
[[passport-typography]] (`Text` with `noAccessibilitySize`), [[passport-utils]] (types).

## Used by
- Through the umbrella `@tiket/passport`: TIX-NEXT-PAYMENT-FE (5 files, e.g. `app/payment/components/PaymentTileTitle/PaymentTileTitle.tsx`, `app/payment-link/components/PromotedGroupItem/…`; see [[payment-fe-payment]], [[payment-fe-payment-link]]) and TIX-FINTECH-NEXT-FE `projects/insurance/…` (claim list, landing banner).
- Internal: 6 packages ([[passport-bottom-tab-navigation]], [[passport-chips]], [[passport-header]], [[passport-segmented-control]], [[passport-sidebar]], [[passport-tabs]]).

## Gotchas
- The pill text opts out of accessibility font scaling (`noAccessibilitySize`), so it keeps its size when large-text mode is on.

## Sources
- `packages/badge/src/Badge.tsx`, `packages/badge/src/Notif.tsx`, `packages/badge/src/types.ts`
- `packages/badge/package.json`
