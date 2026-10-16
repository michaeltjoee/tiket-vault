---
title: Icons
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-icons"
sources:
  - packages/icons/src
  - packages/icons/assets
  - packages/icons/CONTRIBUTING.md
  - packages/icons/package.json
  - scripts/icons-generator
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Icons
> About 460 inline-SVG React icon components (`IconArrowLeft`, `IconPlus`, …), generated from the SVG files in `assets/`.

Part of [[passport-packages]].

## What it does
Each icon is a small component that renders an `<svg>`. `size` maps to a pixel width and height, and `color` maps to a design-token CSS variable or a raw colour string. Dynamic-colour icons (`assets/dynamic-colors/<segment>/`, about 440) take `color`. Static-colour icons (`assets/static-colors/`, about 20 brand marks) only take `size`. 74 other packages list it as a runtime dependency. Only [[passport-utils]] (124) and [[passport-typography]] (97) have more.

## Public API
- `Icon<Name>` components: 463 named exports in `src/index.ts`.
- `IconWishlistAnimated` is written by hand (`isLiked`, `size`). It plays a "like" animation when `isLiked` goes from false to true.
- `SIZES`: `xxs` 12, `xs` 16, `sm` 20, `md` 24 (default), `lg` 32, `xl` 40, `xxl` 48.
- Types: `IconProps` (= `DynamicColorsIconProps`), `StaticColorsIconProps`, `IconColor`, `IconSize`.

| Prop | Notes |
|---|---|
| `size` | `IconSize`, default `md` |
| `color` | an `IconColorToken` from [[passport-design-tokens]] (`high-emphasis`, `low-emphasis`, `invert`, `disabled`, `positive`, `alert`, `price`, `usp`, `static-white`, …) or any CSS colour. Default `default` (= high-emphasis) |
| rest | any `svg` attribute |

## Usage
```tsx
import { IconArrowLeft, IconPlus } from '@tiket/passport-icons';

<IconArrowLeft size="xs" color="invert" />
<Button icon={<IconPlus />}>Add</Button>
```

## Depends on
[[passport-design-tokens]] (`iconColorTokenToCSSVar`, `colors`), [[passport-utils]] (`WithElementProps`, `usePrevious`).

## Used by
- TIX-NEXT-PAYMENT-FE: direct imports in [[payment-fe-downpay]] (`DownPayConfirmation`, `DownPayInstallment*`) and others. Its `.cursor/skills/migrate-tiket-packages/SKILL.md` covers migrating to it.
- TIX-FINTECH-NEXT-FE: [[fintech-fe-gift-card]] (order navigation, share link, sender form, collapsible text).
- TIX-REACT-REMOTE: `src/components/reviews/reload-component/ReloadComponent.tsx` ([[react-remote-reviews]]).
- Internal: almost every UI package, e.g. [[passport-header]], [[passport-page-module]], [[passport-tabs]], [[passport-wishlist]]. [[passport-button]], [[passport-chips]], [[passport-label]], [[passport-list]] and a few others list it only as a devDependency, for stories. [[passport-button]], for example, takes icons as elements from the caller.

## Gotchas
- `src/components/*` and `src/index.ts` are generated, so don't edit them. To add or change an icon: put the optimised SVG under `assets/dynamic-colors/<segment>/` or `assets/static-colors/`, then run the root `generate:icons` script (`scripts/icons-generator`). It regenerates every icon. Commit the SVG together with the generated output.
- In source SVGs, `fill="white"` is special syntax. The generator turns it into `getInsideFill(color)`, so an inner shape flips to dark when `color="invert"`. Write `fill="#fff"` for a white that should stay white.
- `green`, `yellow`, `warning`, `default` and `black` colours are deprecated (not part of TDS).
- Prop types and colour constants live outside the generated files (`src/types.ts`, `src/constants.ts`), so you can change them without regenerating. Keep the two in sync.

## Sources
- `packages/icons/src/index.ts`, `packages/icons/src/types.ts`, `packages/icons/src/constants.ts`, `packages/icons/src/utils.ts`
- `packages/icons/src/components/IconArrowLeft.tsx` (generated sample)
- `packages/icons/src/non-generated-components/IconWishlistAnimated/IconWishlistAnimated.tsx`
- `packages/icons/CONTRIBUTING.md`, `packages/icons/package.json`, root `package.json` (`generate:icons`)
