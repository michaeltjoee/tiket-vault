---
title: NotificationLogin
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-notification-login"
sources:
  - packages/notification-login/src
  - packages/notification-login/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# NotificationLogin
> Shows a one-time "logged in" snackbar or a "welcome / verify your email" popup after login or registration, driven by a short-lived cookie.

Part of [[passport-packages]].

## What it does
It is a cookie handshake across a redirect:
1. Before redirecting, the login or register flow calls `setNotificationLogin({ url, status, ... })`. This writes JSON to the cookie `tiket-login-notification` on `.tiket.com`, which expires after 5 minutes by default.
2. `<NotificationLogin />`, mounted on the landing page, reads the cookie on mount. It acts only if `window.location.href` contains `url`:
   - `status: 'login'`: shows a [[passport-snackbar]] message ("Hore! Kamu berhasil login!"). The cookie is deleted when the user taps OK.
   - `register`, `registerEmailVerifyLater`, `socmedRegister`: after 500 ms, opens a [[passport-figure]] popup with built-in localized copy and an image. It is a [[passport-modal]] on desktop and a [[passport-dialog]] on mobile, switched by CSS classes. Closing deletes the cookie.
   - Any other status: uses `title`, `description`, `image` and `ctaText` from the cookie.

## Public API
- `NotificationLogin`: no props. Reads the locale from `usePassport()`.
- `setNotificationLogin(params: NotificationLoginCookie, expiredHours?: number)`
- Types: `NotificationLoginStatus`, `NotificationLoginCookie`, `Content`.

Not re-exported by [[passport-umbrella]].

## Usage
```ts
// before redirect
setNotificationLogin({ url: '/myaccount', status: 'register' });
// on the destination page
<NotificationLogin />
```

## Depends on
[[passport-snackbar]] (needs a `SnackbarProvider` mounted), [[passport-modal]], [[passport-dialog]], [[passport-bottom-sheet]], [[passport-figure]], [[passport-typography]], [[passport-utils]].

## Used by
- No consumers found in the other workspace repos. The auth pages live elsewhere.

## Gotchas
- The cookie domain is hard-coded to `.tiket.com`, so it does nothing on other hosts (for example localhost).
- The Modal and the Dialog are both rendered. Which one is visible is decided only by CSS (`desktop_only` / `mobile_only`).

## Sources
- packages/notification-login/src/NotificationLogin.tsx
- packages/notification-login/src/core/setNotificationLogin.ts
- packages/notification-login/src/utils/constants.ts
- packages/notification-login/src/utils/cookie.ts
- packages/notification-login/package.json
