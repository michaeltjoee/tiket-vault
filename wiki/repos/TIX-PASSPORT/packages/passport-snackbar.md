---
title: Snackbar
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-snackbar"
umbrella: true
sources:
  - packages/snackbar/src
  - packages/snackbar/package.json
  - packages/snackbar/CONTRIBUTING.md
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Snackbar
> Global toast system modeled on react-hot-toast. Mount `<SnackbarProvider />` once, then call `snackbar('text', opts)` from anywhere, including outside React.

Part of [[passport-packages]].

## What it does
- **Store**: a module-level in-memory state plus a listener array. `snackbar()` dispatches `UPSERT`. Each `SnackbarProvider` subscribes through `useSnackbarStore` and renders the list in a [[passport-portal]] with id `snackbar-portal`, stacked by `SnackbarsPositioner`.
- At most **5** snackbars are kept, newest first. They auto-dismiss after `duration` (default **4000 ms**, `Infinity` = sticky), then are removed 1000 ms later, after the exit animation.
- `IsolatedSnackbar` is a standalone controlled snackbar (`isOpen`, `onClose`, absolute `top`/`right`/`bottom`/`left`/`width`) that doesn't use the global store. Its default duration is also 4000 ms.

## Public API
- `snackbar(textContent, opts?) → id`, `snackbar.dismiss(id?)` (no id dismisses all), `snackbar.remove(id?)`
- `SnackbarProvider({ additionalOffset?, positionerClassName?, positionerStyle? })`
- `IsolatedSnackbar`, `useSnackbarStore`, `useHeightRef`
- Types: `Snackbar`, `SnackbarOptions` (`id`, `duration`, `type`, `actionText`, `onClickAction(id)`, `additionalOffset`, `truncatedMaxLines`, `buttonMaxLines`), `SnackbarType` (`general` | `success` | `error`), `SnackbarProviderProps`

All are in [[passport-umbrella]].

## Usage
```tsx
// app root (see the page-module README)
<PassportProvider {...props}>{children}<SnackbarProvider /></PassportProvider>
// anywhere
snackbar('Kode promo disalin', { type: 'success' });
snackbar(err.message, { type: 'error', actionText: 'OK', onClickAction: snackbar.dismiss });
```

## Depends on
[[passport-portal]], [[passport-typography]], [[passport-utils]].

## Used by
- Inside TIX-PASSPORT: 18 packages (e.g. [[passport-otp-form]], [[passport-otp-unm]], [[passport-phone-verification]], [[passport-notification-login]], [[passport-qr-popup]], [[passport-refund-method]], [[passport-wishlist]], [[passport-snackbar-multi-account]], header, page-module).
- TIX-NEXT-PAYMENT-FE: `SnackbarProvider` in `components/providers/AppProvider.tsx`, `lib/providers/AppRouterProvider.tsx` and `.storybook/preview.tsx`; `snackbar()` in about 21 source files (e.g. `app/payment-link/hooks/useCopyToClipboard.ts`).
- TIX-FINTECH-NEXT-FE: `SnackbarProvider` in `components/providers/AppProvider.tsx` and `AppRouterProvider.tsx`; `snackbar()` in about 14 files.
- TIX-REACT-COMMON: `packages/react-common-error-handler/src/utils/showErrorSnackbar.ts` (via `@tiket/passport`). See [[react-common-error-handler]].

## Gotchas
- The store is a **module singleton**. Two copies of the package in a bundle (for example dist and src, or two versions) give two stores, and `snackbar()` calls from one never reach the other's provider.
- Without a mounted `SnackbarProvider`, calls silently do nothing.
- New features should be ported from react-hot-toast rather than invented (CONTRIBUTING.md).

## Sources
- packages/snackbar/src/core/snackbar.ts
- packages/snackbar/src/core/store.ts
- packages/snackbar/src/core/use-snackbar.ts
- packages/snackbar/src/core/types.ts
- packages/snackbar/src/components/SnackbarProvider.tsx
- packages/snackbar/src/components/IsolatedSnackbar.tsx
- packages/snackbar/CONTRIBUTING.md
- packages/snackbar/package.json
