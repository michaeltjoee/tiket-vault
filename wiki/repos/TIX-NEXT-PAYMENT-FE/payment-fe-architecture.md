---
title: TIX-NEXT-PAYMENT-FE architecture
repo: TIX-NEXT-PAYMENT-FE
kind: architecture
sources:
  - next.config.ts
  - middleware.page.ts
  - tsconfig.base.json
  - app/layout.page.tsx
  - pages/_app.page.tsx
  - pages/_document.page.tsx
  - pages/script.tsx
  - pages/global.scss
  - app/utils
  - README.md
  - AGENTS.md
  - .cursor/rules/typescript-react.mdc
  - lib
  - components/providers
  - app/contexts
  - app/payment/context
  - app/payment-link/context
verified_at: 9e92b20bb
updated: 2026-10-16
status: current
tags: [repo/payment-fe, kind/architecture]
---

# TIX-NEXT-PAYMENT-FE architecture
> How the hybrid Pages Router (`/payment`, `/smart_pay`) + App Router (payment link, `/l`, `/api`) app is wired: routing and why it is split, middleware, build, providers, data layer and `lib/`.

## Two routers in one app
The app runs **Pages Router and App Router side by side**. Each URL belongs to exactly one router:

| Router | Routes | Root | Page |
|---|---|---|---|
| Pages (`pages/`, 300 files) | `/payment` landing, `/payment/[type]` (legacy redirect), `/payment/[type]/{confirm,complete,callback}`, `/payment/payment-partner` | `pages/_app.page.tsx` → `components/providers/AppProvider`, plus `withPaymentPageProvider` per page | [[payment-fe-payment]] (and [[payment-fe-downpay]] inside it) |
| Pages | `/smart_pay`, `/smart_pay/[method]`, `/smart_pay/[method]/{binding,topUp}` | same | [[payment-fe-smart-pay]] |
| App (`app/`) | `/payment-link`, `/payment-link/[method]/{confirm,complete}` | `app/layout.page.tsx` → `lib/providers/AppRouterProvider` | [[payment-fe-payment-link]] |
| App | `/l/[id]` | same | [[payment-fe-l]] |
| App | `/api/{create-token,refresh-token,post-log,csp-report}` | route handlers | [[payment-fe-api]] |

The rest of `app/` holds no routes. `app/payment/` (promo, points, installment, linkage), `app/downpay/`, `app/contexts/` (DownPay), `app/hooks/` (tiket points, installment, date formatters) and `app/utils/` are feature modules **imported by the Pages Router `/payment` landing**. `app/(root)/` is a leftover ([[payment-fe-root]]).

### Why it is hybrid (from git history)
1. The repo began as a Pages Router app ("Initial commit from Create Next App", 2021-11-08). `/payment` started as `pages/v4` (#51, 2022-12, legacy URL `/next/v4`), and `/smart_pay` landed in #573 (2024-05).
2. The Next 14 upgrade (`30553fcd9`, #678, 2024-09-18) added `app/` with only a root layout, `not-found` and `(root)`, and no routes. API routes then moved to `app/api` route handlers (#833 Dec 2024, #807, #894). The last `pages/api` file went in #953 (2025-04-29).
3. The URL restructure (`77ee868c1`, #941, 2025-10-13) renamed `pages/v4` to `pages/payment` but kept it on the Pages Router.
4. Payment link (`1f7dc5f43`, #1181, 2025-11-04) was the first product feature built on the App Router, together with `/l/[id]`.
5. Newer landing features were written under `app/` as modules but are still mounted by the Pages page: DownPay (#1155, 2025-10) and Infinity Promo (#1326/#1430, 2026-05/06), which deleted `components/Promo`.

The intent is stated in docs: README calls `pages/` "Legacy Pages Router (being migrated)", AGENTS.md says "NEVER use Pages Router for new pages", and `.cursor/rules/typescript-react.mdc` says "Always use the App Router for all new features and pages". No commit on main moves `/payment` or `/smart_pay` yet. The migration has happened only for new routes and for code that can live outside `pages/`.

### What keeps the split in place
- **i18n:** `next.config.ts` `i18n` (`en`/`id`, default `id`) applies only to the Pages Router. The middleware strips the `/xx-yy` prefix for `APP_ROUTER_PATHS = ['/l', '/payment-link']` and rewrites every other path to `/${locale}${pathname}`. A route that moves to `app/` must be added to that list.
- **Providers:** the Pages tree (`_app` → `GlobalProvider` → `AppProvider` → per-page `withPaymentPageProvider`) and the App tree (`AppRouterProvider`) are separate and differ (for example `HashStackProvider`, `AnalyticsProvider` and `HyperServiceProvider` are Pages only). See Providers below.
- **Router APIs:** some `app/payment` hooks import `next/router`, so they only run under Pages. Pages code mixes in `next/navigation` (`useSearchParams` in `AppProvider`, `useRouter` in the smart_pay DANA page).
- **Shared code imports from `pages/`:** `components/BackButtonInterceptor`, `components/OrderSummary/components/Flight/detailV4.tsx`, `lib/i18n/i18n.types.ts`, `lib/types/entities/payment/paid-checker.ts` (from `pages/payment`) and `lib/hooks/useSaveHistoryLength.tsx` (from `pages/smart_pay`). App Router payment-link code reaches `pages/smart_pay` through `lib/hooks/usePreventPageLeave`.
- **Config marked for removal:** the `[app-router]` comments (`pageExtensions`, `transpilePackages` "only while the Pages Router exists") mark what to drop once `pages/` is gone.

### Pages Router root files
- `pages/_app.page.tsx`: mounts `MSWInit`, a viewport meta (no user scaling), `pages/script.tsx` with the CSP nonce, `GlobalProvider` (device and locale) and `AppProvider` (i18n dict from `lib/i18n/pages`, middleware data, remote-module SSR props), plus `TiketMetaTag`. `MyApp.getInitialProps` returns `device` (`getPagesDeviceInfo`), `serverTime` and `nonce` for every page. A custom `getInitialProps` in `_app` turns off automatic static optimization for every Pages route.
- `pages/_document.page.tsx`: `<Html lang={locale}>`, `NextHead` from `@tiket/next` and `NextScript`, both with the nonce read by `getNonceValue(ctx)`.
- `pages/script.tsx`: the GTM container snippet (`NEXT_PUBLIC_GTM_ID`, copies the nonce onto `gtm.js`), `window.ANALYTICS_VERSION = "2.1"` and `window.gtm.trackingId`, service worker registration (`NEXT_PUBLIC_SW_PATH`) and `ForterScript`. It is not a route because its name has no `.page.` suffix.
- `pages/global.scss`: passport design tokens + font loader, `styles/downpay-globals.scss`, `styles/payment-disable-text-selection-global.scss`, `body { background-color: #f4f7fe }`.

The App Router root (`app/layout.page.tsx`, `app/globals.scss`) is described on [[payment-fe-root]]. It loads `ForterScript` but not the GTM snippet, the service worker or `downpay-globals.scss`. Nothing under `app/` or `lib/providers` loads `gtm.js`, so App Router `dataLayer` pushes (payment link) rely on GTM being loaded some other way. Check this before you add App Router tracking.

### `app/utils`
Plain helpers shared by the `app/` modules. Despite the folder name, they are not App Router specific.
- `app/utils/date`: `formatIsoDatetimeLabel` (Asia/Jakarta, `GMT+7`/`WIB`), `formatDateLikeString`, `localDate`/`localTime`, with a Storybook demo. Consumed via `app/hooks/useDateFormatters` (DownPay banners, bills, settlement).
- `app/utils/logger/constants/flows.ts`: `FLOW_NAMES` / `FlowName`, the `flowName` values sent with standardized promo, installment and DownPay logs. Used across `app/payment`, `app/downpay` and `components/CardComponentV2`.

**Path alias:** `tsconfig.base.json` maps `@/*` to `["./*", "./app/*"]`. So `@/lib/...` is root `lib/`, and `@/downpay/...` is `app/downpay/`. The same module can be imported as `@/app/downpay/x` or `@/downpay/x`. Root wins on a name clash (`@/lib/hooks` is root `lib/hooks`, never `pages/smart_pay/lib/hooks`).

**File extensions:** `pageExtensions: ['page.tsx', 'page.ts', 'api.ts', 'jsx']`. Routes must be `page.page.tsx`, `layout.page.tsx` or `route.api.ts`, and `middleware.page.ts` is the middleware. Under `pages/`, any `*.page.tsx` is a route, so helpers and components there must not use that suffix (`pages/smart_pay/[method]/dana.page.tsx` breaks this rule and is reachable as a URL). The `[app-router]` comments mark what to rename once the Pages Router is gone.

### Gotcha: AGENTS.md says "app directory only"
AGENTS.md's Architecture section says "**Framework**: Next.js 14 App Router (`app` directory only)". On `origin/main` that is wrong twice. The main product routes (`/payment/**`, `/smart_pay/**`) are Pages Router pages in `pages/`, which has 300 files including `_app`, `_document`, `script.tsx` and `global.scss`. The framework is Next 16, not 14. The same file contradicts itself, since it has a "Promo Flow (Pages Router)" section, a Pages Router test-utils row, and a rule against *new* Pages Router pages. Read that rule as "new routes go in `app/`". Changes to the existing landing or smart_pay still happen under `pages/` (route files, `getServerSideProps`) and in non-route `app/` modules. README's "`/app/` # Next.js 14 App Router pages and API routes" has the same version drift.

## Request flow
1. **Middleware** (`middleware.page.ts`): `chain([nonceMiddleware, localeMiddleware, currencyMiddleware, rewriteMiddleware])`, with the locale and currency modules taken from `@tiket/next/server`. The matcher skips `api`, `_next/*`, `ms-gateway`, `favicon.ico`, `.well-known` and prefetch requests.
   - `rewriteMiddleware`: paths in `APP_ROUTER_PATHS = ['/l', '/payment-link']` get the `/xx-yy` locale-country prefix **stripped** (the App Router has no i18n). Every other path is rewritten to `/${locale}${pathname}` for Pages Router i18n (`locales: ['en','id']`, default `id`, `localeDetection: false`).
   - `nonceMiddleware` (production only): generates a UUID nonce, sets `x-nonce` on the request and a strict CSP on the response (Juspay, Forter, GTM/ads, BliPay iframe, Apple/Google Pay, GCS for QRIS images), and reports to `/api/csp-report`.
2. **Rewrites** (`next.config.ts`): from `@tiket/next/configs` `getRewrites(phase)`, plus legacy `/next/v4` → `/payment`, `/next/v4/pay/:type` → `/payment/:type`, `/next/smart_pay/*` → `/smart_pay/*`, `/:prefix/api/post-log` → `/api/post-log`, and `/.well-known/apple-app-site-association` → an env-specific AASA JSON (prod/preprod/gatotkaca chosen from `NEXT_PUBLIC_NON_PREFIXED_HOSTNAME`).
3. **Hosts:** `payment.tiket.com` / `mpayment.tiket.com` in production (README table has staging/preprod). Pages Router pages that care about this check whether they run on the new domain or the old `/next/v4` path, e.g. `pages/payment/[type]/index.page.tsx`.

## Build and bundling
- `next build --webpack` (Next 16, webpack, not Turbopack). `output: 'standalone'`, and the Docker runner starts `node server.js`.
- Client-only `ModuleFederationPlugin({ name: pkg.name })` with no exposes or remotes. It sets up a federation container so remote components from [[react-common-remote]] (e.g. `RemoteHeader`, `RemoteFooterDesktop`, `RemoteGlobalPopup`, served from TIX-REACT-REMOTE) can load. See [[module-federation]].
- `SubresourceIntegrity` (sha512) from `@tiket/next` in production.
- `transpilePackages`: all `@tiket/passport*` deps, `@tiket/next`, `@tiket/react-common-remote` and `@tiket/react-common-utilities`. The comment says this is needed only while the Pages Router exists. `optimizePackageImports` covers the passport packages.
- `typescript.ignoreBuildErrors: true`: type-checking is a separate `tsc --noEmit` step, because Next 16 type-checks the sources of transpiled packages.
- A webpack alias redirects `next/dist/server/route-modules/app-page/vendored/contexts/html-context` to the shared-runtime module. It works around a Next 16 path move.
- `generateBuildId` = `NEXT_PUBLIC_BASE_PREFIX_FOR_APP + '__' + next-build-id`. `assetPrefix` comes from `@tiket/next`.
- `.lottie` files are webpack `asset/resource`.

## Providers and contexts
**App Router** (`lib/providers/AppRouterProvider.tsx`): MiddlewareData → Global (device, locale, payment-link `isProcessingScreenVisible`) → `QueryClientProvider` → LocaleCountry → `I18nProvider` → `PassportProvider` (env, currency, locale, `isNewURLStructure`) → WindowSize → `ReactRemoteProvider` (sessionData) → `SnackbarProvider` → `ForterProvider` → `ForwardParamsProvider`. It also calls `usePageVisitAnalytics`.

**Pages Router payment pages** (`components/providers/PaymentPageProvider`, through `withPaymentPageProvider`): Global → Time → Session → Order → Landing → Payment → Promo → DownPayment → PaymentNudge → CreditcardRequest → CheckVersion. It blocks rendering on `useCheckVersion`.

**Context inventory**
- `lib/context/` has 10 files. The 8 that AGENTS.md lists (Global, Payment, Landing, Order, Session, Time, WindowSize, HyperService) plus `CheckVersionContext` and `ForterContext`. The `lib/context` barrel exports everything **except `HyperServiceContext`** (the Juspay HyperCheckout SDK loader), which is imported by path.
- Feature contexts outside `lib/context`: `app/contexts/DownPayContext`; `app/payment/context/{PromoContext, PromoTixpointResolverProvider, InstallmentContext, CreditcardRequestProvider, PaymentMethodAccountLinkageProvider}`; `app/payment-link/context/PaymentLinkProvider`; `pages/payment/providers/PaymentPersistenceStatusProvider`; `pages/smart_pay/lib/context` (`SmartPayContext`, never mounted; see [[payment-fe-smart-pay]]).
- So the AGENTS.md rule "use ONLY these 8 contexts" describes the original core. Feature-scoped providers are the pattern in `app/`.

## Data layer
- **React Query v5** (`@tanstack/react-query ^5.90`). AGENTS.md's header still says v3.39.2 but its rules say v5. `lib/providers/QueryClient.ts` creates one browser singleton (and a new client per server request) with `refetchOnMount/WindowFocus/Reconnect: false`.
- **Layout:** `lib/services/*` (fetch functions), `lib/queries/*` (`useQuery` hooks), `lib/mutations/*`. Feature folders keep their own `services/` and `hooks/` (e.g. `app/payment/services/promo`, `app/downpay/services`, `app/l/[id]/services`). Several "get" calls are mutations, not queries: landing data (`useGetLandingData`) and DownPay detail.
- **HTTP:** `fetchClient` from `@tiket/next/client` (credentials, standardized logging, per-call `filterOutRequestBodyInLogs`/`filterOutResponseBodyLogs`). `lib/helpers/coreFetcher.ts` wraps it as a `fetch`. Services return `error(e)` from `lib/utils` instead of throwing.
- **Endpoints** are defined twice: `API_ENDPOINT` in `lib/config.ts` (landing v4, payment group, payment method…) and a separate `API_ENDPOINT` in `lib/endpoint.ts` (discount incl. promo v2, order, payment, members, tiket points). Backends: `tix-payment-core`, `tix-payment-callback`, `tix-loyalty-core`, `tix-order-composer`, `tix-my-order-core`, `tix-member-core`, `tix-member-session`, `tix-discount-engine`. Request and response types follow `XRequest`/`XResponse` (AGENTS.md).
- **Mocks:** MSW (`lib/mocks/msw-*.ts`, `handlers/`, `data/`). The browser worker is started by `components/MSWInit` when `NEXT_PUBLIC_API_MOCKING=enabled`, and `NEXT_PUBLIC_MOCK_PRODUCT_TYPE` picks the vertical fixture.

## lib/ map
| Path | Role |
|---|---|
| `config.ts`, `config/` | env-derived URLs (`HOME_URL`, `API_ENDPOINT`), `setupServerGlobals`/`setupClientGlobals`, dayjs setup |
| `endpoint.ts` | second endpoint map (see above) |
| `context/`, `providers/` | contexts and router providers |
| `services/`, `queries/`, `mutations/` | data layer |
| `helpers/` | `checkoutStatusRecovery` (reopen gate), `checkStatusCooldown`, BIN/co-brand resolution, `sanitizeHtml`/`parseSanitizedHtml` (isomorphic-dompurify), `getPaymentNudges`, `urls` |
| `hooks/` | `useCheckVersion`, `useConfirmPaymentFlow`, `useGTM`, `usePreventPageLeave`, `useSkipStaleLandingEntry`, `useAppsNavOverlay`, `useMemberPhoneOtp`, `useLazyQuery`… |
| `i18n/` | `createI18n`, `client.ts` (`useI18n`), `server.ts` (`i18nServer`, `getI18nDict`), `pages.ts`; dictionaries `en.ts`/`id.ts` plus `downpay/`, `landing-page/`, `payment-link/`, `promo/` |
| `logger/` | `standardizedLogData` (SDC fields for Kibana: accountId, email, correlationId, orderId) + `sanitize/` |
| `jsi/`, `jsi.ts`, `utils/deeplink.ts` | native webview bridge detection (`window.native`/`window.webkit`) and deeplinks |
| `device/` | server/pages device detection (`ua-parser-js`) |
| `tracker/`, `gtm.ts` | GTM dataLayer types, vertical names. See [[gtm-datalayer-tracking]] |
| `jwt/`, `forms/`, `rules.ts`, `core/` | JWT parse/expiry, card form schema, validation rules, constants |
| `mocks/`, `test-utils.tsx`, `test-utils-app-router.tsx` | MSW and test render helpers |
| `types/` | API and entity types |

## External integrations
- **Juspay HyperCheckout** (`lib/context/HyperServiceContext.tsx`, loads `https://payments.juspay.in/payment-page/HyperServices.js`).
- **Forter** fraud detection (`lib/context/ForterContext.tsx`, `scripts/ForterScript.tsx` injected with the CSP nonce). Design doc: `docs/FORTER_INTEGRATION.md`.
- **tiket.com shared packages:** [[passport-umbrella|passport]] and sub-packages for UI, `@tiket/next` for middleware, auth/log API routes, fetch and logger. React-common: [[react-common-remote]], [[react-common-storage]], [[react-common-analytic]], [[react-common-queue]], [[react-common-utilities]].

## Sources
- `next.config.ts`, `middleware.page.ts`, `lib/middlewares/nonceMiddleware.ts`, `tsconfig.base.json`
- `app/layout.page.tsx`, `pages/_app.page.tsx`, `pages/_document.page.tsx`, `pages/script.tsx`, `pages/global.scss`, `lib/providers/AppRouterProvider.tsx`, `lib/providers/QueryClient.ts`, `components/providers/AppProvider.tsx`
- `app/utils/date/index.ts`, `app/utils/logger/constants/flows.ts`, `app/hooks/useDateFormatters.ts`
- `components/providers/PaymentPageProvider/PaymentPageProvider.tsx`
- `lib/context/index.tsx`, `lib/context/HyperServiceContext.tsx`, `lib/endpoint.ts`, `lib/config.ts`, `lib/helpers/coreFetcher.ts`, `lib/logger/index.ts`, `lib/jsi/index.ts`
- `README.md`, `AGENTS.md`, `.cursor/rules/typescript-react.mdc`
- git history: `cf0a95e61` (initial Create Next App, 2021), `30553fcd9` (#678 Next 14, adds `app/`), `7d8f904fc` (#953, last `pages/api` file removed), `77ee868c1` (#941 URL restructure), `1f7dc5f43` (#1181 payment link), `fceeae567` (#1155 DownPay), `6d0b2c385` (#1430 Infinity Promo)
