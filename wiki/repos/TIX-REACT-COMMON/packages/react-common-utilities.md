---
title: react-common-utilities
repo: TIX-REACT-COMMON
kind: package
npm: "@tiket/react-common-utilities"
sources:
  - packages/react-common-utilities/src
  - packages/react-common-utilities/package.json
  - packages/react-common-utilities/README.md
verified_at: 14597c4e
updated: 2026-10-16
status: current
tags: [repo/react-common, kind/package]
---

# react-common-utilities
> Shared helpers for every tiket web app: multi-currency formatting, the new URL structure (locale/country/currency), forwarded query params, device id and cookie helpers, client channel/OS headers, and bot detection. This is the most widely used react-common package.

## What it does
It has no runtime state and works in both client and server code (pages-router `GetServerSidePropsContext`, Next middleware `MiddlewareRequest`, or the browser). The headline API is `createCurrencyFormatter`, which formats amounts per currency, with fixed decimal places per currency ([[multi-currency]]). The rest supports the "new URL structure" rollout ([[new-url-structure]]): locale/country/currency resolution by priority, middleware data, rewriting links with forwarded `tag_*`/UTM params, and mandatory cookies (`device_id`, `country_code`) set from middleware.

## Public API (grouped)
| Group | Main exports |
|---|---|
| currency | `createCurrencyFormatter({ locale, currency, scale })` → `(value) => { toString({ rounding?, withCurrencyLabel? }), toCalendarString(), toNumber({ rounding? }) }`; `COUNTRY_CURRENCY_MAP`, `DECIMAL_PLACES_BY_CURRENCY`, `AVAILABLE_CURRENCIES/LOCALES/COUNTRIES` |
| URL structure | `isNewURLStructure`, `inspectUrlStructure`, `getNewUrlStructure`, `getBaseUrl`, `getLocaleByPriority`, `getCountryByPriority`, `getCurrencyByPriority`, `getLocaleAndCountry`, `getCurrencyFromParams`, `normalizeRelativePath`, `getLanguageAndCurrency`, `getClientSideMiddlewareData` |
| forward params | `ForwardParamsProvider`, `useForwardParams()` (`withForwardParams(link)`, `forwardParamsRef`, `objectParamsToForward`), `createParamsForwarder`, `createWithForwardParams`, `getParamsToForward`, `getMiddlewareDataOutsideHookWorkaround` |
| device / session | `getDeviceId(ctx \| middlewareReq)`, `getOrCreateDeviceId`, `getSSPDeviceId`, `setMandatoryCookies({ req, res })` |
| headers | `getCommonHeaders`, `getUtmMandatoryReqHeaders`, `getClientChannel(req?)`, `getClientOS(req?)`, `getClientPlatform(req?)`, `sanitizeAcceptLanguageHeader` |
| cookies / request | `getBrowserCookieValue`, `getServerCookieValue`, `setServerCookieValue`, `getServerSetCookieValue`, `getCookieValue`, `getRequestHeader`, `getRequestHost`, `getServerUserAgent`, `getBrowserUrl` |
| env detection | `getWebViewEnv`, `getWebViewEnvClient`, `getWebViewEnvServer`, `isServerWebviewEnv`, `isBrowserEnv`, `isServer`, `isStatic`, `isBotUserAgent(ua)`, `BOT_UA_KEYWORDS`, `isJwtToken`, `isValidLocale`, `sanitizeLocale`, `sanitizeUserCurrency` |
| types | `Locale`, `Country`, `Currency`, `MiddlewareData`, `MiddlewareRequest`, `GetServerSidePropsContext` (a slim context so callers can build one by hand)… |

## Usage
```ts
import { createCurrencyFormatter } from '@tiket/react-common-utilities';
const fmt = createCurrencyFormatter({ locale: 'id', currency: 'USD', scale: 2 });
fmt(951).toString();                  // "USD 9,51"
fmt(1050).toString({ rounding: true }); // "USD 11" (discovery pages)
fmt(951).toNumber();                  // 9.51 (for GTM)

// middleware
import { setMandatoryCookies } from '@tiket/react-common-utilities';
setMandatoryCookies({ req, res });    // country_code + 1-year device_id
```

## Depends on
- `uuid`. `ForwardParamsProvider` imports `usePassport` from **`@tiket/passport-utils`**, which is only a devDependency here, so the host must install it ([[passport-utils]]).
- No internal deps (leaf package).

## Used by
- TIX-PASSPORT: 23 packages (calendar, header, page-module, product-card, search widgets, utils, …). See [[passport-overview]].
- TIX-REACT-REMOTE (pinned 4.1.0): [[react-remote-wrapper]] (`PassportWrapper` mounts `ForwardParamsProvider`). It is listed in `consumeFromSource` in `webpack.config.js`, so the remote compiles it from source instead of using `dist`.
- TIX-NEXT-PAYMENT-FE: mostly `createCurrencyFormatter` (about 18 imports, e.g. [[payment-fe-downpay]]), `createParamsForwarder`, `app/hooks/useCommonUtils.ts`.
- TIX-FINTECH-NEXT-FE: gift-card components ([[fintech-fe-gift-card]]).
- Internal: [[react-common-fetch-client]] (bundled in), [[react-common-remote]], [[react-common-error-handler]] (undeclared).

## Gotchas
- `getDeviceId` **creates** a new UUID only when given a middleware request (`'nextUrl' in arg`). In `getServerSideProps` it only reads the cookie, so on the very first request the id is empty unless middleware set it (this is what [[react-common-ab-test]] SSR relies on). In a webview it never creates one.
- `src/isTiketDomain/` exists but is **not exported** from `src/index.ts`.
- README warns: Node 12 lacks the `id` locale for `Intl.NumberFormat`, so use `full-icu`. Calendar strings always round.
- On iPadOS Safari without a `device_type` cookie, channel/OS resolve to `DESKTOP`/`MAC`.
- `build.js` and `babel.config.js` are left over: the build is plain `tsc --project` to `dist/`. Root Jest maps this package to `src/index.ts`, so tests never use a build.

## Sources
- packages/react-common-utilities/src/index.ts, src/forwardParams/context.tsx, src/getDeviceId/*, src/setMandatoryCookies/*, src/isBotUserAgent/*
- packages/react-common-utilities/README.md, package.json
