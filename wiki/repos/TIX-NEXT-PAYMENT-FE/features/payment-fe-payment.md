---
title: Payment landing, confirm and complete (/payment)
repo: TIX-NEXT-PAYMENT-FE
kind: feature
sources:
  - app/payment
  - app/hooks
  - pages/payment
  - components/providers/PaymentPageProvider
  - components/AnalyticsProvider
  - components/SubmitPayment/index.tsx
  - lib/helpers/checkoutStatusRecovery.ts
  - lib/helpers/landingLeaveMarker.ts
  - lib/helpers/checkStatusCooldown.ts
  - lib/hooks/useSkipStaleLandingEntry.ts
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
> The main checkout payment flow: choose a method, apply promo or points, submit, then confirm and poll to completion. The routes are Pages Router pages in `pages/payment/`, and the newer feature modules sit in `app/payment/`, which is not a route.

## What it does
This is the payment page every tiket.com vertical (flight, hotel, train, car, gift card, insurance…) redirects to with `?order_id&order_hash`. The landing loads the order and payment options, lets the user pick a payment method (recommended tiles, groups, saved cards, new card form, linked e-wallets), apply a promo or tiket points, pick card or pay-later installments, and submit. Submitting returns a redirect: a third party or 3DS page, `/payment/{method}/confirm` (VA, QR, instructions), or `/payment/{method}/complete` (status polling and success). [[payment-fe-downpay]] is mounted inside this landing.

## How `pages/payment` and `app/payment` relate
They are **one feature split across two folders**, not the same feature in both routers and not separate routes:
- `pages/payment/` (165 files) owns **every `/payment/**` route**. All six route files are Pages Router pages with `getServerSideProps`.
- `app/payment/` (399 files) owns **no route**. There is no `page.page.tsx`, `layout.page.tsx` or `route.api.ts` under it, and git history shows none was ever added there (`git log --diff-filter=A -- 'app/payment/**/page*'` is empty). It is a feature-module folder that `pages/payment/` imports: `PromoContainer`, `TiketPointsContainer`, `PromoTixpointResolverProvider`, `InstallmentContext`, `CreditcardRequestProvider`, `useCheckAvailabilityNewCard`, the `useRefetchLanding` helpers and promo types/utils. Nothing in `app/` imports from `pages/payment`, and the App Router payment link does not use `app/payment` at all.

History: the routes started as `pages/v4` and were renamed to `pages/payment` in the URL restructure (`77ee868c1`, #941, 2025-10-13), which stayed on the Pages Router. `app/payment/` first appeared with Infinity Promo (#1326, 2026-05-20, reverted in #1376, re-landed as `6d0b2c385` #1430 on 2026-06-25). That change deleted the old `components/Promo/` and rebuilt promo under `app/payment/`. New landing work follows the README ("`pages/` = Legacy Pages Router (being migrated)") and AGENTS.md ("NEVER use Pages Router for new pages") by going into `app/`, but the route itself has not moved, and nothing on main has started moving it.

So "migration in progress" is true only at the module level. Moving the route would still need the provider tree (`PaymentPageProvider`), `getServerSideProps` and next.config `i18n` locale prefixes replaced, and some `app/payment` hooks are Pages-Router-bound (see Gotchas).

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
- **Reopen gate ("payment persistence"):** `pages/payment/hooks/useGetPaymentLandingPhase.ts` re-checks `check-version` so that an order paid or expired in another tab can't be checked out again. `PaymentPersistenceStatusProvider` wraps the landing page and renders from the phase: `allow` shows landing, `loading` shows a spinner while it redirects, `expired` shows the expired popup, `accountMismatch` (error code `DATA_NOT_EXIST`) shows "change account", and `error` shows the generic error page. `mapCheckoutStatusToAction` (`lib/helpers/checkoutStatusRecovery.ts`) maps the status: `SHOPPINGCART` stays on landing, `CHECKOUT`/`PAID_QUEUE` go to confirm, `PAID`/`SUCCESS`/`FAILED` go to complete, `EXPIRED` shows the popup, and `REFUNDED`/`DISCARDED`/unknown are blocked. `CHECKOUT` with `CORPORATE_BILLING` goes to complete, because corporate billing has no confirm page. `?action=CHANGE_PAYMENT_METHOD|CHANGE_ANOTHER_CARD|RE_ENTER_CVV` (sent by the failed page) is a one-shot bypass, latched on mount and then stripped from the URL. The App Router copy is in [[payment-fe-payment-link]].
  - **There is no reset endpoint.** The backend moves the order from `CHECKOUT` back to `SHOPPINGCART` when landing calls `/v4/landing`. Until then check-version still reports `CHECKOUT`, which is why the bypass is latched with `useState`: re-reading the stripped URL would send the user to confirm mid-flow (PLAT-59072 AC3).
  - **Stale history entry** (#1613, `005db6372`): `usePreventPageLeave` leaves a `?preventLeave=true` landing entry below the page that submit replaces, so Back from confirm returns to landing. `SubmitPayment` calls `markLandingLeft(orderId)`, which writes `sessionStorage` key `payment_landing_left:<orderId>` with a 1 h TTL. On mount, `useSkipStaleLandingEntry` consumes the marker, which it always clears. If the marker was there and the URL has `preventLeave`, it calls `history.back()` again.
  - The confirm page's "check payment status" cooldown (30 s) is kept in `localStorage` (`lib/helpers/checkStatusCooldown.ts`), keyed `<namespace>:checkStatusCooldown:<orderId>`, so a refresh doesn't reset it. Regular payment and payment link share an origin and use different namespaces.
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
GTM through `lib/hooks/useGTM` (`pushGTMImpressionV2`, `pushGTMStatusV2`, `pushGTMClickV2`), `components/GTMHandler` and `lib/tracker/GTM.ts`. `gtmVerticalName` maps verticals. Screen names on these Pages Router routes come from `components/AnalyticsProvider` (mounted in `AppProvider`). It sets `window.eventProperties` from the path: `*/confirm` gives `paymentConfirmation`, `/payment*` or `/next/v4*` gives `paymentLanding`, and `*/complete` is left empty on purpose ("as requested by PM"). Then it calls `window.commonAnalytic.updateAnalytics()`. `usePageVisitAnalytics` runs only in the App Router's `AppRouterProvider`. `AppProvider` exports a `pageVisitAnalyticsConfig`, but nothing uses it. Promo tracking helpers: `PromoContainer/helpers/createTrackingEventProperties.ts`, `hooks/useApplyPromo/tracker.ts`. See [[gtm-datalayer-tracking]].

## Tests
110 Vitest specs in `app/payment/`, 7 in `app/hooks/`, 37 in `pages/payment/` (the other 35 `pages/` specs belong to [[payment-fe-smart-pay]]). Playwright (`e2e/scenarios/clean/*`) covers landing, groups, promo, tiket points, price summary, confirm (account info, BCA VA, how-to-pay, submit, status-not-allowed), callback, complete and back navigation. `e2e/scenarios/infinity/` covers linkage and pay-later (BLU, DANA, GoPay/OVO, PL, PL36). The Playwright workflow is manual-only for now (see [[payment-fe-workflows]]).

## Gotchas
- AGENTS.md's "Promo Flow (Pages Router)" section points to `components/Promo/index.tsx`, `useApplyDiscount` and `lib/services/discount.ts`. **`components/Promo` does not exist on main.** The promo UI is now `app/payment/containers/PromoContainer` and calls the v2 promo endpoints, while AGENTS.md lists v1 paths.
- There are two `API_ENDPOINT` objects: `lib/config.ts` (landing, groups, payment-method…) and `lib/endpoint.ts` (discount, order, payment, members, points). The landing imports the first one, `PromoContainer` the second.
- `app/payment/hooks/` contains both `usePaymentMethodSelectionError.ts` and a `usePaymentMethodSelectionError/` folder.
- `app/payment` lives in the App Router folder but is not App-Router-safe. `PromoContainer`'s `useAutomaticApplyPromoFromUrl` and `useRemovePromoFromQuery` import `useRouter` from `next/router`, which only works under the Pages Router.
- Shared code imports from `pages/payment`: `components/BackButtonInterceptor` (from `CorporateBillingSuccess`), `components/OrderSummary/components/Flight/detailV4.tsx` (`RefundReschedule`), `lib/i18n/i18n.types.ts` (`HowToPay/types`) and `lib/types/entities/payment/paid-checker.ts` (`paymentComplete.types`). The dependency runs both ways.
- Promo and points are disabled on DownPay repayment unless the order is `FLEXIBLE_PAYMENT` (`allowPromoAndPointsByDownpayType` in the landing).

## Sources
- `pages/payment/index.page.tsx`, `pages/payment/[type]/{index,confirm/index,complete/index,callback/index}.page.tsx`, `pages/payment/payment-partner/index.page.tsx`
- `pages/payment/hooks/useGetPaymentLandingPhase.ts`, `pages/payment/providers/PaymentPersistenceStatusProvider/*`, `lib/helpers/{checkoutStatusRecovery,landingLeaveMarker,checkStatusCooldown}.ts`, `lib/hooks/useSkipStaleLandingEntry.ts`, `lib/constants/common.ts` (`PAYMENT_STATUS_PHASE`, `PAYMENT_ACTIONS`)
- `components/providers/PaymentPageProvider/PaymentPageProvider.tsx`, `components/providers/AppProvider.tsx`, `components/AnalyticsProvider/index.tsx`
- `app/payment/containers/PromoContainer/hooks/{useAutomaticApplyPromoFromUrl,useRemovePromoFromQuery}/*`
- `app/payment/containers/PromoContainer/PromoContainer.tsx`, `app/payment/context/PromoContext/types.ts`, `app/payment/context/PromoTixpointResolverProvider/types.ts`, `app/payment/services/promo/*`, `app/payment/hooks/useRefetchLanding/index.ts`
- `lib/services/landingData/*`, `lib/endpoint.ts`, `lib/config.ts`
- `next.config.ts` (rewrites/redirects)
- `AGENTS.md` (endpoint list, landing refresh triggers, promo flow, "never Pages Router for new pages"), `README.md` (project structure)
- git history: `77ee868c1` (#941 URL restructure, `pages/v4` → `pages/payment`), `3af267792`/`306cb88c2`/`6d0b2c385` (#1326/#1376/#1430 Infinity Promo creates `app/payment`)
