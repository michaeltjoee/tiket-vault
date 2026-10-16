---
title: Chips
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-chips"
umbrella: true
sources:
  - packages/chips/src
  - packages/chips/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Chips
> `Chip` button for filters and selections, with active, error, inverted and disabled states, prefix and suffix icons, and a badge slot. Also exports `ChipsIconPulse`.

## What it does
`Chip` is a `<button type="button">` with `b2` text. With `variant="default"` it shows active (`activity` colour), error and inverted styles. With `variant="action"` the state styling is skipped. Icons are cloned with a colour chosen by state (disabled, then active, then inverted), then the icon's own colour, then the default (low-emphasis for prefix, high-emphasis for suffix). A `badge` element gets red unless it sets a colour. `ChipsIconPulse` is a decorative pulsing `div` used to animate a chip icon.

## Public API
| Export | Key props |
|---|---|
| `Chip` (forwardRef `HTMLButtonElement`) | `variant: default \| action`, `mode: default \| inverted`, `size: default \| large` (large is desktop-only), `isActive`, `isError`, `disabled`, `prefixIcon`, `suffixIcon`, `badge`, `align: left \| center`, `borderRadius: 'full' \| '8px'`, plus all `button` props |
| `ChipsIconPulse` | `div` props |
Types: `ChipProps`, `ChipOwnProps`, `ChipsIconPulseProps`.

## Usage
```tsx
<Chip isActive={sort === 'cheapest'} prefixIcon={<IconSort />} onClick={() => setSort('cheapest')}>
  Cheapest
</Chip>
```

## Depends on
[[passport-typography]], [[passport-utils]]. Types from [[passport-design-tokens]] and [[passport-badge]]. Badge and icons are devDeps.

## Used by
- Through the umbrella `@tiket/passport`: TIX-FINTECH-NEXT-FE `app/gift-card/checkout/components/*` ([[fintech-fe-gift-card]]) and `projects/insurance/claim-center/claim-list/.../ViewClaimList.tsx`.
- Internal: 9 packages (banner-carousel, banner-grid, chips-carousel, global-search, page-module-shared, page-module, picker, pricing-promo, promo-carousel).

## Gotchas
- The export is `Chip` (singular) even though the package is `chips`.
- `borderRadius` defaults to the string `'16px'`, which isn't in its own type union. Only `'8px'` changes the style, so `'full'` looks the same as the default.
- `type="button"` is set before the rest props, so you can override it.

## Sources
- `packages/chips/src/Chips.tsx`, `src/icon-animation/ChipsIconPulse.tsx`
- `packages/chips/package.json`
