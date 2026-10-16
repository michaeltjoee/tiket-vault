---
title: tix-insurance-core (insurance backend)
kind: entity
repos: [TIX-PASSPORT, TIX-FINTECH-NEXT-FE]
sources:
  - TIX-PASSPORT/packages/insurance/src/widgets/ProtectionSection/services/post-cart.ts
  - TIX-PASSPORT/packages/insurance-pop-up/src/components/SeeDetails/SeeDetails.tsx
  - TIX-FINTECH-NEXT-FE/projects/insurance/shared/lib/services
verified_at:
  TIX-PASSPORT: 7a33010aca
  TIX-FINTECH-NEXT-FE: 5833b842
updated: 2026-10-16
status: current
tags: [kind/entity, repo/passport, repo/fintech-fe]
---

# tix-insurance-core
> The insurance backend behind the standalone insurance flow, the claim center and the flight-insurance pop-up. FE code reaches it at `/ms-gateway/tix-insurance-core/...` (relative `/tix-insurance-core/...` through a host fetch). Its source is not in this workspace.

## Endpoints used by the FE
All paths are under `/tix-insurance-core`. They come from FE call sites, not from backend docs.

| Area | Paths | Caller |
|---|---|---|
| Standalone | `insurances/standalone/{landing, search/{orderId}, pdp/{productId}, cart, cart/{cartId}, checkout, orders, order/{orderId}, insurance-details/{orderId}, price-details/{orderId}}` | [[fintech-fe-insurance-standalone]]. `POST insurances/standalone/cart` is also sent by [[passport-insurance]] `ProtectionSection` |
| Claim center | `insurances/claim-center/{landing, history, all-claim, bank, form, init-form, form/add-bank, form/get-bank, faq/{transactionDetailId}, insurance/detail/{id}, claim/detail/{claimId}, claim/general/{claimId}, order/item-details/{orderId}, {subscriptionCode}/preparation, {subscriptionCode}/claims/{claimId}/fill, …/submit}` | [[fintech-fe-insurance-claim]] |
| Pop-up | `products/popup/display/{uniqueSignature}` | [[fintech-fe-insurance-popup]] (see below) |
| Files | `file/pdf/{id}` (policy PDFs, linked from the pop-up "see details") | [[passport-insurance-pop-up]] |

## Popup display API
`GET /tix-insurance-core/products/popup/display/{uniqueSignature}` returns the "Get Product Popup Display" payload (documented on a PlatTech Confluence page) that [[passport-insurance-pop-up]] renders. TIX-FINTECH-NEXT-FE fetches it in `projects/insurance/shared/lib/services/insurance-popup.ts` and renders the pop-up in `viewMode='webview'`. Changes to the template or opt-out flow ship as Passport releases.

## Gotchas
- Passport's `ProtectionSection` builds its fallback URL with `defaultAPIHostName()` + `/ms-gateway`, and it is only relative when the host passes `customFetch` ([[passport-custom-fetch]]).
- Payment pages deep-link into the claim-center FAQ (`/insurance-claim/faq/<id>?hideToolbar=true`, in a TIX-NEXT-PAYMENT-FE mock), and [[passport-header]] links `/insurance-claim`. These paths are served by fintech-fe and must stay stable.

## Where it shows up
Pages that link here:
- TIX-PASSPORT: [[passport-insurance]], [[passport-insurance-pop-up]]

## Sources
- TIX-PASSPORT `packages/insurance/src/widgets/ProtectionSection/{services/post-cart.ts,utils/common.ts}`, `packages/insurance-pop-up/src/components/SeeDetails/SeeDetails.tsx`, `packages/header/src/utils/Constants.ts`
- TIX-FINTECH-NEXT-FE `projects/insurance/shared/lib/services/{standalone,claim-center,generic,insurance-popup}.ts`
- TIX-NEXT-PAYMENT-FE `lib/mocks/data/standalone-insurance/order-composer.json`
