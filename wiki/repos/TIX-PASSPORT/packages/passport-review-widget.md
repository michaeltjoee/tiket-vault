---
title: ReviewWidget
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-review-widget"
umbrella: true
sources:
  - packages/review-widget/src
  - packages/review-widget/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# ReviewWidget
> Product review section: rating summary, a carousel of user review cards, a review-detail popup with images, and "helpful" likes. Guests get a login popup, and WebView users get an app-download popup.

Part of [[passport-packages]].

## What it does
It is presentational for the review list: the host fetches `reviewData` (`summaryReview` plus `userReviews`) and passes it in. The widget itself only calls `POST /ms-gateway/tix-review-core/review/addHelpfulness` to like a review, with headers from `services/request-headers.ts` and `appsToken` in WebViews. A like from a guest opens `PopupLogin`. `DownloadAppPopup` is lazy-loaded. It shows an empty state (`NoReview`) and GTM tracking (`utils/Tracker.ts`). `reviewType` selects tiket, TripAdvisor or all sources.

## Public API
`ReviewWidget`; types `ReviewWidgetProps`, `ReviewData`, `ReviewDataType`, `SearchParams`. Also in [[passport-umbrella]].

| Prop | Notes |
|---|---|
| `reviewType` | `'tiket' \| 'tripadvisor' \| 'all'` |
| `reviewData` | `{ summaryReview: { ratingSummary[], impression[], totalReview[] }, userReviews[] }` |
| `accountId`, `userName` | `null` = guest |
| `verticalName`, `searchParams` | for tracking and links |
| `overrideTitle`, `overrideReviewSubtitle` | e.g. "From 1,234 verified reviews" |
| `appsToken` | native token in WebViews |

## Usage
From TIX-REACT-REMOTE `src/components/reviews/index.tsx`:
```tsx
const data = await getReviews({ lang, searchParams }); // tix-review-core/verticalReview/internalReview
<ReviewWidget reviewType="all" reviewData={data} accountId={accountId} userName={name}
  verticalName="ttd" searchParams={searchParams} appsToken={appsTokenClient()} />
```

## Depends on
[[passport-bottom-sheet]], [[passport-modal]], [[passport-dialog]], [[passport-card]], [[passport-container]], [[passport-image]], [[passport-button]], [[passport-page-module-shared]] (carousel), [[passport-typography]], [[passport-utils]], icons, `@tiket/react-common-utilities`. External: `keen-slider`, `uuid`.

## Used by
- TIX-REACT-REMOTE (`12.4.2`): the federated `reviews` remote [[react-remote-reviews]] (`src/components/reviews/index.tsx`, `getReviews.ts`, `utils.ts`).
- TIX-REACT-COMMON: `packages/react-common-remote/src/RemoteReviews/Fallback.tsx` renders `ReviewWidget` from `@tiket/passport` as the fallback when the remote fails to load. See [[react-common-remote]] and [[module-federation]].
- TIX-FINTECH-NEXT-FE lists it in `package.json` (`^12.4.3`), but there are no source imports on baseline.

## Gotchas
- The like request uses a relative `/ms-gateway/...` URL and global `fetch`, so it only works on tiket.com origins or behind a proxy.

## Sources
- packages/review-widget/src/ReviewWidget.tsx
- packages/review-widget/src/services/like-review-comment.ts
- packages/review-widget/package.json
- TIX-REACT-REMOTE src/components/reviews/ (origin/main)
- TIX-REACT-COMMON packages/react-common-remote/src/RemoteReviews/Fallback.tsx (origin/master)
