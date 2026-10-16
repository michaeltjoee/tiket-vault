---
title: react-common-push-notif
repo: TIX-REACT-COMMON
kind: package
npm: "@tiket/react-common-push-notif"
sources:
  - packages/react-common-push-notif/src
  - packages/react-common-push-notif/package.json
  - packages/react-common-push-notif/README.md
verified_at: 14597c4e
updated: 2026-10-16
status: current
tags: [repo/react-common, kind/package]
---

# react-common-push-notif
> Registers the browser for Firebase Cloud Messaging web push, saves the token to `tix-push-notif`, and shows foreground notifications for Sendbird chat messages.

## What it does
`initialize({ accountId })` (client only, once) returns early when service workers or FCM are unsupported, when it already ran (`window.initializeFirebase`), when config is missing, or when notification permission is not granted (it prompts if undecided). It then registers **`/serviceworker.js`**, gets an FCM token with the per-environment VAPID key, and POSTs it to `/tix-push-notif/userPushNotif/saveToken` via [[react-common-fetch-client]]. It does this only when `<accountId>-<token>` differs from the `tiket-fcm-x` cookie, which is kept for 1 year. In the foreground, Sendbird chat payloads become a `Notification` that opens `/inbox/chat/<channel_url>`, and unread counts are broadcast on the `push-notif-chat` `BroadcastChannel`. See [[web-push-notifications]].

## Public API
- `initialize({ accountId: string | null }): Promise<void>`
- type `ExtendedWindow`

## Usage
```ts
// TIX-REACT-REMOTE src/components/scripts/index.tsx
import { initialize as initializePushNotification } from '@tiket/react-common-push-notif';
useEffect(() => {
  initializePushNotification({ accountId: userData?.accountId ? `${userData.accountId}` : null });
}, []);
```

## Depends on
- [[react-common-env]] (picks Firebase project: dev/local/staging → `tiketandroid-debug`, preprod → `tiket-preprod`, production → `tiketandroid-e9b2a`), [[react-common-fetch-client]]
- `firebase` ^9.8

## Used by
- TIX-REACT-REMOTE: [[react-remote-scripts]], pinned `1.3.6`.

## Gotchas
- The host app must serve a Firebase messaging service worker at **`/serviceworker.js`**. Background notifications are handled there, not in this package.
- On a VAPID key change (stored in `localStorage['token-fcm']`) it **unregisters the current service worker registration** of the page scope. This is a compat fix for verticals that used the wrong key, but it also removes any other service worker on that scope.
- `initialize` runs only once per page (`window.initializeFirebase`). A later login does not re-save the token until the next page load.
- Greeting-text chat messages are always parsed in `ID`, whatever the user's language.
- README title says `@tiket/react-common-analytic` (copy-paste); the call in it has no `accountId`, but the current signature requires one.
- Excluded from root Jest projects and from Sonar.

## Sources
- packages/react-common-push-notif/src/{index,initialize,getConfig,chat-platform,helpers}.ts
- packages/react-common-push-notif/README.md, package.json
