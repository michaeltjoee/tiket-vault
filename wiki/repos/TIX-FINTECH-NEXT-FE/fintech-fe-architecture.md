---
title: TIX-FINTECH-NEXT-FE architecture
repo: TIX-FINTECH-NEXT-FE
kind: architecture
sources:
  - next.config.js
  - middleware.page.ts
  - tsconfig.json
  - app/layout.page.tsx
  - app/error.page.tsx
  - app/setup-react-cache-workaround.ts
  - pages/_app.page.tsx
  - components/providers
  - lib/fetch
  - lib/middlewares/validateSessionAppRouter.ts
  - docs/data-fetching.md
  - docs/deployment.md
  - docs/i18n.md
  - .claude/rules/project-structure.md
  - .claude/rules/project-route-reexports.md
  - .claude/rules/next-config-next16.md
  - .cursor/skills/project-restructure/SKILL.md
verified_at: 5833b842
updated: 2026-10-16
status: current
tags: [repo/fintech-fe, kind/architecture]
---

# TIX-FINTECH-NEXT-FE architecture

## Layout: team verticals under `projects/`
Team code lives in `projects/{team}/{shared|product}/{feature}`; `app/` and `pages/` hold thin route re-exports (`export { default, generateMetadata } from '@insurance/claim-center/landing'`). Only `layout.page.tsx` may hold logic (provider wiring). Each re-export gets a spec asserting the module is defined (e.g. `app/insurance-claim/__tests__/pages.spec.tsx`). Rule source: `.claude/rules/project-structure.md`, `.claude/rules/project-route-reexports.md`; step-by-step move: `.cursor/skills/project-restructure/SKILL.md`.

| Team | Alias (`tsconfig.json`) | Path | Migration |
|---|---|---|---|
| insurance | `@insurance/*` | `projects/insurance/*` (`claim-center`, `standalone`, `popup`, `shared`) | done |
| refund | `@refund/*` | `projects/refund/*` | done |
| gift-card | `@gift-card/*` | `app/gift-card/*` | pending; still full feature code inside `app/` |

Repo-wide infra stays at root: `@/lib/fetch`, `@/lib/test-utils`, `@/components/providers`, middleware, global MSW bootstrap. A new alias must be added in `tsconfig.json`, `vitest.config.mts` and the `simple-import-sort` groups in `eslint.config.cjs`.

## Two routers in one app
- `next.config.js` sets `pageExtensions: ['page.tsx','page.ts','jsx']`, so App Router files are `page.page.tsx`, `layout.page.tsx`, `route.page.ts`, and middleware is `middleware.page.ts`. Comments marked `[app-router]` say to drop this once Pages Router is gone.
- **App Router**: `/gift-card`, `/insurance-claim`, `/api` (the `APP_ROUTER_PATHS` list in middleware). Root `app/layout.page.tsx` calls `setupServerGlobals()`, reads `getMiddlewareData()`, mounts `MSWInit`, and imports `setup-react-cache-workaround` (registers React `cache` with `@tiket/next`). Route layouts wrap children in `AppRouterProvider`.
- **Pages Router**: insurance standalone, insurance popup, refund. `pages/_app.page.tsx` wraps everything in `ErrorBoundary` → `AppProvider`, imports passport design-token CSS, and renders `RemoteScripts`, `GTMScripts`, `ServiceWorkerScripts`. Pages can define `getLayout`.
- `AppProvider` (Pages) vs `AppRouterProvider` (App) differ: only `AppProvider` passes a `customFetch` (`coreFetcher`) into `PassportProvider`, hydrates React Query `dehydratedState`, and adds `AnalyticsProvider`/`AppContext` (snackbar offset). `AppRouterProvider` instead runs `usePageVisitAnalytics` with a regex config (`/gift-card` → vertical `giftCard`, `/insurance-claim` → `insurance`). Both create a QueryClient with all refetch-on-* turned off.

## Middleware (`middleware.page.ts`)
`chain([localeMiddleware, currencyMiddleware, rewriteMiddleware])` from `@tiket/next/server`. The custom `rewriteMiddleware`:
1. Refund path with `authResult=cancel|failed` → redirect to `NEXT_PUBLIC_LINK_HOME` (PLAT-38603).
2. `/my-refund` and `/my-refund/v4` (bare) → redirect to `/yourorder`, dropping `utm_section`/`utm_logic`.
3. Logs every `sec-fetch-mode: navigate` request with `standardizedLogData` (kept lean on purpose).
4. New URL structure `/{lang}-{country}/...` (e.g. `/en-id/gift-card`): App Router paths are rewritten to the path without the prefix; other paths fall through.
5. App Router paths get `NextResponse.next()` (no locale rewrite) and an `x-url` request header; everything else is rewritten to `/{locale}{pathname}` for Pages Router i18n (`locales: en,id`, default `id`, `localeDetection: false`).

`x-url` is what `validateSessionForPrivatePage()` (`lib/middlewares/validateSessionAppRouter.ts`) uses as the `ref` when it redirects to `/login` (with `/{lang}-{country}` prefix when `isNewURLStructure`). It returns silently if `x-url` is missing, and redirects unconditionally otherwise, so callers must check login first.

## Data fetching
Three entry points (`docs/data-fetching.md`):

| Import | Use |
|---|---|
| `@/lib/fetch` | Pages Router client and `getServerSideProps` (server when `initArg.ctx` has `req`/`res`) |
| `@/lib/fetch/app-router/client` | App Router client components |
| `@/lib/fetch/app-router/server` | RSC, Server Actions, route handlers (`server-only`, wraps `fetchServer`) |

All wrap `@tiket/next` fetch, which handles gateway URL transformation (client `{base}/ms-gateway/<svc>`, server `{SERVER_SIDE_SERVICE_ENDPOINT}/gateway/<svc>`), auth header, guest-token creation (`createGuestToken` default true) and JWT refresh. URLs matching `NEXT_PUBLIC_THIRD_PARTY_URL` (comma-separated, e.g. GCS buckets) bypass the wrapper and its logging. Convention: every service-layer call passes `sendStandardizedLogData: () => standardizedLogData({...})` so logs carry Kibana-searchable SDC fields (`accountId`, `email`, `correlationId`, optional `orderId`, always `isConsumerFe: true`). See [[structured-diagnostic-logging]].

Gotcha: `@/lib/fetch/app-router/server` destructures `skipAuth`, `createGuestToken`, `retry`, `locale` and `opts` out of the options and does not forward them to `fetchServer`. Pass `RequestInit` fields (`method`, `body`, `headers`) at the top level, not under `opts`, and don't expect `skipAuth`/`createGuestToken` to have any effect there.

## Build and deployment
- Webpack only: client build adds an empty `ModuleFederationPlugin({ name: 'tix-fintech-next-fe' })` so the app can host remote components ([[module-federation]]); Next 16 Turbopack can't run it, hence `--webpack` on every script (`.claude/rules/next-scripts-pnpm-webpack.md`).
- `SubresourceIntegrity` (sha512) in production; `.lottie` files as asset resources; `canvas` aliased to `false` (pulled in by refund deps).
- `transpilePackages` and `optimizePackageImports` are computed from every `@tiket/passport*` dependency in `package.json`.
- `output: 'standalone'` for Docker; `serverExternalPackages: ['isomorphic-dompurify','jsdom','ua-parser-js']` because bundling jsdom breaks its `__dirname` stylesheet reads at runtime.
- `generateBuildId` = `NEXT_PUBLIC_BASE_PREFIX_FOR_APP + '__' + git build id`; the prefix is `fintech`. The LB must route `/fintech/_next/*`, `/_next/data/fintech__*` and `/fintech/api/*` to the app (`docs/deployment.md`); `getRewrites` from `@tiket/next` rewrites any prefixed `/…/api/*` to `/api/*`.
- `experimental.clientRouterFilter: false`: the router bloom filter gave false positives on refund URLs (e.g. `/en/my-refund/v4/refunds/1200887827`), forcing a hard navigation that wiped the in-memory zustand store between refund steps.
- Images: `remotePatterns` from `TIKET_LIGHTROOM_HOSTNAMES` in `@tiket/passport-assets/config.cjs` (Next 16 drops `images.domains`).

## i18n
Rosetta-style dictionaries (`I18nDict` type + `en.ts`/`id.ts`), `useI18n()` in components and `createI18n(locale)` on the server (`docs/i18n.md`). Each team has its own dictionaries (`app/gift-card/i18n`, `projects/insurance/shared/lib/i18n`, `projects/refund/shared/lib/i18n`); interpolation params are not type-checked.

## Error handling
`app/error.page.tsx` logs via `createLogger('error-page')` and renders passport `ErrorView` with `RemoteHeader`/`RemoteFooterDesktop`. It reads middleware data from `window.__NEXT_DATA__`. Under App Router that object only exists because route layouts mount `MiddlewareDataAppRouterScripts` ([[fintech-fe-components]]); without it the page falls back to a bare `ErrorView`. Retry uses `router.refresh()` because `reset()` only works inside an error boundary.

## Sources
- `next.config.js`, `middleware.page.ts`, `tsconfig.json`
- `app/layout.page.tsx`, `app/error.page.tsx`, `app/setup-react-cache-workaround.ts`, `pages/_app.page.tsx`
- `components/providers/AppProvider.tsx`, `components/providers/AppRouterProvider.tsx`
- `lib/fetch/fetch.ts`, `lib/fetch/app-router/server.ts`, `lib/middlewares/validateSessionAppRouter.ts`
- `docs/data-fetching.md`, `docs/deployment.md`, `docs/i18n.md`
- `.claude/rules/project-structure.md`, `.claude/rules/project-route-reexports.md`, `.claude/rules/next-config-next16.md`, `.claude/rules/next-scripts-pnpm-webpack.md`, `.cursor/skills/project-restructure/SKILL.md`
