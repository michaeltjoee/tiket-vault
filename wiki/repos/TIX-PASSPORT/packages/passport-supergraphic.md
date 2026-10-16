---
title: Supergraphic
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-supergraphic"
umbrella: true
sources:
  - packages/supergraphic/src
  - packages/supergraphic/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Supergraphic
> Decorative brand "supergraphic" shape: two translucent gradient SVG blobs pinned to a corner or edge of a banner.

Part of [[passport-packages]].

## What it does
It renders an absolutely positioned wrapper with an SVG whose size and path depend on the breakpoint (`usePassport().breakpoint`, mobile 160×204 or desktop 211×270). The two gradient fills come from `variant`. Gradient ids use a per-instance `uuid`, so several supergraphics on one page don't clash. The component renders only after mount, so there is no SSR output and no hydration mismatch from the uuid or the breakpoint.

## Public API
`Supergraphic` (also in [[passport-umbrella]]); `SupergraphicProps` = `div` props plus:
- `variant`: `high` (white), `medium_blue`, `medium_green`, `low_blue`, `low_orange`, `low_red`, `low_green`. `low` is **deprecated**; use `low_blue`.
- `position`: `top_left`, `center_left`, `bottom_left`, `top_right`, `center_right`, `bottom_right`.

## Usage
```tsx
<div style={{ position: 'relative', overflow: 'hidden' }}>
  <Supergraphic variant="medium_blue" position="top_right" />
  <BannerContent />
</div>
```

## Depends on
[[passport-utils]]. External: `uuid`, `classnames`.

## Used by
- Inside TIX-PASSPORT: [[passport-action-banner]], [[passport-gift-voucher-claim-widget]], [[passport-info-banner]], [[passport-kuber-price-dynamic-banner]].
- TIX-FINTECH-NEXT-FE (about 11 files via `@tiket/passport`): gift-card landing (`GiftHeroImage`, `StaticUspBanner`) and insurance claim-center landing (`MoreInfoSection`, `QuickClaimCard`).

## Gotchas
- The parent needs `position: relative` and usually `overflow: hidden`.
- It renders nothing until the client mounts, so it doesn't appear in screenshots of SSR HTML.

## Sources
- packages/supergraphic/src/Supergraphic.tsx
- packages/supergraphic/package.json
