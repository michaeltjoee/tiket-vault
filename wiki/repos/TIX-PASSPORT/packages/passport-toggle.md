---
title: Toggle
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-toggle"
sources:
  - packages/toggle/src
  - packages/toggle/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Toggle
> An on/off switch built on a hidden checkbox. It is controlled and comes in `small` or `large`.

Part of [[passport-packages]].

## What it does
`Toggle` renders a visually hidden `<input type="checkbox">` followed by a styled track and knob. By default both sit inside a `<label>`, so clicking the track toggles the input. `onChange` receives the new boolean, not the event. Remaining props go to the `<input>` (`id`, `name`, `aria-*`, …), `className` goes to the outer wrapper `div`, and `wrapperProps` are spread onto that wrapper.

## Public API
`Toggle`; types `ToggleProps`, `ToggleOwnProps`.
| Prop | Notes |
|---|---|
| `checked` | required (controlled) |
| `onChange(newState: boolean)` | required |
| `size` | `small` (default) or `large` |
| `disabled` | |
| `withWrappingLabel` | default `true`. Set `false` when you supply your own `<label htmlFor>` |
| `wrapperProps` | props for the outer `div` |
| rest | `input` attributes |

## Usage
```tsx
<Toggle checked={usePoints} onChange={setUsePoints} size="large" aria-label="Use tiket points" />
```

## Depends on
No Passport packages are imported. `@tiket/passport-utils` is declared but unused. External: `classnames`.

## Used by
- TIX-NEXT-PAYMENT-FE, through the umbrella `@tiket/passport`: `components/Ovo` and `components/PaymentTile` ([[payment-fe-components]]).
- Internal: [[passport-pricing-promo]], [[passport-search-form-display]], [[passport-wishlist]], and the umbrella. [[passport-group-field]] lists it only as a devDependency.

## Gotchas
- With `withWrappingLabel={false}` the track is no longer clickable unless something else (a `<label htmlFor={id}>`) points at the input. Pass an `id`.
- `wrapperProps` is spread after `className`, so `wrapperProps.className` replaces the container class.

## Sources
- `packages/toggle/src/Toggle.tsx`
- `packages/toggle/package.json`
