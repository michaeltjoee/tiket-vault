---
title: GTM dataLayer and window.gtm tracking
kind: concept
repos: [TIX-NEXT-PAYMENT-FE, TIX-FINTECH-NEXT-FE, TIX-REACT-COMMON, TIX-REACT-REMOTE, TIX-GTM-EXTRAS, TIX-PASSPORT]
sources:
  - TIX-NEXT-PAYMENT-FE/lib/hooks/useGTM.ts
  - TIX-NEXT-PAYMENT-FE/lib/tracker/GTM.ts
  - TIX-NEXT-PAYMENT-FE/app/payment-link/tracking
  - TIX-NEXT-PAYMENT-FE/.env.local.example
  - TIX-FINTECH-NEXT-FE/components/CustomScripts/GTMScripts.tsx
  - TIX-REACT-COMMON/packages/react-common-analytic/src
  - TIX-REACT-REMOTE/src/utils/tracker/tracker.ts
  - TIX-GTM-EXTRAS/scripts/helpers.js
  - TIX-PASSPORT/packages/utils/src/context.tsx
verified_at:
  TIX-NEXT-PAYMENT-FE: 9e92b20bb
  TIX-FINTECH-NEXT-FE: 5833b842
  TIX-REACT-COMMON: 14597c4e
  TIX-REACT-REMOTE: 281778b
  TIX-GTM-EXTRAS: 98478af
  TIX-PASSPORT: 7a33010aca
updated: 2026-10-16
status: current
tags: [kind/concept, repo/payment-fe, repo/fintech-fe, repo/react-common, repo/react-remote, repo/gtm-extras, repo/passport]
---

# GTM dataLayer tracking
> Web tracking runs through one Google Tag Manager container, `GTM-PLRJPPQ`. Apps push events to `window.dataLayer` and describe the page in a global `window.gtm` object. GTM tags, [[react-common-analytic]] and the [[gtm-extras-overview|GTM extras]] pixel scripts all read that object, and no repo documents its schema.

## The two globals
| Global | Written by | Read by |
|---|---|---|
| `window.dataLayer` (array of events) | app trackers (`event`, `eventCategory`, `eventLabel`, `screenName`, `vertical`…), about 31 Passport packages, [[passport-kuber-price-dynamic-banner]] (`eventCategory: kuberBanner`) | GTM. react-common-analytic overrides `dataLayer.push` with `ANALYTICS_VERSION === '2.1'` and forwards events to Amplitude and Mixpanel |
| `window.gtm` (page context: `vertical`, `screenName`, `trackingId`, `user`, `deviceId`, per-vertical objects such as `flight.*`, `hotel.*`, `giftCard.*`) | the app's GTM bootstrap script, react-common-analytic (core attributes and `gtm.user`), react-remote's footer tracker (`screenName`) | GTM variables, [[gtm-extras-helpers]] getters, [[react-common-ab-test]] (`gtm.deviceId`) |

The container id is hard-coded: `NEXT_PUBLIC_GTM_ID=GTM-PLRJPPQ` in payment-fe, `GTM_ID` for every environment in react-common-analytic `getConfig.ts`, and `google_tag_manager['GTM-PLRJPPQ']` in gtm-extras `getDataLayerValue`.

## Per repo
- **TIX-NEXT-PAYMENT-FE**: `lib/hooks/useGTM` (`pushGTMClickV2`, `pushGTMImpressionV2`, `pushGTMStatusV2`) over the `DataLayer` type in `lib/tracker/GTM.ts`, plus `components/GTMHandler`. [[payment-fe-payment-link]] has its own layer in `app/payment-link/tracking` (`gtm-tracker.ts`, `standalone.ts`) that writes `window.dataLayer` directly. Payment events use `eventCategory: paymentProcessing` (see [[payment-fe-payment]], [[payment-fe-downpay]]).
- **TIX-FINTECH-NEXT-FE**: `components/CustomScripts/GTMScripts.tsx` injects the GTM snippet, sets `window.ANALYTICS_VERSION = "2.1"`, `window.gtm.trackingId` and `window.gtm.vertical` (for example `giftCard`). gtm-extras special-cases `vertical === 'giftCard'` ([[fintech-fe-gift-card]]).
- **TIX-REACT-REMOTE**: the `scripts` remote calls react-common-analytic `initialize()`, so on Next pages that mount it, analytics bootstrap comes from the remote ([[react-remote-scripts]], [[react-remote-footer]]).
- **TIX-PASSPORT**: `PassportProvider` takes a `dataLayer` prop (`Record<string, string>`) that some widgets spread into their events, for example [[passport-global-search]], [[passport-currency-bottom-sheet]] and [[passport-country-and-currency-modal]] ([[passport-utils]]).
- **TIX-GTM-EXTRAS**: a single bundle loaded by GTM. Its vendor scripts build Facebook, TikTok and other pixel events from `window.gtm` ([[gtm-extras-facebook]], [[gtm-extras-tiktok]]).

## Gotchas
- `window.gtm` is an implicit contract. Renaming `vertical`, `screenName` or a per-vertical field silently breaks GTM tags and gtm-extras pixels.
- react-common-analytic replaces core attributes on `window.gtm`. App code that sets the same keys overwrites them or gets overwritten ([[analytics-core-attributes]]).
- With `ANALYTICS_VERSION` other than `'2.1'`, react-common-analytic does not override `dataLayer.push`. Its README says `"2.0"`, which takes the old path.
- payment-fe's unit tests check pushes against `window.dataLayer` directly, so the event shape is effectively pinned by specs.

## Where it shows up
Pages that link here:
- TIX-NEXT-PAYMENT-FE: [[payment-fe-architecture]], [[payment-fe-downpay]], [[payment-fe-payment]], [[payment-fe-payment-link]]
- concepts: [[analytics-core-attributes]], [[cross-app-routing]]
- entities: [[kuber]]

## Sources
- TIX-NEXT-PAYMENT-FE `lib/hooks/useGTM.ts`, `lib/tracker/GTM.ts`, `app/payment-link/tracking/{gtm-tracker,standalone}.ts`, `.env.local.example`
- TIX-FINTECH-NEXT-FE `components/CustomScripts/GTMScripts.tsx`
- TIX-REACT-COMMON `packages/react-common-analytic/src/{getConfig,initialize,updateAnalyticCoreAttributes}.ts`
- TIX-REACT-REMOTE `src/utils/tracker/tracker.ts`, `src/components/scripts/index.tsx`
- TIX-GTM-EXTRAS `scripts/helpers.js`
- TIX-PASSPORT `packages/utils/src/context.tsx`; `git grep -l "dataLayer\|window.gtm" origin/main -- 'packages/*/src/**'`
