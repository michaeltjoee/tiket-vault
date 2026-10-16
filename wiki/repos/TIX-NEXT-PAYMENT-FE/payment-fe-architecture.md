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

## Two routers in one app
The app runs **Pages Router and App Router side by side**. README calls `pages/` "Legacy Pages Router (being migrated)". AGENTS.md forbids new Pages Router pages.

| Router | Routes | Root |
|---|---|---|
| Pages (`pages/`) | `/payment` landing, `/payment/[type]/{confirm,complete,callback}`, `/payment/payment-partner`, `/smart_pay` (saved methods, binding, top-up, DANA) | `pages/_app.page.tsx` → `components/providers/AppProvider` |
| App (`app/`) | `/payment-link/**`, `/l/[id]`, `/api/*` | `app/layout.page.tsx` → `lib/providers/AppRouterProvider` |

Feature code for Pages Router routes is increasingly written under `app/` without being a route: `app/payment/` (promo, points, installment, linkage) and `app/downpay/` are imported by `pages/payment/index.page.tsx`. See [[payment-fe-payment]], [[payment-fe-downpay]], [[payment-fe-payment-link]], [[payment-fe-l]], [[payment-fe-api]], [[payment-fe-root]].

**Path alias:** `tsconfig.base.json` maps `@/*` to `["./*", "./app/*"]`. So `@/lib/...` is root `lib/`, and `@/downpay/...` is `app/downpay/`. The same module can be imported as `@/app/downpay/x` or `@/downpay/x`.

**File extensions:** `pageExtensions: ['page.tsx', 'page.ts', 'api.ts', 'jsx']`. Routes must be `page.page.tsx`, `layout.page.tsx` or `route.api.ts`, and `middleware.page.ts` is the middleware. The `[app-router]` comments mark what to rename once the Pages Router is gone.

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
- Feature contexts outside `lib/context`: `app/contexts/DownPayContext`; `app/payment/context/{PromoContext, PromoTixpointResolverProvider, InstallmentContext, CreditcardRequestProvider, PaymentMethodAccountLinkageProvider}`; `app/payment-link/context/PaymentLinkProvider`; `pages/payment/providers/PaymentPersistenceStatusProvider`; `pages/smart_pay/lib/context`.
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
- **tiket.com shared packages:** [[passport-passport|passport]] and sub-packages for UI, `@tiket/next` for middleware, auth/log API routes, fetch and logger. React-common: [[react-common-remote]], [[react-common-storage]], [[react-common-analytic]], [[react-common-queue]], [[react-common-utilities]].

## Sources
- `next.config.ts`, `middleware.page.ts`, `lib/middlewares/nonceMiddleware.ts`, `tsconfig.base.json`
- `app/layout.page.tsx`, `pages/_app.page.tsx`, `lib/providers/AppRouterProvider.tsx`, `lib/providers/QueryClient.ts`
- `components/providers/PaymentPageProvider/PaymentPageProvider.tsx`
- `lib/context/index.tsx`, `lib/context/HyperServiceContext.tsx`, `lib/endpoint.ts`, `lib/config.ts`, `lib/helpers/coreFetcher.ts`, `lib/logger/index.ts`, `lib/jsi/index.ts`
- `README.md`, `AGENTS.md`
