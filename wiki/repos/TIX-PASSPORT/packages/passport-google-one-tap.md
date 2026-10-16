---
title: Google One Tap
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-google-one-tap"
sources:
  - packages/google-one-tap/src
  - packages/google-one-tap/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Google One Tap
> Google One Tap sign-in for logged-out web users. It loads Google Identity Services, prompts, and hands the credential to tiket's `/login` page. On desktop FedCM browsers it can show an optional AB-driven nudge banner next to the prompt.

## What it does
`useGoogleOneTap` injects `https://accounts.google.com/gsi/client` once and calls `google.accounts.id.initialize` with tiket's client ID: `auto_select` unless `sessionStorage.logout === 'true'`, `ux_mode: 'popup'`, FedCM on desktop only, `cancel_on_tap_outside: false`. It then calls `prompt()`, but **never** when `isLogin` or `isWebview` is set. On success the callback redirects to `/login?ref=<href>&g_token=<JWT>&g_type=success&select_by=…&screen_name=…&screen_owner=…` (with forward params). On error it redirects with `g_type=error`. There's no API call in the package. The login app does the token exchange.

Timing: without `hasGlobalPopup` it prompts after mount. With it, the hook waits for the window event **`tiket-google-one-tap`** `{ detail: { command: 'prompt' } }`, which [[passport-global-popup]] dispatches when it closes or when no popup was shown.

Nudge: AB flag `ff-mem-google-one-tap` (`@tiket/react-common-ab-test`) has a payload keyed by `screenName`: `{ icon_url, title, subtitle, bg_color_1, bg_color_2 }`. On desktop FedCM browsers it's shown as a gradient card, portalled to `#modal-root` and positioned near the prompt. Opera, Edge and Firefox are treated as unsupported.

## Public API
| Export | Notes |
|---|---|
| `GoogleOneTap` | `screenName`, `screenOwner` (required). `isLogin`, `isWebview`, `hasGlobalPopup`, `portalId`. Wraps itself in its own `QueryClientProvider` |
| constants | `GOOGLE_ONE_TAP_NUDGE_FEATURE_FLAG`, `GOOGLE_ONE_TAP_CUSTOM_EVENT`, `GOOGLE_ONE_TAP_EVENT_COMMAND`, `GOOGLE_SDK_CLIENT_ID`, `GOOGLE_ONE_TAP_USER_SELECTION_TYPES` |
| types | `GoogleOneTapProps`, `CredentialResponse`, global `window.google` typings |

## Usage
```tsx
<GoogleOneTap screenName="home" screenOwner="discovery" isLogin={isLoggedIn} isWebview={isApp} hasGlobalPopup />
```

## Tracking
`loginRegistration` events: impression `seeGoogleOneTap`, and click `googleOneTapClick` when `select_by` is a user-initiated type.

## Depends on
[[passport-portal]], [[passport-icons]], [[passport-typography]], [[passport-utils]] (`usePassport`, `useForwardParams`), `@tiket/react-common-ab-test` ([[react-common-ab-test]]). Peer `@tanstack/react-query ^5`.

## Used by
- TIX-REACT-REMOTE `src/components/google-one-tap/index.tsx` exposes it as a remote ([[react-remote-google-one-tap]]), pinned `12.4.2`.
- Internal: none.

## Gotchas
- Mount it on pages that also mount the global popup with `hasGlobalPopup`. Otherwise the two compete for attention. The event name is duplicated as a constant in both packages, so keep them in sync.
- The Google client ID is hard-coded, so it's the same one in every environment.
- Not in the umbrella `@tiket/passport`.

## Sources
- `packages/google-one-tap/src/GoogleOneTap.tsx`, `src/hooks/useGoogleOneTap.ts`, `src/utils/{constants,common,trackers,types}.ts`
- `packages/global-popup/src/utils/common.ts` (`toggleOneTapLogin`)
- `packages/google-one-tap/package.json`
