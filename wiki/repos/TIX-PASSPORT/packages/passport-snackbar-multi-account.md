---
title: SnackbarMultiAccount
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-snackbar-multi-account"
umbrella: true
sources:
  - packages/snackbar-multi-account/src
  - packages/snackbar-multi-account/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# SnackbarMultiAccount
> "Logged in with <email / phone> · Change account" snackbar for users with several accounts on one phone number. "Change account" logs out and sends the user back through login.

Part of [[passport-packages]].

## What it does
When `isOpen` first becomes true, it fetches the account once (`GET /tix-member-core/v2/account`, through React Query) to get the phone code and number. It then shows the snackbar ("Udah log in dengan …" / "Logged in with …") using [[passport-snackbar]]. The action ("Ganti akun" / "Change account") calls `POST /tix-member-core/v3/auth/logout` and redirects using `referenceUrl` and `verticalType`. If the fetch fails, it still shows the error variant. GTM events are in `utils/gtm.ts`.

## Public API
`SnackbarMultiAccount` (memo, `'use client'`; also in [[passport-umbrella]]); `SnackbarMultiAccountProps`: `isOpen`, `referenceUrl`, `verticalType`, `email`, `snackbarConfig?: SnackbarOptions`.

## Usage
```tsx
<SnackbarMultiAccount isOpen={isMultiAccount} email={user.email}
  referenceUrl={location.href} verticalType="flight" snackbarConfig={{ duration: Infinity }} />
```

## Depends on
[[passport-snackbar]] (a `SnackbarProvider` must be mounted), [[passport-utils]]. Peer: `@tanstack/react-query`. External: `uuid`.

## Used by
- No internal dependents and no consumers in the other workspace repos.

## Gotchas
- The fetch runs once per mount (guarded by a ref). Toggling `isOpen` again doesn't refetch.

## Sources
- packages/snackbar-multi-account/src/SnackbarMultiAccount.tsx
- packages/snackbar-multi-account/src/components/Layout/index.tsx
- packages/snackbar-multi-account/src/services/
- packages/snackbar-multi-account/src/types/multi-account-props.ts
- packages/snackbar-multi-account/package.json
