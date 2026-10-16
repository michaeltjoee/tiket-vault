---
title: TIX-GROWTH-NEXT-FE architecture
repo: TIX-GROWTH-NEXT-FE
kind: architecture
sources:
  - next.config.js
  - middleware.page.ts
  - instrumentation.page.ts
  - rewrite-path-config.js
  - css-module-ident-config.js
  - pages/_app.page.tsx
  - components/providers/AppProvider.tsx
  - lib/fetch
  - lib/services
  - lib/logger
  - lib/i18n
  - lib/gtm
  - lib/helpers/context.ts
  - lib/contexts/device.tsx
  - lib/config
  - app
  - tsconfig.json
verified_at: d4162e3
updated: 2026-10-16
status: current
tags: [repo/growth-fe, kind/architecture]
---

# TIX-GROWTH-NEXT-FE architecture
> A Pages Router app where every route uses `getServerSideProps`. The tiket middleware chain is skipped for the partner hand-off routes. Remote header and footer come from react-remote, and some features have their own i18n and GTM helpers.

## Layout
```
pages/                 routes (*.page.tsx); each feature folder holds its own _blocks/ or blocks/, hooks, i18n/, tracker.ts
  _app / _document / _error            app shell → [[growth-fe-app-shell]]
  stories/ sitemap/ affiliate/ blibli-affiliate/ metasearch/
  api/partner-config.page.ts           the only Pages API route
app/                   App Router: layout + not-found (required by Next 16 once app/ exists) and api/* route handlers
components/            10 cross-feature folders → [[growth-fe-components]]
lib/                   config, contexts (device), fetch, gtm, helpers, hooks, i18n, logger, mocks, navigation, services, types, utils, test-utils
e2e/                   Playwright specs (affiliate, metasearch)
docs/flow/             FE↔BE sequence docs per affiliate/metasearch flow
middleware.page.ts, instrumentation.page.ts, rewrite-path-config.js, css-module-ident-config.js
```
**Hybrid router:** every page is Pages Router, but because `app/layout` exists, every 404 renders through `app/not-found`. That includes `getServerSideProps` returning `notFound: true`, and there is no `pages/404`. That App Router shell has no `GTMScripts`, no `ErrorBoundary` and no `styles/global.scss` ([[growth-fe-app-shell]]).

Only `*.page.ts(x)` files are routes (`pageExtensions`). That's why helpers such as `pages/stories/helpers.ts` and the `blocks/` folders can live under `pages/`. The single path alias is `@/*` → repo root.

## Request flow
1. **Middleware** (`middleware.page.ts`) returns early, with no locale or rewrite, for **non-application routes**: `/affiliate/book`, `/b2b-gateway`, `/metasearch/r`. Those pages read raw partner query strings and must not be locale-rewritten. All other requests go through `chain([localeMiddleware, currencyMiddleware (disabled via withConfig), rewriteMiddleware])` from `@tiket/next/server`.
   - `rewriteMiddleware` rewrites to `/${locale}${pathname}` (Next i18n: `locales ['en','id']`, `defaultLocale 'id'`, `localeDetection: false`). It also sets `x-pathname` and `x-original-pathname` headers for the App Router metadata helpers (`docs/app-router-metadata.md`).
   - `/stories/**` passes `skipUrlStructureMiddleware: true`, which keeps stories out of the [[new-url-structure]] redirect (added in 1.1.2, "whitelisted stories page from url restructure").
2. **getServerSideProps** reads the result with `getServerSidePropsMiddlewareData(ctx)` and fetches remote props with `getReactRemoteProps` (header and footer) where the page shows tiket chrome. The `metasearch` and `affiliate/r` pages do neither: they only resolve the redirect. Stories landing and detail set `Cache-Control: public, s-maxage=60, stale-while-revalidate=180` (`serverSideCtxCacheControlSetter`).
3. **_app** wraps every page in `ErrorBoundary` (lazy) → `AppProvider`, then renders `TiketMetaTag` (story detail gets a single self-referencing hreflang), the page via `getLayout`, `RemoteScripts` and `GTMScripts`. MSW is required in the browser when `NEXT_PUBLIC_API_MOCKING=enabled`.
4. **AppProvider**: `MiddlewareDataProvider` → `LocaleCountryProvider` → `PassportProvider` (country, currency, `isNewURLStructure`, locale; **no `customFetch`**) → `ReactRemoteProvider` (`dataLayer.screenName: 'affiliate'` for every page) → `DeviceProvider` → a no-op `LoadingContext` → `SnackbarProvider` + `ForwardParamsProvider` → `QueryClientProvider` (no refetch on mount, focus or reconnect) → `HydrationBoundary` → `I18nProvider`. It also calls `usePageVisitAnalytics` with a single rule for `^/core`, which is a starter leftover that matches no route here.
5. **Story detail passes only `{ locale }` as `middlewareData`** (an LCP change in #59). So on that page Passport and `ReactRemoteProvider` get no country, currency, `isNewURLStructure` or session, the hreflang comes out as `{locale}-undefined`, and logs carry no account id ([[growth-fe-stories]]).

## Data fetching
- `lib/fetch/fetch.ts` wraps `apiFetch` from `@tiket/next`. It defaults to guest-token creation, filters `password` from logged bodies, and treats the call as server-side when `initArg.ctx` has `req` and `res`. With `isLocalApi: true` it prefixes `{BASE_URL}/{prefix}/api` so the app can call its own routes ([[growth-fe-api]]). `coreFetcher` adapts it to the `fetch` signature and bypasses it for hosts listed in `NEXT_PUBLIC_THIRD_PARTY_URL`.
- Services live in `lib/services/` (`b2b`, `cobrand`, `partner`, `metasearch`, `seo/getFlightSitemap`, `stories/*`). Endpoints are in `lib/config/apiUrl.ts` and in the services. Calls pass `sendStandardizedLogData` built by `lib/logger` ([[structured-diagnostic-logging]]). On the client it reads `middlewareData` from `window.__NEXT_DATA__`.
- Some services call **absolute internal cluster URLs** from `NEXT_PUBLIC_AFFILIATE_*` env vars instead of gateway paths (for example `cobrand.ts` → `${NEXT_PUBLIC_AFFILIATE_NONA_INGRESS}/tix-affiliate-nona-internal/...`). Those hosts only resolve inside the cluster, so these calls work only from `getServerSideProps` or API routes.
- **Open redirect:** `isRedirectWhitelistDomain` (`lib/utils/url.ts`) tests the whole URL string with a regex instead of parsing the hostname. `https://tiket.com.evil.io/x`, `https://evil.com?.tiket.com` and any URL that merely contains `tiket.onelink` all pass. It guards the metasearch `ref` and the checkout `payment_url` ([[growth-fe-metasearch]]).
- `lib/services/cobrand.ts` and `pages/api/partner-config.page.ts` create `x-request-id` with `uuidv4()` **at module scope**. Every request served by one server process therefore sends the same id.

## i18n
`lib/i18n` follows the starter: `en.ts`/`id.ts`, a client `I18nProvider`/`useI18n`, a server `registerI18n` (`server.ts`), and `pages.ts` (`getI18nDict`, used by `_app`). `pages/stories/i18n` and `pages/affiliate/c/i18n` have **their own** dictionaries and providers. Import the matching `useI18n`.

## Tracking
- `GTMScripts` (`components/CustomScripts`) sets `window.gtm.vertical` from `NEXT_PUBLIC_VERTICAL` (default `growth`).
- `lib/gtm/core.ts` pushes to `window.dataLayer` and merges per-vertical data into `window.gtm` (see [[gtm-datalayer-tracking]]). Features use different vertical names: `growth` (metasearch checkout, blibli-affiliate) and `affiliate` (affiliate book, AppProvider page-visit config). `lib/gtm/harvesterEventWatcher.ts` lets metasearch checkout wait for the harvester page-visit ingest before it redirects ([[growth-fe-metasearch]]).
- Stories have their own `tracker.ts` files.

## Remote components
`next.config.js` registers an empty `ModuleFederationPlugin({ name: pkg.name })` on the client build (host only, see [[module-federation]]). `_app` preconnects to `NEXT_PUBLIC_REACT_REMOTE_URL` and renders `RemoteScripts`. Header and footer remote props are SSR-fetched per page ([[react-remote-ssr-prerender]]). `components/RemoteHeader` wraps the header.

## Build and hosting config
- `assetPrefix` and the base rewrites come from `@tiket/next/configs/config.cjs`. On top of those, `next.config.js` adds:
  - **dev only:** `/b2b-gateway/*` and `/partner-gateway/*` → `https://gatotkaca.tiket.com/...`.
  - **SEO rewrites** (`rewrite-path-config.js`): `/pesawat/maskapai`, `/flights/airlines`, `/pesawat/rute`, `/flights/route`, `/pesawat/tujuan`, `/flights/to`, `/pesawat/maskapai/:slug/tujuan`, `/flights/airlines/:slug/to` → `/sitemap` ([[growth-fe-sitemap]]).
- `generateBuildId` = `${prefix}__${next-build-id}`. SRI (sha512) in production. Images use Passport's `deviceSizes` and the Lightroom hostnames from [[passport-assets]].
- **Short CSS module class names:** in production builds `css-module-ident-config.js` replaces Next's `File_class__hash` names with `c` + 5 base64url chars of sha256(file path + class name). The name has to be deterministic because the server and client compilations must agree. Don't target generated class names from tests or outside CSS.
- Comments marked `[app-router]` list what to remove once the Pages Router is gone (`pageExtensions`, `transpilePackages`, the `.page.ts` middleware name).

## Sources
- `next.config.js`, `middleware.page.ts`, `instrumentation.page.ts`, `rewrite-path-config.js`, `css-module-ident-config.js`, `tsconfig.json`
- `pages/_app.page.tsx`, `components/providers/AppProvider.tsx`, `components/CustomScripts/GTMScripts.tsx`
- `lib/fetch/fetch.ts`, `lib/services/*.ts`, `lib/services/cobrand.ts`, `pages/api/partner-config.page.ts`, `lib/logger/index.ts`, `lib/i18n/*`, `lib/gtm/*`, `lib/helpers/context.ts`, `lib/contexts/device.tsx`, `lib/config/*`
- `app/layout.page.tsx`, `app/not-found.page.tsx`, `docs/app-router-metadata.md`, `CHANGELOG.md` (1.1.2)
