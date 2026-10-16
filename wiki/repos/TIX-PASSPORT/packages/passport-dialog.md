---
title: Dialog
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-dialog"
umbrella: true
sources:
  - packages/dialog/src
  - packages/dialog/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Dialog
> Centered confirmation or alert pop-up, either illustration + title + description + buttons (through [[passport-figure]]) or fully custom children.

## What it does
`Dialog` portals into `#modal-root`, mounts only while open (300 ms close transition), locks body scroll and traps focus. Two modes are picked by whether `children` is present:
- **Figure mode** (no children): figure props (`title`, `description`, `image`, `primaryButtonText`, `onPrimaryButtonClick`, `secondaryButtonText`, …) are passed to `Figure variant="fullWidth"`.
- **Custom mode**: renders `children` in the pop-up body.

The `×` button is optional (`withCloseButton`) and is the only built-in way to call `onClose`. Clicking the backdrop and pressing Escape don't close it.

## Public API
`Dialog`, plus types `DialogProps`, `DialogCommonProps`, `DialogWithFigureProps`, `DialogWithCustomChildrenProps`.
| Prop | Notes |
|---|---|
| `isOpen` (required) | |
| `onClose`, `withCloseButton` | default `false` |
| `portalId` | default `modal-root` |
| `initialFocusRef` | custom mode only. Ignored in figure mode |
| figure props | everything in `FigureProps` except `variant`: `title`, `description`, `image`, `titleSize`, `primaryButtonText`, `secondaryButtonText`, `on{Primary,Secondary}ButtonClick`, `is{Primary,Secondary}ButtonLoading`, `fullWidthButton`, `truncatedMaxLines` |
| rest | `div` props on the root |

## Usage
```tsx
<Dialog
  isOpen={showError}
  image={<img src={tds_si_general_error} alt="" />}
  title="Something went wrong"
  description="Please try again."
  primaryButtonText="Retry"
  onPrimaryButtonClick={retry}
/>
```

## Depends on
[[passport-figure]], [[passport-focus-trap]], [[passport-portal]], [[passport-icons]], [[passport-utils]] (`useMountTransition`, `usePreventScroll`, `usePassport`, and a deep import of `src/context.module.scss`).

## Used by
- Through the umbrella `@tiket/passport`: TIX-NEXT-PAYMENT-FE (about 41 files, e.g. `app/downpay/components/DownPayError/DownPayError.tsx`; [[payment-fe-downpay]], [[payment-fe-payment]]), TIX-FINTECH-NEXT-FE (about 27 files, e.g. `app/gift-card/components/BackConfirmDialog`; [[fintech-fe-gift-card]]), and TIX-REACT-COMMON `packages/react-common-error-handler/src/components/ErrorRenderer/ErrorRenderer.tsx` ([[react-common-error-handler]]).
- Internal: 17 packages (error-view, global-popup, header, insurance, otp-form, otp-unm, phone-verification, refund-method, review-widget, wishlist…).

## Gotchas
- The close button has `tabIndex={-1}`, so keyboard users can't reach it. Provide a button inside the content or the figure.
- Passing `children={undefined}` explicitly switches to custom mode, because the check is `'children' in props`, and the dialog renders empty.

## Sources
- `packages/dialog/src/Dialog.tsx`
- `packages/dialog/package.json`
