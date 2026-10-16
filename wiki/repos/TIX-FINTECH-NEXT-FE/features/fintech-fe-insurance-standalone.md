---
title: Standalone insurance
repo: TIX-FINTECH-NEXT-FE
kind: feature
sources:
  - pages/insurance
  - projects/insurance/standalone
  - projects/insurance/shared/lib/services/standalone.ts
  - projects/insurance/shared/lib/contexts/standalone
  - projects/insurance/shared/lib/configs/hash-keys.ts
  - projects/insurance/shared/lib/utils/getReactRemotePropsForDevice.ts
  - lib/middlewares/validateSession.ts
  - e2e/insurance/standalone
verified_at: 5833b842
updated: 2026-10-16
status: current
tags: [repo/fintech-fe, kind/feature]
---

# Standalone insurance
> Pages Router flow at `/insurance` to buy insurance for an existing tiket.com order after booking: landing → search the order → product detail (PDP) → checkout → payment.

## What it does
- **Landing** `/insurance`: banner, "my order" entry, [[passport-page-module]] content, read-more. Order list, order details and insurance details open as hash-driven popups (`#order-list`, `#order-details`, `#insurance-details`, `#price-details`) via `usePopUpNavigator`, with stacked popups for details.
- **Search** `/insurance/search`: find eligible insurance for an order (private).
- **PDP** `/insurance/pdp/[productId]`: product detail with [[passport-insurance]] components, [[passport-banner-carousel]], [[passport-breadcrumb]].
- **Checkout** `/insurance/checkout/[cartId]`: booking summary and form (private); `useStandaloneCheckout` posts checkout and `window.location.assign`s the returned `paymentUrl` ([[payment-fe-overview]]); `ValidationDialog` can also send the user to payment or to "your order".

## Routes & entry points
| Route | Re-export | Entry |
|---|---|---|
| `/insurance` | `pages/insurance/index.page.tsx` | `projects/insurance/standalone/landing/index.tsx` |
| `/insurance/search` | `pages/insurance/search.page.tsx` | `.../standalone/search/index.tsx` |
| `/insurance/pdp/[productId]` | `pages/insurance/pdp/[productId].page.tsx` | `.../standalone/pdp/index.tsx` |
| `/insurance/checkout/[cartId]` | `pages/insurance/checkout/[cartId].page.tsx` | `.../standalone/checkout/index.tsx` |

Every entry exports `getServerSideProps` returning `middlewareData`, `vertical: 'insurance'` and remote header/footer SSR props; `pages/_app.page.tsx` feeds those into `AppProvider` ([[fintech-fe-architecture]]).

## Data & services
`projects/insurance/shared/lib/services/standalone.ts`, base `/tix-insurance-core/insurances/standalone/`:

| Endpoint | Function |
|---|---|
| `landing` | `getInsuranceStandaloneLanding` |
| `orders`, `order/{orderId}` | order list, order details |
| `search/{orderId}` | `getInsuranceStandaloneSearchOrder` |
| `insurance-details/{orderId}` (POST), `price-details/{orderId}` (POST) | insurance and price details popups |
| `pdp/{productId}` | `getInsuranceStandalonePDP` |
| `cart` (POST), `cart/{cartId}` | create cart, get cart |
| `checkout` (POST) | `postInsuranceStandaloneCheckout` → `paymentUrl` |

- Landing SSR also fetches page modules (`getPageModule` in `lib/services/home.ts`) with the access-token cookie added to session data, but **only when not in a webview**.
- State: `StandaloneProvider` (`shared/lib/contexts/standalone`) holds order list/details and error flags across popups; each page has its own context (`landing/contexts`, `search/contexts`, `checkout/contexts`) and i18n (`*/i18n` plus `shared/lib/i18n/standalone`).

## Key components
Popups and lists from `projects/insurance/shared/components` (`OrderList`, `OrderDetails`, `InsuranceDetails`, `PriceDetails`, `ErrorFullPage`, `ErrorDialog`, `ErrorBottomSheetModal`), loaded with `next/dynamic` and `ssr: false`. Page-local: landing `Banner`, `MyOrder`, `PageModule`, `ReadMore`; checkout `BookingSummary/InsuranceCard`, `ValidationDialog`.

## Tracking
`landing/tracker.ts`, `search` and `checkout/tracker.ts` push GTM events through `@/lib/gtm` (`pageVisit(VERTICAL, ...)`), e.g. landing `eventDescription: 'standAloneInsurancePage'`, `screenName: 'insuranceLandingPage'`, with UTM page/section/logic and `isFirstPage` from `shared/lib/utils/utm.ts`. `shared/lib/trackers/price-details.ts` covers the price popup.

## Tests
45 spec files under `projects/insurance/standalone`, `pages/insurance/__tests__` for the re-exports, and Playwright `e2e/insurance/standalone/login.spec.ts`.

## Gotchas
- Remote header/footer are desktop-only here: `getReactRemotePropsForDevice` skips the SSR remote fetch on mobile/webview to save getServerSideProps latency.
- Search and checkout call the Pages `validateSessionForPrivatePage(context)` (`lib/middlewares/validateSession.ts`). It writes a 302 to `/login?ref=` directly on `context.res` and ends the response, but `getServerSideProps` still returns props afterwards, and the remote header fetch has already run. Keep that order in mind when adding work to these GSSPs.
- Landing and PDP are public; only search and checkout require login.

## Sources
- `pages/insurance/*.page.tsx`, `pages/insurance/__tests__`
- `projects/insurance/standalone/{landing,search,pdp,checkout}/index.tsx`, `projects/insurance/standalone/landing/tracker.ts`, `projects/insurance/standalone/checkout/hooks/useStandaloneCheckout.tsx`, `projects/insurance/standalone/checkout/components/ValidationDialog/ValidationDialog.tsx`
- `projects/insurance/shared/lib/services/standalone.ts`, `projects/insurance/shared/lib/configs/hash-keys.ts`, `projects/insurance/shared/lib/utils/getReactRemotePropsForDevice.ts`
- `lib/middlewares/validateSession.ts`, `e2e/insurance/standalone/login.spec.ts`
