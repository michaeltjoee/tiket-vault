---
title: A/B testing and feature flags
kind: concept
repos: [TIX-REACT-COMMON, TIX-PASSPORT, TIX-REACT-REMOTE, TIX-NEXT-PAYMENT-FE, TIX-HOMEPAGE-NEXT-FE]
sources:
  - TIX-REACT-COMMON/packages/react-common-ab-test/src
  - TIX-REACT-COMMON/packages/react-common-utilities/src
  - TIX-PASSPORT/packages/utils/src/useRollout.ts
  - TIX-PASSPORT/packages/utils/src/context.tsx
  - TIX-REACT-REMOTE/src/components/header/index.tsx
  - TIX-NEXT-PAYMENT-FE/package.json
  - TIX-HOMEPAGE-NEXT-FE/pages/index.page.tsx
  - TIX-HOMEPAGE-NEXT-FE/components/providers/AppProvider.tsx
  - TIX-HOMEPAGE-NEXT-FE/lib/utils/consumeAbTestResponse/consumeAbTestResponse.ts
verified_at:
  TIX-REACT-COMMON: 14597c4e
  TIX-PASSPORT: 7a33010aca
  TIX-REACT-REMOTE: 281778b
  TIX-NEXT-PAYMENT-FE: 9e92b20bb
  TIX-HOMEPAGE-NEXT-FE: 408983f6
updated: 2026-10-16
status: current
tags: [kind/concept, repo/react-common, repo/passport, repo/react-remote, repo/payment-fe, repo/homepage-fe]
---

# A/B testing and feature flags
> Experiments and rollout flags run on **Mixpanel feature flags** (older comments say Amplitude). [[react-common-ab-test]] provides a client hook and a server fetch. Passport widgets read flags through it, and hosts can pre-fetch variants on the server and pass them down as `abTestOnServerResponse`.

## Pieces
- **Client:** `useExperiment()` lazily initialises the Mixpanel browser SDK once per page, fetches flags and returns a client. `getVariant(key)` also fires Mixpanel's exposure event.
- **Server:** `getAbTestOnServer({ deviceId, userId })` uses the Node `mixpanel` SDK (`remote_flags.getAllVariants`) and returns a JSON-safe `{ status, variants }`. Pass it to the hook, which then skips client fetching. It reads `NEXT_PUBLIC_AB_TEST_ENV`, because [[react-common-env]] always says `staging` on the server.
- **Device id:** the `device_id` cookie must exist on the first request. Next middleware sets it with `setMandatoryCookies`/`getDeviceId` from [[react-common-utilities]].
- **Passport:** [[passport-utils]] has `useRollout(key, default, abTestOnServerResponse)` and `PassportProvider` accepts `abTestOnServerResponse`. Its own flag `ff-is-accessibility-support-enabled` gates [[passport-accessibility-font-scaling]]. Six packages import react-common-ab-test: [[passport-country-and-currency-modal]], [[passport-global-popup]], [[passport-global-search]], [[passport-google-one-tap]], [[passport-page-module]] (types only) and passport-utils.
- **TIX-REACT-REMOTE:** header, footer, global-popup and google-one-tap accept an `abTestOnServerResponse` prop and pass it to Passport ([[react-remote-header]]).
- **TIX-NEXT-PAYMENT-FE** declares `@tiket/react-common-ab-test` but imports nothing from it on its baseline.
- **TIX-HOMEPAGE-NEXT-FE** pins `5.0.1` (also forced by a pnpm override). Home, destination, explore, voucher box and cross-sell trip call `getAbTestOnServer` in `getServerSideProps` and pass the result to `PassportProvider` and to `PageModule` `experiments` ([[homepage-fe-architecture]]). Vitest aliases the package to a stub.

## Gotchas
- Requires [[react-common-analytic]] on the page. The client reads `window.gtm.deviceId` after waiting up to 5 s for analytic. If analytic never finished, the distinct id is the string `"undefined"` ([[analytics-core-attributes]]).
- A missing `NEXT_PUBLIC_AB_TEST_ENV` defaults to `development`, so production SSR silently reads development flags.
- `status === 'error'` from the server (for example no `deviceId`) makes the hook return no variants. It does not fall back to fetching on the client.
- Initialisation is a module-level singleton: the first `useExperiment` call fixes the initial variants for the page.
- Variants differ between app, webview and browsers when `gtm.deviceId` or `userId` is empty.

## Where it shows up
Pages that link here:
- TIX-HOMEPAGE-NEXT-FE: [[homepage-fe-architecture]]
- TIX-REACT-COMMON: [[react-common-ab-test]]
- concepts: [[analytics-core-attributes]], [[passport-accessibility-font-scaling]], [[tiket-environments]]
- howto: [[add-new-passport-package]]

## Sources
- TIX-REACT-COMMON `packages/react-common-ab-test/src/{useExperiment,getAbTestOnServer,getUserData,initialize}.ts`, `packages/react-common-utilities/src` (`setMandatoryCookies`, `getDeviceId`)
- TIX-PASSPORT `packages/utils/src/{useRollout.ts,context.tsx}`; `git grep "from '@tiket/react-common-ab-test'" origin/main -- packages`
- TIX-REACT-REMOTE `src/components/{header,footer,global-popup,google-one-tap}/index.tsx`
- TIX-NEXT-PAYMENT-FE `package.json`
- TIX-HOMEPAGE-NEXT-FE `pages/index.page.tsx` (and the other `getAbTestOnServer` callers), `components/providers/AppProvider.tsx`, `lib/utils/consumeAbTestResponse/consumeAbTestResponse.ts`, `vitest.config.mts`
