---
title: Modal
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-modal"
sources:
  - packages/modal/src
  - packages/modal/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Modal
> Centered desktop dialog with header, scrollable body and footer buttons. It is portaled, focus-trapped and scroll-locked, and closes with ESC or an overlay click.

Part of [[passport-packages]].

## What it does
`Modal` is the standard desktop popup. The mobile counterpart is [[passport-bottom-sheet]], and many packages pair the two as "adaptive" or "responsive" popups. It renders through `UnstableBaseModal`, which:
- portals into `#modal-root` (`portalId`) using [[passport-portal]],
- wraps content in a `FocusTrap` from [[passport-focus-trap]],
- locks body scroll via `usePreventScroll`,
- animates mount and unmount with `useMountTransition` (300 ms close delay).

ESC and overlay clicks call `onClose`, but only when `withCloseButton` is true. The body shows overflow indicators: a top border and a bottom shadow.

## Public API
- `Modal` (also in [[passport-umbrella]]); types `ModalProps`, `ModalOwnProps`, `ModalImperativeHandle` (`scrollToTop(options?)`), `Size`, `PaddingVariant`, `WidthVariant`, `DefaultPopupHeight`.
- `UnstableBaseModal`: exported but documented as "internal Passport use only".

| Prop | Default | Notes |
|---|---|---|
| `isOpen`, `onClose` | `false` | controlled |
| `title`, `dynamicContentInHeader` | | `title` renders as `h3`-size `h2` |
| `size` | `'small'` | `small`/`medium`/`large` |
| `primaryButtonText`/`secondaryButtonText` + `onClick*` | `''` | built-in footer buttons. `fullWidthButton` defaults to `size === 'small'` |
| `buttons` | | replaces the built-in buttons entirely |
| `dynamicContentAbove/BelowFooterButtons` | | footer slots |
| `withCloseButton` | `true` | **false also disables ESC and overlay close** |
| `paddingVariant` | `'default'` | `'noPadding'` |
| `widthVariant` | `'default'` | `'auto'` (e.g. calendar) |
| `defaultPopupHeight` | `'auto'` | `'full'` = 100% height |
| `transparentHeader` + `primaryIcon`/`secondaryIcon` | | overlay header that turns solid on scroll; icons are cloned with `size` sm→md |
| `withHasOverflowTop/Bottom`, `disableContentScrolling`, `hideScrollBarPadding` | | body behavior |
| `bodyRef`, `imperativeHandleRef`, `initialFocusRef` | | refs |
| `portalId` | `'modal-root'` | |

## Usage
```tsx
<Modal isOpen={open} onClose={close} title="Hapus kartu?" size="small"
  primaryButtonText="Hapus" onClickPrimaryButton={remove}
  secondaryButtonText="Batal" onClickSecondaryButton={close}>
  <Text>Kartu akan dihapus dari akunmu.</Text>
</Modal>
```

## Depends on
[[passport-portal]], [[passport-focus-trap]], [[passport-button]], [[passport-typography]], [[passport-utils]], icons, design-tokens (type only).

## Used by
- Inside TIX-PASSPORT: 24 packages at runtime (calendar, header, page-module, pricing-promo, otp-form, phone-verification and others), plus 8 that list it only as a devDependency (dropdown, form, tabs, …).
- TIX-NEXT-PAYMENT-FE (~14 files via `@tiket/passport`, e.g. `app/payment/components/PromoListResponsiveModal/PromoListResponsiveModal.tsx`, `components/BottomSheetModal/index.tsx`).
- TIX-FINTECH-NEXT-FE (~7 files, e.g. `components/ModalBottomSheetResponsive/ModalBottomSheetResponsive.tsx`). `vitest.setup.tsx` mocks `@tiket/passport-modal` globally with `__mocks__/@tiket/passport-modal`.

## Gotchas
- The close button has `tabIndex={-1}` and `data-testid="modal-close-button"`.
- `withCloseButton={false}` makes the modal undismissable by keyboard or overlay. [[passport-language-and-currency-modal]] relies on this.
- `'use client'`. Content is not in the SSR markup until it is opened.

## Sources
- packages/modal/src/Modal.tsx
- packages/modal/src/components/BaseModal.tsx
- packages/modal/src/components/ModalBody.tsx
- packages/modal/package.json
