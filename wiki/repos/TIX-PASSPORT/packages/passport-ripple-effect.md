---
title: RippleEffect
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-ripple-effect"
sources:
  - packages/ripple-effect/src
  - packages/ripple-effect/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# RippleEffect
> Wrapper `div` that shows a 500 ms ripple on every mouse-down, with an optional red `danger` color.

Part of [[passport-packages]].

## What it does
On `mousedown` it calls your `onMouseDown`, appends a ripple `div` to itself, and removes it after 500 ms if the component is still mounted. Ripples always start from the CSS-defined origin, not the pointer position. Compare [[passport-ripple]], which positions at the pointer.

## Public API
`RippleEffect` (forwardRef `div`): `className` (**required**), `danger?`, and any `div` props. Not in [[passport-umbrella]].

## Usage
```tsx
<RippleEffect className={styles.check_ripple} danger={isError}>
  <input type="checkbox" />
</RippleEffect>
```

## Depends on
[[passport-utils]] (`useMounted`). External: `classnames`.

## Used by
- Inside TIX-PASSPORT: [[passport-check]].
- No consumers in the other workspace repos.

## Gotchas
- The forwarded `ref` is wrapped in `useRef(ref)` and then used as the element ref. A callback ref from the parent won't receive the element.

## Sources
- packages/ripple-effect/src/RippleEffect.tsx
- packages/ripple-effect/package.json
