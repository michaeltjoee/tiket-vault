---
title: Payment link (/payment-link)
repo: TIX-NEXT-PAYMENT-FE
kind: feature
sources:
  - app/payment-link
  - middleware.page.ts
  - lib/hooks/useCheckVersion.ts
  - lib/helpers/checkoutStatusRecovery.ts
verified_at: 9e92b20bb
updated: 2026-10-16
status: current
tags: [repo/payment-fe, kind/feature]
---

# Payment link (/payment-link)
> Self-contained App Router payment flow (landing → confirm → complete) for orders paid through a shared payment link.

## What it does
The payment-link flow is a separate, slimmer payment UI written fully for the App Router. A customer usually arrives through the short link [[payment-fe-l]], which resolves to `/payment-link?order_id&order_hash`. They choose a method from the recommended list or from payment groups (VA, e-wallet, pay later, credit card), submit it, then land on a confirm page (VA instructions) or a complete page that polls for payment status. It reuses the shared `lib/` services and some `components/`, but keeps its own reducer-based context, query keys, tracking and many duplicated UI pieces (`Header`, `TnC`, `ImportantInfo`, `Stepper`, `SuccessV2`). Promo and tiket points from the regular landing ([[payment-fe-payment]]) are not part of this flow.

## Routes & entry points
| Route | File | Notes |
|---|---|---|
| `/payment-link` | `app/payment-link/page.page.tsx` | Server component. Awaits `searchParams` and redirects to `HOME_URL` without `order_id`/`order_hash`. `generateMetadata` uses `i18nServer` and `generateTiketMetadataAlternates`. Renders `containers/PaymentLinkContainer`. |
| `/payment-link/[method]/confirm` | `[method]/confirm/page.page.tsx` | Wraps the container in `PaymentLinkProvider` and a `TimeContextProvider` (server time for the SYNC expiry check in `useConfirmPaymentFlow`). |
| `/payment-link/[method]/complete` | `[method]/complete/page.page.tsx` | `PaymentLinkProvider` + `PaymentLinkCompleteContainer`. |
| layout | `app/payment-link/layout.page.tsx` | `'use client'`. Renders the local `Header` ("continuePayment" title, order id), and drops min-height on `/complete`. |

`middleware.page.ts` puts `/payment-link` in `APP_ROUTER_PATHS`: the `/xx-yy` locale-country prefix is stripped instead of being turned into a Next i18n locale. The root `app/layout.page.tsx` supplies `AppRouterProvider` (React Query, passport, i18n, Forter, WindowSize) to all of these routes.

## Data & services
- **State:** `context/PaymentLinkProvider.tsx` combines a `useReducer` (`store/reducer.ts`, `store/actions.ts`; holds orderId/orderHash and the selected `paymentMethod` with a `source` of `initial | radio | modal`), a react-hook-form `FormProvider` validated by Zod (`utils/form.ts` → `createPaymentLinkSchema` per method, used for card fields), and the submit mutation. The whole page is wrapped in a `<form>`.
- **Landing:** `hooks/useLanding.ts` calls the shared `lib/services/landingData/getLandingData` with query key `['landing-payment-link', orderId, orderHash, {paymentMethod, subPaymentMethod, source}]`. When `source === 'radio'` it first looks up the cached initial-load entry and only refetches for `modal` selections.
- **Cache policy** (`constants/api.ts`): landing 0, order summary 10 min, order details 15 min, payment methods 5 min, price detail 3 min, confirm 5 min.
- **Submit:** `hooks/usePaymentSubmission.ts` → shared `mutationSubmitPayment` (`/tix-payment-core/payment/detail`). Non-`SUCCESS` responses are thrown. `utils/navigation.ts#handleSubmitPaymentNavigation` handles the result: if the response has `paymentSuccessUrl`, `confirmPaymentUrl` or `thirdPartyResponse.redirect_url`, it goes there (full `window.location` for absolute `http` URLs such as 3DS, `router.push` otherwise). Next comes `gopayUrl`, and the default is `/payment-link/{method}/confirm`. `handleRetrySubmit(overwrite)` resubmits with `overwriteExistTransaction` after a `TRANSACTION_ID_EXIST` error (existing VA).
- **Reopen gate:** `hooks/usePaymentLinkLandingPhase.ts` is the App Router counterpart of `pages/payment/hooks/useGetPaymentLandingPhase`. It reads check-version once (`staleTime: Infinity`), maps `paymentStatus` with `mapCheckoutStatusToAction` and redirects via `buildPaymentLinkRecoveryRedirectUrl`. The `?action=` bypass is latched on mount, and the param is stripped from the URL.
- **Complete:** `[method]/complete/hooks/usePaymentPolling.ts` polls `mutationPaymentChecker` (`/tix-payment-callback/payment/paid-checker`). It maps provider error codes (`nicepay-*`, `xendit-*`) to UI reasons (`restrictedCard`, `fraudRiskBlocked`, `bankRejectedTransaction`…), and treats `FAILED`/`CANCELED` as terminal. `hooks/usePageModuleData.ts` loads the `PAYMENT_SUCCESS` page module (rendered by `SuccessPageModule` through [[passport-page-module]]).
- **Short-link verification** lives in [[payment-fe-l]].

## Key components
`app/payment-link/components/` (route-local): `PaymentMethodSelector`/`PaymentMethodItem`/`GroupViews`/`PromotedGroupItem` (method picking), `CreditCardForm` (CardNumber/CardExpired/CardCVV), `PaymentInformation` (VA number, amount, copy, status bar/modal), `PriceDetailModal`, `PaymentChangeDialog`, `PendingStatusDialog`, and error screens (`AccountMismatchError`, `GeneralError`, `PaymentExpiredError`, `PaymentLinkSubmissionError` with `errorConfig.ts`). Containers: `PaymentLinkContainer` (mobile/desktop layouts), `PaymentLinkOrderContainer`, `PaymentLinkPaymentMethodContainer`, `PaymentGroupsContainer`, `PaymentLinkPriceDetailContainer`.
Shared pieces taken from `components/`: `Countdown`, `Image`, `OrderSummary`, `PaymentSteps`, `BottomSheetOrModal`, `PriceDetailV4`, `CardComponent`, `NotificationBanner` (see [[payment-fe-components]]).
Passport: mostly [[passport-umbrella|passport]] (`Container`, `Dialog`, `Divider`, `useForwardParams`…), [[passport-icons]], [[passport-assets]], [[passport-page-module]], [[passport-radio]].

## Tracking
Own GTM layer in `app/payment-link/tracking/`: `usePaymentLinkGTM` (impression/click/status/submit), `PageViewTracker`, `gtm-tracker.ts`, and `standalone.ts#pushHeaderBackClick`, which writes to `window.dataLayer` directly so the layout-level `Header` can track without the context. Event categories include `paymentProcessing`, `paymentSuccess`, `changePaymentMethod` and `changePaymentMethodFromOverLimit` (`tracking/constants.ts`). See [[gtm-datalayer-tracking]].

## Tests
83 Vitest specs under `app/payment-link/` (use `@/lib/test-utils-app-router`). No Playwright scenario targets `/payment-link`.

## Gotchas
- Pages are server components that await `params`/`searchParams` (Next 15+ async APIs). Server files import `TimeContextProvider` from `@/lib/context/TimeContext` directly, because the `@/lib/context` barrel also re-exports files without `'use client'`.
- `usePaymentSubmission` casts between the local `SubmitPaymentRequest` and the canonical `SubmitPaymentParams`. `referenceId` is a `string` locally and a `number` canonically, and the canonical response type lacks `paymentSuccessUrl`. Keep both in sync by hand.
- `installmentMonth` is always `1` and `paymentToken`/`kkiOneTimeToken`/`useReward` are `null` on submit: no installments, saved tokens or rewards in this flow.
- `[method]` in the URL is the lowercase payment-method slug used by `WAIT_FOR_PROCESS_TYPES`/`REDIRECT_MY_ORDER` in `constants/complete.ts`.

## Sources
- `app/payment-link/page.page.tsx`, `layout.page.tsx`
- `app/payment-link/[method]/confirm/page.page.tsx`, `app/payment-link/[method]/complete/page.page.tsx`
- `app/payment-link/containers/PaymentLinkContainer.tsx`
- `app/payment-link/context/PaymentLinkProvider.tsx`
- `app/payment-link/hooks/useLanding.ts`, `usePaymentSubmission.ts`, `usePaymentLinkLandingPhase.ts`, `usePageModuleData.ts`
- `app/payment-link/[method]/complete/hooks/usePaymentPolling.ts`
- `app/payment-link/utils/navigation.ts`
- `app/payment-link/constants/api.ts`, `complete.ts`, `payment-method.ts`
- `app/payment-link/tracking/constants.ts`, `standalone.ts`
- `middleware.page.ts`
