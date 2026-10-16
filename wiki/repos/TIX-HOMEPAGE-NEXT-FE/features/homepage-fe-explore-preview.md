---
title: Explore preview (/explore-preview/[id])
repo: TIX-HOMEPAGE-NEXT-FE
kind: feature
sources:
  - pages/explore-preview
  - components/DynamicLandingPageContent
  - lib/services/dynamic-landing-page.ts
  - lib/config.ts
verified_at: 408983f6
updated: 2026-10-16
status: current
tags: [repo/homepage-fe, kind/feature]
---

# Explore preview (/explore-preview/[id])
> A CMS preview of a dynamic landing page by draft id. It renders the same `DynamicLandingPageContent` as `/explore` from the `tix-home` admin preview endpoint, with `noindex`.

## What it does
Content editors open a DLP draft before publishing. The UI is the [[homepage-fe-explore]] content component. The differences are the data source, no SSR of the remote header/footer, and a `noindex, nofollow` head.

## Routes & entry points
- `pages/explore-preview/[id]/index.page.tsx`. `getLayout` wraps the page in `DimensionProvider`.
- `getServerSideProps` returns `currency`, `device`, `sessionData`, `userAgent`, `id`, `middlewareData`. It deliberately skips `getReactRemoteProps` ("Skip fetch remote when it is preview page"), the A/B fetch and any prefetch. The `id` default is `'123'` if the query is missing.
- `DynamicLandingPageContent` detects preview by `router.pathname.includes(PAGE_ROUTES.SLUG_PREVIEW)` (`/explore-preview`, `lib/config.ts`). It then renders a plain `<Head>` with `robots: noindex, nofollow` instead of `SEOPageHead`.

## Data & services
- `getDynamicLandingPagePreviewData` → `GET /tix-home/v2/admin/page-modules/dynamic-landing-preview?id={id}&platform={device}`, called from the browser. Headers: `X-Account-Id`, `X-Channel-Id` (`MOBILE_WEB` or the device), `X-Loyalty-Level`, `X-Username`.
- React Query key `['dlp-preview', router.query.id]`.
- `recommendationVersion` is passed as `""`.

## Key components
`components/DynamicLandingPageContent` and `@tiket/passport` `ErrorView` ([[homepage-fe-components]]).

## Tracking
Inherits the DLP trackers (`pageVisit`, `share`, `floatingButton`) and `AnalyticsEventHandler({ screenName: 'dynamicPage' })`. `getServerSideProps` returns no `dataLayer`.

## Tests
`pages/explore-preview/[id]/__tests__/index.spec.tsx`, `getSsrProps.spec.tsx`.

## Gotchas
- While loading, the page renders `null` (no skeleton, no header), unlike `/explore`.
- `host` and `isWebView` are not passed to `DynamicLandingPageContent`, so inside the app the share button opens the in-page share sheet instead of the native one.
- `getDynamicLandingPagePreviewData` uses `window.navigator.userAgent` when `userAgent` is empty, so it is browser-only.

## Sources
- `pages/explore-preview/[id]/index.page.tsx`, `pages/explore-preview/[id]/__tests__/*`
- `components/DynamicLandingPageContent/DynamicLandingPageContent.tsx`
- `lib/services/dynamic-landing-page.ts`, `lib/config.ts`
