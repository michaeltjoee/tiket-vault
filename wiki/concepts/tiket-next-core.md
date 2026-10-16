---
title: "@tiket/next (tiket Next.js core)"
kind: concept
repos: [TIX-NEXT-PAYMENT-FE, TIX-FINTECH-NEXT-FE, TIX-REACT-COMMON]
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
verified_at:
  TIX-NEXT-PAYMENT-FE: 9e92b20bb
  TIX-FINTECH-NEXT-FE: 5833b842
  TIX-REACT-COMMON: 14597c4e
updated: 2026-10-16
status: current
tags: [kind/concept, repo/payment-fe, repo/fintech-fe, repo/react-common]
---

# @tiket/next
> `@tiket/next` is tiket's shared Next.js toolkit (middleware, gateway fetch, logger, i18n, auth routes, build config). Both Next apps depend on it (`^3.0.0`), but its source is **not** in this workspace, so its behaviour can only be read from `node_modules` or inferred from call sites.

## What the apps take from it
| Entry | Used for | Import count (payment-fe / fintech-fe) |
|---|---|---|
| `@tiket/next/client` | `fetchClient`, `useMiddlewareData`, `useLocaleCountry`, `MiddlewareDataProvider`, `LocaleCountryProvider`, `createI18nContext` | 175 / 69 |
| `@tiket/next/server` | `chain`, `localeMiddleware`, `currencyMiddleware`, `getMiddlewareData`, route handlers `createTokenGET`, `refreshTokenGET`, `postLogPOST` | 9 / 44 |
| `@tiket/next/types` | `MiddlewareModule`, `MiddlewareData` and related types | 47 / 55 |
| `@tiket/next/logger` | `createLogger` (server and middleware logs) | 22 / 10 |
| `@tiket/next/pages` | Pages Router helpers | 13 / 16 |
| `@tiket/next/fetch` | `apiFetch` (fintech-fe's `lib/fetch` wrapper) | 0 / 2 |
| `@tiket/next/react-cache-workaround` | `registerCache(cache)`, imported first in the root layout | 1 / 3 |
| `@tiket/next/configs/config.cjs`, `@tiket/next/webpack-subresource-integrity` | `getAssetPrefix`, `getRewrites`, SRI plugin in `next.config.*` | config files |

Counts are files under `app`, `pages`, `lib`, `components` and `projects` on each baseline.

## Contracts other repos rely on
- **Token routes.** [[react-common-fetch-client]] calls `/api/create-token` and `/api/refresh-token` on 401. Both apps serve them as one-line re-exports of `createTokenGET` and `refreshTokenGET` (`app/api/*/route.api.ts` in payment-fe, `route.page.ts` in fintech-fe; see [[payment-fe-api]], [[fintech-fe-api]]). Removing them breaks every react-common fetch on that host.
- **Middleware data.** `localeMiddleware` and `currencyMiddleware` produce the middleware data (locale, currency, country, `isNewURLStructure`, correlation id) that [[react-common-remote]] server components, [[structured-diagnostic-logging]] and [[new-url-structure]] read.
- **Passport fetch.** Both apps wrap the `@tiket/next` client as Passport's `customFetch` ([[passport-custom-fetch]]).

## Gotchas
- Both apps list `@tiket/next` in `transpilePackages`.
- payment-fe's Vitest config aliases `@tiket/next/server` to a mock, so unit tests never run its middleware or route handlers ([[payment-fe-workflows]]).
- fintech-fe's App Router fetch wrapper (`@/lib/fetch/app-router/server`) silently drops `skipAuth`, `createGuestToken`, `retry`, `locale` and `opts` ([[fintech-fe-architecture]]).

## Where it shows up
Pages that link here:
- TIX-FINTECH-NEXT-FE: [[fintech-fe-api]], [[fintech-fe-overview]]
- concepts: [[eagle-eye-logging]], [[new-url-structure]], [[passport-custom-fetch]], [[structured-diagnostic-logging]]

## Sources
- TIX-NEXT-PAYMENT-FE `package.json`, `middleware.page.ts`, `next.config.ts`, `app/api/{create-token,refresh-token,post-log}/route.api.ts`, `lib/helpers/coreFetcher.ts`
- TIX-FINTECH-NEXT-FE `package.json`, `middleware.page.ts`, `next.config.js`, `app/api/*/route.page.ts`, `lib/fetch/fetch.ts`
- TIX-REACT-COMMON `packages/react-common-fetch-client/src/client/helper.ts`
- Import counts: `git grep -h -o "from '@tiket/next[^']*'" origin/main -- app pages lib components projects`
