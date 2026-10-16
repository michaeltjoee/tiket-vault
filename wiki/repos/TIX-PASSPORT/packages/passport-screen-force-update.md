---
title: ScreenForceUpdate
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-screen-force-update"
sources:
  - packages/screen-force-update/src
  - packages/screen-force-update/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# ScreenForceUpdate
> Full-screen "please update the app" page for WebViews. The CTA opens the App Store or Play Store, and an optional secondary button lets the user continue when the update isn't mandatory.

Part of [[passport-packages]].

## What it does
It shows the tiket partner logo, the `tds_si_update_force` illustration, a localized title and description, and buttons. The primary button calls `onTrackerPrimaryButtonClick`, then `redirectToAppsDevice`. That sets `window.location.href` to the App Store link on iOS (detected with `getWebViewEnvClient` from `@tiket/react-common-utilities`) and to the Play Store link otherwise. Both links go through `withForwardParams`. The secondary button (`onSecondaryButtonClick`) is hidden when `isMandatory`.

## Public API
`ScreenForceUpdate` (also in [[passport-umbrella]]); `ScreenForceUpdateProps`: `onSecondaryButtonClick` (required), `isMandatory` (default false), `title`, `description`, `primaryTextButton`, `secondaryTextButton`, `onTrackerPrimaryButtonClick`.

## Usage
From [[passport-phone-verification]], shown when the OTP step reports `DEPRECATED_VERSION`:
```tsx
<ScreenForceUpdate onSecondaryButtonClick={handleScreenForceUpdateSecondaryCta} />
```

## Depends on
[[passport-button]], [[passport-typography]], [[passport-utils]] (`usePassport`, `useForwardParams`), assets, `@tiket/react-common-utilities` ([[react-common-utilities]]).

## Used by
- Inside TIX-PASSPORT: [[passport-phone-verification]].
- No consumers in the other workspace repos.

## Sources
- packages/screen-force-update/src/ScreenForceUpdate.tsx
- packages/screen-force-update/src/utils/device.ts
- packages/screen-force-update/package.json
