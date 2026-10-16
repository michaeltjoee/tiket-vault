---
title: OtpForm
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-otp-form"
sources:
  - packages/otp-form/src
  - packages/otp-form/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# OtpForm
> Self-contained OTP entry form. It generates an OTP for a recipient, shows the code input with a resend countdown, verifies the code, and handles the max-attempt, suspend and blocked-prefix popups.

Part of [[passport-packages]].

## What it does
When `recipient` is set or changes, it calls `POST /tix-member-core/v3/otp/generate/{requestType}`. When the code is complete (4 digits by default), it calls `/tix-member-core/v3/otp/verify` with `{ token, trxId }`. Both use React Query `useMutation`. Requests go to `${clientSideServiceEndpoint}/ms-gateway/...`. Verify response codes are mapped as follows:
- `SUCCESS` calls `onSuccess(trxId, token)`.
- `INVALID_OTP` and `OTP_EXPIRED` show an inline error.
- `MAX_ATTEMPT_INPUT_OTP` shows the max-attempt popup.
- Anything else calls `onFailure(err, 'VERIFY_OTP')`.

Generate-side errors open responsive popups (Modal on desktop, Dialog on mobile) for suspend, max attempt, invalid phone combination and blocked prefix, with a contact-us redirect. GTM events go through `useOtpFormTrackers`.

## Public API
- `OtpForm` (memo). `OtpFormDesktop` and `OtpFormMobile` are aliases of the same component, kept for the old adaptive API. All three are in [[passport-umbrella]].
- Types: `OtpFormWrapperProps`, `RequestTypeOtp` (`VERIFY_PHONE`, `VERIFY_EMAIL`, `GUEST_VERIFY_*`, `LOGIN_OTP`, `FORGOT_PASSWORD`, `CHANGE_PIN`, `TRUSTED_DEVICE`, `CHANGE_PHONE*`, `CHANGE_EMAIL`, `LOYALTY_USE_TIXPOINT`, `VERIFICATION_AFTER_ORDER_SUCCESS`).

Key props (`OtpFormContextValue` and `OtpFormProps`): `recipient`, `requestType`, `accountId`, `username`, `locale`, `screenName`, `clientSideServiceEndpoint`, `sessionAccessToken`, `onSuccess`, `onFailure(error, step?)`, `onLoading`, `onClose`, `eventCategory`/`eventLabel`/`additionalGtmVariables`/`customSubmitOtpTracker`, `magicLinkAdditionalParameter`, `appDetails` (native device info), `showHelperTextPhone` (default true), `showHelperTextEmail` and `onClickHelperTextEmail`.

## Usage
```tsx
<OtpForm recipient="+628123456789" requestType="VERIFY_PHONE"
  accountId={id} username={email} locale="id" screenName="phoneVerification"
  clientSideServiceEndpoint={gatewayHost}
  onSuccess={(trxId, token) => submit(trxId, token)}
  onFailure={log} onLoading={setLoading} onClose={close} />
```

## Depends on
[[passport-modal]], [[passport-dialog]], [[passport-figure]], [[passport-snackbar]], [[passport-typography]], [[passport-utils]]. Peer: `@tanstack/react-query`, so a `QueryClientProvider` is required. External: `uuid`.

## Used by
- Inside TIX-PASSPORT: [[passport-phone-verification]].
- No direct consumers in the other workspace repos. TIX-FINTECH-NEXT-FE refund has its own `projects/refund/shared/components/FormOTP`.

## Gotchas
- Generation fires automatically on mount whenever `recipient` is truthy. Re-rendering with a new recipient re-sends the OTP.
- `onLoading(false)` is delayed by 1 s on unknown errors.

## Sources
- packages/otp-form/src/OtpForm.tsx
- packages/otp-form/src/hooks/useOtpForm.ts
- packages/otp-form/src/services/
- packages/otp-form/src/types/otp-form.ts
- packages/otp-form/package.json
