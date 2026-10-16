---
title: Shared components (components/)
repo: TIX-GROWTH-NEXT-FE
kind: feature
sources:
  - components
verified_at: d4162e3
updated: 2026-10-16
status: current
tags: [repo/growth-fe, kind/feature]
---

# Shared components (components/)
> The 10 cross-feature folders under `components/`: the provider tree, GTM bootstrap, error boundary and 404 view, a `next/image` wrapper with Lightroom helpers, two remote-header layouts, a loader, a sanitised rich-text renderer and the SEO head. Feature-only UI lives in each `pages/<feature>/` (`_blocks`, `blocks`, `components`).

## What it does
`components/` holds what the app shell needs and what more than one route uses. Most of it serves the shell, stories ([[growth-fe-stories]]), sitemap ([[growth-fe-sitemap]]) and the affiliate pages ([[growth-fe-affiliate]], [[growth-fe-blibli-affiliate]]). Metasearch ([[growth-fe-metasearch]]) uses only `Image`.

## Routes & entry points
None. They are imported via `@/components/*` (`tsconfig` / Jest map `@/` to the repo root).

## Data & services
Only `providers/AppProvider` touches services: it builds the React Query client and reads `middlewareData`. See [[growth-fe-app-shell]] for the provider order.

## Key components
| Folder | Purpose | Used by | Notable deps |
|---|---|---|---|
| `providers` | `AppProvider` (provider tree, React Query client, `setupClientGlobals`, `usePageVisitAnalytics`), `pageVisitAnalyticsConfig`, `LoadingContext` | `pages/_app`, `app/layout` ([[growth-fe-app-shell]]) | [[passport-umbrella\|passport]] `PassportProvider`/`SnackbarProvider`/`ForwardParamsProvider`, [[react-common-remote]] `ReactRemoteProvider`, `@tiket/next/client`, `@tanstack/react-query` |
| `CustomScripts` | `GTMScripts`: GTM container snippet plus `window.gtm` attributes (only if `NEXT_PUBLIC_UA_TRACKING_ID` is set) | `_app` | `next/script`, `next/head` ([[gtm-datalayer-tracking]]) |
| `ErrorBoundary` | Class error boundary: logs with `createLogger({ name: 'error-boundary' })` + `standardizedLogData`, shows `ErrorView variant="generic"` with a reload button | `_app` (via `next/dynamic`, outside `AppProvider`) | [[passport-error-view]], `@tiket/next` |
| `NotFound` | Passport `Figure` with the `tds_si_no_result` illustration and an en/id title and description (`translation.ts`), keyed on `usePassport().locale` | `app/not-found` | passport `Figure`, [[passport-assets]], `components/Image` |
| `Image` | `next/image` wrapper: Lightroom loader for `s-light`/`s-gk`/`s-pg.tiket.photos`, identity loader otherwise, `fallbackSrc` on error (default 1×1 white PNG), blur placeholder. `helper.ts` adds `getOptimalLightroomImageUrl`, `getOptimizeLightroomImageUrl` (desktop `rsfit19201280gsm`, else `platform-ios-mid`), `getLightroomTinyImageUrl` (`platform-mweb-low`), `generateImagePresets`, `getLCPImagePreloadUrlServerSide` (builds a `Link: rel=preload` header value with `imagesrcset`) | stories (landing `_blocks`, category `ArticleList`, tags `ArticleCard`, detail `Header`, `ImageBanner`, `ArticleContent`, `FlightCard`, `HotelCard`, `SocialMediaSection`), blibli-affiliate (`HeaderPage`, `InformationSection`), metasearch checkout, `NotFound` | `next/image` (see [[passport-image]] for the Passport equivalent) |
| `Layout/MainLayout` | [[react-remote-header]] (`activeMenu="growth"`, `layoutVariantCode` default `001`, `rightIcons`, `showBackIcon`, `hideBottom`) + optional [[react-remote-footer]] around the page | `pages/stories/layout.tsx` (all stories routes), blibli-affiliate | [[react-common-remote]] `RemoteHeader`/`RemoteFooter`, [[passport-design-tokens]] breakpoint mixin |
| `RemoteHeader` | Bare `RemoteHeader isMultiCurrencyAvailable` in a wrapper that reserves 112 px on desktop | sitemap | [[react-common-remote]] |
| `Loading` | Centred Passport `LoadingIndicator` | affiliate cobrand `/affiliate/c/[slug]` | passport |
| `RichText` | Renders HTML from CMS through `DOMPurify.sanitize` (`isomorphic-dompurify`) in a Passport `Text as="div"` with heavy `!important` WYSIWYG styles. Calls `onLoad` once on mount | affiliate cobrand `Terms` | passport `Text`, [[passport-typography]] types, `isomorphic-dompurify` |
| `SEOPageHead` | `next/head` with `<title>`, description, Open Graph (incl. fixed Jakarta geo/contact tags), Twitter, Facebook app IDs, app links, `manifest.json` (non-dev only), Android/iOS alternates. `useSEOData` falls back to `i18n('meta.title')` / `meta.description` | stories (landing, category, tags, detail), sitemap, blibli-affiliate | `next/router`, `lib/hooks/useHost`, `lib/i18n` |

## Tracking
Only `CustomScripts/GTMScripts` (GTM bootstrap) and `AppProvider` (`usePageVisitAnalytics`, `ReactRemoteProvider` `dataLayer.screenName: 'affiliate'`). Feature trackers live in `lib/gtm` and in each feature folder.

## Tests
Specs: `providers/__tests__/AppProvider.spec.tsx`, `providers/analytics-config.spec.ts`, `CustomScripts/GTMScripts.spec.tsx`, `Image/__test__/Image.spec.tsx` + `helper.spec.ts`, `RemoteHeader/__tests__/MainRemoteHeader.spec.tsx`. `ErrorBoundary`, `NotFound`, `Layout/MainLayout`, `Loading`, `RichText` and `SEOPageHead` have no spec of their own. Feature specs mock `@/components/Image`, `SEOPageHead`, `Layout/MainLayout`, `RemoteHeader` and `Loading`.

## Gotchas
- **`Image` defaults to `unoptimized = true`.** With `unoptimized`, `next/image` skips the loader, so the Lightroom preset swap only happens when a caller passes `unoptimized={false}` (stories landing `Header`, blibli `HeaderPage`; the Image spec says the same). Story detail `Header` and `ImageBanner` pass `unoptimized` and pick the preset themselves with `getOptimizeLightroomImageUrl`. The `fallbackPng` prop is typed and destructured but never used.
- `Image/constants.ts` says "sync with next.config.js", but `next.config.js` now takes `TIKET_LIGHTROOM_HOSTNAMES` from `@tiket/passport-assets/config.cjs`. The local list (`s-light`, `s-gk`, `s-pg`) can drift from it.
- `NotFound` passes legacy `next/image` props (`layout="responsive"`, `objectFit="contain"`) through `Image`.
- `MainLayout`: `showHeaderInMobile={false}` hides the header on **all** viewports (the name is misleading), and `isDesktop` is accepted but unused. `MainLayout` reserves 56 px min-height plus the safe-area top inset for the header. `RemoteHeader` reserves nothing on mobile. Picking one or the other changes layout shift.
- `SEOPageHead` emits `og:title` and `og:image` twice under different keys. The two `og:image` values can differ (`image || https://www.tiket.com/Icon-192.png` vs `image ?? https://{hostPrefix}tiket.com/Icon-192.png`). It also emits Android/iOS `alternate` links (`m.tiket.com`) on top of the ones `TiketMetaTag` in `_app` emits (`www.tiket.com`). The `host`, `withAltMedia` and `source` props are unused, and `useHost` ignores `device`.
- `LoadingContext` is provided with a constant `{ isLoading: false, setIsLoading: noop }`, and nothing on main reads it.
- `components/Layout/Layout.module.scss` (`.layout_pwa`, 480 px column) is not imported anywhere on main (dead CSS; the PWA-width column suggests it predates the affiliate migration from TIX-AFFILIATE-PUBLIC-FE).
- `RichText` sanitises on every render. `isomorphic-dompurify` pulls `jsdom` on the server, so it also runs in SSR.

## Sources
- `components/providers/AppProvider.tsx`, `components/providers/__tests__/AppProvider.spec.tsx`, `components/providers/analytics-config.spec.ts`
- `components/CustomScripts/GTMScripts.tsx` (+ spec), `components/ErrorBoundary/index.tsx`
- `components/NotFound/index.tsx`, `translation.ts`, `index.module.scss`
- `components/Image/Image.tsx`, `constants.ts`, `helper.ts`, `index.ts`, `__test__/*`
- `components/Layout/Layout.module.scss`, `components/Layout/MainLayout/index.tsx`, `MainLayout.module.scss`
- `components/RemoteHeader/index.tsx`, `RemoteHeader.module.scss`, `__tests__/MainRemoteHeader.spec.tsx`
- `components/Loading/*`, `components/RichText/*`, `components/SEOPageHead/index.tsx`, `types.ts`, `useSEOData.ts`
- `lib/hooks/useHost.ts`, `lib/config/appDefaults.ts`, `next.config.js`
- consumers: `git grep '@/components/' origin/main -- pages app`
