---
title: OtpUnm
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-otp-unm"
sources:
  - packages/otp-unm/src
  - packages/otp-unm/package.json
  - packages/otp-unm/README.md
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# OtpUnm
> Multi-channel OTP verification UI (WhatsApp, SMS, email) for the UNM (user and member) auth backend `gks-unm-go-be`, with resend, "use another method", "OTP not received" and customer-care flows.

Part of [[passport-packages]].

## What it does
It is the newer OTP component used by login, register and verification flows. Compare [[passport-otp-form]], which talks to `tix-member-core`. It posts to `{serviceHost || window.location.origin}`:
- `/gks-unm-go-be/api/v1/otp/generate`
- `/gks-unm-go-be/api/v1/otp/verify`
- a customer-info endpoint for the customer-care sheet.

It renders sections (Recipient, EnterOtp, Resend, Alternative, IssueWithOtp). Popups open in a modal or bottom sheet depending on `useMatchMedia`, and push URL hashes (`utils/hash.ts`), so the browser back button closes them. On success it calls `onSuccess(passCode, type)`.

## Public API
- `OtpUnm` (default export of `OtpWrapper`), `CustomerCare` components, and all types (`OtpProps`, `OtpType`, `ActionOtp`, `OtherMethod`, `ChannelId`…). Not in [[passport-umbrella]].

| Prop | Notes |
|---|---|
| `type` | `WA_OTP` \| `SMS_OTP` \| `EMAIL_OTP` |
| `action` | `LOGIN_OTP`, `REGISTER_OTP`, `VERIFY_EMAIL`, `VERIFY_PHONE`, `CHANGE_PHONE`, `MERGE_ACCOUNT`, `VERIFY_DOUBLE_EMV` or any string |
| `recipient` / `recipientId` | masked display value / raw id used for generation (phone without `+`) |
| `otherMethods: { type, recipient }[]` | other OTP channels, plus `EMAIL_PASSWORD`/`PHONE_PASSWORD`/`PASSWORD_CONFIRMATION` (password menu) and `CREATE_ACCOUNT` |
| `onSuccess`, `onError(err, step)`, `onClose` | required |
| `onGenerate`, `onSubmit`, `onPasswordMethodClick`, `onCustomBottomActionClick`, `renderCustomBottomAction`, `shouldClosePreviousForCustomBottomAction` | optional hooks |
| `serviceHost`, `channelId` (`DESKTOP`/`WEB`/`MOBILE`/`ANDROID`/`IOS`), `logger`, `renderLoading`, `trackerProperties`, `dvId` (DataVisor id) | |

## Usage
From the README:
```tsx
<QueryClientProvider client={queryClient}>
  <OtpUnm action="VERIFY_PHONE" type="WA_OTP"
    recipient="+62****1234" recipientId="uuid"
    serviceHost="http://m.gatotkaca.tiket.com"
    otherMethods={[{ type: 'SMS_OTP', recipient: '+62****1234' }, { type: 'EMAIL_PASSWORD', recipient: '' }]}
    onClose={close} onSuccess={(code) => submit(code)} onError={handleError} />
</QueryClientProvider>
```

## Depends on
[[passport-modal]], [[passport-bottom-sheet]], [[passport-dialog]], [[passport-accordion]], [[passport-list]], [[passport-logo]], [[passport-snackbar]] (a `SnackbarProvider` is required, because verify errors show a snackbar), [[passport-content-loader]], [[passport-typography]], [[passport-utils]]. Peer: `@tanstack/react-query`.

## Used by
- No consumers found in the other workspace repos.

## Gotchas
- The README says to install `react-query`, but the peer dependency is `@tanstack/react-query`.
- The hash-based popup history calls `window.history.back()` to close a popup. Hosts that also use hashes can conflict with it.

## Sources
- packages/otp-unm/src/types.ts
- packages/otp-unm/src/utils/constants.ts
- packages/otp-unm/src/utils/hash.ts
- packages/otp-unm/src/index.ts
- packages/otp-unm/README.md
- packages/otp-unm/package.json
