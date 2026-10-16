---
title: SnakeAnimation
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-snake-animation"
umbrella: true
sources:
  - packages/snake-animation/src
  - packages/snake-animation/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# SnakeAnimation
> Animated SVG border where one or two gradient "snake" strokes travel around a rounded container. It highlights promo or festive cards.

Part of [[passport-packages]].

## What it does
It wraps `children` in a bordered container and draws an SVG rect over it: a static track stroke plus 1–2 animated dashes (each 25 % of the perimeter). Lap time is `perimeter / pxPerSecond` (default **600 px/s**, with a 2000 ms fallback before measurement). Speed is constant across sizes, so banners of different widths are deliberately not in sync. `snakeColor` takes a design-system gradient token (`GRADIENT_TOKENS`, e.g. `tosca` (default), `purple`, `blue`) or any CSS color. It has no runtime Passport dependencies.

## Public API
`SnakeAnimation` (forwardRef; also in [[passport-umbrella]]); types `SnakeAnimationProps`, `SnakeGradientToken`.

| Prop | Default |
|---|---|
| `strokes` | `1` (or `2`) |
| `strokeSize` | `1` (or `2`) px |
| `borderRadius` | `4` |
| `snakeColor` | `'tosca'` |
| `trackColor` | `'var(--color-N300)'` |
| `pxPerSecond` | `600` |
| `paused` | `false` |
| `children`, `className` | |

## Usage
```tsx
<SnakeAnimation strokes={2} borderRadius={8} snakeColor="purple">
  <PromoCard {...promo} />
</SnakeAnimation>
```

## Depends on
No internal packages. External: `classnames`.

## Used by
- Inside TIX-PASSPORT: [[passport-pricing-promo]].
- No consumers in the other workspace repos. It was added in PR #3236 (NCT-21424).

## Sources
- packages/snake-animation/src/SnakeAnimation.tsx
- packages/snake-animation/src/utils.ts
- packages/snake-animation/package.json
