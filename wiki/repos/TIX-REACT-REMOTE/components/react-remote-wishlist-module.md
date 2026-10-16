---
title: Remote WishlistModule
repo: TIX-REACT-REMOTE
kind: component
npm: "@tiket/passport-wishlist"
sources:
  - src/components/wishlist-module
verified_at: 281778b
updated: 2026-10-16
status: current
tags: [repo/react-remote, kind/component]
---

# Remote WishlistModule
> Federated wrapper around `WishlistModule` from [[passport-wishlist]].

## What it does
Exposed as `wishlist-module`. It passes all props through to `WishlistModule` and the common ones to `PassportWrapper`. Mounted with `reuseRoot: true` (commit 51acd87). The consumer re-calls `mount()` whenever the wishlist state changes, and reusing the root turns that into a prop update instead of a remount.

## Public API
`CommonComponentProps & WishlistModuleProps`. It sets no defaults of its own.

## Usage
```tsx
import { RemoteWishlistModule } from '@tiket/react-common-remote';
<RemoteWishlistModule />  // spreads usePassport().wishlistData into props
```

## Depends on
[[passport-wishlist]], [[react-remote-wrapper]].

## Used by
- TIX-NEXT-PAYMENT-FE `components/providers/AppProvider.tsx` ([[payment-fe-components]]).

## Gotchas
- `wishlistData` contains setter functions (`setWish`, `setActiveWishIds`…). Functions only work through client mount props, never through SSR, so this module is effectively CSR-only.
- `PassportWrapper` also accepts a `wishlistData` prop, but this component does not pass it. The wishlist state lives in the module's own props.

## Sources
- src/components/wishlist-module/index.tsx
- src/components/wishlist-module/bootstrap.ts
- src/components/wrapper/PassportWrapper/index.tsx
- TIX-REACT-COMMON packages/react-common-remote/src/RemoteWishlistModule/index.tsx
