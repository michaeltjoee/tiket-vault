---
title: Remote Reviews
repo: TIX-REACT-REMOTE
kind: component
npm: "@tiket/passport-review-widget"
sources:
  - src/components/reviews
verified_at: 281778b
updated: 2026-10-16
status: current
tags: [repo/react-remote, kind/component]
---

# Remote Reviews
> tiket.com review widget (`ReviewWidget` from [[passport-review-widget]]) with its own data fetching, served over module federation.

## What it does
Exposed as `reviews`. This is the only remote that fetches backend data itself, on both server and client:
- **Server**: `getServerSideProps` calls `getReviews` with `cross-fetch` against `${MS_GATEWAY_BASE_URL}/gateway/tix-review-core/verticalReview/internalReview`, forwarding the request `cookie` header and `tiket-token-app` as `Authorization: Bearer`.
- **Client**: if no `reviewData` came from SSR and `skipGetReviewData` is false, it calls the same path relative to the page through [[react-common-fetch-client]].

Default query: `page 0, size 5, searchType INVENTORY, reviewSubmitColumn HELPFULNESS, sortDirection DESC`. Caller `searchParams` override it (only string or number values are kept). The backend response is mapped to the `ReviewData` shape (`filterReviewsResponseType`): dates are formatted with date-fns per locale, comments are joined, the primary image and the `type_of_traveler` answer are extracted. `DATA_NOT_EXIST` becomes empty data. Any other code throws, and the component shows a `ReloadComponent` with a 1 s debounced retry.

## Public API
`CommonComponentProps` plus `dataLayer` (`verticalName` is forwarded), `reviewData`, `searchParams`, `skipGetReviewData` (default `false`), `userData` (`accountId`, `username`).

Caching: `getSsrCacheConfig` disables both the render cache and the getServerSideProps cache. `getCriticalCssCacheKey` returns the constant `'reviews-critical-css'`, so PurgeCSS runs once per process.

## Usage
```tsx
import { RemoteReviews } from '@tiket/react-common-remote';
<RemoteReviews searchParams={searchParams} /> // Record<string,string>, merged over the default query
```
The wrapper defaults `isCritical={false}` and fills `userData`/`dataLayer` from `ReactRemoteContext`. There is also `ServerComponents/RemoteReviews` for the App Router.

## Depends on
[[passport-review-widget]], [[passport-icons]], [[passport-typography]], [[passport-utils]], [[react-common-fetch-client]], `cross-fetch`, `date-fns`.

## Used by
No direct `RemoteReviews` usage found in TIX-NEXT-PAYMENT-FE or TIX-FINTECH-NEXT-FE baselines.

## Gotchas
- `MS_GATEWAY_BASE_URL` is a **server runtime** env var (pod env), not a DefinePlugin build arg. See [[react-remote-workflows#Environment variables]].
- `bootstrap.ts` mounts with `reuseRoot: true`.

## Sources
- src/components/reviews/index.tsx
- src/components/reviews/getReviews.ts
- src/components/reviews/utils.ts
- src/components/reviews/reload-component/ReloadComponent.tsx
- TIX-REACT-COMMON packages/react-common-remote/src/RemoteReviews/index.tsx
