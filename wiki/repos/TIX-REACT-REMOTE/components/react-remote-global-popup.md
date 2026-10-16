---
title: Remote GlobalPopup
repo: TIX-REACT-REMOTE
kind: component
npm: "@tiket/passport-global-popup"
sources:
  - src/components/global-popup
  - src/utils/mount.tsx
verified_at: 281778b
updated: 2026-10-16
status: current
tags: [repo/react-remote, kind/component]
---

# Remote GlobalPopup
> Federated wrapper around `GlobalPopupWithFeatureFlag` from [[passport-global-popup]].

## What it does
Exposed as `global-popup`. Renders the feature-flagged global popup inside `PassportWrapper`, forwarding `abTestOnServerResponse` so the flag can be read from server A/B data. It is mounted with `reuseRoot: true`, as are [[react-remote-wishlist-module]] and [[react-remote-reviews]]: repeated `mount()` calls on the same element re-render the existing React root instead of creating a new one.

## Public API
`GlobalPopupProps & CommonComponentProps`. Passed through: `screenName`, `screenOwner`, `clientSideServiceEndpoint`, `globalPopupContentData`, `platform`. `lang` (default `'id'`) is passed as `locale`. `country` defaults to `'id'`.

## Usage
```tsx
import { RemoteGlobalPopup } from '@tiket/react-common-remote';
<RemoteGlobalPopup screenName="paymentComplete" screenOwner="payment" />
```
The consumer wrapper merges `abTestOnServerResponse` from `ReactRemoteContext`.

## Depends on
[[passport-global-popup]] (not in `package.json`; it resolves as a transitive dependency of `@tiket/passport` because pnpm uses `nodeLinker: hoisted`), [[react-remote-wrapper]].

## Used by
- TIX-NEXT-PAYMENT-FE `components/providers/AppProvider.tsx`, `pages/payment/[type]/complete/components/SuccessV2/SuccessV2.tsx`, `app/payment-link/[method]/complete/containers/PaymentLinkCompleteContainer.tsx`.

## Gotchas
- `reuseRoot` exists because a remount fired the popup's side effects twice (comment in `src/utils/mount.tsx`). Do not remove it.
- Types are imported from `@tiket/passport-global-popup/src/types`, a deep import that breaks if Passport moves the file.

## Sources
- src/components/global-popup/index.tsx
- src/components/global-popup/bootstrap.ts
- src/utils/mount.tsx
- TIX-REACT-COMMON packages/react-common-remote/src/RemoteGlobalPopup/index.tsx
