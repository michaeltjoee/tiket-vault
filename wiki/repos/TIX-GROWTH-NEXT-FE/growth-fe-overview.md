---
title: TIX-GROWTH-NEXT-FE overview
repo: TIX-GROWTH-NEXT-FE
kind: overview
sources:
  - package.json
  - README.md
  - next.config.js
  - middleware.page.ts
  - rewrite-path-config.js
  - .env.local.example
  - pages
  - app
  - components
  - lib
  - docs
  - .github/CODEOWNERS
  - pnpm-lock.yaml
verified_at: d4162e3
updated: 2026-10-16
status: current
tags: [repo/growth-fe, kind/overview]
---

# TIX-GROWTH-NEXT-FE overview
> The Growth team's Next.js app: travel stories (SEO articles), the flight SEO sitemap, affiliate and co-brand landing pages, the Google Flights B2B booking hand-off, metasearch partner redirects and checkout, and the Blibli affiliate landing page.

## What it is
A Next.js **Pages Router** app (`tix-growth-next-fe`, private, v1.2.1 on the baseline), served under the asset/API prefix `growth` (`NEXT_PUBLIC_BASE_PREFIX_FOR_APP`). It started from the same tiket Next starter as [[homepage-fe-overview|TIX-HOMEPAGE-NEXT-FE]] and pulls in routes migrated from the older TIX-NEXT-FE monolith (`.cursor/rules` and the middleware comments say "mirrors TIX-NEXT-FE"). The routes fall into two groups:
- **SEO content** (`/stories/**`, `/sitemap`): server-rendered with CDN cache headers and JSON-LD.
- **Acquisition hand-offs** (`/affiliate/**`, `/metasearch/**`, `/blibli-affiliate`): pages that a partner (Google Flights, TikTok, ShopBack, affiliates) links to. They mostly resolve the partner's parameters, set attribution and redirect into the normal tiket funnel (search, PDP, cart or payment).

The README is partly out of date: it says Next 14 and a `packageManager` field. The real stack is Next 16, and `package.json` has no `packageManager`. The current docs are `docs/flow/*.md` (FE↔BE sequence docs for each affiliate and metasearch flow) and `.cursor/rules`.

## Features
| Route(s) | Page file(s) | Wiki page |
|---|---|---|
| `/stories`, `/stories/[type]`, `/stories/[type]/[slug]`, `/stories/tags/[slug]` | `pages/stories/**` | [[growth-fe-stories]] |
| `/sitemap`, plus the SEO rewrites `/pesawat/maskapai`, `/flights/airlines`, `/pesawat/rute`, … → `/sitemap` | `pages/sitemap/**`, `rewrite-path-config.js` | [[growth-fe-sitemap]] |
| `/affiliate/book/[product]` (Google Flights B2B), `/affiliate/c/[slug]` (co-brand landing), `/affiliate/r/[slug]` (affiliate redirect) | `pages/affiliate/**` | [[growth-fe-affiliate]] |
| `/blibli-affiliate` | `pages/blibli-affiliate/**` | [[growth-fe-blibli-affiliate]] |
| `/metasearch/r/[slug]` (partner redirect), `/metasearch/c/[dcoCartId]` (TikTok DCO checkout) | `pages/metasearch/**` | [[growth-fe-metasearch]] |
| `_app`, `_document`, `_error`, App Router `layout`/`not-found`, GTM | `pages/_*.page.tsx`, `app/layout.page.tsx`, `app/not-found.page.tsx` | [[growth-fe-app-shell]] |
| `/api/create-token`, `/api/refresh-token`, `/api/post-log`, `/api/partner-config` | `app/api/**`, `pages/api/partner-config.page.ts` | [[growth-fe-api]] |
| Shared UI (`components/`, 10 folders) | `components/**` | [[growth-fe-components]] |

## Tech stack
- Next.js `^16.2.2` (Pages Router, `pageExtensions: ['page.tsx','page.ts']`, **webpack** build because of Module Federation, `output: 'standalone'`), React `^19.2.4`, TypeScript (`@/*` alias only), Sass modules with short hashed class names (`css-module-ident-config.js`).
- Data: `@tanstack/react-query` 5.90 with SSR `HydrationBoundary`, and `@tiket/next` fetch through `lib/fetch`.
- Quality: **Jest 30** + Testing Library + MSW 2 for unit tests, **Playwright** for E2E (`e2e/affiliate`, `e2e/metasearch`), ESLint 10 flat config, stylelint, Prettier, commitlint, husky, Sonar via [[gatekeeper-ci]].
- Others: `dayjs`, `isomorphic-dompurify` (story HTML), `lru-cache`, `ua-parser-js`, `uuid`.
- Node 24.14.1 (Volta, plus `use-node-version` in `.npmrc`). CI and Docker install with pnpm 9.

## Internal dependencies
- **@tiket/next** `3.3.1` (exact pin): middleware chain, `apiFetch`, i18n, token and post-log route handlers, `registerFetchMock` instrumentation, SRI plugin, asset prefix and rewrites. Not in this workspace, see [[tiket-next-core]].
- **Passport `^8.0.0`, resolved to 8.0.0.** That is four majors behind Passport's `main` (12.x, see [[passport-packages]]), so check the 8.x API before you copy usage from a Passport page in this wiki. Declared: [[passport-umbrella|@tiket/passport]], [[passport-assets]], [[passport-breadcrumb]], [[passport-design-tokens]], [[passport-icons]], [[passport-image]], [[passport-page-module]] (types and `getInitialData` only), [[passport-page-module-shared]] (`Carousel`/`Layout`), [[passport-typography]], [[passport-utils]]. `next.config.js` adds every `@tiket/passport*` dependency to `transpilePackages` and `optimizePackageImports`.
- **React-common:** [[react-common-remote]] `^3.0.0` (`ReactRemoteProvider`, `getReactRemoteProps`, `RemoteScripts`, remote header/footer), [[react-common-utilities]] `^4.0.0`, [[react-common-fetch-client]] (only `getCookie` in `lib/logger`), [[react-common-eagle-eye]] (declared, not imported in app source).
- **React-remote components** loaded at runtime through [[module-federation]]: [[react-remote-header]], [[react-remote-footer]], [[react-remote-scripts]].

## Backends
Reached through `@tiket/next` fetch (relative gateway paths) unless noted:
- `tix-seo-control` (`/v1/stories`, `/v1/seo-contents`) and `tix-flight-seo` (`/site-map`) for stories and sitemap.
- `tix-affiliate-platform` (flight search and stream) and `tix-flight-cart/v5/b2b/metasearch/cart`, both through `apiGateway: 'b2b-gateway'`, for the Google Flights book flow. `next.config.js` proxies `/b2b-gateway` and `/partner-gateway` to `gatotkaca.tiket.com` only under `next dev`. No app code calls `/partner-gateway` directly.
- Affiliate partner services on **internal cluster hosts**, called from SSR: `NEXT_PUBLIC_AFFILIATE_NONA_INGRESS` (`tix-affiliate-nona-internal`, co-brand config) and `NEXT_PUBLIC_AFFILIATE_BE_INTERNAL_SERVICE` (`tix-affiliate-partner-internal`, partner validation).
- Metasearch book: `POST /meta/partner/tk2/hotel/carts/{id}/book` through the default gateway. `NEXT_PUBLIC_METASEARCH_API_ENDPOINT` is in `.env.local.example`, but nothing reads it.Details per feature on the feature pages.

## Who uses it
- End users who arrive from Google search (stories, sitemap), Google Flights, TikTok, ShopBack and affiliate links.
- [[react-common-gatekeeper]] holds this repo's Sonar project (`src/sonar/projects/tix-growth-next-fe.ts`).
- [[passport-header]] shows the partner logo that the co-brand page stores in sessionStorage (`aff-co-logo`, `tag_aff_id`; `packages/header/src/utils/cobrand/getCoBrandLogoUrl.ts`). See [[growth-fe-affiliate]].
- The Google Flights book flow replaces the legacy TIX-B2B-LANDING-FE (not in this workspace) and keeps that repo's attribution-tag order on purpose.
- No other repo in the workspace imports from this app on its baseline.

## Commands (short)
`pnpm test` (Jest + coverage) · `pnpm e2e` (Playwright) · `pnpm run check-all` · `pnpm run type-check` · `pnpm run lint:js` · `pnpm run build` · `pnpm dev` (needs local HTTPS). Full list in [[growth-fe-workflows]].

## Owners
CODEOWNERS: @rahmatkurniawantiket, @achwahyu-tiket, @bobkombat, @imbarwinata-tix, @kemsandiz, @michaeltjoee, @rullysaputra.

## Sources
- `package.json`, `README.md`, `next.config.js`, `middleware.page.ts`, `rewrite-path-config.js`, `.env.local.example`, `.github/CODEOWNERS`, `pnpm-lock.yaml` (resolved `@tiket/*` versions)
- `pages/`, `app/`, `components/`, `lib/` (tree listing on `origin/main`), `lib/config/apiUrl.ts`, `lib/services/*`
- `docs/flow/*.md`, `.cursor/rules/*.mdc`
- TIX-REACT-COMMON `packages/react-common-gatekeeper/src/sonar/projects/index.ts` (origin/master)
