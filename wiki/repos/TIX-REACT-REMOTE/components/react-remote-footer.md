---
title: Remote Footer
repo: TIX-REACT-REMOTE
kind: component
npm: "@tiket/passport-footer"
sources:
  - src/components/footer
  - src/utils/footer.ts
  - src/utils/tracker/footer.ts
verified_at: 281778b
updated: 2026-10-16
status: current
tags: [repo/react-remote, kind/component]
---

# Remote Footer
> Responsive site footer served over module federation, built on `Footer` from [[passport-footer]].

## What it does
Exposed as `footer`. Picks static footer data from [[passport-footer]] by language and currency (`getFooterData`: `FOOTER_DATA_ID_IDR` / `FOOTER_DATA_EN_IDR` when currency is IDR, otherwise `DEFAULT_FOOTER_DATA_ID` / `_EN`), sets the tiket logo from [[passport-assets]], and wires three GTM trackers that push to `window.dataLayer`. Forwards `abTestOnServerResponse` into `PassportProvider`. Siblings: [[react-remote-footer-desktop]] and [[react-remote-footer-mobile]] share the same data and trackers.

## Public API
`CommonComponentProps`: `lang` (default `'id'`), `country` (default `'id'`), `currency`, `isNewURLStructure`, `abTestOnServerResponse`.

`getServerSideProps` returns `{ currency: req.cookies.tiket_currency }` when the cookie is present.

## Tracking
All pushes go through `pushDataLayer` (`src/utils/tracker/tracker.ts`), which defaults `event: 'click'` and fills `screenName` from `window.gtm.screenName` or the path (`/` → `home`, `/myreview*` → `reviewLandingPage`).

| Tracker | eventCategory | action |
|---|---|---|
| `footerContentGTMTracker` | `selectContent` | `click` (+ `sectionTitle`) |
| `downloadAppGTMTracker` | `downloadApp` | `click` |
| `socialMediaGTMTracker` | `selectContent` | `openSocmed` |

All carry `eventLabel: 'footer'`, `itemTitle`, `sectionItemTotal`, `itemOrder`, `url`.

## Usage
```tsx
import { RemoteFooter } from '@tiket/react-common-remote';
<RemoteFooter />
```
`RemoteFooter` defaults `isCritical={false}` (critical CSS not inlined) and pulls `abTestOnServerResponse` from `ReactRemoteContext`.

## Depends on
[[passport-footer]], [[passport-assets]], [[react-remote-wrapper]].

## Used by
- TIX-NEXT-PAYMENT-FE `components/providers/AppProvider.tsx` ([[payment-fe-components]]).
- TIX-FINTECH-NEXT-FE: gift-card landing/checkout/order/redeem wrappers under `app/gift-card/**`, insurance `projects/insurance/shared/components/Footer/Footer.tsx` and claim-form layout, refund `projects/refund/shared/components/Footer/index.tsx`.

## Gotchas
- On the client the currency comes from the `tiket_currency` cookie, on the server from the prop. If they differ, the hydrated footer data can differ from the SSR HTML.

## Sources
- src/components/footer/index.tsx
- src/utils/footer.ts
- src/utils/tracker/footer.ts
- src/utils/tracker/tracker.ts
- TIX-REACT-COMMON packages/react-common-remote/src/RemoteFooter/index.tsx
