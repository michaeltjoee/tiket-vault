---
title: react-common-core-attributes
repo: TIX-REACT-COMMON
kind: package
npm: "@tiket/react-common-core-attributes"
sources:
  - packages/react-common-core-attributes/src
  - packages/react-common-core-attributes/package.json
  - packages/react-common-core-attributes/build.js
verified_at: 14597c4e
updated: 2026-10-16
status: current
tags: [repo/react-common, kind/package]
---

# react-common-core-attributes
> Builds and persists the "core attributes" (device id, tiket session id, language, currency, country, platform, user, UTM) that every tracker and backend header uses.

## What it does
`initialize(options?)` collects attributes in the browser and calls `updateCoreAttributes`, which saves them to shared storage under `tiket-com-analytic` ([[react-common-storage]]) and announces them with `window.postMessage({ name: 'EVENT_CORE_ATTRIBUTES_UPDATED', data })`. On web it gets or creates a 30-minute session id (firing a `launchTiket` event when a session starts or expires), reads locale cookies or middleware data, and fetches the user from `/tix-member-core/v2/account` unless `options.user` is passed. In a webview it instead asks the native app over webkit/Android bridges (`getAppDetails`, `getUserAuthenticationDetails`) and writes `device_id` cookies. It is normally driven by [[react-common-analytic]], not called directly. See [[analytics-core-attributes]].

## Public API
| Group | Exports |
|---|---|
| bootstrap | `initialize(options?: InitializationOptions)`, `window.commonCoreAttributes.updateCoreAttributes` |
| attributes | `getCoreAttributes()`, `updateCoreAttributes(attrs)` |
| session | `createSessionId`, `getOrCreateSessionId({ onEmptyOrExpired })`, `triggerLaunchTiketEvent` |
| env | `isWebview()`, `TIKET_QUERY_DEVICE_TYPE`, `TIKET_APP_UA`, `getCookie` |
| UTM / referrer | `getUtmParams`, `getUtmExternal`, `getUtmReferrer`, `getReferrer`, `isReferrerUrlFromTiket`, `getTagParams`, `isFirstPage`, `getClientSideMiddlewareData` |
| backend | `postUserAttributes({ eventName, projectName, utmAttributes?, attributes? })`: posts to CDP "cancer harvester" `/cancer/harvester/event` (`api-gatotkaca.tiket.com` non-prod, `api.tiket.com` prod) |
| constants | `LOCAL_STORAGE_KEY*`, `SESSION_EXPIRATION_TIME_*` (30 min), `EVENT_CORE_ATTRIBUTES_UPDATED`, `COOKIE_*` (`device_id`, `tiket_currency`, `userlang`, `tiket_session_id`…), `DEFAULT_CORE_ATTRIBUTES` |
| types | `ICoreAttributes`, `IBaseCoreAttributes`, `IUserAttributes`, `IUtmAttributes`, `UpdateCoreAttributesEventData`, `InitializationOptions`… |

## Usage
```ts
import { EVENT_CORE_ATTRIBUTES_UPDATED, initialize } from '@tiket/react-common-core-attributes';
window.addEventListener('message', (e) => {
  if (e.data.name === EVENT_CORE_ATTRIBUTES_UPDATED) console.log(e.data.data);
});
initialize(); // as done in react-common-analytic/src/initialize.ts
```

## Depends on
- [[react-common-env]], [[react-common-storage]], [[react-common-jsi]], [[react-common-fetch-client]] (also imports `@tiket/react-common-fetch-client/src/logger` by deep path)
- `uuid` ^9

## Used by
- [[react-common-analytic]] (main consumer).
- TIX-FINTECH-NEXT-FE: listed in `package.json`, no direct import found.
- No direct use in TIX-PASSPORT, TIX-REACT-REMOTE or TIX-NEXT-PAYMENT-FE (they get it through analytic).

## Gotchas
- In `initialize.ts`, `getCookie('userlang') || isNewURLStructure ? A : B` parses as `(cookie || isNew) ? A : B`: the cookie value is only a truthiness test and is never used as the language. The same holds for currency and country. Values come from middleware data (defaults `en`/`USD`/`us`) or the legacy `window.__data` (`ID`/`IDR`/`id`).
- Results are delivered by `postMessage`, not a return value; `initialize` resolves before attributes are ready. Use the analytic queue keys to wait.
- Sets `window.isSessionExpired` as a global; analytic reads it in `updateAnalytics`.
- `postUserAttributes` skips the `affiliate` screen name.
- `src/analytic/` is marked temporary and meant to move to [[react-common-analytic]].

## Sources
- packages/react-common-core-attributes/src/{index,initialize,constants,initializeBridgeData,isWebview}.ts
- packages/react-common-core-attributes/src/coreAttributes/*, src/services/*, src/fetcher/getUserData.ts, src/types/index.ts
- packages/react-common-core-attributes/package.json, build.js
