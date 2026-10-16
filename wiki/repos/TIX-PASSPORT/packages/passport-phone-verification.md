---
title: PhoneVerification
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-phone-verification"
sources:
  - packages/phone-verification/src
  - packages/phone-verification/package.json
  - packages/phone-verification/README.md
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# PhoneVerification
> End-to-end "verify your phone number" flow: a phone input with a country picker, then a phone check, then an OTP ([[passport-otp-form]]), then confirm and update the account phone.

Part of [[passport-packages]].

## What it does
1. The user enters a number. The country list comes from `/tix-profile-core/data/countries` through [[passport-country-list-selection]].
2. `/tix-member-core/v2/guest/check-phone/{phone}` validates the number.
3. It opens `OtpForm` with `requestType` (for example `VERIFY_PHONE` or `VERIFICATION_AFTER_ORDER_SUCCESS`).
4. On OTP success it calls `/tix-member-core/v2/verification/phone/confirm`, unless `skipVerifyPhoneConfirm` is set, and `/tix-members-core/verification/phone-number/v2` (update phone), then `onSuccess(otpToken, otpTrxId, phoneCode, phoneNumber)`.

If the OTP step fails with `DEPRECATED_VERSION`, it shows [[passport-screen-force-update]]. Any other failure shows an error snackbar. The flow renders in a Modal on desktop or a BottomSheet on mobile (`ModalBottomsheetResponsive`) and can close a native WebView (`utils/close-webview.ts`).

## Public API
- `PhoneVerification`. `PhoneVerificationDesktop` and `PhoneVerificationMobile` are aliases of it. Not in [[passport-umbrella]].
- Types: `PhoneVerificationWrapperProps`, `RequestActionVerifyPhoneType`.

Key props: `description` (required), `primaryButtonText`, `requestType`, `onSuccess`, `onFailure(error, step?)`, `clientSideServiceEndpoint`, `accountId`, `username`, `locale`, `orderId` (required for `VERIFICATION_AFTER_ORDER_SUCCESS`), `sessionAccessToken` (pass the app token in WebViews), `skipVerifyPhoneConfirm`, `phoneCode`/`phoneNumber` (prefill), `secondaryButtonText`/`onClickSecondaryButton`, `platform` (`mobile`|`desktop`|`webview`), `image`, `withCloseButton`, `fullWidthButton`, `loadingComponent`, `showHelperTextPhone`, `eventLabel`/`screenName`/`additionalGtmVariables`/`additionalGtmOtpVariables`/`overrideGtmOnVerify`.

## Usage
```tsx
<QueryClientProvider client={queryClient}>
  <PhoneVerification requestType="VERIFY_PHONE" description="Verifikasi nomor HP"
    primaryButtonText="Kirim OTP" clientSideServiceEndpoint=""
    onSuccess={(token) => done(token)} onFailure={(e) => snackbar(e, { type: 'error' })} />
  <SnackbarProvider />
</QueryClientProvider>
```

## Depends on
[[passport-otp-form]], [[passport-screen-force-update]], [[passport-country-list-selection]], [[passport-form]], [[passport-modal]], [[passport-bottom-sheet]], [[passport-dialog]], [[passport-portal]], [[passport-snackbar]], [[passport-loading-indicator]], [[passport-button]], [[passport-typography]], [[passport-utils]]. Peer: `@tanstack/react-query`.

## Used by
- TIX-NEXT-PAYMENT-FE (`^8.11.1`, direct dependency): `components/Groups/index.tsx` (uses `PhoneVerificationDesktop`/`Mobile`), `pages/payment/[type]/confirm/components/PointsAdvice/PointsAdvice.tsx`, `pages/smart_pay/components/Items/index.tsx`. These are the payment-method gating and points flows.

## Gotchas
- The README says `react-query`, but the peer dependency is `@tanstack/react-query`.
- The update-phone path is `tix-members-core` (with an "s"), unlike the other `tix-member-core` calls. This comes straight from `services/update-phone.ts`.

## Sources
- packages/phone-verification/src/PhoneVerification.tsx
- packages/phone-verification/src/hooks/usePhoneVerification.ts
- packages/phone-verification/src/services/
- packages/phone-verification/src/types/phone-verification.ts
- packages/phone-verification/README.md
- packages/phone-verification/package.json
