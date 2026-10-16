---
title: App shell (_app, _document, _error, App Router layout, globals, MSW)
repo: TIX-GROWTH-NEXT-FE
kind: feature
sources:
  - pages/_app.page.tsx
  - pages/_document.page.tsx
  - pages/_error.page.tsx
  - pages/__tests__
  - app/layout.page.tsx
  - app/not-found.page.tsx
  - app/setup-react-cache-workaround.ts
  - app/globals.scss
  - components/providers
  - components/CustomScripts
  - lib/config/setupClientGlobals.ts
  - lib/config/setupServerGlobals.ts
  - lib/config/setupGlobalDayjs.ts
  - instrumentation.page.ts
  - lib/mocks/msw-browser.ts
  - lib/mocks/msw-handlers.ts
  - lib/mocks/msw-init.ts
  - lib/mocks/msw-server.ts
verified_at: d4162e3
updated: 2026-10-16
status: current
tags: [repo/growth-fe, kind/feature]
---

# App shell (_app, _document, _error, App Router layout, globals, MSW)
> The frame around every growth-fe route: the Pages Router `_app`/`_document`/`_error`, a minimal App Router `layout` that exists only for `not-found`, the shared `AppProvider` tree, GTM bootstrap, dayjs globals, and MSW start-up on client and server.

## What it does
- **`pages/_app.page.tsx`** wraps each page in `ErrorBoundary` (loaded with `next/dynamic`), then `AppProvider` with `localeCountry = getLocaleAndCountry(router.locale)`, the app i18n dictionary (`getI18nDict`), and the `pageProps` passthroughs `middlewareData`, `remoteModuleSsrProps`, `remoteModuleVersion`. Inside it renders:
  - `TiketMetaTag` from `@tiket/next/client` with `pathname={router.asPath}` (favicon, canonical, hreflang, app deep-link alternates; see [[tiket-next-core]]). Only for the route `/stories/[type]/[slug]` it also passes `xDefaultHrefLocaleCountry` and `hrefLangsAlternates` built from `middlewareData.locale` + `countryCode` ([[growth-fe-stories]]);
  - a viewport meta (`maximum-scale=5.0, user-scalable=0`) and preconnects to `NEXT_PUBLIC_ASSET_PREFIX`, GTM and `NEXT_PUBLIC_REACT_REMOTE_URL`;
  - `getLayout` support (only story detail defines one, to wrap the page in `StoryDetailPageProvider`);
  - `RemoteScripts` from [[react-common-remote]], then `GTMScripts`.
  It imports `styles/global.scss` (radii, safe-area and content-padding tokens) and Passport `base.css` + `font-loader.css` ([[passport-design-tokens]]). With `NEXT_PUBLIC_API_MOCKING=enabled` it `require`s `@/lib/mocks/msw-init`.
- **`pages/_document.page.tsx`** is minimal: `<Html lang={locale}>` and `<meta name="google" content="notranslate">`. Unlike homepage-fe ([[homepage-fe-app-shell]]) there is no `RemoteConfigScript`, no font preloads and no GTM preload here.
- **`pages/_error.page.tsx`** renders Passport `ErrorView variant="generic"` ([[passport-error-view]]) whose button calls `reloadLocation()`. `getInitialProps` logs once with `createLogger` from `@tiket/next`, named `server-error-page` when `req` exists and `client-error-page` otherwise, through `standardizedLogData` (`lib/logger`, see [[structured-diagnostic-logging]]). There is no `pages/404.page.tsx` and no `_offline` page.
- **App Router (`app/`)** holds only `layout.page.tsx`, `not-found.page.tsx` and the API handlers ([[growth-fe-api]]). No route page lives under `app/`.
  - `layout.page.tsx` (async server component) calls `setupServerGlobals()`, reads `getMiddlewareData()` from `@tiket/next/server`, renders `NextjsUnsupportedMetaTags`, preconnect/dns-prefetch for GTM, Facebook, TikTok, the asset prefix and the remote URL, a `preload` of `gtm.js?id=NEXT_PUBLIC_GTM_ID`, and wraps children in the same `AppProvider` (with `localeCountry={{ locale }}` only) plus `RemoteScripts`. `viewport` export: `maximumScale: 1`, `userScalable: false`, `themeColor: '#005ACC'`.
  - `not-found.page.tsx` renders `components/NotFound` with static English metadata (`Page Not Found | Tiket.com`). Its comment explains why it exists: once `app/layout` exists, a Pages Router `getServerSideProps` returning `{ notFound: true }` is rendered through this App Router boundary, not `pages/404`, so without it users see the default Next.js 404.
  - `setup-react-cache-workaround.ts` calls `registerCache(cache)` from `@tiket/next/react-cache-workaround`. `@tiket/next` 3.3.1 wraps `getMiddlewareData` in that registered `cache`; without the import it falls back to an identity function and is not memoised per request.
  - `globals.scss` only imports Passport `base.css` and `font-loader.css`.
- **Globals (`lib/config`)**: `setupGlobalDayjs(locale)` imports `dayjs/locale/id` and sets `dayjs.locale`. `setupClientGlobals(locale)` calls it from `AppProvider` on every render. `setupServerGlobals()` reads the locale from `getMiddlewareData()` and is called only in `app/layout`. Its comment says to call it in layout **and all pages** because the layout runs in a different process, but no App Router page exists yet.
- **MSW**: `instrumentation.page.ts` calls `registerFetchMock(getHandlers)` from `@tiket/next/instrumentation`, which starts an MSW node server only when `NEXT_RUNTIME === 'nodejs'` and `NEXT_PUBLIC_API_MOCKING === 'enabled'`. This mocks `getServerSideProps` fetches. In the browser, `msw-init.ts` starts `setupWorker` from `msw-browser.ts` (`onUnhandledRequest: 'bypass'`). Its server branch is commented out (msw issue #1340), so server-side mocking goes only through instrumentation. `msw-server.ts` is used by Jest (`jest.setup.js`, `lib/test-utils`). `msw-handlers.ts` mocks inbox unread count, `tix-members-core/account/basic/v2`, and the B2B flight search, search stream and metasearch cart endpoints used by [[growth-fe-affiliate]] (`/affiliate/book/[product]`). A `MockCase=Error` search parameter or a `requestItem` other than `mock-requestitem-flight` returns `MockResponseError`. The `prepare` script runs `msw init ./public`, so `public/mockServiceWorker.js` is generated.

## Routes & entry points
`_app`, `_document`, `_error` (500 and unhandled errors), `app/layout` + `app/not-found` (all 404s, including Pages Router `notFound: true`), `instrumentation.page.ts` (named `.page.ts` because `pageExtensions: ['page.tsx','page.ts']` also applies to it and to `middleware.page.ts`).

## Data & services
None of its own. `_app` forwards SSR props; `app/layout` calls `getMiddlewareData()`. `AppProvider` builds the React Query client (`refetchOnMount`, `refetchOnWindowFocus`, `refetchOnReconnect` all `false`) and wraps children in `HydrationBoundary` with `dehydratedState`, but no page passes `dehydratedState` on main. Provider order, outer to inner: `MiddlewareDataProvider` → `LocaleCountryProvider` → `PassportProvider` (country, currency, `isNewURLStructure`, locale) → `ReactRemoteProvider` (`sessionData`, `dataLayer.screenName: 'affiliate'`) → `DeviceProvider` → `LoadingContext` → `SnackbarProvider` + `ForwardParamsProvider` → `QueryClientProvider` → `HydrationBoundary` → `I18nProvider`. Unlike homepage-fe, `PassportProvider` gets no `customFetch`.

## Key components
`components/providers/AppProvider.tsx`, `components/CustomScripts/GTMScripts.tsx`, `components/ErrorBoundary`, `components/NotFound`. See [[growth-fe-components]].

## Tracking
- `GTMScripts` (Pages Router only) injects the GTM container snippet with `next/script` (default `afterInteractive`) for `NEXT_PUBLIC_GTM_ID`. Only when `NEXT_PUBLIC_UA_TRACKING_ID` is set does it also set `window.ANALYTICS_VERSION = "2.1"`, `window.gtm.trackingId` and `window.gtm.vertical` (`NEXT_PUBLIC_VERTICAL`, default `growth`). See [[gtm-datalayer-tracking]].
- `usePageVisitAnalytics(pageVisitAnalyticsConfig)` in `AppProvider` maps `^/core` to screen `affiliate`, vertical `affiliate`.
- `ReactRemoteProvider` passes `dataLayer: { screenName: 'affiliate' }` to remote widgets on every route, stories and sitemap included.

## Tests
`pages/__tests__/_error.spec.tsx` (render + `getInitialProps` logging). `components/providers/__tests__/AppProvider.spec.tsx`, `components/providers/analytics-config.spec.ts`, `components/CustomScripts/GTMScripts.spec.tsx`, `lib/config/__tests__/setupClientGlobals.spec.ts`, `setupGlobalDayjs.spec.ts`. Jest coverage ignores `_app`, `layout`, `document`, `middleware` and `lib/mocks/`. Sonar excludes `pages/_app.page.tsx`, `pages/_document.page.tsx`, `lib/config/**`, `**/mocks/**` and `app/api/**`. In `jest.setup.js` the `mswServer.listen()` call is commented out, so specs that need MSW must start it themselves.

## Gotchas
- **Two routers, two shells.** Pages Router routes get `_app` (GTM, `TiketMetaTag`, `styles/global.scss`, `ErrorBoundary`). The App Router `not-found` gets only `app/layout`: no `GTMScripts` (although `gtm.js` is preloaded), no `ErrorBoundary`, no `styles/global.scss` tokens, and a different viewport (`maximumScale: 1`). A new App Router page would inherit the same gaps.
- **Story detail hreflang uses a trimmed `middlewareData`.** Story detail's `getServerSideProps` returns `middlewareData: { locale }` only (trimmed for LCP in #59). `_app` therefore builds `currentLocaleCountry` as `<locale>-undefined`. `TiketMetaTag` only builds alternates for paths that start with `/xx-yy/`, and stories skip the URL-structure middleware, so in practice no hreflang or x-default links are emitted on that route. The same trim means `AppProvider` on story detail gets no `countryCode`, `currency`, `isNewURLStructure` or `sessionData`. `PassportProvider` and `ReactRemoteProvider` get `undefined`, and `standardizedLogData` (which reads `__NEXT_DATA__.props.pageProps.middlewareData`) logs no account ID.
- `ErrorBoundary` wraps `AppProvider` from the outside, so its fallback `ErrorView` renders without `PassportProvider` and uses Passport's default context locale.
- `pageVisitAnalyticsConfig` only matches `/core…` paths, and no growth-fe route starts with `/core` (the `.env.test` base prefix is `core`). It looks like a template leftover, so this hook sends no page visits on real routes. Stories has its own `pages/stories/usePageVisitStories.tsx`.
- `setupClientGlobals` runs during render, not in an effect, so it also runs during Pages Router SSR. `setupServerGlobals` exists only for App Router code.
- `_app` reads `NEXT_PUBLIC_ASSET_PREFIX` and `NEXT_PUBLIC_REACT_REMOTE_URL` for preconnects. Unset values produce `href="undefined"` / `"undefined/"`.
- MSW only intercepts what the handlers list. `/ms-gateway/tix-members-core/account/basic/v2` is a relative path, so on the server only the absolute `SERVER_SIDE_SERVICE_ENDPOINT` inbox handler and the wildcard B2B handlers match.

## Sources
- `pages/_app.page.tsx`, `pages/_document.page.tsx`, `pages/_error.page.tsx`, `pages/__tests__/_error.spec.tsx`
- `app/layout.page.tsx`, `app/not-found.page.tsx`, `app/setup-react-cache-workaround.ts`, `app/globals.scss`
- `components/providers/AppProvider.tsx` (+ specs), `components/CustomScripts/GTMScripts.tsx` (+ spec), `components/ErrorBoundary/index.tsx`
- `lib/config/setupClientGlobals.ts`, `setupServerGlobals.ts`, `setupGlobalDayjs.ts` (+ specs)
- `instrumentation.page.ts`, `lib/mocks/msw-browser.ts`, `msw-handlers.ts`, `msw-init.ts`, `msw-server.ts`, `jest.setup.js`, `jest.config.mjs`, `sonar-project.properties`, `package.json`, `next.config.js`, `.env.local.example`, `.env.test`
- `pages/stories/[type]/[slug]/index.page.tsx` (trimmed `middlewareData`), `middleware.page.ts`, `lib/logger/index.ts`
- `@tiket/next` 3.3.1 `src/instrumentation.ts`, `src/react-cache-workaround.ts`, `src/metadata/TiketMetaTag.tsx` (installed package, same version as the main pin)
