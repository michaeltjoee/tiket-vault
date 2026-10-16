---
title: API route handlers (app/api)
repo: TIX-HOMEPAGE-NEXT-FE
kind: feature
sources:
  - app/api
  - next.config.ts
  - components/RemoteConfigScript
  - .env.local.example
  - lib/mocks/handlers/core
  - worker/custom-runtime-caching.js
verified_at: 408983f6
updated: 2026-10-16
status: current
tags: [repo/homepage-fe, kind/feature]
---

# API route handlers (app/api)
> Five App Router route handlers. They are the only `app/` code in this Pages Router app: token create/refresh and client post-log (re-exported from `@tiket/next`), plus a session validate proxy and a ping.

## What it does
| Route | File | Behaviour |
|---|---|---|
| `/api/create-token` | `app/api/create-token/route.page.ts` | `createTokenGET` from `@tiket/next/server`, bound to GET, POST, PUT and DELETE |
| `/api/refresh-token` | `app/api/refresh-token/route.page.ts` | `refreshTokenGET` from `@tiket/next/server`, bound to all four methods |
| `/api/homepage-post-log` | `app/api/homepage-post-log/route.page.ts` | `POST` = `postLogPOST` from `@tiket/next/server` (client log sink) |
| `/api/session` | `app/api/session/route.page.ts` | `GET`: forwards the request `cookie` to `SERVER_SIDE_SERVICE_ENDPOINT/gateway/tix-member-session/v1/session/validate`. Returns the session `data` with 200 when `code === 'SUCCESS'`, else an empty 401 |
| `/api/ping` | `app/api/ping/route.page.ts` | `GET` → `{ code: 'SUCCESS', data: null, message: 'Success', serverTime }` |
The token handlers are part of the `@tiket/next` auth flow (see [[tiket-next-core]]). [[react-common-fetch-client]] calls `/api/create-token` and `/api/refresh-token` from the browser.

## Routes & entry points
- Files are named `route.page.ts` because `pageExtensions: ['page.tsx','page.ts']` applies to the App Router too.
- Public paths: production `next.config.ts` rewrites `/{NEXT_PUBLIC_BASE_PREFIX_FOR_APP}/api/:path*` → `/api/:path*`, so the handlers are reached as `/homepage-v4/api/...` behind the LB. MSW handlers mock `${BASE_URL}/${prefix}/api/create-token` and `refresh-token` (`lib/mocks/handlers/core/`).

## Data & services
- **Post-log path:** the client log route is deliberately named `homepage-post-log`, not the shared default `post-log`. `.env.local.example` explains: "Set to a homepage-specific path so other repos defaulting to the homepage-v4 prefix do not pollute this service's logs." [[react-common-fetch-client]] defaults `basePrefixForApp` to `homepage-v4` and `postLogPath` to `post-log` (`src/config.ts`). Any app or remote that doesn't configure its own values therefore posts to `/homepage-v4/api/post-log`, which this app doesn't serve. `RemoteConfigScript` publishes `postLogPath: '/api/homepage-post-log'` and `basePrefixForApp` on `window.__TIX_REMOTE_CONFIG__`, so remotes running **on this host** log to the right route ([[homepage-fe-app-shell]]).
- TIX-NEXT-PAYMENT-FE works around the same default from its side with a `/:app-base-prefix/api/post-log` rewrite ([[payment-fe-api]]).

## Key components
None (handlers only).

## Tracking
None.

## Tests
No specs for `app/api` on main. `pages/api/**` (an older path) is in the coverage and Sonar exclude lists, but `app/api` isn't.

## Gotchas
- `/api/session` logs with `console.info`, against the AGENTS.md rule to use `createLogger` from `@tiket/next`. It also returns a bare 401 for any failure, network errors included.
- No code on main calls `/api/session` or `/api/ping`. They are probably kept for external callers (for example health checks), but the repo doesn't document that.
- The service worker caches same-origin `/api/*` GETs NetworkFirst with a 10 s timeout (`apis` cache, 24 h, `/api/auth/*` excluded). A slow `/api/session` can therefore be answered from cache ([[homepage-fe-architecture]]).

## Sources
- `app/api/create-token/route.page.ts`, `app/api/refresh-token/route.page.ts`, `app/api/homepage-post-log/route.page.ts`, `app/api/session/route.page.ts`, `app/api/ping/route.page.ts`
- `next.config.ts` (rewrites, `pageExtensions`), `.env.local.example`, `components/RemoteConfigScript/RemoteConfigScript.tsx`
- `lib/mocks/handlers/core/getCreateToken.ts`, `getRefreshToken.ts`, `index.ts`
- `worker/custom-runtime-caching.js`, `vitest.config.mts`, `sonar-project.properties`
- TIX-REACT-COMMON `packages/react-common-fetch-client/src/config.ts` (origin/master)
