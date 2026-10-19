---
title: TIX-HOMEPAGE-NEXT-FE architecture
repo: TIX-HOMEPAGE-NEXT-FE
kind: architecture
sources:
  - next.config.ts
  - middleware.page.ts
  - instrumentation.page.ts
  - pages/_app.page.tsx
  - pages/_document.page.tsx
  - pages/index.page.tsx
  - components/providers/AppProvider.tsx
  - components/RemoteConfigScript
  - pages/home/components/HomePageModule/index.tsx
  - pages/home/utils/getHomeRemoteModules.ts
  - pages/destination/utils/getDestinationRemoteModules.ts
  - lib/fetch
  - lib/services
  - lib/i18n
  - lib/jwt
  - lib/session
  - lib/jsi
  - lib/config.ts
  - lib/tracker
  - context
  - hooks
  - worker
  - patches
  - docs/data-fetching.md
  - docs/i18n.md
  - docs/deployment.md
verified_at: 408983f6
updated: 2026-10-19
status: current
tags: [repo/homepage-fe, kind/architecture]
---

# TIX-HOMEPAGE-NEXT-FE architecture
> A Pages Router app where every route is `getServerSideProps` + React Query. The page body is mostly a Passport `PageModule` fed by `tix-home` or `tix-promotion-page`, and the header and footer are react-remote widgets.

## Layout
```
pages/                 routes (*.page.tsx); each feature folder holds its own components/, hooks/, i18n/, trackers.ts
  _app / _document / _error / 404 / _offline / index.page.tsx   (app shell + home route)
  home/                home-only components and contexts (no route of its own; used by index.page.tsx)
app/api/               App Router route handlers only (no app pages)
components/            22 cross-feature folders → [[homepage-fe-components]]
context/               AuthContext, CurrencyTicker, DeviceContext, DimensionContext, Promo
hooks/                 useNotificationCount (home unread inbox/chat badge) + its useBroadcastChannel ('push-notif-chat')
lib/                   config, fetch, services, i18n, jwt, session, jsi, tracker, helpers, hooks, utils, mocks, types, test-utils
worker/                service-worker add-ons for next-pwa
middleware.page.ts, instrumentation.page.ts
```
The `*.page.ts(x)` extension is required for anything Next treats as a route, middleware or instrumentation (`pageExtensions` in `next.config.ts`). That's why `middleware.page.ts` and `instrumentation.page.ts` have the suffix, and why plain `.tsx` files such as `pages/script.tsx` and `pages/jsonLd/*` can live inside `pages/` without becoming routes. Path aliases are `@lib/*`, `@components/*`, `@context/*`, `@hooks/*`, `@pages/*`, `@middleware/*` (AGENTS.md).

## Request flow
1. **Middleware** (`middleware.page.ts`): `chain([localeMiddleware, currencyMiddleware, rewriteMiddleware])` from `@tiket/next/server`. The local `rewriteMiddleware` rewrites every request to `/${locale}${pathname}`, because Next's built-in i18n (`locales: ['en','id']`, `defaultLocale: 'id'`, `localeDetection: false`) expects the locale as the first path segment. A comment says to rename it to `middleware.ts` when the Pages Router goes away.
2. **getServerSideProps** reads the middleware result with `getServerSidePropsMiddlewareData(ctx)` (locale, currency, country, `sessionData`, `isBot`, `isNewURLStructure`). It then runs the A/B test fetch (`getAbTestOnServer`, see [[ab-testing]]) and `getReactRemoteProps(...)` for SSR'd remote widgets, usually in parallel via `Promise.allSettled`. Voucher-box is the exception: it awaits them one after the other. **Page data is not prefetched for real users on any route.** Home, destination and explore prefetch into a `QueryClient` (`dehydratedState`) only when `isBot`. Promo detail fetches only the meta for bots. Promo list, the previews, voucher box and cross-sell fetch nothing on the server. Humans always get a skeleton, then a client `useQuery`.
3. **_app** (`pages/_app.page.tsx`) wraps every page in `AppProvider` and adds `TiketMetaTag`, `GlobalJsonLd`, the GTM `Script` and `RemoteScripts` (details in [[homepage-fe-app-shell]]). Pages can set `getLayout`.
4. **AppProvider** (`components/providers/AppProvider.tsx`) nests: `ErrorBoundary` → `MiddlewareDataProvider` → `LocaleCountryProvider` → `PassportProvider` (locale, `customFetch`, country, currency, `isNewURLStructure`, `isLoggedIn`, `ssrEstimatedDeviceType`, `abTestOnServerResponse`) → `QueryClientProvider` (no refetch on mount, focus or reconnect) → `HydrationBoundary` → `ReactRemoteProvider` → `ForwardParamsProvider` → `RemoteCountryAndCurrencyModal` + `SnackbarProvider` + `I18nProvider`. It also calls `usePageVisitAnalytics` and `setupClientGlobals` (dayjs locale).

## Data fetching
- `lib/fetch/fetch.ts` wraps `apiFetch` from `@tiket/next/fetch`. It defaults to `shouldCreateGuestToken: true`, drops `password` from request-body logs and removes API responses from logs. It treats the call as server-side when `initArg.ctx` has `req` and `res`. `coreFetcher({ locale })` adapts it to the `fetch` signature. That adapter is what `PassportProvider.customFetch` and `PageModule.fetch` receive (see [[passport-custom-fetch]]).
- URL transformation (docs/data-fetching.md): a relative path such as `/tix-home/v2/home-pages` becomes `{base_url}/ms-gateway/...` on the client and `{lb}/gateway/...` on the server. Some server services build the absolute `SERVER_SIDE_SERVICE_ENDPOINT + '/gateway/...'` URL themselves (`getHomepageData`).
- Services live in `lib/services/` (one file per feature: `HomeServices`, `get-destination`, `dynamic-landing-page`, `promo/`, `voucher-box`, `cross-sell-trip`, `account`). They return the `APIResponse` envelope (`code: 'SUCCESS'`), and on exception they return `error(e)` instead of throwing. Calls pass `sendStandardizedLogData` with an SDC (`constructSdc`), see [[structured-diagnostic-logging]].
- Backends: `tix-home` (`/v2/home-pages`, `/v2/page-modules-with-meta`, `/v2/page-modules-full`, `/v2/hero-banners`, `/v2/admin/page-modules/dynamic-landing-preview`), `tix-promotion-page` (promos, promo codes, voucher box, cross-sell entry points), `tix-member-core`, `tix-member-session`.
- **Home is client-fetched for humans.** `pages/index.page.tsx` prefetches `getHomepageData` on the server **only when `middlewareData.isBot`**. Otherwise the page renders loaders and `useQuery` calls `getHomepageDataClient` in the browser. The query key `['homepage-data', currency, platform]` is shared between both paths.
- `docs/data-fetching.md` still shows `react-query` v3 (`useQuery(['key'], fn)`, `status === 'loading'`) and says React Query "isn't installed in the starter". The code uses v5 object syntax.

## Page-module rendering
Every content route renders `PageModule` from [[passport-page-module]] (`12.5.0`). The host wires in its own pieces:
- `fetch={coreFetcher({ locale })}`, `clientSideServiceEndpoint` (current origin on the client, `BASE_URL` on the server; `lib/utils/webview.ts`), `locale`, `currency`, `accountId`, `loyaltyLevel`, `username`, `screenName`/`screenOwner`, `experiments` (A/B variants), `recommendationVersion`.
- Image renderers from `components/PageModuleImageRenderer` (`CarouselImageRenderer`, `DefaultPageModuleImageRenderer`, `PageModuleLogoImageRenderer`) passed as `bannerGridImageRenderer`, `promoCarouselImageRenderer`, `textWithImageImageRenderer`, `logoImageRenderer` and similar props. Several are cast `as any`.
- Critical rendering on home: for mobile non-bots, `forceRender` (`NEXT_PUBLIC_FORCE_RENDER_PAGEMODULE`, default `enabled`) plus `aboveTheFoldIndex: 4`. `getCriticalImageModuleIndexes` and `getPreloadImages` (`lib/helpers/pagemodule/`) emit `<link rel="preload" fetchPriority="high">` for the module background images.
- A/B experiments are passed to the backend as a query string built by `constructPageModuleQueryParamsExperiments` (exported by page-module).
- Loading skeletons use `Carousel` from [[passport-page-module-shared]].

Hosts: `pages/home/components/HomePageModule`, `pages/destination/[slug]/components/RenderPageModule`, `components/DynamicLandingPageContent` (explore and explore-preview), `pages/voucher-box/components/VoucherBoxPageModule`, `pages/cross-sell-trip/components/CrossSellTripPageModule`. On `origin/main` they all import the root `@tiket/passport-page-module` (the dist build with its static module registry). The `next/dynamic` registry variant ([[page-module-next-poc]]) is validated in this repo, but only on a branch. Main doesn't use it.

## Remote components
Header, footer, global popup, Google One Tap, country/currency modal and scripts come from TIX-REACT-REMOTE through [[react-common-remote]] and [[module-federation]]. The host side is:
- `_document` puts `RemoteConfigScript` **first in `<head>`**. It sets `window.__TIX_REMOTE_CONFIG__ = { basePrefixForApp, postLogPath }` before any `remoteEntry.js` loads. The shared fetch client inside each remote reads that at call time, because `NEXT_PUBLIC_*` values are inlined into the remote's own build ([[react-common-fetch-client]] `src/config.ts`).
- `next.config.ts` registers an empty `ModuleFederationPlugin({ name: pkg.name })` on the client build (host only, no remotes declared statically).
- SSR: `getReactRemoteProps(modules, ctx)` with per-feature module lists. Home asks for `header` (desktop only, `variant: 'transparent'`, `isSticky`, `layoutVariantCode: '004'`, `isMultiCurrencyAvailable`) and `footer` (desktop or bots). Destination asks for `header` (desktop) and always `footer`. The results (`remoteModuleSsrProps`, `remoteModuleVersion`) flow through `_app` into `ReactRemoteProvider`. See [[react-remote-ssr-prerender]].
- On webview pages `components/Header` skips the remote header and renders Passport `HeaderMobile`, or nothing when the native toolbar is shown. The reason is a back-button rendering issue with the remote header in webviews (comment links to Slack).

## i18n
Next i18n routing plus a Rosetta-style dictionary (docs/i18n.md). `lib/i18n` has `en.ts`/`id.ts`/`i18n.types.ts`, a client `I18nProvider`/`useI18n` from `createI18nContext` (`@tiket/next/client`), and a server `registerI18n` (`@tiket/next/server`). `_app` passes `getI18nDict(locale)` into `AppProvider`. Several features have **their own** `i18n/` folder with a separate provider and `useI18n` (`pages/promo`, `pages/voucher-box`, `pages/destination/[slug]`, `pages/cross-sell-trip`, `pages/home/components/SSONotification`, `components/DynamicLandingPageContent`, `components/MobileHeader`). Import the matching one. `pnpm detect-unused-i18n` (`scripts/detect-unused-i18n-keys.ts`) finds dead keys.

## Session, JWT and auth
- The session comes from `@tiket/next` middleware (`middlewareData.sessionData`, type `Session`). Pages wrap content in `AuthProvider` (`context/AuthContext`), which derives `accountId`, `userName`, `loyaltyLevel`, `isAuthenticated` and `normalizedCurrency` (from the currency cookie).
- Tokens are created and refreshed by the `@tiket/next` handlers mounted at `app/api/create-token` and `app/api/refresh-token` ([[homepage-fe-api]]). Guest tokens are auto-created by `lib/fetch`.
- `lib/jwt` (`parseJWT`, `isInvalidOrExpired`, `COOKIE_CONFIG` for `.tiket.com`) is a starter leftover that only its own specs import on main. In `lib/session`, only `types.ts` (`GetServerSidePropsContextWithSession`) is used by services. `defaultGuestSession` appears only in a service spec.
- `lib/jsi/types.ts` only defines `PlatformEnum` (android/ios), used for webview device detection via the `device_type` cookie (`lib/utils/webview.ts`). For the bridge itself see [[webview-jsi-bridge]].

## Tracking
- GTM bootstrap in `pages/script.tsx` (`window.gtm.vertical = 'home'`), then per-feature `trackers.ts` files push to `window.dataLayer` (`lib/tracker/GTM.ts`). See [[gtm-datalayer-tracking]].
- `AnalyticsEventHandler` (`lib/tracker/Analytics.ts`) sets `window.eventProperties` and calls `window.commonAnalytic.updateAnalytics()` ([[react-common-analytic]]).
- `pageProps.dataLayer` (`screenName`, `screenOwner`, `variantName`) goes to `ReactRemoteProvider`, so remotes track with the host's screen.
- `lib/config.ts` sets `VERTICAL_NAME = 'flight'`, which `lib/tracker/GTM.ts` uses as a `window.gtm` key. This is a starter leftover, not the home vertical.

## Service worker (PWA)
`next-pwa` writes `public/serviceworker.js` with custom runtime caching from `worker/custom-runtime-caching.js`. `worker/index.js` is merged into it: it imports `braze.js` and `worker/firebase-messaging.js` (FCM push rewrite, see [[web-push-notifications]]). On activation it deletes every runtime cache except Workbox precache and `custom-order-detail-cache`.
- Because the app owns `/`, the worker serves other apps' paths too. It caches `yourorder/detail` and `ms-gateway/tix-order-composer|tix-my-order-core` for a year (offline order detail), and `pages/_offline.page.tsx` has special handling for `/yourorder/detail` in the Android webview.
- To-do flows (`/to-do`) and Queue-it are kept out of Workbox routes and out of the navigate fallback, so the SW never answers them (to keep `Set-Cookie` and avoid "302 from service worker").
- `/api/auth/*` is excluded from the `apis` cache (Safari OAuth issue noted in the file).

## Build and hosting config
- `assetPrefix` and rewrites come from `@tiket/next/configs/config.cjs`. Production adds `/{prefix}/_next/*`, `/{prefix}/_next/assets/*` and `/{prefix}/api/*` rewrites, plus Apple App Site Association and `/.well-known/openai-apps-challenge` rewrites to files under `BASE_URL/.well-known/` (choice of production/preprod/gatotkaca by hostname). In dev, `/ms-gateway/*` is proxied to `BASE_URL`.
- `generateBuildId` = `${prefix}__${next-build-id}` (git-based). The LB routes `/_next/data/{prefix}__*` here (docs/deployment.md).
- `SubresourceIntegrity` (sha512) in production, from `@tiket/next`.
- **date-fns alias:** [[passport-picker]] was compiled against date-fns v2's default locale imports. `next.config.ts` aliases `date-fns/locale/id` and `en-US` to the `date-fns@2.30.0` copy in the pnpm store, and `pnpm.overrides` forces `date-fns: ^2.30.0`, although `package.json` declares `^4.1.0`.
- Images: `next/image` with Passport's `deviceSizes`/`imageSizes` and Lightroom hostnames, served at `/{prefix}/_next/image`.

## patches/
`patches/jsdom@26.1.0.patch` makes `window.location` and its members configurable, so tests can mock them. **It is not wired up on main:** `package.json` has no `pnpm.patchedDependencies` and the lockfile has no patch entry, so pnpm doesn't apply it. The `migrate-jest-testing` skill (`.cursor/skills/migrate-jest-testing/SKILL.md`) describes the `patchedDependencies` entry that would enable it. The Dockerfile still copies `patches/` into the deps stage.

## Cross-page gotchas (408983f6)
- **Guest `userId` is the string `"undefined"`.** Home, destination, explore, voucher-box and cross-sell GSSPs all do `String(sessionData?.accountId) || undefined`. `String(undefined)` is truthy, so guests reach `getAbTestOnServer` with `userId: "undefined"`. The fix is `accountId ? String(accountId) : undefined`.
- **Services never throw, so React Query's `isError` is almost never true.** Each service returns `error(e)`, which is cached as successful data. Pages must branch on `data.code !== 'SUCCESS'`. A `try/catch` around `prefetchQuery` in GSSP (as on home) is dead code.
- **No GSSP sets `Cache-Control` or returns `notFound`.** A missing destination, explore or promo is a 200 soft 404. The explore and promo error views are `ssr:false`, so bots get an empty page.
- **Previews have no auth gate in the app.** `destination-preview` and `explore-preview` rely on the `tix-home` admin endpoint to reject callers. Explore-preview sets `noindex` (via a pathname check in `DynamicLandingPageContent`). Destination-preview doesn't, and still emits Article JSON-LD.
- **`components/SEOPageHead/customCanonicalLink.ts`** contains test entries (`/explore/test-slug`, `/explore/thailand` → a Kalibata apartment page) that ship to production.

## Sources
- `next.config.ts`, `middleware.page.ts`, `instrumentation.page.ts`
- `pages/_app.page.tsx`, `pages/_document.page.tsx`, `pages/index.page.tsx`, `pages/script.tsx`, `pages/_offline.page.tsx`
- `components/providers/AppProvider.tsx`, `components/RemoteConfigScript/RemoteConfigScript.tsx`, `components/Header/index.tsx`
- `pages/home/components/HomePageModule/index.tsx`, `pages/home/utils/getHomeRemoteModules.ts`, `pages/destination/utils/getDestinationRemoteModules.ts`
- `lib/fetch/fetch.ts`, `lib/services/HomeServices.ts` (+ other `lib/services/*`), `lib/i18n/*`, `lib/jwt/*`, `lib/session/*`, `lib/jsi/types.ts`, `lib/config.ts`, `lib/utils/webview.ts`, `lib/tracker/*`, `lib/helpers/pagemodule/*`
- `context/AuthContext/index.tsx`, `hooks/`
- `worker/index.js`, `worker/custom-runtime-caching.js`, `worker/firebase-messaging.js`
- `patches/jsdom@26.1.0.patch`, `pnpm-lock.yaml`, `Dockerfile`, `.cursor/skills/migrate-jest-testing/SKILL.md`
- `docs/data-fetching.md`, `docs/i18n.md`, `docs/deployment.md`, `AGENTS.md`
- TIX-REACT-COMMON `packages/react-common-fetch-client/src/config.ts` (origin/master)
