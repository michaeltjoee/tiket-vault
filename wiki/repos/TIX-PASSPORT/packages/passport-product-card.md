---
title: ProductCard
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-product-card"
sources:
  - packages/product-card/src
  - packages/product-card/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# ProductCard
> Generic image product card plus vertical-specific cards (accommodation, flight, train, airport transfer, car rental) used by page-module product carousels and grids.

Part of [[passport-packages]].

## What it does
- `ProductCard` is a generic linked card (`href`, a forwarded ref to `<a>`): an image with an optional ribbon (`ribbonColor` red/blue/green/orange, or a `customRibbon` hex triple), a label, `importantInfo`, `productStatus` and `children`. Compose the children from `ProductName`, `ProductInfo` and `ProductPrice` (the `product-*` files). Images go through `imageRenderer`, which defaults to an `<img>` that is lazy unless `isCriticalImage`. Override it for `next/image` (see `src/WithNextImage.mdx`).
- `ProductCardGrid` lays the cards out in a grid. `ProductCardLoading` and the `*Loading` variants are skeletons.
- Vertical cards take page-module `ProductCardData`: `AccomProductCard` (star rating, review score, top-property label, promo list via `normalizeAccomodationPromoList`, price via [[passport-price-module]]), `FlightProductCard` (with `PriceDropBanner`), `TrainProductCard`, `AirportTransferProductCard`, `CarRentalProductCard`. They build URLs with page-module's `useComposeUrl` and fire impressions with `useImpression`.
- `AccomProductSpriteProvider` renders the review flower and star SVG sprites once for all accommodation cards. [[passport-page-module]] mounts it at its root.

## Public API
`ProductCard`, `defaultImageRenderer`, `ProductCardGrid`, `ProductCardLoading`, the product-name, product-info and product-price parts, `AccomProductCard`, `FlightProductCard`, `TrainProductCard`, `AirportTransferProductCard`, `CarRentalProductCard` (each with a loading variant), `AccomProductSpriteProvider`, and types (`ProductCardProps`, …). Not in [[passport-umbrella]].

## Usage
```tsx
<ProductCard href={url} image={img} imageAlt={name} ribbon="Promo" ribbonColor="red"
  imageRenderer={({ src, alt }) => <Image src={src} alt={alt} fill />}>
  <ProductName>{name}</ProductName>
</ProductCard>
```
Docs: `src/ProductCard.mdx`, `src/ProductCardGrid.mdx`, `src/WithNextImage.mdx`.

## Depends on
[[passport-page-module]] (runtime: `useComposeUrl`, `useImpression`, `FLIGHT_AND_TRAIN_CARD_WIDTH_*`, `VERTICAL_DEFAULT_FORMAT_ENUM`, plus types), [[passport-page-module-shared]], [[passport-price-module]], [[passport-card]], [[passport-image]], [[passport-label]], [[passport-tooltip]], [[passport-divider]], [[passport-content-loader]], [[passport-design-tokens]], [[passport-typography]], [[passport-utils]], assets, icons, `@tiket/react-common-utilities`. External: `react-intersection-observer`.

## Used by
- Inside TIX-PASSPORT: [[passport-page-module]] and [[passport-global-popup]] at runtime. [[passport-page-module-shared]] (types) and [[passport-highlight-discover]] list it only as a devDependency.
- No direct consumers in the other workspace repos.

## Gotchas
- **Circular runtime dependency with page-module.** product-card imports hooks and constants from the `@tiket/passport-page-module` root (`dist`), and page-module imports product-card. Under the [[page-module-next-poc]] this puts about 5 small page-module dist utils in the initial chunk next to the src copies. The noted fix is to move those utils out of page-module.

## Sources
- packages/product-card/src/index.ts
- packages/product-card/src/components/ProductCard.tsx
- packages/product-card/src/components/AccomProductCard/AccomProductCard.tsx
- packages/product-card/src/components/AccomProductCard/AccomProductSpriteContext.tsx
- packages/product-card/src/components/FlightProductCard/FlightProductCard.tsx
- packages/product-card/package.json
