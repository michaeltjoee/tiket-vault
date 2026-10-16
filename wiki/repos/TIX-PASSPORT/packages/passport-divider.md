---
title: Divider
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-divider"
sources:
  - packages/divider/src
  - packages/divider/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Divider
> A horizontal or vertical separator line in default, bold or dashed style.

## What it does
It renders an empty `div`. The classes for `alignment` and `variant` set the border colour, thickness and style from design tokens. Extra `div` props pass through.

## Public API
`Divider`, plus types `DividerProps`, `Alignment` (`horizontal | vertical`, default horizontal) and `Variant` (`default | bold | dashed`, default `default`).

## Usage
```tsx
<Divider />
<Divider variant="bold" />
<Divider alignment="vertical" variant="dashed" />
```

## Depends on
[[passport-utils]], `classnames`. Colours come from [[passport-design-tokens]].

## Used by
- Through the umbrella `@tiket/passport`: TIX-NEXT-PAYMENT-FE (about 50 files) and TIX-FINTECH-NEXT-FE (about 91 files, e.g. [[fintech-fe-gift-card]] checkout). FINTECH's `vitest.setup.tsx` mocks it.
- Internal: 28 packages.

## Gotchas
- A vertical divider has no intrinsic height. Its parent needs a height, or flex `align-items: stretch`.
- The exported type names `Variant` and `Alignment` are generic. Alias them when you import alongside other packages' types.

## Sources
- `packages/divider/src/Divider.tsx`
- `packages/divider/package.json`
