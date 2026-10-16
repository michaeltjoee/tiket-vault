---
title: Ripple (utility)
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-ripple"
sources:
  - packages/ripple/src
  - packages/ripple/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Ripple
> Imperative Material-style ripple: call `createRipple(variant, event)` from an `onMouseDown` handler. This is the ripple used inside [[passport-button]] and [[passport-tabs]].

Part of [[passport-packages]].

## What it does
`createRipple` adds a `<span>` circle, sized to the element's larger dimension and centered on the pointer, to `event.currentTarget`. It keeps at most **5** ripple spans per element (`MAX_RIPPLES`) and colors them by `RippleVariant`. The target needs `position: relative; overflow: hidden`. If it doesn't have that, wrap it in `RippleContainer`. The approach follows the css-tricks recipe linked in the source.

## Public API
- `createRipple(variant: RippleVariant, event: MouseEvent<HTMLButtonElement | HTMLAnchorElement>)`
- `RippleContainer({ children })`
- `RippleVariant = 'primary' | 'secondary' | 'tertiary' | 'danger' | 'special_for_tabs'`

Not in [[passport-umbrella]].

## Usage
From the docstring:
```tsx
const handleMouseDown = useCallback((evt) => {
  createRipple(rippleVariant, evt);
  onMouseDown(evt);
}, [onMouseDown, rippleVariant]);
```

## Depends on
[[passport-utils]] (declared). External: `classnames`.

## Used by
- Inside TIX-PASSPORT: [[passport-button]], [[passport-tabs]].
- No consumers in the other workspace repos.

## Gotchas
- This is a different package from [[passport-ripple-effect]], which is a wrapper component used by [[passport-check]]. They have different APIs and styles.

## Sources
- packages/ripple/src/Ripple.tsx
- packages/ripple/package.json
