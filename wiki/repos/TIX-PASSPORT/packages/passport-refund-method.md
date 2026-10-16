---
title: RefundMethod
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-refund-method"
sources:
  - packages/refund-method/src
  - packages/refund-method/package.json
  - packages/refund-method/CONTRIBUTING.md
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# RefundMethod
> Refund-method selector: choose how a refund is paid out (bank transfer, BliPay, tiket points, original card, Juspay…), add, verify or select a bank account, and track where the money went after the refund.

Part of [[passport-packages]].

## What it does
It takes the method list from the refund backend (`data: RefundMethodData[]`), so the backend controls which methods, badges and inputs appear. The user picks a method. For bank transfer they pick a saved account or add one. Adding goes through the bank list, a form, a check, then an OTP verification. Juspay methods render the dynamic `inputs` (with regex and required flags) from the payload. Popups are adaptive (Modal on desktop, BottomSheet on mobile) with bottom-sheet navigation history. Tracking goes through `useTracker` and `customTracker`.

The services call `tix-refund`. The path prefix is `external` for customers and `dashboard` for the panel variant:
- `/tix-refund/{prefix}/banks?countries=Indonesia`
- `/tix-refund/{prefix}/refunds/{path}/bank-account` (list)
- `.../bank-account/check`
- `.../bank-account/check-result`

## Public API
- `RefundMethod`: the customer-facing selector.
- `RefundMethodPanel`: an internal or CS-dashboard variant. It is always English, uses the `dashboard` prefix and has extra `prefilledBankAccount`, `disabled`, `onChangeMethodSSRR` and `isOpenModal` props.
- `RefundMethodTrack`: read-only "refunded to" status (`data`, `isLoading`).
- All types from `types/refund-method.ts`: `RefundMethodKey` (`blipay`, `bank_transfer`, `credit_card`, `shopee_pay`, `pay_later`, `tix_point`, `emd`, `gift_voucher`, `juspay`, `ovo`, `qris`), `RefundMethodData`, `RefundMethodOptions`, `InputsData`, `BankAccountData`, `JuspayStateValuesType`, …

Key `RefundMethodProps`: `data`, `isLoading`, `clientSideServiceEndpoint`, `vertical`, `orderData`, `customTracker`, `onChangeMethod`, `onSetBankAccount`, `onSetBankAccountJuspay`, `onActivateBlipayClick`. Not in [[passport-umbrella]].

## Usage
Fixtures in `src/mocks/refund-method/*` cover each scenario: single or multiple method, BliPay (linked and unlinked), forced bank transfer, partial SSRR, Juspay and corporate billing. See `RefundMethod.stories.tsx`.
```tsx
<RefundMethod data={methods} isLoading={false} clientSideServiceEndpoint=""
  vertical="flight" orderData={order}
  onChangeMethod={setMethod} onSetBankAccount={setAccount} onSetBankAccountJuspay={setJuspay} />
```

## Depends on
[[passport-modal]], [[passport-bottom-sheet]], [[passport-dialog]], [[passport-radio]], [[passport-check]], [[passport-form]], [[passport-dropdown]], [[passport-search-box]], [[passport-list]], [[passport-card]], [[passport-notification-banner]], [[passport-snackbar]], [[passport-loading-indicator]], [[passport-content-loader]], [[passport-figure]], [[passport-divider]], [[passport-button]], [[passport-typography]], [[passport-utils]], assets, icons, `@tiket/react-common-utilities` (`getCommonHeaders`).

## Used by
- TIX-FINTECH-NEXT-FE (`^12.4.3`, direct dependency), the refund project: `RefundMethod` in `projects/refund/shared/components/RefundMethodEstimation{,V2}/components/Wrapper/index.tsx`, `RefundMethodTrack` in `projects/refund/catch-all/components/RefundDetailPage/components/RefundMethodTrackWrapper/index.tsx`, and types in `projects/refund/shared/lib/types/*`. See [[fintech-fe-refund]].

## Gotchas
- Local Storybook needs https and a logged-in gatotkaca session, because the module needs a session access token. Test login steps are in `packages/refund-method/CONTRIBUTING.md`.
- Bank list requests are hard-coded to `countries=Indonesia`.

## Sources
- packages/refund-method/src/index.ts
- packages/refund-method/src/RefundMethodPanel.tsx
- packages/refund-method/src/RefundMethodTrack.tsx
- packages/refund-method/src/types/refund-method.ts
- packages/refund-method/src/services/
- packages/refund-method/CONTRIBUTING.md
- packages/refund-method/package.json
