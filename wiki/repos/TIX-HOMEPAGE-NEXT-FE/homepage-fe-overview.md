---
title: TIX-HOMEPAGE-NEXT-FE overview
repo: TIX-HOMEPAGE-NEXT-FE
kind: overview
sources:
  - package.json
  - README.md
  - AGENTS.md
  - next.config.ts
  - middleware.page.ts
  - .env.local.example
  - pages
  - app/api
  - components
  - lib
  - skills-lock.json
verified_at: 408983f6
updated: 2026-10-16
status: current
tags: [repo/homepage-fe, kind/overview]
---

# TIX-HOMEPAGE-NEXT-FE overview
> tiket.com's discovery web app: the home page, destination and explore (dynamic landing) pages, promo list and detail, voucher box and the cross-sell trip offer/prize pages, all built from [[passport-page-module]] content.

## What it is
A Next.js **Pages Router** app (`tix-homepage-next-fe`, private, v4.7.0 on the baseline). It is served under the asset/API prefix `homepage-v4` (`NEXT_PUBLIC_BASE_PREFIX_FOR_APP`) and owns the site root `/`, so its service worker (`serviceworker.js`) and offline page apply to other tiket paths too (see [[homepage-fe-architecture]]). Most pages are thin hosts for `tix-home` page-module payloads that Passport renders. The pages also run inside the native apps as webviews (`WebViewWrapper`, legacy-webview header handling in `components/Header`).

The README is the untouched `create-next-app` template. The real guidance is `AGENTS.md`, `.cursor/rules`, `.cursor/skills` and `docs/`.

## Features
| Route(s) | Page file(s) | Wiki page |
|---|---|---|
| `/` home | `pages/index.page.tsx` + `pages/home/**` | [[homepage-fe-home]] |
| `/destination/[slug]` (and `/destination` → redirect to `/`) | `pages/destination/**` | [[homepage-fe-destination]] |
| `/destination-preview/[id]` (CMS preview) | `pages/destination-preview/**` | [[homepage-fe-destination-preview]] |
| `/explore/[slug]` dynamic landing page (DLP) | `pages/explore/**` | [[homepage-fe-explore]] |
| `/explore-preview/[id]` (CMS preview) | `pages/explore-preview/**` | [[homepage-fe-explore-preview]] |
| `/promo/[[...category]]`, `/promo/[category]/[slug]`, `/promo/preview/[slug]` | `pages/promo/**` | [[homepage-fe-promo]] |
| `/voucher-box`, `/voucher-box/all` | `pages/voucher-box/**` | [[homepage-fe-voucher-box]] |
| `/cross-sell-trip`, `/cross-sell-trip/prize` | `pages/cross-sell-trip/**` | [[homepage-fe-cross-sell-trip]] |
| `_app`, `_document`, `_error`, `404`, `_offline`, GTM script, JSON-LD | `pages/_*.page.tsx`, `pages/404.page.tsx`, `pages/script.tsx`, `pages/jsonLd/` | [[homepage-fe-app-shell]] |
| Route handlers `/api/*` (token, session, post-log, ping) | `app/api/**` | [[homepage-fe-api]] |
| Shared UI (`components/`, 22 folders) | `components/**` | [[homepage-fe-components]] |

## Tech stack
- Next.js `^16.3.3` (Pages Router, `pageExtensions: ['page.tsx','page.ts']`, webpack build, `output: 'standalone'`), React `^19.2.4`, TypeScript, Sass modules.
- Data: `@tanstack/react-query` 5.90 (SSR `dehydrate` + `HydrationBoundary`), `@tiket/next` fetch through `lib/fetch`.
- PWA: `next-pwa` with custom Workbox runtime caching (`worker/`).
- Quality: Vitest 5 + Testing Library + MSW 2, ESLint 10 flat config, stylelint, Prettier, commitlint, husky, Sonar via [[gatekeeper-ci]].
- Others: `keen-slider` ([[keen-slider]]), `lottie-web`, `ua-parser-js`, `isomorphic-dompurify`, `rmc-pull-to-refresh`.
- Node 24.14.1 (Volta, `.nvmrc`), `pnpm@10.25.0`.

## Internal dependencies
- **@tiket/next** `3.3.0`: middleware chain, fetch, logger, i18n locale helpers, token/post-log route handlers, MSW instrumentation, SRI plugin and rewrites. Not in this workspace, see [[tiket-next-core]].
- **Passport** (all pinned to `12.5.0`): [[passport-umbrella|@tiket/passport]], [[passport-assets]], [[passport-breadcrumb]], [[passport-chips-carousel]], [[passport-country-and-currency-modal]], [[passport-design-tokens]], [[passport-error-view]], [[passport-floating-button]], [[passport-global-search]], [[passport-header]], [[passport-icons]], [[passport-image]], [[passport-notification-login]], [[passport-page-module]], [[passport-page-module-shared]], [[passport-product-card]], [[passport-review-widget]], [[passport-search-widget-flight]], [[passport-search-widget-ttd]], [[passport-social-share]], [[passport-utils]], [[passport-voucher-card]]. `next.config.ts` adds every `@tiket/passport*` dependency to `transpilePackages` and `optimizePackageImports`.
- **React-common:** [[react-common-remote]] `^3.0.2` (provider, `getReactRemoteProps`, `RemoteHeader`, `RemoteFooter`, `RemoteGlobalPopup`, `RemoteGoogleOneTap`, `RemoteCountryAndCurrencyModal`, `RemoteScripts`), [[react-common-ab-test]] `5.0.1` (`useExperiment` and `getAbTestOnServer`; pinned and also forced by a pnpm override), [[react-common-utilities]] (`getDeviceId`, cookies, currency types).
- **Declared but not imported** in app source on main: [[passport-country-and-currency-modal]], [[passport-notification-login]], [[passport-review-widget]], [[react-common-analytic]], [[react-common-eagle-eye]], [[react-common-fetch-client]]. They still matter: they are prebundled for Vitest and transpiled by Next, and the remotes and Passport packages use some of them at runtime (for example `window.commonAnalytic`).
- **React-remote components** loaded at runtime through [[module-federation]]: [[react-remote-header]], [[react-remote-footer]], [[react-remote-global-popup]], [[react-remote-google-one-tap]], [[react-remote-country-and-currency-modal]], [[react-remote-scripts]].

## Who uses it
End users through the tiket.com home page and the discovery/promo links. In the other repos:
- [[react-common-fetch-client]] defaults `basePrefixForApp` to `homepage-v4` (`packages/react-common-fetch-client/src/config.ts`), so a remote or app that doesn't set its own prefix calls this app's `/homepage-v4/api/...` routes. This app sets `NEXT_PUBLIC_POST_LOG_PATH=/api/homepage-post-log` so that stray default `post-log` calls don't land in its logs (see [[homepage-fe-api]]).
- TIX-NEXT-PAYMENT-FE `next.config.ts` keeps a `/:app-base-prefix/api/post-log` fallback rewrite because "post-log from core is sending /homepage-v4/api/post-log".
- [[react-common-gatekeeper]] holds this repo's Sonar project (`src/sonar/projects/tix-homepage-next-fe.ts`).
- The Passport [[page-module-next-poc]] (`next/dynamic` page-module registry) is validated here. That work is not on `origin/main`.

## Commands (short)
`pnpm test` (Vitest + coverage) · `pnpm run check-all` · `pnpm run type-check` · `pnpm run lint:js` · `pnpm run build` · `pnpm dev` (needs local HTTPS). `pnpm ctx …` is the agent context toolkit from AGENTS.md. Full list in [[homepage-fe-workflows]].

## Where to read more
- `AGENTS.md`: stack, path aliases (`@lib`, `@components`, `@context`, `@hooks`, `@pages`, `@middleware`; no `@/`), "never `console.log`", test-utils import rule, `pnpm ctx` toolkit.
- `.cursor/skills/` is the source of truth for skills; `.claude/skills/*` are symlinks into it (`pnpm run sync:claude-skills`). `.agents/skills/` are copies installed from `tiket/TIX-NEXT-FE` (`skills-lock.json`), and some are generic or out of date: `.agents/skills/testing` still says Jest and `@/lib/test-utils`.
- `docs/`: data-fetching, deployment, https-for-local-development, i18n, testing. They come from the old starter and are partly stale (see [[homepage-fe-workflows]]).
- [[homepage-fe-architecture]] for routing, middleware, providers, page-module and remote rendering.

## Sources
- `package.json`, `README.md`, `AGENTS.md`, `next.config.ts`, `middleware.page.ts`, `.env.local.example`, `skills-lock.json`
- `pages/`, `app/api/`, `components/`, `lib/` (tree listing on `origin/main`)
- `.agents/skills/testing/SKILL.md`, `.claude/skills/*` (symlinks)
- TIX-REACT-COMMON `packages/react-common-fetch-client/src/config.ts`, `packages/react-common-gatekeeper/src/sonar/projects/index.ts` (origin/master)
- TIX-NEXT-PAYMENT-FE `next.config.ts` (origin/main)
