---
title: Payment landing, confirm and complete (/payment)
repo: TIX-NEXT-PAYMENT-FE
kind: feature
sources:
  - app/payment
  - app/hooks
  - pages/payment
  - components/providers/PaymentPageProvider
  - lib/services/landingData
  - lib/endpoint.ts
  - lib/config.ts
  - next.config.ts
verified_at: 9e92b20bb
updated: 2026-10-16
status: current
tags: [repo/payment-fe, kind/feature]
---

# Payment landing, confirm and complete (/payment)
> The main checkout payment flow: choose a method, apply promo or points, submit, then confirm and poll to completion. Pages Router routes, with feature code in `app/payment/`.

## What it does
This is the payment page every tiket.com vertical (flight, hotel, train, car, gift card, insurance…) redirects to with `?order_id&order_hash`. The landing loads the order and payment options, lets the user pick a payment method (recommended tiles, groups, saved cards, new card form, linked e-wallets), apply a promo or tiket points, pick card or pay-later installments, and submit. Submitting returns a redirect: a third party or 3DS page, `/payment/{method}/confirm` (VA, QR, instructions), or `/payment/{method}/complete` (status polling and success). [[payment-fe-downpay]] is mounted inside this landing.

**`app/payment/` is not a route.** It has no `page.page.tsx`. It holds the newer, App-Router-style feature modules (promo, tiket points, installment, credit-card request, account linkage) that the Pages Router landing imports. The routes themselves are still in `pages/payment/`.

## Routes & entry points
| URL (after rewrites) | File | Notes |
|---|---|---|
| `/{locale}/payment` | `pages/payment/index.page.tsx` (~1.2k lines) | Landing. `getServerSideProps` uses `getServerSidePropsMiddlewareData`. Wrapped in `withPaymentPageProvider`. |
| `/{locale}/payment/{type}/confirm` | `pages/payment/[type]/confirm/index.page.tsx` | Payment instructions: VA/QR (`AccountInfo/QRCode`), `HowToPay`, `GooglePayButton`, `PointsAdvice`. Uses `useGetPaymentConfirm` and `useConfirmPaymentFlow`. |
| `/{locale}/payment/{type}/complete` | `pages/payment/[type]/complete/index.page.tsx` | Polls `mutationPaymentChecker` (paid-checker) with `useInterval`, OVO redirection, `SuccessV2` / `SuccessPageModule`, corporate billing and linkage success variants. |
| `/{locale}/payment/{type}/callback` | `pages/payment/[type]/callback/index.page.tsx` | OVO-style provider callback (`usePostSubmitOvoCallbackQuery`), then redirects to complete. |
| `/{locale}/payment/{type}` | `pages/payment/[type]/index.page.tsx` | Legacy: server redirect to `/payment?…` (new domain) or `/next/v4?…`. |
| `/{locale}/payment/payment-partner` | `pages/payment/payment-partner/index.page.tsx` | Iframe landing that `postMessage`s `{type:'payment-partner', data:{transaction_id}}` to `window.parent`. |

Legacy URLs are kept by `next.config.ts` rewrites: `/next/v4` → `/payment`, `/next/v4/pay/:type` → `/payment/:type`. There is also a redirect from `/:locale/payment/pay/:path` to `/:locale/payment/:path`. The middleware rewrites every non-App-Router path to `/${locale}${pathname}` for Pages Router i18n (see [[payment-fe-architecture]]).

## Data & services
- **Providers** (`components/providers/PaymentPageProvider`): Global → Time → Session → Order → Landing → Payment → `PromoProvider` → `DownPaymentProvider` → `PaymentNudgeProvider` → `CreditcardRequestProvider` → `CheckVersionProvider`. It renders a loader until `useCheckVersion` (`/tix-payment-core/payment/check-version`) resolves. Inside the landing, `PromoTixpointResolverProvider` and `InstallmentProvider` are also mounted.
- **Landing data:** `lib/services/landingData/getLandingData` + `useGetLandingData` (a mutation) against `/tix-payment-core/payment/v4/landing`. Per AGENTS.md, landing data is refetched after: apply/remove promo, apply/remove points, change payment method, change installment. `app/payment/hooks/useRefetchLanding/` holds the promo and points variants (`useRefetchLandingForApplyPromo`, `…ForUnapplyPromo`, `…ForTixPoints`) and the request-body helpers (`buildLandingRequestBody`, `getRequestPaymentMethod`, `getSelectedInstallment`…).
- **Reopen gate:** `pages/payment/hooks/useGetPaymentLandingPhase.ts` re-checks `check-version` so that an order paid or expired in another tab can't be checked out again. `?action=` is a one-shot bypass, latched on mount and then stripped from the URL. The App Router copy is in [[payment-fe-payment-link]].
- **Promo** (`app/payment/containers/PromoContainer`, `context/PromoContext`, `reducers/PromoReducer.ts`, `services/promo/*`): suggestions (`/promo/suggestion`), apply/unapply/check-availability on the **v2** endpoints (`/tix-payment-core/promo/v2/apply|unapply|check-availability`), and cashback (`/tix-discount-engine/discount/cashback`). Listener hooks handle auto-apply from URL, auto-unapply, sync-from-landing and availability watching. `IneligibleReason` combines backend codes (from tix-promo-go `/evaluate`) and FE-only codes such as `LOGIN_REQUIRED` and `TENOR_NOT_SELECTED`.
- **Promo ↔ points conflict:** `context/PromoTixpointResolverProvider` (+ `PromoTixpointResolveReducer`) shows "can't use promo" and "can't use points" dialogs and reapplies points with updated values.
- **Tiket points:** `containers/TiketPointsContainer`, `app/hooks/useGetTiketPoints|useApplyTiketPoints|useUnapplyTiketPoints` → `/tix-payment-core/loyalty/v1/eligible-points|apply-point|unapply-point`.
- **Installment / cards:** `context/InstallmentContext`, `app/hooks/useInstallment`, `context/CreditcardRequestProvider`, `hooks/useCheckAvailabilityNewCard` (BIN check, `lib/services/bank-bin.ts`).
- **Linkage:** `context/PaymentMethodAccountLinkageProvider`, `hooks/useGetLinkageRedirectionUrl`, `constants/linkage.ts` (OVO/GoPay/DANA/BLU linking from the tile).
- **Submit:** `components/SubmitPayment` → `/tix-payment-core/payment/detail`. Status: `/tix-payment-callback/payment/paid-checker` and `/tix-payment-core/payment/check-status`.

## Key components
Route-local in `app/payment/components/`: `PromoCard`, `PromoSuggestionCard`, `PromoListResponsiveModal`, `PromoTnCModal`, `PromoCodeInputForm`, `BestSuitedPromoBanner`, `InfinityTiketPoints`, `Groups/*` (desktop/mobile group modals, linkage overlay), `PaymentTile*` (Info, Title, Nudge, InsufficientAlert, LinkageButton), `InsufficientBalanceDialog`, `PaymentLoginBanner`, `LoadingFullPageOverlay`, `DialogWithMountTransition`. Containers: `PromoContainer`, `TiketPointsContainer`, `CancelFullPayment`.
Landing-local in `pages/payment/components/`: `LpgBanner`, `PageLeaveDialog`, `OrderSummary/RefundReschedule`, `iFrame`. `providers/PaymentPersistenceStatusProvider` lives there too.
From the shared `components/` ([[payment-fe-components]]): `Groups`, `PaymentMethod`, `PaymentTile`, `SavedCards`, `CardComponentV2`, `Installment`, `OrderSummary`, `PriceSummary`, `SubmitPayment`, `LoginBox`, `Countdown`, `Header`, `Stepper`, `TnC`, `GTMHandler`, `Infinity/PopupAppliedPromoError`.

## Tracking
GTM through `lib/hooks/useGTM` (`pushGTMImpressionV2`, `pushGTMStatusV2`, `pushGTMClickV2`), `components/GTMHandler` and `lib/tracker/GTM.ts`. `gtmVerticalName` maps verticals. Page visits come from `usePageVisitAnalytics` in `AppRouterProvider`/`AppProvider` (`screenName: paymentLanding` for `/payment` and `/v4`). Promo tracking helpers: `PromoContainer/helpers/createTrackingEventProperties.ts`, `hooks/useApplyPromo/tracker.ts`. See [[gtm-datalayer-tracking]].

## Tests
110 Vitest specs in `app/payment/`, 7 in `app/hooks/`, 72 in `pages/`. Playwright (`e2e/scenarios/clean/*`) covers landing, groups, promo, tiket points, price summary, confirm (account info, BCA VA, how-to-pay, submit, status-not-allowed), callback, complete and back navigation. `e2e/scenarios/infinity/` covers linkage and pay-later (BLU, DANA, GoPay/OVO, PL, PL36). The Playwright workflow is manual-only for now (see [[payment-fe-workflows]]).

## Gotchas
- AGENTS.md's "Promo Flow (Pages Router)" section points to `components/Promo/index.tsx`, `useApplyDiscount` and `lib/services/discount.ts`. **`components/Promo` does not exist on main.** The promo UI is now `app/payment/containers/PromoContainer` and calls the v2 promo endpoints, while AGENTS.md lists v1 paths.
- There are two `API_ENDPOINT` objects: `lib/config.ts` (landing, groups, payment-method…) and `lib/endpoint.ts` (discount, order, payment, members, points). The landing imports the first one, `PromoContainer` the second.
- `app/payment/hooks/` contains both `usePaymentMethodSelectionError.ts` and a `usePaymentMethodSelectionError/` folder.
- Promo and points are disabled on DownPay repayment unless the order is `FLEXIBLE_PAYMENT` (`allowPromoAndPointsByDownpayType` in the landing).

## Sources
- `pages/payment/index.page.tsx`, `pages/payment/[type]/{index,confirm/index,complete/index,callback/index}.page.tsx`, `pages/payment/payment-partner/index.page.tsx`
- `pages/payment/hooks/useGetPaymentLandingPhase.ts`
- `components/providers/PaymentPageProvider/PaymentPageProvider.tsx`
- `app/payment/containers/PromoContainer/PromoContainer.tsx`, `app/payment/context/PromoContext/types.ts`, `app/payment/context/PromoTixpointResolverProvider/types.ts`, `app/payment/services/promo/*`, `app/payment/hooks/useRefetchLanding/index.ts`
- `lib/services/landingData/*`, `lib/endpoint.ts`, `lib/config.ts`
- `next.config.ts` (rewrites/redirects)
- `AGENTS.md` (endpoint list, landing refresh triggers, promo flow)
