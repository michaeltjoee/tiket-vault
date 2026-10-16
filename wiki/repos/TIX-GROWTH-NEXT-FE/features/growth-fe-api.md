---
title: API routes (app/api, pages/api)
repo: TIX-GROWTH-NEXT-FE
kind: feature
sources:
  - app/api
  - pages/api/partner-config.page.ts
  - next.config.js
  - middleware.page.ts
  - lib/fetch/fetch.ts
  - lib/types/pwa.ts
  - .env.local.example
verified_at: d4162e3
updated: 2026-10-16
status: current
tags: [repo/growth-fe, kind/feature]
---

# API routes (app/api, pages/api)
> Three App Router route handlers re-exported from `@tiket/next/server` (guest token create and refresh, client log sink) and one legacy Pages Router proxy, `/api/partner-config`, that nothing on main calls.

## What it does
| Route | File | Behaviour | Called by |
|---|---|---|---|
| `/api/create-token` | `app/api/create-token/route.page.ts` | `GET` = `createTokenGET` from `@tiket/next/server`: creates a guest token and sets the session access/refresh token cookies | [[react-common-fetch-client]] `fetchClient` (client helper, via `getFinalFetchURL('/api/create-token')`) when the browser has no valid token. growth-fe reaches it through `lib/fetch` → `apiFetch` from `@tiket/next` → `fetchClient` |
| `/api/refresh-token` | `app/api/refresh-token/route.page.ts` | `GET` = `refreshTokenGET` from `@tiket/next/server` | Same client helper, when the access token has expired. It falls back to create-token if refresh fails |
| `/api/post-log` | `app/api/post-log/route.page.ts` | `POST` = `postLogPOST` from `@tiket/next/server`: the server-side sink for browser logs | `createLogger` from `@tiket/next` on the client (`navigator.sendBeacon`, fetch fallback) at `origin/{NEXT_PUBLIC_BASE_PREFIX_FOR_APP}/api/{NEXT_PUBLIC_POST_LOG_PATH \|\| 'post-log'}`. The react-common-fetch-client logger posts to the same `/{prefix}/api/post-log` |
| `/api/partner-config?slug=` | `pages/api/partner-config.page.ts` | Proxies `GET {NEXT_PUBLIC_AFFILIATE_BE_INTERNAL_SERVICE}{NEXT_PUBLIC_AFFILIATE_INTERNAL_GATEWAY}/pwa/landing-page?slug=` and returns the affiliate PWA landing config (`PartnerConfigResponse`: partner branding, T&C, menus, `isActive`). Also exports `fetchPartnerConfig` | Nothing on main. It came over in the affiliate migration from TIX-AFFILIATE-PUBLIC-FE (#9). The cobrand page uses `lib/services/cobrand.ts` and the redirect page uses `lib/services/partner.ts` instead ([[growth-fe-affiliate]]) |

The token and post-log handlers belong to the `@tiket/next` session and logging flow, see [[tiket-next-core]] and [[eagle-eye-logging]].

## Routes & entry points
- Files are named `route.page.ts` because `pageExtensions: ['page.tsx','page.ts']` applies to the App Router too.
- Public path: `getRewrites()` from `@tiket/next/configs/config.cjs` rewrites `/{NEXT_PUBLIC_BASE_PREFIX_FOR_APP}/api/:path*` → `/api/:path*`. With the default prefix `growth` (`.env.local.example`) the handlers are reached as `/growth/api/create-token`, `/growth/api/refresh-token`, `/growth/api/post-log`. In `.env.test` the prefix is `core`.
- `middleware.page.ts` has no `matcher`. It runs on these requests, but the `@tiket/next` `chain` constructor returns early for `/{prefix}/api…`, `/homepage-v4/api…`, `_next`, file paths and `ms-gateway`, so the locale chain and the `/${locale}` rewrite don't touch API calls.

## Data & services
- `partner-config` uses `lib/fetch` (`apiFetch` from `@tiket/next`) with headers `accept-language: id`, `x-channel-id: WEB` and an `x-request-id`, and logs through `standardizedLogData`.
- No `app/api/session` or `ping` handler here, unlike [[homepage-fe-api]]. The log route keeps the shared default name `post-log` (homepage-fe renamed its own to avoid other apps' logs).

## Key components
None (handlers only).

## Tracking
None.

## Tests
No specs for `app/api` or `pages/api`. Sonar excludes `app/api/**`. `lib/gtm/__tests__/harvesterEventWatcher.spec.ts` uses `https://api.tiket.com/growth/api/post-log` only as a sample URL that the harvester watcher must ignore.

## Gotchas
- **`partner-config` status mapping is broken.** It calls `res.status(ResponseCode[result.code ?? 200])`. `ResponseCode` only has `INTERNAL_SERVER_ERROR` (500) and `UNPROCESSABLE_ENTITY` (422). For `SUCCESS`, `ERROR` or `SLUG_NOT_EXIST` the lookup is `undefined` (the `?? 200` applies to the key, not the result), and Node rejects an invalid status code when it writes the response. The catch then returns a canned 500 with a hard-coded `serverTime: '2021-11-11T14:04:17.975+0000'`. Fix this before anyone calls the route.
- `partner-config` creates `requestId = uuidv4()` at module scope, so every request from one server process sends the same `x-request-id`.
- `NEXT_PUBLIC_AFFILIATE_INTERNAL_GATEWAY` is not in `.env.local.example`. Locally the URL becomes `{service}undefined/pwa/landing-page`.
- The token handlers only bind `GET` (homepage-fe binds all four methods to `createTokenGET`/`refreshTokenGET`). The client helper calls them with GET, so this is fine today.

## Sources
- `app/api/create-token/route.page.ts`, `app/api/refresh-token/route.page.ts`, `app/api/post-log/route.page.ts`
- `pages/api/partner-config.page.ts`, `lib/types/pwa.ts`, `lib/fetch/fetch.ts`, `lib/services/partner.ts`, `lib/services/cobrand.ts`
- `next.config.js` (rewrites, `pageExtensions`), `middleware.page.ts`, `.env.local.example`, `.env.test`, `sonar-project.properties`
- `lib/gtm/__tests__/harvesterEventWatcher.spec.ts`
- `@tiket/next` 3.3.1 `configs/config.cjs`, `src/route-handlers/*`, `src/logger/engine.ts`, `src/constants/common.ts`, `src/middlewares/utils/isApplicationRoute.ts`, `src/middlewares/constructor/constructor.ts` (installed package, same version as the main pin)
- `@tiket/react-common-fetch-client` 3.0.0 `src/client/helper.ts`, `src/logger/engine.ts` (installed package)
