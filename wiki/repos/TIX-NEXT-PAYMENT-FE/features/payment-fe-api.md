---
title: API route handlers (app/api)
repo: TIX-NEXT-PAYMENT-FE
kind: feature
sources:
  - app/api
  - lib/middlewares/nonceMiddleware.ts
  - next.config.ts
  - middleware.page.ts
verified_at: 9e92b20bb
updated: 2026-10-16
status: current
tags: [repo/payment-fe, kind/feature]
---

# API route handlers (app/api)
> Four App Router route handlers: session token create/refresh, log forwarding and CSP violation reporting.

## What it does
Server-side endpoints the browser calls on the payment host. Three are one-line re-exports from `@tiket/next/server` (the shared Next.js toolkit), so their behaviour lives in that package, not here. Only `csp-report` has local logic.

## Routes & entry points

| Route | Method | File | Behaviour |
|---|---|---|---|
| `/api/create-token` | GET | `app/api/create-token/route.api.ts` | `createTokenGET` from `@tiket/next/server` (issues the session token cookie) |
| `/api/refresh-token` | GET | `app/api/refresh-token/route.api.ts` | `refreshTokenGET` from `@tiket/next/server` |
| `/api/post-log` | POST | `app/api/post-log/route.api.ts` | `postLogPOST` from `@tiket/next/server` (client log shipping) |
| `/api/csp-report` | POST | `app/api/csp-report/route.api.ts` | Logs the CSP report as one JSON line (`sdc.context: 'csp-report'`, `source` = `report-to` if the body is an array, else `report-uri`) and returns `{}` |

Files end in `.api.ts` because `next.config.ts` sets `pageExtensions: ['page.tsx', 'page.ts', 'api.ts', 'jsx']`. A plain `route.ts` would be ignored.

## Data & services
- `create-token` and `refresh-token` are what [[react-common-fetch-client]] calls (`packages/react-common-fetch-client/src/client/helper.ts` in TIX-REACT-COMMON builds `/api/create-token` and `/api/refresh-token` via `getFinalFetchURL`). The app must keep these paths for the shared fetch client to authenticate.
- `csp-report` is the target of the CSP header that `lib/middlewares/nonceMiddleware.ts` sets in production: `report-uri /${NEXT_PUBLIC_BASE_PREFIX_FOR_APP}/api/csp-report` plus a `Reporting-Endpoints` header for `report-to`.

## Key components
None (handlers only).

## Tracking
None. CSP reports go to stdout and are picked up by the log pipeline (see Kibana link in the repo README).

## Tests
No specs under `app/api/` on the baseline.

## Gotchas
- `next.config.ts` rewrites `/:app-base-prefix/api/post-log` to `/api/post-log`. The comment (17 Nov 2025) says core code was sending `/homepage-v4/api/post-log`; the wildcard avoids 404s for any prefix.
- `middleware.page.ts` excludes `api` from its matcher, so these routes skip locale/currency/nonce middleware.
- The nonce middleware is a no-op outside `NODE_ENV=production`, so no CSP reports are generated in local dev.

## Sources
- `app/api/*/route.api.ts`
- `lib/middlewares/nonceMiddleware.ts`
- `next.config.ts` (rewrites, pageExtensions)
- `middleware.page.ts`
- TIX-REACT-COMMON `packages/react-common-fetch-client/src/client/helper.ts` (origin/master)
