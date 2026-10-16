---
title: Button
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-button"
umbrella: true
sources:
  - packages/button/src
  - packages/button/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Button
> The design-system button, rendered as `<button>` or `<a>`. It has variants, sizes, modes, a loading state, icons and a ripple on mouse-down.

## What it does
`Button` renders `<button>` by default, or `<a role="link">` with `as="a"`. On mouse-down it creates a ripple through [[passport-ripple]], unless `isLoading` is set. `isLoading` swaps the content for a spinner while keeping the width, and swallows clicks. `icon`/`rightIcon` elements are cloned with a colour chosen in this order: disabled, then the icon's own `color`, then `inverted` mode, then by variant. Text size follows the button size (`small` b3, `medium` b2, `large` b1) when `noButtonAccessibility` is set.

## Public API
`Button` (forwardRef to `HTMLButtonElement | HTMLAnchorElement`). Types: `ButtonProps`, `CommonProps`, `ButtonType`, `AnchorType`, `Mode`, `Size`, `Variant`, `HorizontalPadding`, `ValidRef`.
| Prop | Values / default |
|---|---|
| `variant` | `primary` (default), `secondary`, `tertiary`, `danger` |
| `size` | `small`, `medium` (default), `large` |
| `mode` | `default`, `inverted` (on dark backgrounds), `dusky` |
| `as` | `button` (default) or `a` (+ anchor props) |
| `disabled`, `isLoading`, `fullWidth` | |
| `horizontalPadding` | `default` or `none` |
| `icon`, `rightIcon` | JSX icon elements, e.g. `<IconPlus />` |
| `truncatedMaxLines` | line clamp, only in accessibility mode |
| `noButtonAccessibility` | opt out of OS font scaling |

## Usage
```tsx
<Button variant="secondary" size="large" fullWidth isLoading={submitting} onClick={submit}>
  Continue
</Button>
<Button as="a" href="/promo" variant="tertiary" icon={<IconArrowRight />}>See all</Button>
```

## Depends on
[[passport-ripple]], [[passport-loading-indicator]], [[passport-typography]], [[passport-utils]]. Icon colour types come from [[passport-design-tokens]].

## Used by
- Through the umbrella `@tiket/passport`: TIX-NEXT-PAYMENT-FE (about 60 files across [[payment-fe-payment]], [[payment-fe-payment-link]], [[payment-fe-downpay]], [[payment-fe-components]]) and TIX-FINTECH-NEXT-FE (about 61 files, e.g. [[fintech-fe-gift-card]] and `projects/insurance`). TIX-NEXT-PAYMENT-FE's `AGENTS.md` and `.cursor/rules` tell agents to use it.
- Internal: 66 packages. It's the second most depended-on component after icons.

## Gotchas
- No default `type` is set, so inside a `<form>` it submits. Pass `type="button"` for non-submit actions.
- `as="a"` ignores `isLoading`, and `disabled` only adds a class. The anchor stays clickable, so guard `onClick` yourself.
- The ripple runs on `onMouseDown`, so a custom `onMouseDown` still gets called, after the ripple.

## Sources
- `packages/button/src/Button.tsx`
- `packages/button/package.json`
