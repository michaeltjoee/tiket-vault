---
title: react-common-analytic
repo: TIX-REACT-COMMON
kind: package
npm: "@tiket/react-common-analytic"
sources:
  - packages/react-common-analytic/src
  - packages/react-common-analytic/package.json
  - packages/react-common-analytic/build.js
  - packages/react-common-analytic/webpack.config.js
  - packages/react-common-analytic/README.md
  - packages/react-common-analytic/docs
verified_at: 14597c4e
updated: 2026-10-16
status: current
tags: [repo/react-common, kind/package]
---

# react-common-analytic
> Client-side analytics bootstrap: gathers core attributes, writes them to `window.gtm`, initialises Amplitude and Mixpanel, sends page-visit/session events, and exposes core-attribute headers for backend tracking.

## What it does
`initialize(options?)` (client only, call once at app root) starts [[react-common-core-attributes]] and waits for its `EVENT_CORE_ATTRIBUTES_UPDATED` `postMessage`. Then it updates `window.gtm` and `window.gtm.user`. With `window.ANALYTICS_VERSION === '2.1'` on web, it initialises the Amplitude and Mixpanel SDKs itself (each can be disabled via `options.config`), replays `dataLayer` events pushed before init, and overrides `dataLayer.push` so later pushes also go to the SDKs. In a webview it forwards events to the native app via JSI ([[react-common-jsi]]) instead. Completion is published through [[react-common-queue]] keys so other code can `waitFor` it. See [[analytics-core-attributes]].

## Public API
| Export | Purpose |
|---|---|
| `initialize(options?: InitializationOptions)` | bootstrap; returns a promise resolved after core attributes arrive. `options.config.{isAmplitudeEnabled,isMixpanelEnabled}` default `true` |
| `updateAnalytics()` | call on SPA navigation: page-visit event + global properties (skipped if session expired) |
| `injectAnalyticCoreAttributes(req?)` | returns `{ appversion, deviceid, devicemodel, externalparty, osversion, platform, tiketsessionid }` headers from `window.gtm` on client or from `req.headers` on server; empty values dropped |
| `updateAnalyticCoreAttributes`, `updateGtmCoreAttributes` | write core attrs into `window.gtm` |
| `triggerPageVisitEvent`, `handlePageVisitOnInit`, `handleTrackerEventsAfterExpiration`, `lastActivityListener` | page-visit/session events |
| `getAmplitudeInstance`, `initializeAmplitudeSDK`, `initializeMixpanelSDK` | SDK access/init |
| `QUEUE_KEY_REACT_COMMON_ANALYTIC`, `QUEUE_KEY_REACT_COMMON_ANALYTIC_DEVICE_ATTRS_INITIALIZED`, `AMPLITUDE_EVENT_LOGGER_NAME`, `EVENT_LAUNCH_TIKET` | constants |

Also sets globals: `window.commonAnalytic.{initialize, updateAnalytics, waitForInitialization, waitForDeviceAttrsInitialization, getCoreAnalyticHeaders}` and `window.__CORE_DATA__['react-common-analytic'].version`.

## Usage
```ts
import { initialize } from '@tiket/react-common-analytic';
useEffect(() => { initialize(); }, []); // root App, client only

// wait before a call that needs device headers (TIX-NEXT-PAYMENT-FE SubmitPayment)
import { QUEUE_KEY_REACT_COMMON_ANALYTIC } from '@tiket/react-common-analytic';
import { waitFor } from '@tiket/react-common-queue';
await waitFor(QUEUE_KEY_REACT_COMMON_ANALYTIC, { timeout: 5000 });
```

## Depends on
- [[react-common-core-attributes]], [[react-common-env]], [[react-common-queue]], [[react-common-jsi]], [[react-common-storage]]
- `@amplitude/analytics-browser` ^1.10, `mixpanel-browser` ^2.80. Requires a GTM script on the page.

## Used by
- TIX-PASSPORT: global-search (package.json).
- TIX-REACT-REMOTE: [[react-remote-scripts]] (`src/components/scripts/index.tsx`), pinned `5.0.6`.
- TIX-NEXT-PAYMENT-FE: `components/SubmitPayment/index.tsx` waits on the analytic queue key ([[payment-fe-components]]).

## Gotchas
- README says set `window.ANALYTICS_VERSION = "2.0"` before GTM, but the code only takes the "new approach" (library-owned Amplitude/Mixpanel init, `dataLayer.push` override) when it is **`'2.1'`**. Otherwise on web it only updates `window.gtm` (and logs to Amplitude in non-prod).
- Webview: Mixpanel is **not** initialised here; [[react-common-ab-test]] initialises it itself.
- `window.commonAnalytic.disablePageVisitEventOnInitialize = true` also disables the global-properties update; you must call `window.commonAnalytic.updateAnalytics()` yourself before navigating.
- Mixpanel session recording sample: staging 10%, production 0.5%, others 0. `mixpanel.reset()` runs when there is no userId or it differs from the distinct id.
- esbuild bundles `jsi` and `storage` into the output (only env, queue, core-attributes are external); see [[react-common-architecture]].
- `build-cdn` (webpack + swc) emits `lib/commonAnalytic.js` from `initialize.ts`; README marks CDN install as work in progress.
- Delete any project-side code that sets the same core attributes on `window.gtm`, or it overwrites them.

## Sources
- packages/react-common-analytic/src/{index,initialize,injectAnalyticCoreAttributes,updateAnalyticCoreAttributes,constants,types}.ts
- packages/react-common-analytic/src/mixpanel/initializeMixpanelSDK.ts, src/events/*, src/amplitude/*
- packages/react-common-analytic/README.md, build.js, webpack.config.js, docs/*.puml
- .cursor/skills/contribute-analytic/ (read in place)
