---
title: Chips Carousel
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-chips-carousel"
umbrella: true
sources:
  - packages/chips-carousel/src
  - packages/chips-carousel/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Chips Carousel
> Horizontal scroller for a row of chips, with prev/next arrow buttons that appear only when content overflows.

## What it does
It wraps each child in a `div` (with `chipWrapperClassName`) inside a horizontally scrollable track. `useOverflow` from [[passport-utils]] decides whether to show the left and right arrow buttons ([[passport-button]], inverted secondary). Each arrow smooth-scrolls by 300 px. The component doesn't care what the children are. It's usually [[passport-chips]] `Chip`.

## Public API
`ChipsCarousel` with `children` and `chipWrapperClassName?`. Type: `ChipsCarouselProps`.

## Usage
```tsx
<ChipsCarousel chipWrapperClassName={styles.chip}>
  {filters.map((f) => <Chip key={f.id} isActive={f.id === active} onClick={() => setActive(f.id)}>{f.label}</Chip>)}
</ChipsCarousel>
```

## Depends on
[[passport-button]], [[passport-icons]], [[passport-utils]]. [[passport-chips]] is a devDep used only in stories.

## Used by
- Through the umbrella `@tiket/passport`: TIX-FINTECH-NEXT-FE `app/gift-card/checkout/components/{CardInventories,GiftCardCarousel,RecipientDynamicForm}` ([[fintech-fe-gift-card]]).
- Internal: 6 packages ([[passport-banner-carousel]], [[passport-banner-grid]] as devDeps; [[passport-global-search]], [[passport-page-module-shared]], [[passport-page-module]], [[passport-promo-carousel]]).

## Gotchas
- Arrow aria-labels are hard-coded English ("Previous" / "Next").

## Sources
- `packages/chips-carousel/src/ChipsCarousel.tsx`
- `packages/chips-carousel/package.json`
