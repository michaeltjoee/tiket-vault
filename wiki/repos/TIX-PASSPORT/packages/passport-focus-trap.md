---
title: Focus Trap
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-focus-trap"
sources:
  - packages/focus-trap/src
  - packages/focus-trap/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Focus Trap
> Thin wrapper over `react-focus-lock` that keeps keyboard focus inside overlays and returns it to the trigger on close.

## What it does
`FocusTrap` renders `ReactFocusLock` with `returnFocus` always on. When `initialFocusRef` is given, it turns on `autoFocus` and focuses that element in a `setTimeout(0)` after activation, following react-focus-lock's guidance on unmount and focus timing. With no ref, it doesn't auto-focus, so the first focusable element isn't grabbed. `disabled` turns the lock off. Overlays pass `disabled={!isMounted}`.

## Public API
`FocusTrap`, plus types `FocusTrapProps` (`children`, `initialFocusRef?`, `disabled?`) and `FocusableElement` (`{ focus(options?) }`).

## Usage
```tsx
<FocusTrap initialFocusRef={inputRef} disabled={!isOpen}>
  <div role="dialog">…<input ref={inputRef} /></div>
</FocusTrap>
```

## Depends on
`react-focus-lock`, [[passport-utils]].

## Used by
- No direct consumers in other repos.
- Internal: [[passport-bottom-sheet]], [[passport-dialog]], [[passport-dropdown]], [[passport-modal]], [[passport-search-widget-flight]]. Every Passport overlay traps focus through this package.

## Gotchas
- Two stacked overlays both trap focus. react-focus-lock gives the most recently activated one priority, but closing order matters for `returnFocus`.
- Not in the umbrella `@tiket/passport`. The `FocusableElement` type is re-exported in overlay props (`initialFocusRef`).

## Sources
- `packages/focus-trap/src/FocusTrap.tsx`
- `packages/focus-trap/package.json`
