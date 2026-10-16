---
title: QrPopup
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-qr-popup"
umbrella: true
sources:
  - packages/qr-popup/src
  - packages/qr-popup/package.json
  - packages/qr-popup/README.md
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# QrPopup
> "Scan to install the app" QR popup. Mount one provider, then open the popup from anywhere with `useQrCoordinator().openQr()`.

Part of [[passport-packages]].

## What it does
`QrPopupProvider` wraps a config context (`clientSideServiceEndpoint`, `platform`, `screenName`, `screenOwner`) and a coordinator context, and mounts **exactly one** `<QrCodePopup>`. `openQr({ pageUrl? })` opens it. The popup fetches its content from `GET /tix-promotion-page/popups/qr-app-install/async-content?...` using `customFetch` from `usePassport()`, then renders a QR code (`react-qr-code`) for the page or deep link, a copy-link button and store hints. It has loading and error/reload states, uses a modal or bottom sheet by platform, and fires GTM events from `trackers.ts`.

It was extracted from [[passport-global-popup]] so that [[passport-page-module]] could use it without a circular dependency (README).

## Public API
- `QrPopupProvider` (`QrPopupProviderProps`), `QrCodePopup`
- `QrCoordinatorProvider`, `QrCoordinatorContext`, `useQrCoordinator()` → `{ isOpen, pageUrl, openQr, closeQr }`
- `QrPopupConfigProvider`, `QrPopupConfigContext`, `useQrPopupConfig`
- `getQrAppInstallPopupContent`, `QR_APP_INSTALL_POPUP_ID = 'qr-app-install'`
- i18n constants `QR_POPUP_*`, `QR_ERROR_*`; types `PopupQRContent`, `QrAppInstallPopupRequest`, `QrAppInstallPopupContentResponse`

All are re-exported by [[passport-umbrella]].

## Usage
```tsx
<QrPopupProvider clientSideServiceEndpoint={endpoint} platform="DESKTOP"
  screenName="home" screenOwner="discovery">
  {children}
</QrPopupProvider>
// anywhere below
const { openQr } = useQrCoordinator();
<button onClick={() => openQr({ pageUrl: location.href })}>Download app</button>
```

## Depends on
[[passport-modal]], [[passport-bottom-sheet]], [[passport-button]], [[passport-snackbar]], [[passport-content-loader]], [[passport-divider]], [[passport-design-tokens]], [[passport-typography]], [[passport-utils]], assets, `@tiket/react-common-utilities`. External: `react-qr-code`.

## Used by
- Inside TIX-PASSPORT: [[passport-page-module]] (mounted in `PageModule` with `platform` from the breakpoint), [[passport-global-popup]], [[passport-pricing-promo]].
- No direct consumers in the other workspace repos.

## Gotchas
- Without a provider, `useQrCoordinator()` returns no-op `openQr`/`closeQr`. Nothing happens and there is no error.
- `PageModule` mounts its own `QrPopupProvider`, so a page that also has one renders two popups. Each opener reaches only its nearest provider.

## Sources
- packages/qr-popup/src/index.ts
- packages/qr-popup/src/components/QrPopupProvider.tsx
- packages/qr-popup/src/contexts/QrCoordinatorContext.tsx
- packages/qr-popup/src/contexts/QrPopupConfigContext.tsx
- packages/qr-popup/src/services/get-qr-app-install-popup-content.ts
- packages/qr-popup/README.md
- packages/qr-popup/package.json
