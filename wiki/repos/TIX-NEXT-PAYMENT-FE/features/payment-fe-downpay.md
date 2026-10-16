---
title: DownPay / flexible payment (app/downpay)
repo: TIX-NEXT-PAYMENT-FE
kind: feature
sources:
  - app/downpay
  - app/contexts/DownPayContext
  - components/providers/PaymentPageProvider/PaymentPageProvider.tsx
  - pages/payment/index.page.tsx
  - components/SubmitPayment/hooks/useSubmitPayment.ts
verified_at: 9e92b20bb
updated: 2026-10-16
status: current
tags: [repo/payment-fe, kind/feature]
---

# DownPay / flexible payment (app/downpay)
> Pay part of an order now and the rest in scheduled installments. The feature is a modal flow mounted inside the regular payment landing.

## What it does
DownPay lets the customer pay a first installment (the "down payment") and settle the rest later. The landing response carries `downPayDetails` (`type: 'DOWNPAY' | 'FLEXIBLE_PAYMENT'`, `feeVariant: 'no_fee' | 'upfront_fee' | 'fee_in_final'`, and a list of installments with `paymentStatus`). From that the landing decides:
- **First entry** (`shouldShowDownPayEntry`): type is `DOWNPAY` and the first installment is unpaid. A DownPay button appears next to the normal pay button. Clicking it opens a confirmation modal (terms, how it works, installment picker, payment method), then submits through the normal submit flow with `useDownPayment`.
- **Repayment** (`isDownPayInstallment`): at least one installment is already `PAID`. The landing shows `DownPaySettlement` and lets the user pay the next installment or settle in full (`useFullSettlement`).
- **Flexible payment** (`FLEXIBLE_PAYMENT`): no DownPay entry button. Promo and points stay allowed, and an unpaid installment still sets the installment number on submit (`isFlexiblePaymentWithUnpaidInstallment`).

## Routes & entry points
There is **no `/downpay` route**: `app/downpay/` has no `page.page.tsx`. Everything renders inside the Pages Router landing `pages/payment/index.page.tsx` ([[payment-fe-payment]]):
- `DownPayButtonContainer`, `DownPayPaymentOptionContainer`, `DownPaySettlement` placed in the landing layout (mobile and desktop branches).
- `DownPayModalContainer` mounted once inside `InstallmentProvider`. It shows `DownPayError` if `state.error` is set, else `DownPayCancelPromoPoint`, else `DownPayConfirmation`. All three are `next/dynamic` with `ssr: false`.
- `DownPaymentProvider` (from `app/contexts/DownPayContext`) is mounted by `components/providers/PaymentPageProvider` between `PromoProvider` and `PaymentNudgeProvider`, so the confirm and complete pages also have it.

## Data & services
- `POST /tix-payment-core/down-payment/detail` (`services/getDownPaymentData.ts`, via `fetchClient` with core headers, `lang`, `username` and `accountId`). It strips `cardNumber` from request logs and `selectedPaymentMethod.tokens` from response logs. Wrapped as a React Query **mutation** in `useGetDownPaymentData`, not a query.
- `DownPaymentProvider` (`app/contexts/DownPayContext/DownPayContext.tsx`): a `useReducer` over `DownPaymentState` (`isOpen`, `isDownPayPaymentInfoOpen`, `isPaymentMethodOpen`, `isDownPayCancelPromoPointOpen`, `currentStep: 'terms' | 'payment-method' | 'processing' | 'success' | 'error'`, `data`, `selectedInstallment`, `useDownPayment`, `fullSettlement`, `requestSubmitDownPayment`).
  - `openDownPayment(orderId, orderHash, paymentMethod, cardNumber?)` sends the selected installment month from `useInstallment`.
  - `openDownPaymentInfo` sends `fromOrder: true` to skip the payment-method eligibility check (info-only view).
  - `submitDownPayment` only closes the modal and dispatches `SUBMIT_DOWNPAYMENT`. The actual submit is done by `components/SubmitPayment`, which reads `state.useDownPayment`/`state.fullSettlement` in `useSubmitPayment`.
- `useDownPayNativeOverlay` shows or hides the native app nav overlay (`showAppsNavOverlay`/`hideAppsNavOverlay`) while DownPay modals are open in a webview.
- `hooks/useRefetchLanding.ts` and `useDownPayFirstAmount.ts` refresh landing data and compute the first-payment amount.
- Settlement predicates in `utils/settlementUtils.ts`: `getCurrentInstallmentNumber`, `shouldShowDownPayEntry`, `isDownPayInstallment`, `isFirstDownpayInstallment`, `shouldResolveDownPayInstallmentNumber`, `shouldShowMultipleSettlementOption`.
- Copy lives in `lib/i18n/downpay/`.

## Key components
`app/downpay/components/`: `DownPayButton` (container + `useDownPayButtonLogic`), `DownPayConfirmation` (main modal; hooks for installment selection, read-more and scroll title), `DownPayInstallment` (picker, options, list, dialog), `DownPayPaymentMethod`, `DownPayPaymentOption` (+ `DownPayPaymentInfo`), `DownPayHowItWorks` (`buildDownPayBillSteps`), `DownPayTermsConditions`, `DownPayFooterTerms`, `DownPaySettlement` / `DownPaySettlementCard` (`SelectSettlementDialog`, `SettlementItem`), `DownPayCancelPromoPoint`, `DownPayError`, `DownPayInfoBanner`, `DownPayConfirmPaymentInfoBanner`, `DownPaySuccessPaymentInfoBanner`, `DownPayBillsNudge`, `TwoColumnContent`.
Shared components that branch on DownPay: `components/CardComponentV2` (`CardInstallmentV2`), `components/Installment`, `components/PriceDetailV4/components/DownPayDetails`, `components/PriceSummary`, `components/SubmitPayment`, the confirm `AccountInfo` and complete `SuccessV2` under `pages/payment/[type]/`.

## Tracking
GTM via `lib/hooks/useGTM` (`pushGTMClickV2`), category `paymentProcessing`: `clickDownPayButton` (with `ctaTitle` and `paymentMethod`), `downPayLandingPage` (impression), `submitFinalizePaymentWithDownPay`. See [[gtm-datalayer-tracking]].

## Tests
47 Vitest specs under `app/downpay/`, plus 5 under `app/contexts/DownPayContext/`. Playwright: `e2e/scenarios/clean/downpay.spec.ts`, `downpay-confirm-complete.spec.ts`, `e2e/scenarios/infinity/tests/DOWNPAY/downpay.spec.ts`. Mock mode supports `NEXT_PUBLIC_MOCK_PRODUCT_TYPE=downpay` (README).

## Gotchas
- **Two import aliases for the same folder.** `tsconfig.base.json` maps `@/*` to both `./*` and `./app/*`, so `@/downpay/...` and `@/app/downpay/...` both resolve to `app/downpay/`. Both forms appear in the code (`pages/payment/index.page.tsx` uses both).
- When promo, gift card or tiket points are applied, the DownPay button opens `DownPayCancelPromoPoint` first instead of the confirmation, because the two can't be combined (`useDownPayButtonLogic`). On repayment the landing also disables promo and points unless the type is `FLEXIBLE_PAYMENT`.
- `useGetDownPaymentData`'s `onError` rethrows. Errors from `getDownPaymentData` itself are returned (`error(e)`), not thrown, so callers must check `code`.
- `DownPayContext` lives in `app/contexts/` and is not one of the 8 contexts listed in AGENTS.md (see [[payment-fe-architecture]]).

## Sources
- `app/contexts/DownPayContext/DownPayContext.tsx`, `constants.ts`, `types.ts`, `hooks/useDownPayActions.ts`, `hooks/useDownPayNativeOverlay.ts`
- `app/downpay/services/getDownPaymentData.ts`, `useGetDownPaymentData.ts`
- `app/downpay/types/downpay.types.ts`
- `app/downpay/utils/settlementUtils.ts`
- `app/downpay/components/index.ts`, `DownPayModalContainer/DownPayModalContainer.tsx`, `DownPayButton/hooks/useDownPayButtonLogic.ts`, `DownPayConfirmation/DownPayConfirmation.tsx`
- `components/providers/PaymentPageProvider/PaymentPageProvider.tsx`
- `components/SubmitPayment/hooks/useSubmitPayment.ts`
- `pages/payment/index.page.tsx`
- `tsconfig.base.json`
