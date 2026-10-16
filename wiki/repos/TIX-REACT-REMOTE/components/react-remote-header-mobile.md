---
title: Remote HeaderMobile
repo: TIX-REACT-REMOTE
kind: component
npm: "@tiket/passport-header"
sources:
  - src/components/header-mobile
  - src/utils/header
verified_at: 281778b
updated: 2026-10-16
status: current
tags: [repo/react-remote, kind/component]
---

# Remote HeaderMobile
> Mobile-only header (`HeaderMobile` from [[passport-header]]) served over module federation.

## What it does
Exposed as `header-mobile`. It is a smaller version of [[react-remote-header]]. It shares the sticky logic (`useHeaderProps`) and the unread-count hook (`useNotificationCount`), and renders `rightIcons` only on the client. It also renders an empty boundary `div` after the header, which gets a spacer class once the header is fixed. It has no vertical menu data, no currency resolution, and no `abTestOnServerResponse` forwarding.

## Public API
`CommonComponentProps` plus `dataLayer`, `isLogin` (default `false`), `isMultiCurrencyAvailable` (default `true`), `isSticky`, `leftSlot`, `pageTitle`, `rightIcons`, `showBackIcon`, `unreadMessageCount`, `userData`, `variant` (default `'default'`).

`getSsrCacheConfig` whitelists `isLogin`, `variant`, `showBackIcon`.

## Usage
```tsx
import { RemoteHeaderMobile } from '@tiket/react-common-remote';
<RemoteHeaderMobile pageTitle="Payment" showBackIcon />
```

## Depends on
[[passport-header]], [[react-common-fetch-client]], [[react-remote-wrapper]].

## Used by
No direct `RemoteHeaderMobile` usage found in TIX-NEXT-PAYMENT-FE or TIX-FINTECH-NEXT-FE baselines. A server-component variant exists in [[react-common-remote]] (`ServerComponents/RemoteHeaderMobile`).

## Gotchas
- The consumer wrapper does not pass `userData`, so `useNotificationCount` gets no `accountId` and the unread badge stays at the `unreadMessageCount` prop value unless the caller passes `userData` through `restProps`.
- `leftSlot` and `rightIcons` are React elements and do not survive the SSR request.

## Sources
- src/components/header-mobile/index.tsx
- src/utils/header/index.ts
- TIX-REACT-COMMON packages/react-common-remote/src/RemoteHeaderMobile/index.tsx
