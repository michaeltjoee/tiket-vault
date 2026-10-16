---
title: Remote Header
repo: TIX-REACT-REMOTE
kind: component
npm: "@tiket/passport-header"
sources:
  - src/components/header
  - src/utils/header
verified_at: 281778b
updated: 2026-10-16
status: current
tags: [repo/react-remote, kind/component]
---

# Remote Header
> Responsive site header served over module federation, built on `Header` from [[passport-header]].

## What it does
Exposed as `header`. Adds behaviour on top of the Passport header:
- **Vertical menu data**: picks `DEFAULT_VERTICALS_DATA_{ID,EN}` or the `_MULTICURRENCY_` variants when `isMultiCurrencyAvailable` and currency is not IDR.
- **Currency**: prop `currency` → `userData.currency` (if logged in) → `tiket_currency` cookie → `IDR`.
- **Sticky behaviour** (`useHeaderProps`, `src/utils/header/index.ts`): when `isSticky`, it listens to scroll and switches to fixed at `scrollY >= 240`. A `transparent` variant uses the inverted logo and hides the bottom bar until fixed, then becomes `default`. Layout code `004` becomes `001` once fixed.
- **Unread badge** (`useNotificationCount`): when `userData.accountId` is set and no `unreadMessageCount` prop is given, it fetches `/tix-inbox/userInbox/unreadCount` and `/tix-chat-platform/v1/users/unread_count` through [[react-common-fetch-client]], sums them, and listens on BroadcastChannel `push-notif-chat` for live chat counts.
- **Client-only props**: `activeMenu`, `rightIcons` and `userData` are held in state and applied after mount. This keeps the SSR cache key small and avoids CLS (NCT-2554).

## Public API
`CommonComponentProps & HeaderProps` plus `activeMenu`, `dataLayer`, `isSticky`, `showBackIcon`, `unreadMessageCount`, `clientVersion`. Defaults: `lang 'id'`, `country 'id'`, `device 'desktop'`, `variant 'default'`, `isLogin false`, `isMultiCurrencyAvailable true`, `wishlistEnabled true`, `useDeprecatedHeader true`.

`getSsrCacheConfig` adds `isLogin`, `variant`, `showBackIcon`, `hideBottom`, `hideGlobalSearch`, `layoutVariantCode` to the SSR whitelist (see [[react-remote-architecture#SSR and caching]]).

## Usage
```tsx
import { RemoteHeader } from '@tiket/react-common-remote';
<RemoteHeader isSticky variant="transparent" />
```
The consumer wrapper fills `isLogin`/`userData` from `ReactRemoteContext.sessionData`, `dataLayer` from context, and always sends `useDeprecatedHeader: false`. For the App Router there is also a server component in `@tiket/react-common-remote/server` (`ServerComponents/RemoteHeader`).

## Depends on
[[passport-header]], [[passport-design-tokens]], [[passport-assets]] (logos), [[react-common-fetch-client]], [[react-remote-wrapper]].

## Used by
- TIX-NEXT-PAYMENT-FE `components/providers/AppProvider.tsx`, `pages/smart_pay/components/Layout/index.tsx`.
- TIX-FINTECH-NEXT-FE: `app/error.page.tsx`, gift-card wrappers under `app/gift-card/**` and `app/(external)/gift-card/order`, insurance headers in `projects/insurance/**/Header.tsx`, refund `projects/refund/shared/components/Header/index.tsx`.

## Gotchas
- `useDeprecatedHeader` is forced to `false` when the request header `x-client-version-flag` is `2.0` (the server passes it as `clientVersion`). The [[react-common-remote]] fetcher always sends `2.0`, so SSR renders the new header even if the prop says otherwise.
- `rightIcons` are React elements. They can't be serialized into the SSR request, so the server renders an empty fragment and the real icons appear only after hydration.
- The `currency` memo depends only on `userData.currency`. A later change to the `currency` prop alone does not recompute it.

## Sources
- src/components/header/index.tsx
- src/utils/header/index.ts
- src/utils/header/useNotificationCount.ts
- src/utils/header/useBroadcastChannel.ts
- TIX-REACT-COMMON packages/react-common-remote/src/RemoteHeader/index.tsx
