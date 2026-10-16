---
title: Explore / dynamic landing page (/explore/[slug])
repo: TIX-HOMEPAGE-NEXT-FE
kind: feature
sources:
  - pages/explore
  - components/DynamicLandingPageContent
  - components/DynamicLandingPageLoading
  - components/HeroBanner
  - components/SEOPageHead/customCanonicalLink.ts
  - lib/services/dynamic-landing-page.ts
  - lib/tracker/dynamic-landing-page.ts
  - context/DimensionContext
verified_at: 408983f6
updated: 2026-10-16
status: current
tags: [repo/homepage-fe, kind/feature]
---

# Explore / dynamic landing page (/explore/[slug])
> The CMS "dynamic landing page" (DLP, screen `dynamicPage`): a campaign page built from a `LANDING_PAGE` page-module set in `tix-home`, with a hero banner, anchor navigation, share and auto-scroll to a `#module` hash.

## What it does
Marketing builds a page in the CMS and gets `/explore/{slug}`. The page renders a hero banner with an optional menu of anchors, a share button, the page modules, a floating "next section" button, an auto-hiding mobile header and the remote footer. If the backend answers `DATA_NOT_EXIST`, the browser is sent to `/` (forward params kept). Other errors show a generic `ErrorView` with retry (reload).

## Routes & entry points
- `pages/explore/[slug]/index.page.tsx`. `getLayout` wraps the page in `DimensionProvider` (`context/DimensionContext`).
- `getServerSideProps`: in parallel, `getAbTestOnServer` and `getReactRemoteProps` with **three header aliases** (`header-desktop` default/sticky/`layoutVariantCode: '001'`, `header-mobile` with back icon, `header-mobile-transparent`) plus `footer`. `recommendationVersion` comes from `NEO_POLARIS_EXPERIMENT`. Data is prefetched into the dehydrated cache **only for bots**. Returns `abTestOnServerResponse` and `dataLayer: { screenName: 'dynamicPage', screenOwner: 'discovery' }`.
- The client page picks a header alias by platform and renders `components/Header` with `skipRemote={device.isWebView}`. It mounts `RemoteGlobalPopup` and `RemoteGoogleOneTap` with `next/dynamic` and `ssr: false`.
- `_app` sets a **custom canonical** for DLP pages: when `pageProps.dataLayer.screenName === 'dynamicPage'`, the path (minus locale prefix) is looked up in `components/SEOPageHead/customCanonicalLink.ts`, which maps a few `/explore/apartemen-*` slugs to `/homes/apartment/brand/...` URLs.

## Data & services
- `getDynamicLandingPageData` (server, `ctx`) / `getDynamicLandingPageDataClient` (browser): `GET /tix-home/v2/page-modules-with-meta?pageModuleCode={slug}&pageModuleType=LANDING_PAGE`, plus `processType=ASYNC` in webviews, `platform` (android/ios cookie), `recommendationVersion` and UTM params. Headers are the same as destination (`X-Channel-Id` via `getXChannelId`, `user-agent` outside webviews).
- React Query key `['dynamicLandingPageData', slug, locale]`, with no refetch on mount, reconnect or focus.
- `DynamicLandingPageContent` (shared with [[homepage-fe-explore-preview]]) renders `PageModule` through **`next/dynamic`** (`import('@tiket/passport-page-module').then(m => m.PageModule)`). It passes `criticalImageModuleIndexes` `'0,1'` (mobile) / `'0,1,2'` (desktop), `additionalGtmVariables: { slug }`, the usual image renderers, and `forceRender` only when the URL has a scroll target hash. See [[passport-page-module]].
- `useAutoScrollToModule`: after a successful load, smooth-scrolls to the module whose anchor id equals the URL hash (page-module ids are slugified titles). It waits up to 5 s and for 300 ms of DOM quiet, because async modules change height.
- `useAnchor`: hero-banner menu anchors and floating-button state. `useHideRemoteHeaderTitle`: hides the remote header title over a transparent hero.
- Share: in a supported app webview (≥ `SUPPORTED_VERSIONS.SOCIAL_SHARE` `5.14.0`) it navigates to the native sharing URL. Otherwise it opens `ResponsiveSocialShare` with per-channel UTM (`utm_external=organic`, `utm_medium=dlp;share_button;{slug}`).
- Copy: `components/DynamicLandingPageContent/i18n/` plus app-level `@lib/i18n`.

## Key components
`components/DynamicLandingPageContent` (+ hooks), `components/DynamicLandingPageLoading`, `components/HeroBanner` (`HeroBannerContent`, `useNavigation`, colour utils), `components/Header`, `components/WebViewWrapper`, `components/PageModuleImageRenderer`, `components/ResponsiveSocialShare`, `components/SEOPageHead`. Passport: `AutoHidingHeader`, `Container`, `Divider`, [[passport-header]] `HeaderMobile`, [[passport-floating-button]], [[passport-error-view]]. See [[homepage-fe-components]].

## Tracking
`lib/tracker/dynamic-landing-page.ts` (`eventLabel: 'dynamicPage'`): `pageVisit` (with `customDimension1: 'heroBanner'` when there is one), `share`, `floatingButton`. Also `AnalyticsEventHandler({ screenName: 'dynamicPage' })`. PageModule tracks with `screenName: 'dynamicPage'`, `screenOwner: 'discovery'`.

## Tests
`pages/explore/[slug]/__tests__/index.spec.tsx`, `getSsrProps.spec.tsx`, `components/DynamicLandingPageContent/DynamicLandingPageContent.spec.tsx`, `hooks/__tests__/useAutoScrollToModule.spec.tsx`, `components/DynamicLandingPageLoading/*.spec.tsx`, `components/HeroBanner/*.spec.tsx`.

## Gotchas
- This is the one host that already loads `PageModule` lazily, but as a single `next/dynamic` of the whole package root, not a per-module registry. The per-module `next/dynamic` registry is the [[page-module-next-poc]], branch-only.
- The `DATA_NOT_EXIST` redirect only happens in the browser. On the server render it falls through to the error/content branch.
- `RemoteGoogleOneTap` gets `isNewURLStructure={false}` hard-coded (same as destination).
- `customCanonicalLink.ts` contains test and example entries (`/explore/test-slug`, `/explore/thailand` "example testing on gatotkaca") next to real mappings.

## Sources
- `pages/explore/[slug]/index.page.tsx`, `pages/explore/[slug]/__tests__/*`
- `components/DynamicLandingPageContent/DynamicLandingPageContent.tsx`, `hooks/useAnchor.tsx`, `hooks/useAutoScrollToModule.ts`, `hooks/useHideRemoteHeaderTitle.tsx`, `i18n/*`
- `components/DynamicLandingPageLoading/*`, `components/HeroBanner/*`, `components/Header/index.tsx`
- `components/SEOPageHead/customCanonicalLink.ts`, `pages/_app.page.tsx`
- `lib/services/dynamic-landing-page.ts`, `lib/tracker/dynamic-landing-page.ts`, `lib/utils/webview.ts`, `context/DimensionContext/index.tsx`
