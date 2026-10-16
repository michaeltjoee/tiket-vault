---
title: Action Banner
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-action-banner"
umbrella: true
sources:
  - packages/action-banner/src
  - packages/action-banner/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Action Banner
> Card-style banner with image, title, description and either one or two buttons or a slide-to-confirm slider.

## What it does
Renders a header (image, bold title, description) and a footer. The footer holds either `secondaryButton` + `primaryButton` (any elements you pass) or a [[passport-button-slider]] when `slider` is set. `color` adds a top-right [[passport-supergraphic]] in that variant.

## Public API
`ActionBanner`, plus types `ActionBannerProps` and `ActionBannerOwnProps`. It also spreads remaining `div` props.
| Prop | Notes |
|---|---|
| `title` (string), `description` (string or JSX), `image` (node) | required |
| `primaryButton`, `secondaryButton` | JSX elements, typically `<Button>` |
| `slider` + `sliderProps: ButtonSliderProps` | discriminated union: `sliderProps` is required iff `slider` |
| `color` | `SupergraphicProps['variant']` |
| `elevation` | default `true` (shadow) vs plain |
| `truncatedMaxLines` | line clamp applied only in accessibility mode |

## Usage
```tsx
<ActionBanner
  title="Complete your profile"
  description="Get faster checkout"
  image={<img src={tds_si_no_result} alt="" />}
  primaryButton={<Button>Complete</Button>}
/>
```

## Depends on
[[passport-button-slider]], [[passport-supergraphic]], [[passport-typography]], [[passport-utils]]. [[passport-button]] is a devDep used only in stories.

## Used by
- No direct imports in other repos on their baselines. It's available through the umbrella `@tiket/passport`.
- Internal: [[passport-kuber-price-dynamic-banner]].

## Gotchas
- The outer element is an extra bare `<div>`. `className` and rest props go on the inner div, so layout styles on the wrapper need a parent.

## Sources
- `packages/action-banner/src/ActionBanner.tsx`
- `packages/action-banner/package.json`
