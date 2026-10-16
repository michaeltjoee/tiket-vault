---
title: Passport accessibility font scaling
kind: concept
repos: [TIX-PASSPORT, TIX-REACT-REMOTE, TIX-REACT-COMMON]
sources:
  - TIX-PASSPORT/packages/utils/src/context.tsx
  - TIX-PASSPORT/packages/utils/src/context.module.scss
  - TIX-PASSPORT/packages/design-tokens/variables.css
  - TIX-PASSPORT/packages/design-tokens/a11y-support.css
  - TIX-REACT-REMOTE/src/components/wrapper/PassportWrapper/index.module.scss
verified_at:
  TIX-PASSPORT: 7a33010aca
  TIX-REACT-REMOTE: 281778b
  TIX-REACT-COMMON: 14597c4e
updated: 2026-10-16
status: current
tags: [kind/concept, repo/passport, repo/react-remote, repo/react-common]
---

# Passport accessibility font scaling
> Inside the tiket iOS and Android apps, Passport text follows the user's system font size. The app sets `--font-scale` on `<html>`, and [[passport-utils]] copies it into `--dynamic-type-scale`, which the `-rem` typography variables multiply by. A rollout flag gates the feature.

## Mechanism
1. **Flag.** `PassportProvider` reads `ff-is-accessibility-support-enabled` through `useRollout` ([[ab-testing]]), using `abTestOnServerResponse` when the host passed one. `isAccessibilityOn` is `true` unless the variant is `'off'`, so a failed flag fetch leaves it **on**.
2. **Wrapper class.** When on, children render inside the `accessibility_changes` class (`context.module.scss`). It redefines mobile heading and body sizes as `var(--font-size-mobile-<x>-rem) * var(--dynamic-type-scale)`.
3. **Scale.** Only in webviews (`device_type` cookie `ios` or `android`; see [[webview-jsi-bridge]]): it copies `--font-scale` from `<html>` style to `--dynamic-type-scale` and keeps it in sync with a `MutationObserver` on the `style` attribute. Elsewhere `--dynamic-type-scale` stays at its default `1` from `variables.css` ([[design-tokens]]).
4. **iOS Safari.** `a11y-support.css` sets `font: -apple-system-body` on `<html>` below 840 px, and `[data-disable-a11y='true']` pins sizes back to px.

About 26 packages reference `isAccessibilityOn`, `accessibility_changes` or `--dynamic-type-scale` directly, most of all [[passport-header]], [[passport-calendar]], [[passport-search-form-display]] and [[passport-file-upload]].

## Consumers
- TIX-REACT-REMOTE `PassportWrapper/index.module.scss` keeps px values by default and notes that `a11y-support.css` must be imported to use rem values ([[react-remote-wrapper]]).
- TIX-NEXT-PAYMENT-FE and TIX-FINTECH-NEXT-FE don't import `a11y-support.css` on their baselines.

## Gotchas
- Desktop always stays in px. Only mobile breakpoints use the rem variables.
- A component that hard-codes `font-size` in px, or uses non-`-rem` variables, won't scale. Check new components in a webview with a large system font.
- The flag is read per `PassportProvider`. A remote widget and its host page can disagree if they get different `abTestOnServerResponse` values.

## Where it shows up
Pages that link here:
- TIX-PASSPORT: [[passport-utils]]
- concepts: [[ab-testing]], [[design-tokens]]

## Sources
- TIX-PASSPORT `packages/utils/src/{context.tsx,context.module.scss,useRollout.ts}`, `packages/design-tokens/{variables.css,a11y-support.css}`
- TIX-REACT-REMOTE `src/components/wrapper/PassportWrapper/index.module.scss`
- Package count: `git grep -l -E 'dynamic-type-scale|accessibility_changes|isAccessibilityOn' origin/main -- packages` (specs and stories excluded)
