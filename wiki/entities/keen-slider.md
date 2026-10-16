---
title: keen-slider (carousel library)
kind: entity
repos: [TIX-PASSPORT]
sources:
  - TIX-PASSPORT/packages/design-tokens/base.css
  - TIX-PASSPORT/packages/design-tokens/keen-slider.css
  - TIX-PASSPORT/packages/*/package.json
verified_at:
  TIX-PASSPORT: 7a33010aca
updated: 2026-10-16
status: current
tags: [kind/entity, repo/passport]
---

# keen-slider
> keen-slider is the third-party carousel library behind Passport's sliders. Nine packages depend on it (`^6.6.14`), and [[passport-design-tokens]] ships its stylesheet inside `base.css`.

## Where Passport uses it
[[passport-global-search]], [[passport-gradient-banner]], [[passport-highlight-discover]] (`HighlightDiscoverMobileCarousel`, looping), [[passport-image-preview]], [[passport-page-module]], [[passport-picker]], [[passport-price-module]], [[passport-promo-carousel]] and [[passport-review-widget]].

## Styles
`packages/design-tokens/keen-slider.css` is a vendored copy of the library's CSS, and `base.css` imports it with `@import './keen-slider.css'`. Apps that import `@tiket/passport-design-tokens/base.css` get slider styles globally ([[design-tokens]]). Importing only `variables.css` leaves sliders unstyled.

## Gotchas
- The vendored CSS doesn't follow the npm version. Check it after a keen-slider major upgrade.

## Where it shows up
Pages that link here:
- TIX-PASSPORT: [[passport-highlight-discover]]
- concepts: [[design-tokens]]

## Sources
- TIX-PASSPORT `packages/design-tokens/{base.css,keen-slider.css}`
- `git grep '"keen-slider"' origin/main -- 'packages/*/package.json'`
