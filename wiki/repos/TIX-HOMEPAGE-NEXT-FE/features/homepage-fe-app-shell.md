---
title: App shell (_app, _document, _error, 404, _offline)
repo: TIX-HOMEPAGE-NEXT-FE
kind: feature
sources:
  - pages/_app.page.tsx
  - pages/_document.page.tsx
  - pages/_error.page.tsx
  - pages/404.page.tsx
  - pages/_offline.page.tsx
  - pages/_offline.module.scss
  - pages/index.page.tsx
  - pages/index.module.scss
  - pages/script.tsx
  - pages/jsonLd
  - pages/types.ts
  - pages/variables.css
  - pages/__tests__
  - components/providers
  - components/RemoteConfigScript
  - components/SEOPageHead/customCanonicalLink.ts
  - lib/helpers/offline.ts
verified_at: 408983f6
updated: 2026-10-16
status: current
tags: [repo/homepage-fe, kind/feature]
---

# App shell (_app, _document, _error, 404, _offline)
> The Pages Router frame around every route: the provider tree, fonts, meta and canonical, site-wide JSON-LD, GTM bootstrap, remote config and scripts, the error and 404 pages, and the PWA offline fallback.

## What it does
- **`_app.page.tsx`**: wraps each page in `AppProvider` ([[homepage-fe-architecture]] lists the provider order) with `localeCountry` (`getLocaleAndCountry(router.locale)`), the app i18n dictionary, and the `pageProps` passthroughs `middlewareData`, `remoteModuleSsrProps`, `remoteModuleVersion`, `dehydratedState`, `device`, `dataLayer`, `abTestOnServerResponse`. It also renders:
  - the viewport meta and inline `@font-face` rules for **TiketOdysseyText** (6 weights/styles from `storage.tiket.com`), plus Passport `base.css` and `font-loader.css` from [[passport-design-tokens]], and `pages/variables.css` (extra spacing and z-index tokens Passport doesn't ship, see [[design-tokens]]);
  - `TiketMetaTag` from `@tiket/next`, with a custom canonical for DLP pages ([[homepage-fe-explore]]);
  - `GlobalJsonLd` and the GTM `Script`;
  - `RemoteScripts` ([[react-remote-scripts]]) after the page;
  - `getLayout` support.
  With `NEXT_PUBLIC_API_MOCKING=enabled` it requires `@lib/mocks/msw-init`.
- **`_document.page.tsx`**: `RemoteConfigScript` **must stay first in `<head>`**, before any `remoteEntry.js`, because it sets `window.__TIX_REMOTE_CONFIG__` (`basePrefixForApp`, `postLogPath`) for [[react-common-fetch-client]] inside the remotes. Then: preconnect to `s-light.tiket.photos`, the asset prefix, `storage.tiket.com`, `NEXT_PUBLIC_REACT_REMOTE_URL` and GTM; dns-prefetch Facebook and TikTok; preload `gtm.js` and the Regular/Bold font files.
- **`script.tsx`** (not a route: no `.page`): injects the GTM container snippet (`NEXT_PUBLIC_GTM_ID`) and sets `window.ANALYTICS_VERSION = "2.1"`, `window.gtm.trackingId`, `window.gtm.vertical = 'home'`. The comment says `lazyOnload` is avoided because it didn't load in the PG environment. See [[gtm-datalayer-tracking]].
- **`jsonLd/`**: `GlobalJsonLd` = `OrganizationWebSiteJsonLd` (Organization/TravelAgency + WebSite with `SearchAction` targets that use the current `?search=` value) + `SoftwareApplicationJsonLd` (Android/iOS app list with ratings). Constants live in `lib/constants/tiketEntity`, serialised by `lib/utils/jsonLd`. On every page.
- **`_error.page.tsx`**: logs through `createLogger` from `@tiket/next/logger`: `server-error-boundary` in `getInitialProps` with the request URL, and `client-error-boundary` on mount with `window.location.href`. Both use `constructLoggerDataForErrorPage` with screen name `errorPage`. Renders [[passport-error-view]] `variant="server"`, and the button reloads.
- **`404.page.tsx`**: `ErrorPageContent type="notFound"` with `tds_si_no_result` ([[passport-assets]]). The button goes to the origin.
- **`_offline.page.tsx`**: the `next-pwa` offline fallback page for navigations (see the service worker in [[homepage-fe-architecture]]). Its language comes from the `userlang` cookie (`lib/helpers/offline.ts`, default `en`), because no i18n context is available. Back calls `window.native.backOrClose()` (Android JSI, see [[webview-jsi-bridge]]) or `history.back()`. Reload reloads, and on `/yourorder/detail` it also closes the webview, because a reload there would open a new webview instance.
- **`index.page.tsx`** is the home route, documented in [[homepage-fe-home]]. `index.module.scss` holds its layout styles and `types.ts` its response types (`HomepageLandingData`).

## Routes & entry points
`_app`, `_document`, `_error` (500 and unhandled errors), `/404`, `/_offline` (served by the SW fallback), `/` (home). `components/ErrorBoundary` (a class component inside `AppProvider`) catches render errors in the client tree, logs them with `createLogger({ name: 'error-boundary' })`, and shows a Passport `ErrorView`.

## Data & services
None of its own. `_app` only forwards SSR props. `AppProvider` builds the React Query client (no refetch on mount, focus or reconnect) and `customFetch = coreFetcher({ locale })` for `PassportProvider` ([[passport-custom-fetch]]).

## Key components
`components/providers/AppProvider.tsx`, `AppContext.ts`, `components/RemoteConfigScript`, `components/ErrorBoundary`, `components/ErrorPageContent`, `components/Image` (`_app` has a bare `import '@components/Image'`, but the module has no side effects or styles, so the import only puts it in the `_app` chunk), `components/SEOPageHead/customCanonicalLink.ts`. See [[homepage-fe-components]].

## Tracking
- GTM bootstrap (`script.tsx`).
- `usePageVisitAnalytics(pageVisitAnalyticsConfig)` in `AppProvider` maps `/core`, `/localization`, `/metadata` paths to page-visit screens with vertical `core`.
- `pageProps.dataLayer` goes to `ReactRemoteProvider`, so remote widgets report the host screen.

## Tests
`pages/__tests__/`: `_document.spec.tsx`, `__error.spec.tsx`, `404.spec.tsx`, `_offline.spec.tsx`, `script.spec.tsx` (+ snapshot), plus `index.spec.tsx` and `getSsrProps.spec.tsx` for home. `jsonLd/*.spec.tsx`. `components/providers/AppProvider.spec.tsx`, `AppContext.spec.ts`, `analytics-config.spec.ts`. `_app.page.tsx` is excluded from coverage and Sonar.

## Gotchas
- `_document` reads `NEXT_PUBLIC_REACT_REMOTE_URL` and `NEXT_PUBLIC_ASSET_PREFIX` at render time for preconnects. If they are unset, the `href`s become `"undefined/"`.
- `AppProvider` calls `setupClientGlobals(locale)` (dayjs locale) during render, not in an effect, so it runs on the server too.
- `AppProvider` still polyfills `Promise.allSettled` on the client in an effect. The `browserslist` (Chrome ≥ 91, Safari ≥ 15) already has it natively.
- The custom canonical logic in `_app` lowercases the path and strips query/hash, but only for DLP screen names that have a mapping.

## Sources
- `pages/_app.page.tsx`, `pages/_document.page.tsx`, `pages/_error.page.tsx`, `pages/404.page.tsx`, `pages/_offline.page.tsx`, `pages/_offline.module.scss`
- `pages/index.page.tsx`, `pages/index.module.scss`, `pages/types.ts`, `pages/variables.css`, `pages/script.tsx`
- `pages/jsonLd/GlobalJsonLd.tsx`, `OrganizationWebSiteJsonLd.tsx`, `SoftwareApplicationJsonLd.tsx` (+ specs)
- `pages/__tests__/*`
- `components/providers/AppProvider.tsx`, `components/RemoteConfigScript/RemoteConfigScript.tsx`, `components/ErrorBoundary/ErrorBoundary.tsx`, `components/ErrorPageContent/index.tsx`, `components/SEOPageHead/customCanonicalLink.ts`
- `lib/helpers/offline.ts`, `lib/utils/jsonLd.ts`, `lib/constants/tiketEntity.ts`, `next.config.ts` (next-pwa), `package.json` (browserslist)
