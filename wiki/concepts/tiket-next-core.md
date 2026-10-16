---
title: "@tiket/next (tiket Next.js core)"
kind: concept
repos: [TIX-NEXT-PAYMENT-FE, TIX-FINTECH-NEXT-FE, TIX-REACT-COMMON, TIX-HOMEPAGE-NEXT-FE, TIX-GROWTH-NEXT-FE]
sources:
  - TIX-NEXT-PAYMENT-FE/package.json
  - TIX-NEXT-PAYMENT-FE/middleware.page.ts
  - TIX-NEXT-PAYMENT-FE/next.config.ts
  - TIX-NEXT-PAYMENT-FE/app/api
  - TIX-FINTECH-NEXT-FE/package.json
  - TIX-FINTECH-NEXT-FE/middleware.page.ts
  - TIX-FINTECH-NEXT-FE/next.config.js
  - TIX-FINTECH-NEXT-FE/app/api
  - TIX-FINTECH-NEXT-FE/lib/fetch/fetch.ts
  - TIX-REACT-COMMON/packages/react-common-fetch-client/src/client/helper.ts
  - TIX-HOMEPAGE-NEXT-FE/package.json
  - TIX-HOMEPAGE-NEXT-FE/middleware.page.ts
  - TIX-HOMEPAGE-NEXT-FE/app/api
  - TIX-GROWTH-NEXT-FE/package.json
  - TIX-GROWTH-NEXT-FE/middleware.page.ts
  - TIX-GROWTH-NEXT-FE/app/api
verified_at:
  TIX-NEXT-PAYMENT-FE: 9e92b20bb
  TIX-FINTECH-NEXT-FE: 5833b842
  TIX-REACT-COMMON: 14597c4e
  TIX-HOMEPAGE-NEXT-FE: 408983f6
  TIX-GROWTH-NEXT-FE: d4162e3
updated: 2026-10-16
status: current
tags: [kind/concept, repo/payment-fe, repo/fintech-fe, repo/react-common, repo/homepage-fe, repo/growth-fe]
---

# @tiket/next
> `@tiket/next` is tiket's shared Next.js toolkit (middleware, gateway fetch, logger, i18n, auth routes, build config). All four Next apps depend on it (`^3.0.0` in payment-fe and fintech-fe, exact `3.3.0` in homepage-fe and `3.3.1` in growth-fe), but its source is **not** in this workspace, so its behaviour can only be read from `node_modules` or inferred from call sites.

## What the apps take from it
| Entry | Used for | Import count (payment-fe / fintech-fe / homepage-fe / growth-fe) |
|---|---|---|
| `@tiket/next/client` | `fetchClient`, `useMiddlewareData`, `useLocaleCountry`, `MiddlewareDataProvider`, `LocaleCountryProvider`, `createI18nContext` | 175 / 69 / 48 / 14 |
| `@tiket/next/server` | `chain`, `localeMiddleware`, `currencyMiddleware`, `getMiddlewareData`, route handlers `createTokenGET`, `refreshTokenGET`, `postLogPOST` | 9 / 44 / 4 / 7 |
| `@tiket/next/types` | `MiddlewareModule`, `MiddlewareData` and related types | 47 / 55 / 94 / 34 |
| `@tiket/next/logger` | `createLogger` (server and middleware logs) | 22 / 10 / 12 / 0 |
| `@tiket/next/pages` | Pages Router helpers | 13 / 16 / 15 / 13 |
| `@tiket/next/fetch` | `apiFetch` (the `lib/fetch` wrapper in fintech-fe and homepage-fe) | 0 / 2 / 1 / 0 |
| `@tiket/next/react-cache-workaround` | `registerCache(cache)`, imported first in the root layout | 1 / 3 / 0 / 1 |
| `@tiket/next` (root) | growth-fe takes `createLogger`, `apiFetch` and `sanitizeLocale` from here; homepage-fe takes `TiketMetaTag` and `sanitizeLocale` | — / — / 2 / 14 |
| `@tiket/next/configs/config.cjs`, `@tiket/next/webpack-subresource-integrity` | `getAssetPrefix`, `getRewrites`, SRI plugin in `next.config.*` | config files |

Counts are files under `app`, `pages`, `lib`, `components` and `projects` on each baseline.

## Contracts other repos rely on
- **Token routes.** [[react-common-fetch-client]] calls `/api/create-token` and `/api/refresh-token` on 401. All four apps serve them as one-line re-exports of `createTokenGET` and `refreshTokenGET` (`app/api/*/route.api.ts` in payment-fe, `route.page.ts` in fintech-fe, homepage-fe and growth-fe; see [[payment-fe-api]], [[fintech-fe-api]], [[homepage-fe-api]], [[growth-fe-api]]). homepage-fe exports `createTokenGET` for GET, POST, PUT and DELETE. Removing them breaks every react-common fetch on that host.
- **Middleware data.** `localeMiddleware` and `currencyMiddleware` produce the middleware data (locale, currency, country, `isNewURLStructure`, correlation id) that [[react-common-remote]] server components, [[structured-diagnostic-logging]] and [[new-url-structure]] read.
- **Passport fetch.** payment-fe, fintech-fe and homepage-fe wrap the `@tiket/next` client as Passport's `customFetch`. growth-fe passes none ([[passport-custom-fetch]]).

## Gotchas
- All four apps list `@tiket/next` in `transpilePackages`.
- payment-fe's Vitest config aliases `@tiket/next/server` to a mock, so unit tests never run its middleware or route handlers ([[payment-fe-workflows]]).
- fintech-fe's App Router fetch wrapper (`@/lib/fetch/app-router/server`) silently drops `skipAuth`, `createGuestToken`, `retry`, `locale` and `opts` ([[fintech-fe-architecture]]).

## Where it shows up
Pages that link here:
- TIX-FINTECH-NEXT-FE: [[fintech-fe-api]], [[fintech-fe-overview]]
- TIX-GROWTH-NEXT-FE: [[growth-fe-affiliate]], [[growth-fe-api]], [[growth-fe-app-shell]], [[growth-fe-overview]], [[growth-fe-stories]]
- TIX-HOMEPAGE-NEXT-FE: [[homepage-fe-api]], [[homepage-fe-overview]]
- concepts: [[eagle-eye-logging]], [[new-url-structure]], [[passport-custom-fetch]], [[structured-diagnostic-logging]]

## Sources
- TIX-NEXT-PAYMENT-FE `package.json`, `middleware.page.ts`, `next.config.ts`, `app/api/{create-token,refresh-token,post-log}/route.api.ts`, `lib/helpers/coreFetcher.ts`
- TIX-FINTECH-NEXT-FE `package.json`, `middleware.page.ts`, `next.config.js`, `app/api/*/route.page.ts`, `lib/fetch/fetch.ts`
- TIX-HOMEPAGE-NEXT-FE and TIX-GROWTH-NEXT-FE `package.json`, `middleware.page.ts`, `next.config.*`, `app/api/*/route.page.ts`
- TIX-REACT-COMMON `packages/react-common-fetch-client/src/client/helper.ts`
- Import counts: `git grep -h -o "from '@tiket/next[^']*'" origin/main -- app pages lib components projects`
