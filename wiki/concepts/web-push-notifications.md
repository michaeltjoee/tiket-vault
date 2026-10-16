---
title: Web push notifications
kind: concept
repos: [TIX-REACT-COMMON, TIX-REACT-REMOTE, TIX-NEXT-PAYMENT-FE, TIX-HOMEPAGE-NEXT-FE, TIX-GROWTH-NEXT-FE]
sources:
  - TIX-REACT-COMMON/packages/react-common-push-notif/src/initialize.ts
  - TIX-REACT-REMOTE/src/components/scripts/index.tsx
  - TIX-NEXT-PAYMENT-FE/components/providers/AppProvider.tsx
  - TIX-HOMEPAGE-NEXT-FE/worker/firebase-messaging.js
  - TIX-HOMEPAGE-NEXT-FE/next.config.ts
  - TIX-HOMEPAGE-NEXT-FE/pages/_app.page.tsx
  - TIX-GROWTH-NEXT-FE/pages/_app.page.tsx
verified_at:
  TIX-REACT-COMMON: 14597c4e
  TIX-REACT-REMOTE: 281778b
  TIX-NEXT-PAYMENT-FE: 9e92b20bb
  TIX-HOMEPAGE-NEXT-FE: 408983f6
  TIX-GROWTH-NEXT-FE: d4162e3
updated: 2026-10-16
status: current
tags: [kind/concept, repo/react-common, repo/react-remote, repo/payment-fe, repo/homepage-fe, repo/growth-fe]
---

# Web push notifications
> Browser push (Firebase Cloud Messaging) is set up by [[react-common-push-notif]]. Apps don't call it directly: the `scripts` remote from TIX-REACT-REMOTE initialises it on every page that mounts that remote ([[react-remote-scripts]]).

## Flow
1. The host mounts the `scripts` remote, as payment-fe's `AppProvider` does ([[payment-fe-components]]). homepage-fe and growth-fe render `RemoteScripts` in `_app` (growth-fe also in `app/layout`).
2. The remote calls `initializePushNotification({ accountId })`.
3. If the browser supports service workers and FCM and permission is granted (it prompts when undecided), it registers **`/serviceworker.js`** on the host, gets an FCM token with the environment's VAPID key ([[tiket-environments]]), and POSTs it to `/tix-push-notif/userPushNotif/saveToken` through [[react-common-fetch-client]]. The `tiket-fcm-x` cookie (`<accountId>-<token>`, 1 year) prevents re-posting.
4. In the foreground, Sendbird chat payloads become a `Notification` that opens `/inbox/chat/<channel_url>`, and unread counts are broadcast on the `push-notif-chat` `BroadcastChannel`.

## Gotchas
- **Every host must serve `/serviceworker.js`** at its own origin. Background notifications are handled there, not in the package.
  - homepage-fe generates it with `next-pwa` (`sw: 'serviceworker.js'`) and merges `worker/firebase-messaging.js`, which rewrites FCM payloads and posts chat counts on the same `push-notif-chat` channel that its `useNotificationCount` hook reads. Because homepage-fe owns `/`, this worker also controls other apps' paths on that origin ([[homepage-fe-architecture]]).
  - growth-fe has no service worker of its own on `main`.
- A VAPID key change unregisters the page-scope service worker registration. That can also remove another service worker registered on the same scope. MSW's mock worker in local mock mode may be affected (not verified).
- Initialisation runs once per page (`window.initializeFirebase`), so a login after page load doesn't save the token until the next load.

## Where it shows up
Pages that link here:
- TIX-HOMEPAGE-NEXT-FE: [[homepage-fe-architecture]]
- TIX-REACT-COMMON: [[react-common-push-notif]]
- concepts: [[tiket-environments]]

## Sources
- TIX-REACT-COMMON `packages/react-common-push-notif/src/initialize.ts`, `README.md`
- TIX-REACT-REMOTE `src/components/scripts/index.tsx`
- TIX-NEXT-PAYMENT-FE `components/providers/AppProvider.tsx`
- TIX-HOMEPAGE-NEXT-FE `next.config.ts` (`next-pwa`), `worker/index.js`, `worker/firebase-messaging.js`, `hooks/useNotificationCount.ts`, `pages/_app.page.tsx`
- TIX-GROWTH-NEXT-FE `pages/_app.page.tsx`, `app/layout.page.tsx`; `git ls-tree -r origin/main` (no service worker file)
