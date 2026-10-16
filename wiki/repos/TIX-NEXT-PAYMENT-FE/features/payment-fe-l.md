---
title: Payment short link (/l/[id])
repo: TIX-NEXT-PAYMENT-FE
kind: feature
sources:
  - app/l/[id]
  - middleware.page.ts
verified_at: 9e92b20bb
updated: 2026-10-16
status: current
tags: [repo/payment-fe, kind/feature]
---

# Payment short link (/l/[id])
> Resolves a short payment-link id to an order and redirects to [[payment-fe-payment-link]].

## What it does
`/l/{link-id}` is the shareable short URL for a payment link (README calls it "Short Link"). The page calls the payment-core verification API with the id. On `SUCCESS` with `orderId` and `orderHash` it does a client-side `router.replace` to `/payment-link?order_id=…&order_hash=…`, keeping forwarded query params. On failure it shows a blocking error dialog whose only button goes to `HOME_URL`. There is no UI on the happy path: it renders an empty `<div />` while loading and while redirecting.

## Routes & entry points
- `app/l/[id]/page.page.tsx`: async server component. Awaits `params` (Next 15+ async params), redirects to `HOME_URL` if `id` is empty, otherwise renders the client container.
- `containers/PaymentLinkVerificationContainer.tsx`: `'use client'`. Holds the redirect and error mapping.
- Reached as `/{locale-country}/l/{id}`. `middleware.page.ts` lists `/l` in `APP_ROUTER_PATHS` and strips the `/xx-yy` locale-country prefix before rewriting, because the App Router has no i18n config.

## Data & services
- `services/verification.ts`: `GET /tix-payment-core/payment-link?id={id}` via `fetchClient` from `@tiket/next/client`. Errors are wrapped with `error()` from `lib/utils`, not thrown.
- `hooks/usePaymentLinkVerification.ts`: React Query `useQuery`, key `['payment-link-verification', id]`, `retry: 1`, `staleTime: 0`.
- Response type `{ orderId, orderHash }`. Error codes: `DATA_NOT_EXIST`, `LINK_EXPIRED`, `LINK_LIMIT_REACHED`. Any other non-`SUCCESS` code, and any thrown query error, maps to `DATA_NOT_EXIST`.

## Key components
- `components/ErrorMessage`: passport `Dialog` with the `payment-timeout.png` asset. `LINK_EXPIRED` and `LINK_LIMIT_REACHED` share the "payment expired" copy (`paymentLinkPage.error.paymentExpired.*`); everything else shows "not found".

## Tracking
None in this route.

## Tests
`app/l/[id]/__tests__/page.page.spec.tsx`, plus specs for the container, hook, service and `ErrorMessage`.

## Gotchas
- This endpoint (`/tix-payment-core/payment-link`) is not in the AGENTS.md endpoint allow-list, although AGENTS.md says to use only listed endpoints.
- `LINK_LIMIT_REACHED` shows the same "expired" copy as `LINK_EXPIRED`; there is no separate message for it.

## Sources
- `app/l/[id]/page.page.tsx`
- `app/l/[id]/containers/PaymentLinkVerificationContainer.tsx`
- `app/l/[id]/hooks/usePaymentLinkVerification.ts`
- `app/l/[id]/services/verification.ts`
- `app/l/[id]/types/index.ts`
- `app/l/[id]/components/ErrorMessage/ErrorMessage.tsx`
- `middleware.page.ts`
- `README.md` (URL table)
