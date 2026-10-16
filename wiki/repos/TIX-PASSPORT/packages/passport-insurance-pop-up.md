---
title: Insurance Pop-Up
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-insurance-pop-up"
sources:
  - packages/insurance-pop-up/src
  - packages/insurance-pop-up/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Insurance Pop-Up
> Renders the flight-insurance upsell pop-up from the "Get Product Popup Display" API payload. The template is picked by `templateName`, and the same component serves verticals, webviews and the CMS panel preview.

Part of [[passport-packages]].

## What it does
You pass the API response as `data`. `InsurancePopUpSwitch` lazy-loads one template by `data.templateName`:

| `templateName` | Template |
|---|---|
| `FLIGHT_DELAY` | Delay |
| `FLIGHT_GENERAL` | General (baggage, full protection, reschedule) |
| `FLIGHT_FULLREFUND_1` / `_2` | Full refund variant 1 (chart) / variant 2 (segments) |
| `DISRUPTION` / `DISRUPTION_2` | Disruption variant 1 / variant 2 (Lottie animation, two protection options) |
| `INHOUSE_DISRUPTION` | In-house disruption |

`viewMode` sets the shell. `vertical` is a [[passport-modal]] on desktop and a full-screen [[passport-bottom-sheet]] on mobile. `webview` is a full page for the in-app webview. `preview` is a fixed-size frame (`previewSize` `mobile` 360×640 or `desktop` 1440×720) for the admin panel. Mobile or desktop is decided by measured width (`DimensionProvider`), not by the Passport breakpoint. `popupContent.themes` controls the header (`default`/`custom`), modal size, padding and full width, and the footer (`default`, or `dynamic` for the two-option templates). On mount it pushes a GTM impression (`pageLoadedInsurancePopup`, with a `PRP` suffix when `trackerData.screenName === 'prp'`), and another one when "see details" opens.

## Public API
`InsurancePopUp`, plus types `InsurancePopUpProps`, `PopUp` (the union of all templates), `DelayPopUp`, `GeneralPopUp`, `FullRefundVariant1PopUp`, `FullRefundVariant2PopUp`, `DisruptionVariant1PopUp`, `DisruptionVariant2PopUp`.
| Prop | Notes |
|---|---|
| `data` | `PopUp`: `{ templateName, insuranceData?: { minRefundAmount, trackerData }, popupContent }` |
| `viewMode` | `vertical`, `webview` or `preview` (required) |
| `isOpen` | `vertical` only |
| `previewSize` | `preview` only |
| `onClose`, `onClickButtonPrimary`, `onClickButtonSecondary` | footer CTAs. With the dynamic footer, "primary" means option `body1` and "secondary" means option `body2` |
| `onSeeDetailsOpen`, `onSeeDetailsClose` | |

## Usage
```tsx
<InsurancePopUp
  viewMode="webview"
  data={data as PopUp}
  onClose={handleClose}
  onClickButtonPrimary={handleButtonPrimary}
  onClickButtonSecondary={handleButtonSecondary}
/>
```
(from TIX-FINTECH-NEXT-FE `projects/insurance/popup/index.tsx`)

## Depends on
[[passport-bottom-sheet]], [[passport-modal]], [[passport-header]] (`HeaderMobile` and its `Variant` type), [[passport-button]], [[passport-card]], [[passport-divider]], [[passport-floating-button]], [[passport-icons]], [[passport-label]], [[passport-radio]], [[passport-typography]], [[passport-utils]], [[passport-assets]], [[react-common-utilities]]; `lottie-react`. The data contract is the PlatTech Confluence page "Get Product Popup Display" ([[insurance-popup-api]]).

## Used by
- TIX-FINTECH-NEXT-FE: [[fintech-fe-insurance-popup]] (`projects/insurance/popup`, webview mode). `projects/insurance/shared/lib/types/popup` re-uses the `PopUp` types.
- Internal: only the umbrella `@tiket/passport`.

## Gotchas
- The pop-up does no fetching or submitting itself. The host loads `data` and handles the CTA callbacks (e.g. adding insurance to the cart).
- An unknown `templateName` renders nothing, with no error.
- Tracking pushes straight to `window.dataLayer` with `eventCategory: insurancePopup`, `vertical: insurance`, and `parentVertical` taken from `trackerData.verticalOwner`. It fires again whenever `data` changes.
- `src/mocks/*.json` hold sample payloads for every template. They are useful as fixtures.

## Sources
- `packages/insurance-pop-up/src/InsurancePopUp.tsx`, `packages/insurance-pop-up/src/index.ts`
- `packages/insurance-pop-up/src/components/InsurancePopUpSwitch/InsurancePopUpSwitch.tsx`, `packages/insurance-pop-up/src/components/BasePopUp/BasePopUp.tsx`
- `packages/insurance-pop-up/src/types/`, `packages/insurance-pop-up/src/context/dimension.tsx`, `packages/insurance-pop-up/src/utils/Tracker.ts`
- `packages/insurance-pop-up/package.json`
