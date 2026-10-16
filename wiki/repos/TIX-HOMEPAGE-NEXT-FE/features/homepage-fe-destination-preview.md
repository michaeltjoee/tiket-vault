---
title: Destination preview (/destination-preview/[id])
repo: TIX-HOMEPAGE-NEXT-FE
kind: feature
sources:
  - pages/destination-preview
  - pages/destination/[slug]/Layout
  - pages/destination/[slug]/contexts/destination.tsx
  - lib/services/get-destination.ts
verified_at: 408983f6
updated: 2026-10-16
status: current
tags: [repo/homepage-fe, kind/feature]
---

# Destination preview (/destination-preview/[id])
> A CMS preview of an unpublished travel-guide page, by draft id. It renders the destination page's `Layout` against the `tix-home` admin preview endpoint.

## What it does
Lets content editors see a destination page before it's published. The UI is the [[homepage-fe-destination]] page. Only the data source changes.

## Routes & entry points
- `pages/destination-preview/[id]/index.page.tsx`. `getLayout` mounts the destination's `AuthProvider` → `DestinationIntlProvider` → `DestinationProvider` (`slug={id}`, `isPreview`, `recommendationVersion=""`) → `DimensionProvider`, and the page body is `dynamic(() => import('../../destination/[slug]/Layout'))`.
- `getServerSideProps` only returns `sessionData`, `deviceInfo`, `host`, `id`, `middlewareData` and `currency` (`getLanguageAndCurrency` from [[react-common-utilities]]). No A/B fetch, no remote SSR props, no prefetch.

## Data & services
- `getDestinationPreview` → `GET /tix-home/v2/admin/page-modules/dynamic-landing-preview?id={id}&platform={device}` with the same account/channel/loyalty headers as the live page. It is called from the browser by `DestinationProvider` when `isPreview` is true (the live `getDestinationClient` query is disabled).
- Both queries use the key `['destination', slug, locale]`. `slug` holds the preview id here.

## Key components
All from `pages/destination/[slug]/` (see [[homepage-fe-destination]]).

## Tracking
Same trackers as the live page. `Layout/trackers.ts` fires `pageVisit` and `AnalyticsEventHandler({ screenName: 'travelGuidePage' })` for previews too.

## Tests
`pages/destination-preview/__test__/index.page.spec.tsx`.

## Gotchas
- The shared `Layout` renders `SEOPageHead` without `robots`, so **the preview page has no `noindex` meta**. The explore and promo previews do set `noindex, nofollow`.
- No `getReactRemoteProps`: the remote header/footer only render on the client.
- `currency` comes from `getLanguageAndCurrency({ req })`, not from the middleware currency used elsewhere.
- `vitest.setup.ts`'s dynamic-route list doesn't include `/destination-preview/[id]`.

## Sources
- `pages/destination-preview/[id]/index.page.tsx`, `pages/destination-preview/__test__/index.page.spec.tsx`
- `pages/destination/[slug]/Layout/DestinationContent.tsx`, `pages/destination/[slug]/contexts/destination.tsx`
- `lib/services/get-destination.ts`
- `components/SEOPageHead/useSEOPageHead.ts`, `vitest.setup.ts`
