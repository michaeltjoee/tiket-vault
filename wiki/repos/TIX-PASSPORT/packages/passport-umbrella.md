---
title: "@tiket/passport (umbrella)"
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport"
sources:
  - packages/passport/index.js
  - packages/passport/types
  - packages/passport/package.json
  - packages/passport/README.md
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# @tiket/passport (umbrella)
> A single-import barrel that re-exports the public components, hooks and context of most Passport packages: `import { Button, Text, Modal } from '@tiket/passport'`.

Part of [[passport-packages]].

## What it does
`packages/passport` has no source of its own. It contains:
- `index.js`: hand-maintained named re-exports from 95 `@tiket/passport-*` packages. Its `build` script is `cp index.js index.d.ts`, so the JS file doubles as the type declaration. `index.d.ts` is gitignored as a build output.
- `types/<pkg>.d.ts` (90 files): `export type * from '@tiket/passport-<pkg>'`. They let apps import a package's types without depending on it directly, e.g. `import type { RadioGroupValue } from '@tiket/passport/types/radio'`.
- `package.json`: depends on 98 packages at `workspace:*`; `"type": "module"`, peer `react ^19`, `publishConfig.access: restricted`.

The version moves together with every other package through changesets `fixed` versioning (see [[changesets-fixed-versioning]]). It is 12.8.1 on this baseline.

## Public API
Named exports only. These include `PassportProvider` / `PassportContext` / `usePassport` / `ForwardParamsProvider` from [[passport-utils]], `Text` from [[passport-typography]], the `SnackbarProvider`/`snackbar` API from [[passport-snackbar]], and the main component of each package. See `index.js` for the full list.

**Not re-exported** (import the package directly):
- in deps but not in `index.js`: [[passport-button-slider]], [[passport-design-tokens]] (CSS and tokens), [[passport-insurance-pop-up]]
- not even a dependency: [[passport-page-module]], [[passport-page-module-shared]], [[passport-logo]], [[passport-notification-login]], [[passport-otp-unm]], [[passport-phone-verification]], [[passport-price-history-bar]], [[passport-refund-method]], [[passport-reseller-finance-module]], [[passport-ripple]], [[passport-ripple-effect]], [[passport-social-share-mobile]], [[passport-top-nav-srp]], plus icons, assets and others from the first half of [[passport-packages]].
- Only part of some packages is re-exported. For example [[passport-manage-order]] exports only `ManageOrder`, and [[passport-snackbar-multi-account]] only `SnackbarMultiAccount`.

## Usage
```tsx
import { PassportProvider, SnackbarProvider, Button, Text } from '@tiket/passport';
import '@tiket/passport-design-tokens/base.css';
import '@tiket/passport-design-tokens/font-loader.css';
```

## Depends on
98 internal packages (`workspace:*`). No external runtime deps.

## Used by
This is the most common way apps consume Passport:
- TIX-NEXT-PAYMENT-FE (`^8.11.1`, about 349 import sites; plus `@tiket/passport/types/*` and `__mocks__/@tiket/passport-types.ts`).
- TIX-FINTECH-NEXT-FE (`^12.4.3`, about 362 import sites).
- TIX-REACT-REMOTE (`12.4.2`, exact pin).
- TIX-REACT-COMMON: [[react-common-error-handler]] (`package.json` and `ErrorRenderer.tsx`).
- Inside TIX-PASSPORT it creates cycles: [[passport-manage-order]], [[passport-search-widget-flight]] and [[passport-search-widget-ttd]] import `@tiket/passport` while the umbrella depends on them.

## Gotchas
- Adding a new package does **not** expose it here automatically. Someone has to add the dependency and the export line in `index.js`, and a `types/<pkg>.d.ts` if needed.
- The barrel isn't tree-shaken unless the consumer's bundler honors each package's `sideEffects` (they declare only CSS and media files).
- Consumers sit on different majors (payment-fe v8, fintech and remote v12), so umbrella-level behavior differs per app.

## Sources
- packages/passport/index.js
- packages/passport/types/
- packages/passport/package.json
- packages/passport/README.md
- packages/passport/.gitignore
- package.json of TIX-NEXT-PAYMENT-FE, TIX-FINTECH-NEXT-FE, TIX-REACT-REMOTE (origin/main)
