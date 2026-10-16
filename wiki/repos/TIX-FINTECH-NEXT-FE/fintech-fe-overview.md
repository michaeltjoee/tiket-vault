---
title: TIX-FINTECH-NEXT-FE overview
repo: TIX-FINTECH-NEXT-FE
kind: overview
sources:
  - package.json
  - README.md
  - CHANGELOG.md
  - .github/CODEOWNERS
  - .env.local.example
  - app
  - pages
  - projects
verified_at: 5833b842
updated: 2026-10-16
status: current
tags: [repo/fintech-fe, kind/overview]
---

# TIX-FINTECH-NEXT-FE overview
> Next.js 16 app (`tix-fintech-next-fe`, v1.4.0, private) serving tiket.com's fintech/platform products: insurance (claim center, standalone purchase, post-booking popup), refund and gift card.

## Products and routes

| Product | Router | Public route(s) | Code lives in | Page |
|---|---|---|---|---|
| Gift card (buy, redeem) | App | `/gift-card`, `/gift-card/checkout[/id]`, `/gift-card/redeem/[code]` | `app/gift-card/*` (legacy, not yet moved) | [[fintech-fe-gift-card]] |
| Gift card order detail (shared link) | App | `/gift-card/order/detail` via `app/(external)` | `app/(external)/gift-card` | [[fintech-fe-external]] |
| Insurance claim center | App | `/insurance-claim/*` | `projects/insurance/claim-center` | [[fintech-fe-insurance-claim]] |
| Standalone insurance purchase | Pages | `/insurance`, `/insurance/search`, `/insurance/pdp/[productId]`, `/insurance/checkout/[cartId]` | `projects/insurance/standalone` | [[fintech-fe-insurance-standalone]] |
| Insurance popup (post-booking upsell) | Pages | `/insurance-popup/[uniqueSignature]` | `projects/insurance/popup` | [[fintech-fe-insurance-popup]] |
| Refund (my-refund v4, smart refund) | Pages | `/my-refund/v4/refunds/...`, `/myorder/smart-refund` | `projects/refund` | [[fintech-fe-refund]] |
| API routes | App | `/api/{ping,post-log,create-token,refresh-token}` | `app/api` | [[fintech-fe-api]] |

Shared repo-wide UI is on [[fintech-fe-components]]. Structure, data flow and middleware are on [[fintech-fe-architecture]]; dev, test and release on [[fintech-fe-workflows]].

## Tech stack
- Next 16 (Webpack mode, not Turbopack), React 19, TypeScript, SCSS modules. Both App Router and Pages Router run side by side ([[fintech-fe-architecture]]).
- `@tiket/next` (the tiket Next core: middleware chain, fetch, logger, `getMiddlewareData`) — not one of the workspace repos. See [[tiket-next-core]].
- UI from [[passport-overview|TIX-PASSPORT]] (`@tiket/passport` plus [[passport-insurance]], [[passport-insurance-pop-up]], [[passport-refund-method]], [[passport-page-module]], [[passport-picker]], [[passport-banner-carousel]], [[passport-breadcrumb]], `passport-icons`, `passport-assets`, `passport-design-tokens`, `passport-utils`, all `^12.4.3`). Header/footer come as remote components through `@tiket/react-common-remote` ([[react-remote-overview|TIX-REACT-REMOTE]], [[module-federation]]).
- [[react-common-overview|TIX-REACT-COMMON]] packages: [[react-common-remote]], [[react-common-fetch-client]], [[react-common-error-handler]], [[react-common-utilities]], [[react-common-storage]], [[react-common-navigator-permission]]; [[react-common-gatekeeper]] runs in CI. `react-common-ab-test` is not a dependency but has a stub in `__mocks__/` and `vitest.setup.tsx`.
- State/data: TanStack Query v5, zustand, react-hook-form + zod.
- Tests: Vitest (migrated from Jest) + Testing Library + MSW 2; Playwright for E2E.

## Who consumes it
It is a deployed app, not a library. Inbound links from other repos:
- [[passport-header]] has a menu entry linking to `/insurance-claim` (`packages/header/src/utils/Constants.ts` in TIX-PASSPORT).
- TIX-NEXT-PAYMENT-FE mock data links to `/insurance-claim/faq/<id>?hideToolbar=true` (`lib/mocks/data/standalone-insurance/order-composer.json`), i.e. payment pages deep-link into the claim center FAQ inside webviews.
- [[react-common-gatekeeper]] carries a Sonar project config for `tix-fintech-next-fe` (`packages/react-common-gatekeeper/src/sonar/projects/` in TIX-REACT-COMMON), which the Jenkins gate uses.

## Commands
| Command | What |
|---|---|
| `pnpm dev` | sources `.env.local`, runs `next dev --experimental-https --webpack` with the local `local.tiket.com` cert |
| `pnpm build` / `pnpm start` | `next build --webpack` (8 GB heap); `start` runs `next start` plus a local SSL proxy 3001→3000 |
| `pnpm test` | Vitest with coverage and `-u` (updates snapshots); `pnpm test:ci` without `-u` |
| `pnpm e2e` | Playwright |
| `pnpm check-all` | type-check, eslint, stylelint, prettier, test (also the pre-push hook) |

## Owners
CODEOWNERS: @rahmatkurniawantiket, @imbarwinata-tix, @jonathan-tiket, @dvnchristian, @michaeltjoee, @achwahyu-tiket.

## Gotchas
- README still says `npm i` and Node 16; the real toolchain is pnpm 9.15.9 and Node 24.14.1 (Volta in `package.json`). Install needs `GITHUB_TOKEN` with `read:packages` for `@tiket/*`.
- Many tiket backends need a CORS-disabled browser locally (README step 6).
- Some declared dependencies have no direct imports on the baseline: `@tiket/passport-review-widget`, `@tiket/passport-header`, `@tiket/react-common-eagle-eye`, `@tiket/react-common-core-attributes`. The two passport ones still land in `transpilePackages`/`optimizePackageImports`, which `next.config.js` computes from every `@tiket/passport*` dependency.
- `learning-records/` and `lessons/` exist only as empty, untracked directories in the local checkout; the team knowledge actually lives in `docs/`, `.claude/rules/`, `.cursor/rules/` and `.cursor/skills/` (summarised on [[fintech-fe-workflows]] and [[fintech-fe-architecture]]).

## Sources
- `package.json`, `README.md`, `CHANGELOG.md`, `.github/CODEOWNERS`, `.env.local.example`
- `app/`, `pages/`, `projects/` (route inventory)
- TIX-PASSPORT `packages/header/src/utils/Constants.ts`; TIX-NEXT-PAYMENT-FE `lib/mocks/data/standalone-insurance/order-composer.json`; TIX-REACT-COMMON `packages/react-common-gatekeeper/src/sonar/projects/index.ts`
