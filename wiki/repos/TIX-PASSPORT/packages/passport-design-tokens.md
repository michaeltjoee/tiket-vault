---
title: Design Tokens
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-design-tokens"
umbrella: true
sources:
  - packages/design-tokens
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Design Tokens
> The foundation of Passport styling: global CSS (normalize, reset, CSS variables), the TiketOdyssey font, SCSS breakpoint and mixin helpers, and TS colour-token maps and mappers.

## What it does
It ships three kinds of artifact (see [[design-tokens]] for the cross-repo concept).
1. **Global CSS** that apps import once. `base.css` = `variables.css` (about 730 lines of `:root` vars: colours `--color-B400`…, semantic `--text-color-*`, `--icon-color-*`, typography `--font-size-{h1..xs}`, `--edge-padding`, `--container-max-width`, responsive overrides at 600/840/960/1280/1440 px) + `keen-slider.css` + modern-normalize + reset. `font-loader.css` declares the TiketOdyssey `@font-face`s (fonts in `fonts/`). `a11y-support.css` handles iOS dynamic type: below 840 px it uses `-apple-system-body`, and `[data-disable-a11y='true']` pins font variables back to px.
2. **SCSS partials** used by every package's `.module.scss`: `_breakpoint.scss` (`@include breakpoint(mobile|desktop|small|medium|large|xlarge|xxlarge|xxxlarge)`) and `_mixins.scss` (`text-truncate($lines)`, `gradient($token, $dir)`, `hide-scrollbar`, `always-show-scrollbar`, `plain-button`).
3. **TS tokens** (`index.ts`): `colors`, `alphaColors`, `gradients`, `iconColors`, `backgroundColors`, `strokeColors`, `solidAndGradientTokens`, the TDS-to-FE enum maps, colour mappers (`*-color-mapper.ts`, `color-token-to-css-var`), and `computeSolidAndGradientBgStyle` / `computeTDSolidAndGradientBgStyle`. Types: `TextColorToken`, `IconColorToken`, `BackgroundColorToken`, `StrokeColorToken`, `SolidColorToken`, `SolidAndGradientToken`, `GradientTDSEnum`…

## Public API
- CSS: `@tiket/passport-design-tokens/base.css`, `/font-loader.css`, `/a11y-support.css`, `/variables.css`
- SCSS: `@use '@tiket/passport-design-tokens/breakpoint' as *;` and `@use '@tiket/passport-design-tokens/mixins';`
- TS: `import { colors, computeSolidAndGradientBgStyle, type TextColorToken } from '@tiket/passport-design-tokens'`

## Usage
```tsx
// app root, once
import '@tiket/passport-design-tokens/base.css';
import '@tiket/passport-design-tokens/font-loader.css';
```
```scss
@use '@tiket/passport-design-tokens/breakpoint' as *;
.title { color: var(--text-color-high-emphasis); @include breakpoint(desktop) { font-size: var(--font-size-h2); } }
```

## Depends on
Nothing. It's the root of the dependency graph.

## Used by
- TIX-NEXT-PAYMENT-FE: `app/(root)/globals.scss`, `.storybook/preview.tsx` and many `*.module.scss`. Its `generate-css-modules-types` script aliases `@tiket/passport-design-tokens` for `typed-scss-modules`.
- TIX-FINTECH-NEXT-FE: most `*.module.scss` under `app/` and `projects/`.
- TIX-REACT-REMOTE: `src/index.ts`, `src/components/wrapper/PassportWrapper/index.tsx`, header and country-currency components.
- Internal: 110 of 130 packages. Most list it as a **devDependency** because they only `@use` it from SCSS, which works because consumers install it themselves (README: it comes with `@tiket/passport`).

## Gotchas
- Breakpoints are hard-coded twice, in `_breakpoint.scss` and in the `variables.css` media queries, and also in `page-module-shared/_page-module-container.scss`. Search for `[DUPLICATE_HARDCODED_BREAKPOINTS]` before changing one. Solid colours are duplicated the same way (`[DUPLICATE_HARDCODED_SOLID_COLOR]` in `colors.ts`, `variables.css` and some component SCSS).
- The 840 px boundary (`mobile` ≤839, `desktop` ≥840) is the same one `usePassport().breakpoint` uses at runtime ([[passport-utils]]).
- `source` is the root `index.ts`, not `src/`. `src/index.ts` only re-exports `../index` so tools that resolve `<pkg>/src/index.ts` (e.g. TIX-REACT-REMOTE `consumeFromSource`) still work.
- If an app also loads the legacy react-ui fonts, `font-loader.css` produces duplicate `@font-face` rules (README).

## Sources
- `packages/design-tokens/{index.ts,src/index.ts,package.json,README.md}`
- `packages/design-tokens/{base.css,variables.css,a11y-support.css,font-loader.css,_breakpoint.scss,_mixins.scss,types.ts,utils.ts}`
- `packages/design-tokens/color-mappers/*`
