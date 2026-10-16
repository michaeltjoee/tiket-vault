---
title: Global Popup
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-global-popup"
sources:
  - packages/global-popup/src
  - packages/global-popup/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Global Popup
> Site-wide campaign popup engine. It fetches the popups the promotion service picked for the current screen and renders them by content type (gift voucher, promo code, full image, inventory, combination, floating), with ack, interact and claim calls plus GTM.

## What it does
`GlobalPopup` sets up its own React Query client, an `AccomProductSpriteProvider`, a session context (sessionStorage-backed `doNextCall` / expiry handling) and a config context. Then:
- **Client fetch path** (`Layout`): `GET /tix-promotion-page/popups/multi?…` for `screenName`, `screenOwner`, `platform` and `orderId`.
- **Prefetched path** (`LayoutSuperAPI`): used when `globalPopupContentData` (`{ popups, doNextCall }`, fetched server-side by the host) has popups.

Per the BE contract, a response has **0..N `FLOATING` popups plus at most one non-floating popup** (`partitionPopups`). All floatings render stacked, and only the first non-floating one renders. Non-floating types are `GIFT_VOUCHER`, `PROMO_CODE`, `FULL_IMAGE`, `INVENTORY` and `COMBINATION` (a modular popup made of banner grid, description, gift voucher, inventory and promo code modules). Some types load more data: async content (`/popups/{id}/async-content`), best-promo inventory (`/tix-recommendation/promo-recommendation`), and gift-voucher claims (`/tix-promotion-page/cross-sell/claim-vouchers`). Display is acked with `PUT /popups/ack` and clicks with `PUT /popups/interact`. QR "install the app" CTAs come from [[passport-qr-popup]].

## Public API
| Export | Notes |
|---|---|
| `GlobalPopup` | `locale`, `screenName`, `screenOwner`, `clientSideServiceEndpoint` (required). `globalPopupContentData`, `orderId`, `platform` (`DESKTOP \| MOBILE`, falls back to the breakpoint), `popupInventoryVariant` |
| `GlobalPopupWithFeatureFlag` | HOC that reads the AB flag `2025-discovery-pop-up-cross-sell` (old/new, with `abTestOnServerResponse` from `usePassport`), passes it as `popupInventoryVariant`, and renders nothing until the flag resolves |
| `GlobalPopupContent` | inner renderer |
| re-exports from [[passport-qr-popup]] | `QrCodePopup`, `QrCoordinatorProvider`, `QrCoordinatorContext`, `useQrCoordinator`, `getQrAppInstallPopupContent`, `QR_APP_INSTALL_POPUP_ID`, types `PopupQRContent`, `QrAppInstallPopupRequest`, `QrAppInstallPopupContentResponse` |

## Usage
From TIX-REACT-REMOTE `src/components/global-popup/index.tsx`:
```tsx
<PassportWrapper country={country} currency={currency} lang={lang} {...(abTestOnServerResponse && { abTestOnServerResponse })}>
  <GlobalPopupWithFeatureFlag locale={lang} screenName={screenName} screenOwner={screenOwner}
    clientSideServiceEndpoint={clientSideServiceEndpoint} globalPopupContentData={globalPopupContentData} platform={platform} />
</PassportWrapper>
```

## Data & services
All calls go through `getFinalApiUrl(apiUrl, clientSideServiceEndpoint, customFetch)`: relative with `customFetch`, otherwise `${endpoint}/ms-gateway…` ([[passport-custom-fetch]]). Feature flags come from `@tiket/react-common-ab-test` ([[react-common-ab-test]]), headers from `@tiket/react-common-utilities`. The msw handlers for stories and tests are in `mocks/services/global-popup/` at the repo root.

## Depends on
About 25 packages, including [[passport-banner-grid]], [[passport-bottom-sheet]], [[passport-modal]], [[passport-dialog]], [[passport-gift-voucher]], [[passport-voucher-card]], [[passport-promo-code-popup]], [[passport-product-card]], [[passport-page-module]], [[passport-page-module-shared]], [[passport-qr-popup]], [[passport-button-slider]], [[passport-countdown]], [[passport-snackbar]], [[passport-error-view]], [[passport-content-loader]]. External: `lottie-react`, `react-qr-code`. Peers: `@tanstack/react-query ^5`, `date-fns ^4`.

## Used by
- TIX-REACT-REMOTE `src/components/global-popup/index.tsx` exposes `GlobalPopupWithFeatureFlag` as a federated remote ([[react-remote-global-popup]]). It imports `GlobalPopupProps` from the deep path `@tiket/passport-global-popup/src/types`.
- Internal: none.

## Gotchas
- **Google One Tap coupling.** On first render, and again whenever the popup closes, it dispatches `window` event `tiket-google-one-tap` with `{ command: 'prompt' }`. [[passport-google-one-tap]] listens for it, so the One Tap prompt shows only after the campaign popup is gone.
- It creates a module-level `QueryClient`, separate from the host's. Host React Query devtools and cache don't see its queries.
- `@tanstack/react-query` is a **peer** dep. The host must install v5.
- `PROMO_CODE` and `COMBINATION` popups can be expired by the time they render. Layout then shows the next popup (`doNextCall`) as a fallback.

## Sources
- `packages/global-popup/src/GlobalPopup.tsx`, `src/index.ts`, `src/hoc/withFeatureFlag.tsx`, `src/constants/featureFlag.ts`, `src/components/Layout/{Layout.tsx,partitionPopups.ts}`, `src/services/*.ts`, `src/types/{global-popup.ts,api-response.ts}`, `src/utils/{common.ts,constants.ts}`
- `packages/global-popup/package.json`
- TIX-REACT-REMOTE `src/components/global-popup/index.tsx` (281778b)
