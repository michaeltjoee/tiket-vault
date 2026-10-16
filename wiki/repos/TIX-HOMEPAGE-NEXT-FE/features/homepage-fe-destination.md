---
title: Destination / travel guide (/destination/[slug])
repo: TIX-HOMEPAGE-NEXT-FE
kind: feature
sources:
  - pages/destination
  - lib/services/get-destination.ts
  - lib/services/utils.ts
  - components/DestinationPageLoading
  - components/Header
verified_at: 408983f6
updated: 2026-10-16
status: current
tags: [repo/homepage-fe, kind/feature]
---

# Destination / travel guide (/destination/[slug])
> A CMS-built travel-guide page for a destination: image slider, title, tags, description, a page-module body with a "next section" floating button, travel tips and other destinations. Content is `tix-home` page modules of type `TRAVEL_GUIDE`.

## What it does
The page shows a hero image slider (manual or auto scroll, from `pageMetaData.images`), title and subtitle, tags, description, share button, the page-module list, travel tips and "other destinations". A remote footer closes the page. On desktop it has the remote header. On mobile it has a custom header with a webview-aware back button. `/destination` itself (no slug) is a temporary redirect to `/`.

## Routes & entry points
- `pages/destination/[slug]/index.page.tsx`. It uses `getLayout` to wrap the page in `AuthProvider` → `DestinationIntlProvider` → `DestinationProvider` → `DimensionProvider`, and renders `Layout` (dynamic) plus `RemoteGoogleOneTap` (`screenName: 'travelGuidePage'`).
- `getServerSideProps`: `getAbTestOnServer` + `getReactRemoteProps(getDestinationRemoteModules(...))` (desktop `header`, always `footer`). `recommendationVersion` is read from the `NEO_POLARIS_EXPERIMENT` payload. Content is prefetched (`queryClient.fetchQuery`) **only for bots**.
- `pages/destination/index.page.tsx`: `redirect: { destination: '/', permanent: false }`.
- `dataLayer`: `{ screenName: 'travelGuidePage', screenOwner: 'discovery' }`.

## Data & services
- `getDestination` (server) / `getDestinationClient` (browser): `GET /tix-home/v2/page-modules-with-meta?pageModuleCode={slug}&pageModuleType=TRAVEL_GUIDE`, plus `processType=ASYNC` in webviews, `platform` (android/ios from the `device_type` cookie), `recommendationVersion` and UTM params. Headers include `X-Channel-Id` from `getXChannelId`: the `device_type` cookie in webviews, else `MOBILE_WEB`/`WEB`. A `user-agent` header is forwarded outside webviews.
- `DestinationProvider` (`contexts/destination.tsx`): one `useQuery` under key `['destination', slug, locale]`. It normalises `pageMetaData` (title, images, scrollType, tags, metaContent, travelTip, otherDestination) and `modules`. Empty CMS rows are filtered out: other-destination items need `imageUrl` or `name`, because the BE always returns one object with a prefilled `clickUrl`.
- `DimensionProvider` (`contexts/dimension.tsx`) supplies `isMobile` from viewport width.
- Page-module body: `RenderPageModule` normalises modules with `normalizeTabbingData` and drives a [[passport-floating-button]] "next section / back to top" button. It uses page-module navigation helpers (`getNextAnchoredModule`, `getCurrentParentModule`, `getSectionId`…) and IntersectionObservers on the module container and footer. It passes the same image renderers and `AuthContext` values as home (see [[homepage-fe-architecture]]).
- Copy in `pages/destination/[slug]/i18n/` (own provider, `useI18n` from `../../i18n/client`).

## Key components
`pages/destination/[slug]/components/`: `Slider` (+ `useSlider`, `useMove`), `Title`, `Tags`, `Description`, `SocialShare` (lazy `ResponsiveSocialShare` + `useShareUrl`), `RenderPageModule`, `TravelTips` (`TravelTipsCard`), `OtherDestination`, `HeaderDesktop` (remote header), `HeaderMobile` (+ `webview.ts`), `Footer` (remote footer), `ErrorViewPage` (passport-error-view), `DestinationArticleJsonLd` (Article JSON-LD).
Shared: `DestinationPageLoading`, `SEOPageHead`, `WebViewWrapper`, `PageModuleImageRenderer`, `ResponsiveSocialShare`, `Image` ([[homepage-fe-components]]).

## Tracking
`Layout/trackers.ts` sends a `pageVisit` with title, slug, scroll type and image count once loading ends, plus `AnalyticsEventHandler({ screenName: 'travelGuidePage' })`. Component trackers: `pageContent` (slider next/prev, description), `share`, `travelTips`, `otherDestination`, `floatingButton`. `libs/gtm.ts` is the helper. See [[gtm-datalayer-tracking]].

## Tests
27 specs under `pages/destination/` (components, contexts, hooks, the page and `getSsrProps`).

## Gotchas
- Humans always get a client fetch. The server prefetch is bot-only, like on home.
- `getServerSideProps` doesn't return `abTestOnServerResponse`, so `PassportProvider`/`ReactRemoteProvider` get no server variants on this route (only `recommendationVersion` is used).
- `RemoteGoogleOneTap` is imported straight from [[react-common-remote]] with `isNewURLStructure={false}` hard-coded, unlike home's wrapper `components/RemoteGoogleOneTap`, which reads it from middleware data.
- The preview route reuses this folder's `Layout`, contexts and i18n ([[homepage-fe-destination-preview]]), so changes here affect both.

## Sources
- `pages/destination/index.page.tsx`, `pages/destination/[slug]/index.page.tsx`
- `pages/destination/[slug]/Layout/*`, `components/**`, `contexts/*`, `hooks/useResizeObserver.ts`, `i18n/*`, `libs/gtm.ts`, `types/*`
- `pages/destination/utils/getDestinationRemoteModules.ts`
- `pages/destination/__test__/*`, `pages/destination/[slug]/__tests__/*`
- `lib/services/get-destination.ts`, `lib/services/utils.ts`, `lib/utils/webview.ts`
- `components/DestinationPageLoading/DestinationPageLoading.tsx`
