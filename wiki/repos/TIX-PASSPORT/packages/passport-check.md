---
title: Check
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-check"
umbrella: true
sources:
  - packages/check/src
  - packages/check/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Check
> Checkbox: a native `<input type="checkbox">` inside a `<label>`, with custom tick and indeterminate visuals.

## What it does
It renders a label wrapper, a visually customised native checkbox, a tick icon or indeterminate bar, and `children` as `b1` text. It forwards the ref to the input, so `react-hook-form` `register()` works directly. `isIndeterminate` sets `aria-checked="mixed"` and `isError` sets `aria-invalid`. Styling depends on those attributes, so tests can use `toBePartiallyChecked()` and `toBeInvalid()`.

## Public API
`Check` (forwardRef to `HTMLInputElement`), plus types `CheckProps`, `CheckOwnProps`. It accepts all `input` props.
| Prop | Default | Notes |
|---|---|---|
| `children` | — | string or inline JSX (no `div`, since the parent is a `label`) |
| `isIndeterminate`, `isError` | `false` | |
| `block` | `false` | flex instead of inline-flex |
| `checkPosition` | `left` | or `right` |
| `wrapperProps` | — | props for the `label` |
| `className` | — | applied to the **input**, not the wrapper |

## Usage
```tsx
<Check checked={agree} onChange={(e) => setAgree(e.target.checked)} isError={!agree && submitted}>
  I agree to the <a href="/tnc">Terms</a>
</Check>
```

## Depends on
[[passport-icons]], [[passport-typography]], [[passport-utils]]. `@tiket/passport-ripple-effect` is listed as a dependency but not imported (see [[passport-ripple-effect]]).

## Used by
- Through the umbrella `@tiket/passport`: TIX-NEXT-PAYMENT-FE `components/CardComponent/components/SaveCard/SaveCard.tsx` ([[payment-fe-components]]) and TIX-FINTECH-NEXT-FE `projects/insurance/claim-center/claim-form/...` (9 files).
- Internal: 6 packages ([[passport-corporate-interim-module]], [[passport-group-field-v2]], [[passport-list]], [[passport-refund-method]], [[passport-reseller-finance-module]], [[passport-toggle]]).

## Gotchas
- `className` targets the input. Use `wrapperProps.className` to style the row.
- Indeterminate is only visual and ARIA. The DOM `indeterminate` property isn't set.

## Sources
- `packages/check/src/Check.tsx`
- `packages/check/package.json`
