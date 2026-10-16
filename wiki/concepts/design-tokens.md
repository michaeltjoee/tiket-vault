---
title: Design tokens across repos
kind: concept
repos: [TIX-PASSPORT, TIX-REACT-REMOTE, TIX-NEXT-PAYMENT-FE, TIX-FINTECH-NEXT-FE]
sources:
  - TIX-PASSPORT/packages/design-tokens
  - TIX-REACT-REMOTE/src/components/wrapper/PassportWrapper/index.tsx
  - TIX-REACT-REMOTE/src/index.ts
  - TIX-NEXT-PAYMENT-FE/app/(root)/globals.scss
  - TIX-NEXT-PAYMENT-FE/package.json
verified_at:
  TIX-PASSPORT: 7a33010aca
  TIX-REACT-REMOTE: 281778b
  TIX-NEXT-PAYMENT-FE: 9e92b20bb
  TIX-FINTECH-NEXT-FE: 5833b842
updated: 2026-10-16
status: current
tags: [kind/concept, repo/passport, repo/react-remote, repo/payment-fe, repo/fintech-fe]
---

# Design tokens
> All Passport styling resolves to CSS custom properties defined once in [[passport-design-tokens]]. Every app must load those variables globally and compile the SCSS partials itself, because Passport ships uncompiled SCSS modules.

## How tokens reach a page
1. **Global CSS, once per app.** payment-fe imports `base.css` and `font-loader.css` in `app/(root)/globals.scss`. react-remote imports `base.css` in `src/index.ts` and `variables.css` in the header, the country-and-currency modal and `PassportWrapper`.
2. **SCSS partials at build time.** App and Passport `.module.scss` files `@use '@tiket/passport-design-tokens/breakpoint'` or `/mixins` (about 160 files in payment-fe and 210 in fintech-fe). Passport's `dist/` still imports `.module.scss`, so apps transpile `@tiket/passport*` and need Sass to resolve the package path ([[passport-architecture]]). payment-fe's `typed-scss-modules` script has an alias for the tokens package for the same reason.
3. **TS token maps** (`colors`, `iconColors`, `computeSolidAndGradientBgStyle`…) for colours that come from API data, such as Kuber banners ([[passport-kuber-price-dynamic-banner]]).

Inside Passport, 110 packages depend on design-tokens (as a devDependency, because only SCSS `@use` reads it).

## Scoping problem in the remote
react-remote scopes Passport variables under its `.passport` wrapper. [[passport-portal]] renders modals into `document.body`, outside that scope, where icons with `fill="var(--icon-color-high-emphasis)"` turn invisible. `PassportWrapper/index.tsx` therefore injects a hard-coded `:root{--icon-color-*;--font-color-*}` block. Those hex values are a hand-kept copy of the tokens and drift when Passport changes colours ([[react-remote-wrapper]]).

## Related
- Mobile font scaling builds on the `-rem` and `--dynamic-type-scale` variables: [[passport-accessibility-font-scaling]].
- `base.css` also bundles `keen-slider.css` for the carousel packages ([[keen-slider]]).

## Where it shows up
Pages that link here:
- TIX-PASSPORT: [[passport-design-tokens]]
- TIX-REACT-REMOTE: [[react-remote-wrapper]]
- concepts: [[module-federation]], [[passport-accessibility-font-scaling]]
- entities: [[keen-slider]], [[kuber]]
- howto: [[add-new-passport-package]]

## Sources
- TIX-PASSPORT `packages/design-tokens/{base.css,variables.css,a11y-support.css,_breakpoint.scss,_mixins.scss,index.ts}`, `packages/*/package.json`
- TIX-REACT-REMOTE `src/index.ts`, `src/components/wrapper/PassportWrapper/index.tsx`, `src/components/header/index.tsx`
- TIX-NEXT-PAYMENT-FE `app/(root)/globals.scss`, `package.json` (`generate-css-modules-types`)
- `git grep "@use '@tiket/passport-design-tokens"` on the payment-fe and fintech-fe baselines
