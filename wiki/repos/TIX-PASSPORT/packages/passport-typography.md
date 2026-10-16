---
title: Typography
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-typography"
sources:
  - packages/typography/src
  - packages/typography/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Typography
> `Text`, the polymorphic text component every Passport package uses. It maps design-system size, weight and colour tokens to CSS classes, and adds an optional diagonal strike-through for slashed prices.

Part of [[passport-packages]].

## What it does
`Text` renders a `span` by default, or any element through `as` (it's built on `react-polymorphic-box` and forwards refs). Size is separate from the tag, so an `<h2>` can be `b2`. Sizes are mobile-first and switch to desktop values at 840 px. On mobile: `h1` 32/38, `h2` 22/28, `h3` 18/24, `b1` 16/22, `b2` 14/20, `b3` 12/16, `sm` 10/14 (`xs` also exists). Font sizes come from CSS variables that scale with the OS accessibility font size. `noAccessibilitySize` swaps in fixed-size classes, picking mobile or desktop from `usePassport().breakpoint`. `diagonalStrikeThrough` wraps the text in a `div` with an SVG line, default colour `R500` and width 2.

## Public API
`Text`, plus the constants `variantConfig`, `sizeConfig`, `weightConfig` (e.g. for building docs or pickers). Types: `TextProps<E>`, `TextOwnProps`, `Size`, `Weight` (`regular` 400, `semibold` 600, `bold` 700), `Align`, `OpenTypeFeature`, `DiagonalStrikeThroughOptions`, and `Variant` (deprecated; use `TextColorToken` from [[passport-design-tokens]]).
| Prop | Values |
|---|---|
| `as` | any element or component, default `span` |
| `size` | `h1`, `h2`, `h3`, `b1`, `b2`, `b3`, `sm`, `xs` |
| `weight` | `regular`, `semibold`, `bold` |
| `variant` | text colour token: `highEmphasis`, `lowEmphasis`, `disabled`, `activity`, `alert`, `positive`, `invert`, `subtleInvert`, `lightInvert`, `price`, `analytics`, `usp`, `crossSell`, `staticWhite`, `staticBlack` |
| `align` | `left`, `center`, `right` |
| `italic` | `true`/`false`. Leave it `undefined` to inherit |
| `openTypeFeature` | `fractions`, `caseSensitiveForms`, `tabularFigures`, `superscript`, `subscript` (TiketOdyssey features) |
| `diagonalStrikeThrough` | `true` or `{ width: 1 \| 2, color: SolidColorToken }` |
| `noAccessibilitySize` | opt out of OS font scaling |

## Usage
```tsx
<Text as="h2" size="h3" weight="bold">Price details</Text>
<Text size="b3" variant="lowEmphasis" diagonalStrikeThrough>IDR 1.200.000</Text>
<Text openTypeFeature="tabularFigures">{countdown}</Text>
```

## Depends on
[[passport-utils]] (`usePassport`), [[passport-design-tokens]] (types, CSS variables, breakpoint mixin); `react-polymorphic-box`.

## Used by
- Nearly every consumer of Passport. TIX-NEXT-PAYMENT-FE ([[payment-fe-components]], [[payment-fe-downpay]], …) and TIX-FINTECH-NEXT-FE ([[fintech-fe-gift-card]], insurance, refund) import `Text` from the umbrella `@tiket/passport`.
- Internal: 97 packages list it as a runtime dependency, so it is effectively the base of the [[passport-design-system]], next to [[passport-icons]] and [[passport-utils]].

## Gotchas
- With `diagonalStrikeThrough` the output is wrapped in a `<div>`, so don't use it inside a `<p>` or inline-only context (invalid nesting causes hydration warnings).
- `noAccessibilitySize` picks its fixed class from the Passport context `breakpoint`. Without a `PassportProvider` breakpoint, `size` falls back to the normal scalable class.
- Colour tokens in `variantConfig` duplicate hard-coded values in `variables.css` (`DUPLICATE_HARDCODED_TEXT_COLORS`), so change both.
- The polymorphic `Box` needs `@ts-expect-error` under React 19 types. If you build wrappers, type them through `TextOwnProps`.

## Sources
- `packages/typography/src/Text.tsx`, `packages/typography/src/constants.ts`, `packages/typography/src/Text.module.scss`, `packages/typography/src/Text.mdx`
- `packages/typography/package.json`
