---
title: API routes
repo: TIX-FINTECH-NEXT-FE
kind: feature
sources:
  - app/api
  - lib/mocks/handlers/core.ts
  - middleware.page.ts
  - next.config.js
  - docs/deployment.md
verified_at: 5833b842
updated: 2026-10-16
status: current
tags: [repo/fintech-fe, kind/feature]
---

# API routes
> Four App Router route handlers under `app/api`: a health check plus three re-exported `@tiket/next` handlers that the client fetch and logger depend on.

## What it does
| Route | Method | Implementation | Purpose |
|---|---|---|---|
| `/api/ping` | GET | local, returns `{ code: 'SUCCESS', data: null, message: 'Success', serverTime }` | health/liveness check |
| `/api/post-log` | POST | `postLogPOST` from `@tiket/next/server` | receives browser logs from `@tiket/next/logger` and writes them server-side |
| `/api/create-token` | GET | `createTokenGET` from `@tiket/next/server` | creates a guest JWT (used when fetch runs with `createGuestToken`, the default) |
| `/api/refresh-token` | GET | `refreshTokenGET` from `@tiket/next/server` | refreshes an expired JWT for the client fetch auto-refresh |

The logic of the last three lives in the `@tiket/next` core package ([[tiket-next-core]]), so behavior changes come from bumping that dependency, not from this repo.

## Routes & entry points
`app/api/{ping,post-log,create-token,refresh-token}/route.page.ts` (the `.page.ts` suffix is required by `pageExtensions`, see [[fintech-fe-architecture]]).

## Data & services
- `/api` is in `APP_ROUTER_PATHS` in `middleware.page.ts`, so it skips locale rewriting; new-URL-structure requests (`/en-id/api/...`) are rewritten to `/api/...`.
- Deployed behind the `fintech` prefix: the LB routes `/fintech/api/*` to the app (`docs/deployment.md`) and `getRewrites(phase)` from `@tiket/next/configs/config.cjs` rewrites any `/<prefix>/api/*` to `/api/*` (`next.config.js`). That is why the MSW mock for logs matches `*/fintech/api/post-log`.
- MSW handlers in `lib/mocks/handlers/core.ts` stub `create-token`, `refresh-token` and `post-log` for local mocking and tests.

## Tests
`app/api/__tests__/{ping,post-log,refresh-token}.spec.ts`. No spec for `create-token`.

## Sources
- `app/api/ping/route.page.ts`, `app/api/post-log/route.page.ts`, `app/api/create-token/route.page.ts`, `app/api/refresh-token/route.page.ts`
- `app/api/__tests__/`
- `lib/mocks/handlers/core.ts`, `middleware.page.ts`, `next.config.js`, `docs/deployment.md`
