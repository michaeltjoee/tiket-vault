---
title: Bottom Sheet
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-bottom-sheet"
sources:
  - packages/bottom-sheet/src
  - packages/bottom-sheet/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Bottom Sheet
> The mobile overlay primitive: portal-mounted, focus-trapped, scroll-locked, swipe-to-close, with a collapsing sticky header and an optional sticky footer.

## What it does
`BottomSheet` mounts into a portal (`#modal-root` by default) only while open, plus a 300 ms close transition (`useMountTransition`). It locks body scroll (`usePreventScroll`) and traps focus. Dragging the header resizes the body, and releasing past 20% of the content height calls `onClose`. After scrolling more than 5 px the header collapses and shows a shadow. A `stickyFooter` gets a top shadow when the content overflows (`useOverflow`).

## Public API
`BottomSheet`, plus types `BottomSheetProps`, `BottomSheetOwnProps`, `BottomSheetVariant`, `BottomSheetDefaultPopupHeight`, `BottomSheetImperativeHandle`.
| Prop | Notes |
|---|---|
| `isOpen`, `onClose(e?)` | `onClose` is required. It's called from the backdrop handle and from swipe-down |
| `title`, `titleIcon`, `titleMaxLines` | the title is expected in the default variant |
| `textButtonText`, `textButtonOnClick`, `textButtonMaxLines` | right-hand header link (e.g. "Reset") |
| `variant` | `default`, `clean`, `noShadow` or `noPadding` |
| `defaultPopupHeight` | `auto` (default) or `full` |
| `stickyFooter` | usually a [[passport-bottom-app-bar]] |
| `transparentHeader: true` + `primaryIcon`/`secondaryIcon` | image-hero sheets. The title is not rendered |
| `portalId`, `initialFocusRef`, `bodyRef`, `imperativeHandleRef` (`scrollToTop()`) | |
Rest props go to the root `div`.

## Usage
```tsx
<BottomSheet
  isOpen={open}
  onClose={() => setOpen(false)}
  title="Select currency"
  stickyFooter={<BottomAppBar><BottomAppBarMain><Button fullWidth>Apply</Button></BottomAppBarMain></BottomAppBar>}
>
  {list}
</BottomSheet>
```

## Depends on
[[passport-focus-trap]], [[passport-portal]], [[passport-icons]], [[passport-typography]], [[passport-utils]] (`useMountTransition`, `usePreventScroll`, `useOverflow`, `throttle`, `usePassport`).

## Used by
- Through the umbrella `@tiket/passport`: TIX-NEXT-PAYMENT-FE (25 files, e.g. `app/downpay/components/DownPaySettlementCard/SelectSettlementDialog.tsx`; see [[payment-fe-downpay]], [[payment-fe-components]]) and TIX-FINTECH-NEXT-FE (9 files, e.g. `components/ModalBottomSheetResponsive/ModalBottomSheetResponsive.tsx`; see [[fintech-fe-components]]). `vitest.setup.tsx` in FINTECH mocks it.
- Internal: 27 packages, including every sheet-based widget ([[passport-calendar]], [[passport-currency-bottom-sheet]], [[passport-header]], [[passport-global-popup]], [[passport-page-module]]…).

## Gotchas
- The body carries `data-bottom-sheet-scrollable-element`. [[passport-calendar]] queries it to scroll to the selected month. Don't remove it in overrides.
- The swipe start position `touchY` is a module-level variable shared by all sheet instances. That's fine for one open sheet, but stacked sheets can interfere.
- It imports `@tiket/passport-utils/src/context.module.scss` by deep path, which relies on `src/` being published in `files`.
- When `isAccessibilityOn` is false, the collapsed title and the text button pin font size with `data-disable-a11y`.
- Without a portal target (`#modal-root`) in the DOM, [[passport-portal]] decides where it renders. Make sure the app shell has one.

## Sources
- `packages/bottom-sheet/src/BottomSheet.tsx`
- `packages/bottom-sheet/package.json`
