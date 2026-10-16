---
title: Image
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-image"
sources:
  - packages/image/src
  - packages/image/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Image
> One component, `DefaultImageWrapper`: a `div` whose background is the tiket placeholder image, so the placeholder shows until (or instead of) the real image.

Part of [[passport-packages]].

## What it does
`DefaultImageWrapper` renders a `div` with a CSS background of the standard tiket placeholder (from `s-light.tiket.photos`), set to `cover` and centred. On mobile it uses the `platform-android-low` rendition and elsewhere `platform-android-mid`. Put the real `<img>` inside. If the image fails or hasn't loaded, the placeholder shows through. The package has no image-loading logic of its own. Consumers pair it with their own `imageRenderer` or with `useImage` from [[passport-page-module-shared]].

## Public API
`DefaultImageWrapper`. Props are all `div` props plus `showDefaultImage?: boolean`.

## Usage
```tsx
<DefaultImageWrapper className={styles.image_container}>
  {image && imageRenderer({ src: image, alt: imageAlt, className: styles.default_image })}
</DefaultImageWrapper>
```
(from `packages/product-card/src/components/ProductCard.tsx`)

## Depends on
[[passport-design-tokens]] (breakpoint mixin, in SCSS). `@tiket/passport-utils` is declared but not imported.

## Used by
- No direct importers in the other repos.
- Internal: [[passport-gift-voucher]] (stories only, devDependency), [[passport-global-search]], [[passport-highlight-discover]], [[passport-kuber-price-dynamic-banner]], [[passport-page-module]], [[passport-page-module-shared]], [[passport-pricing-promo]], [[passport-product-card]], [[passport-promo-carousel]], [[passport-review-widget]], [[passport-seo]].

## Gotchas
- `showDefaultImage` is typed but never read. It's spread onto the DOM `div`, which can make React warn about an unknown attribute. Don't pass it.
- The wrapper sets no size. Give it dimensions (or an aspect ratio) through `className`, or the background has nothing to fill.

## Sources
- `packages/image/src/components/DefaultImageWrapper/DefaultImageWrapper.tsx`, `packages/image/src/components/DefaultImageWrapper/DefaultImageWrapper.module.scss`
- `packages/image/package.json`
