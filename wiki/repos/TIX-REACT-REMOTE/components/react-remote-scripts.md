---
title: Remote Scripts
repo: TIX-REACT-REMOTE
kind: component
npm: "@tiket/react-common-analytic"
sources:
  - src/components/scripts
  - webpack.config.js
  - Dockerfile
verified_at: 281778b
updated: 2026-10-16
status: current
tags: [repo/react-remote, kind/component]
---

# Remote Scripts
> Headless remote that initializes analytics ([[react-common-analytic]]) and push notifications ([[react-common-push-notif]]) on consumer pages.

## What it does
Exposed as `scripts`. It renders only an empty `Wrapper` div. On mount it:
1. Calls `initialize()` from [[react-common-analytic]] unless both `window.isAmplitudeSDKInitialized` and `window.isMixpanelSDKInitialized` are already set. If `userData` is non-empty it passes a `user` object: email (`username`), first/last name, `userId` (`accountId`), `unmUserId`, `isB2bCorp`, `isGuest`, `isEmailVerified`, `isPhoneVerified`, `loginType` (from `loginMedia`: TIKET/GOOGLE/FACEBOOK/APPLE, default TIKET) and `signupType` (from `facebookRegist`/`googleRegist`).
2. Passes `config.isAmplitudeEnabled` and `config.isMixpanelEnabled` from `process.env.IS_AMPLITUDE_ENABLED` / `IS_MIXPANEL_ENABLED`. These are **build-time** values inlined by `DefinePlugin`.
3. Always calls `initializePushNotification({ accountId })`.

## Public API
`CommonComponentProps` plus `userData?: UserData` (see `src/types.ts`). Only `userData` and `isNewURLStructure` are used.

## Usage
```tsx
import { RemoteScripts } from '@tiket/react-common-remote';
<RemoteScripts />   // userData comes from ReactRemoteContext.sessionData when logged in
```

## Depends on
[[react-common-analytic]], [[react-common-push-notif]], [[react-remote-wrapper]] (only `Wrapper`, no PassportWrapper).

## Used by
- TIX-NEXT-PAYMENT-FE `components/providers/AppProvider.tsx` ([[payment-fe-components]]).
- TIX-FINTECH-NEXT-FE `pages/_app.page.tsx`, `app/gift-card/layout.page.tsx`, `app/(external)/gift-card/layout.page.tsx`, `app/insurance-claim/layout.page.tsx`.

## Gotchas
- Defaults differ: Dockerfile `IS_AMPLITUDE_ENABLED=false`, `IS_MIXPANEL_ENABLED=true`; the webpack fallbacks are the same; but `pnpm test:build:docker` defaults Amplitude to `true`. Setting these in the K8s ConfigMap does nothing because the client bundle is already built (incident behind `docs/SOP-ENVIRONMENT-VARIABLES.md`, v2.0.17).
- It logs `Amplitude enabled:` / `Mixpanel enabled:` to the console on every mount. This is useful to verify the build args after a deploy.
- The analytics init guard uses `||`, so if only one SDK is marked initialized, `initialize()` still runs.

## Sources
- src/components/scripts/index.tsx
- src/components/scripts/utils.ts
- webpack.config.js
- Dockerfile
- docs/SOP-ENVIRONMENT-VARIABLES.md
- TIX-REACT-COMMON packages/react-common-remote/src/RemoteScripts/index.tsx
