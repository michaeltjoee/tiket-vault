---
title: react-common-ab-test
repo: TIX-REACT-COMMON
kind: package
npm: "@tiket/react-common-ab-test"
sources:
  - packages/react-common-ab-test/src
  - packages/react-common-ab-test/package.json
  - packages/react-common-ab-test/build.js
  - packages/react-common-ab-test/README.md
verified_at: 14597c4e
updated: 2026-10-16
status: current
tags: [repo/react-common, kind/package]
---

# react-common-ab-test
> A/B test variants from Mixpanel feature flags, client-side via a React hook and server-side via `getAbTestOnServer`.

## What it does
Client side, `useExperiment()` lazily initialises the Mixpanel browser SDK (core loader) once per page, fetches flags and wraps them in a `MixpanelExperimentClient`. Reading a variant through `getVariant(key)` also fires Mixpanel's exposure tracking (`flags.get_variant_sync`). Server side, `getAbTestOnServer({ deviceId, userId })` uses the Node `mixpanel` SDK's `remote_flags.getAllVariants` and returns a JSON-safe `{ status, variants }` to pass into the hook, which then skips client fetching. Despite older comments, the backend is Mixpanel, not Amplitude (see [[ab-testing]]).

## Public API
| Entry | Export | Notes |
|---|---|---|
| `@tiket/react-common-ab-test` | `useExperiment({ abTestOnServerResponse? })` | returns `{ isLoading, getVariant(key), exposeExperimentExposureTracker(key \| key[]) }` |
| | `initialize({ initialVariants? })` | returns `IExperimentClient` (`variant(key)`, `allVariants()`) |
| | types `Variant`, `Variants`, `IExperimentClient`, `AbTestOnServerResponse`, `ExperimentConfig`… | `Variant` = `{ experimentId, key, value, isExperimentActive, isQaTester, payload }` |
| `@tiket/react-common-ab-test/server` | `getAbTestOnServer({ deviceId, userId?, config? })` | `config.remote_flags_config.{api_host, request_timeout_in_seconds}` (default `api.mixpanel.com`, 5 s) |

## Usage
```tsx
// getServerSideProps / server component
import { getAbTestOnServer } from '@tiket/react-common-ab-test/server';
import { getDeviceId } from '@tiket/react-common-utilities';
const abTestOnServerResponse = await getAbTestOnServer({ deviceId: getDeviceId(ctx), userId });

// client
import { useExperiment } from '@tiket/react-common-ab-test';
const { isLoading, getVariant } = useExperiment({ abTestOnServerResponse });
const show = getVariant('fe-testing')?.payload?.value;
```

## Depends on
- [[react-common-env]] (`getEnvironment`, `Env`), [[react-common-queue]]
- `mixpanel-browser` ^2.73 (client), `mixpanel` ^0.19 (server); peer React 19

## Used by
- TIX-PASSPORT: 6 packages (country-and-currency-modal, global-popup, global-search, google-one-tap, page-module, utils). See [[passport-overview]].
- TIX-NEXT-PAYMENT-FE: dependency in `package.json` ([[payment-fe-overview]]).
- TIX-FINTECH-NEXT-FE: only mocked in `vitest.setup.tsx`, not a direct dependency.

## Gotchas
- **Requires [[react-common-analytic]] set up** on the page (README). On webview, analytic does not pre-initialise Mixpanel, so `initialize` is the only init; it uses the mutated `mixpanelCore` singleton, not the return value of `init`.
- Initialisation is a module-level singleton promise: the first `useExperiment` call decides `initialVariants`; later calls with different server data reuse the first client.
- `abTestOnServerResponse.status === 'error'` (e.g. no `deviceId`) makes the hook stop loading and return no variants; it does **not** fall back to client fetching.
- SSR needs `NEXT_PUBLIC_AB_TEST_ENV` (`production` or `development`); it defaults to `development`, so a missing var in prod silently reads dev flags. The deviceId cookie must be set by middleware before the first SSR.
- With server data, `getVariant` still goes through the client once it exists, because that is what fires exposure tracking. Use `exposeExperimentExposureTracker` when you read variants from props directly.
- Client `getUserData` waits up to 5 s for analytic (`waitFor(QUEUE_KEY_REACT_COMMON_ANALYTIC, { timeout: 5000 })`), then reads `window.gtm.deviceId`. If analytic never finished, `deviceId` is the **string `"undefined"`** and becomes the Mixpanel distinct id.
- Inconsistent variants between app and webview/browsers happen when `gtm.deviceId`/`userId` are empty.

## Sources
- packages/react-common-ab-test/src/{index,server,initialize,useExperiment,getAbTestOnServer,experimentClient,trackExperimentExposure,types,constants}.ts
- packages/react-common-ab-test/README.md, package.json, build.js
- .cursor/skills/contribute-ab-test/SKILL.md (read in place)
