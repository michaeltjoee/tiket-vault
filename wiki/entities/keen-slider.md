---
title: keen-slider (carousel library)
kind: entity
repos: [TIX-PASSPORT, TIX-HOMEPAGE-NEXT-FE]
sources:
  - TIX-PASSPORT/packages/design-tokens/base.css
  - TIX-PASSPORT/packages/design-tokens/keen-slider.css
  - TIX-PASSPORT/packages/*/package.json
  - TIX-HOMEPAGE-NEXT-FE/package.json
  - TIX-HOMEPAGE-NEXT-FE/pages/destination/[slug]/components/Slider/index.tsx
verified_at:
  TIX-PASSPORT: 7a33010aca
  TIX-HOMEPAGE-NEXT-FE: 408983f6
updated: 2026-10-16
status: current
tags: [kind/entity, repo/passport, repo/homepage-fe]
---

# keen-slider
> keen-slider is the third-party carousel library behind Passport's sliders. Nine packages depend on it (`^6.6.14`), and [[passport-design-tokens]] ships its stylesheet inside `base.css`.

## Where Passport uses it
[[passport-global-search]], [[passport-gradient-banner]], [[passport-highlight-discover]] (`HighlightDiscoverMobileCarousel`, looping), [[passport-image-preview]], [[passport-page-module]], [[passport-picker]], [[passport-price-module]], [[passport-promo-carousel]] and [[passport-review-widget]].

## Outside Passport
TIX-HOMEPAGE-NEXT-FE depends on it directly (`^6.8.6`). The destination page's own `Slider` uses `useKeenSlider` and imports `keen-slider/keen-slider.min.css` from npm, on top of the vendored copy that `base.css` already loads in `_app` ([[homepage-fe-destination]]).

## Styles
`packages/design-tokens/keen-slider.css` is a vendored copy of the library's CSS, and `base.css` imports it with `@import './keen-slider.css'`. Apps that import `@tiket/passport-design-tokens/base.css` get slider styles globally ([[design-tokens]]). Importing only `variables.css` leaves sliders unstyled.

## Gotchas
- The vendored CSS doesn't follow the npm version. Check it after a keen-slider major upgrade.

## Where it shows up
Pages that link here:
- TIX-HOMEPAGE-NEXT-FE: [[homepage-fe-overview]]
- TIX-PASSPORT: [[passport-highlight-discover]]
- concepts: [[design-tokens]]

## Sources
- TIX-PASSPORT `packages/design-tokens/{base.css,keen-slider.css}`
- `git grep '"keen-slider"' origin/main -- 'packages/*/package.json'`
- TIX-HOMEPAGE-NEXT-FE `package.json`, `pages/destination/[slug]/components/Slider/index.tsx`, `pages/_app.page.tsx`
