---
title: Analytics core attributes
kind: concept
repos: [TIX-REACT-COMMON, TIX-REACT-REMOTE, TIX-NEXT-PAYMENT-FE, TIX-FINTECH-NEXT-FE, TIX-HOMEPAGE-NEXT-FE, TIX-GROWTH-NEXT-FE]
sources:
  - TIX-REACT-COMMON/packages/react-common-core-attributes/src
  - TIX-REACT-COMMON/packages/react-common-analytic/src
  - TIX-REACT-REMOTE/src/components/scripts/index.tsx
  - TIX-NEXT-PAYMENT-FE/lib/helpers/unm.ts
  - TIX-NEXT-PAYMENT-FE/components/SubmitPayment/index.tsx
  - TIX-FINTECH-NEXT-FE/projects/refund/shared/lib/helpers/unm.ts
  - TIX-HOMEPAGE-NEXT-FE/pages/_app.page.tsx
  - TIX-HOMEPAGE-NEXT-FE/lib/tracker/Analytics.ts
  - TIX-GROWTH-NEXT-FE/pages/_app.page.tsx
  - TIX-GROWTH-NEXT-FE/lib/gtm/harvesterEventWatcher.ts
verified_at:
  TIX-REACT-COMMON: 14597c4e
  TIX-REACT-REMOTE: 281778b
  TIX-NEXT-PAYMENT-FE: 9e92b20bb
  TIX-FINTECH-NEXT-FE: 5833b842
  TIX-HOMEPAGE-NEXT-FE: 408983f6
  TIX-GROWTH-NEXT-FE: d4162e3
updated: 2026-10-16
status: current
tags: [kind/concept, repo/react-common, repo/react-remote, repo/payment-fe, repo/fintech-fe, repo/homepage-fe, repo/growth-fe]
---

# Analytics core attributes
> One set of identity and context fields (device id, session id, language, currency, country, platform, user, UTM and `tag_*` params) is computed once per page by [[react-common-core-attributes]]. It is shared through cross-subdomain storage, `postMessage` and `window.gtm`, so every tracker and backend sees the same values.

## Pipeline
1. [[react-common-analytic]] `initialize()` starts core-attributes. On the Next app pages (payment-fe, fintech-fe, homepage-fe, growth-fe) this happens inside the `scripts` remote from TIX-REACT-REMOTE ([[react-remote-scripts]]).
2. core-attributes builds the attributes. On web it creates or reuses a 30-minute `tiketSessionId` (firing `launchTiket` on a new session), reads middleware data or cookies, and fetches the user from `/tix-member-core/v2/account`. In a webview it asks the app over the bridge ([[webview-jsi-bridge]]).
3. It saves them under the shared-storage key **`tiket-com-analytic`** ([[cross-subdomain-storage]]) and broadcasts `window.postMessage({ name: 'EVENT_CORE_ATTRIBUTES_UPDATED', data })`.
4. analytic writes them to `window.gtm` and `window.gtm.user` ([[gtm-datalayer-tracking]]) and, with `ANALYTICS_VERSION '2.1'`, registers them as Amplitude and Mixpanel properties.
5. `injectAnalyticCoreAttributes` turns them into request headers for backends. Completion is published on [[react-common-queue]] keys.

## Consumers outside react-common
- TIX-NEXT-PAYMENT-FE `components/SubmitPayment` waits on `QUEUE_KEY_REACT_COMMON_ANALYTIC` (5 s) before building device headers, and `lib/helpers/unm.ts` reads `tiket-com-analytic` from shared storage for the device id ([[payment-fe-components]]).
- TIX-FINTECH-NEXT-FE refund has a copy of the same helper, `projects/refund/shared/lib/helpers/unm.ts`, which reads `tiket-com-analytic` through [[react-common-storage]] ([[fintech-fe-refund]]).
- TIX-HOMEPAGE-NEXT-FE mounts `RemoteScripts` in `_app`. Its `AnalyticsEventHandler` (`lib/tracker/Analytics.ts`) sets `window.eventProperties` and calls `window.commonAnalytic.updateAnalytics()` ([[homepage-fe-architecture]]).
- TIX-GROWTH-NEXT-FE mounts `RemoteScripts` in `_app` and `app/layout`. Metasearch checkout patches `fetch` to wait for the harvester's `pageVisit` post to `/cancer/harvester/event` (after `launchTiket`) before it redirects (`lib/gtm/harvesterEventWatcher.ts`, [[growth-fe-metasearch]]).
- [[react-common-ab-test]] uses `window.gtm.deviceId` as the Mixpanel distinct id ([[ab-testing]]).

## Gotchas
- `initialize` resolves before the attributes exist. Wait on the queue key or the `postMessage`, not the promise.
- Operator precedence bug in `initialize.ts`: `getCookie('userlang') || isNewURLStructure ? A : B` never uses the cookie value. Language, currency and country come from middleware data (defaults `en`/`USD`/`us`) or legacy `window.__data` (`ID`/`IDR`/`id`). See [[new-url-structure]].
- Safari/iOS store `tiket-com-analytic` in a cookie, other browsers in the storage iframe. A value written in one is not visible in the other.
- If analytic never finishes, ab-test reads the **string** `"undefined"` as `deviceId`.

## Where it shows up
Pages that link here:
- TIX-REACT-COMMON: [[react-common-analytic]], [[react-common-core-attributes]]
- concepts: [[ab-testing]], [[cross-subdomain-storage]], [[gtm-datalayer-tracking]], [[new-url-structure]]

## Sources
- TIX-REACT-COMMON `packages/react-common-core-attributes/src/{initialize.ts,constants.ts}`, `packages/react-common-analytic/src/{initialize,injectAnalyticCoreAttributes,updateAnalyticCoreAttributes}.ts`
- TIX-REACT-REMOTE `src/components/scripts/index.tsx`
- TIX-NEXT-PAYMENT-FE `components/SubmitPayment/index.tsx`, `lib/helpers/unm.ts`
- TIX-FINTECH-NEXT-FE `projects/refund/shared/lib/helpers/unm.ts`
- TIX-HOMEPAGE-NEXT-FE `pages/_app.page.tsx`, `lib/tracker/Analytics.ts`
- TIX-GROWTH-NEXT-FE `pages/_app.page.tsx`, `app/layout.page.tsx`, `lib/gtm/harvesterEventWatcher.ts`
