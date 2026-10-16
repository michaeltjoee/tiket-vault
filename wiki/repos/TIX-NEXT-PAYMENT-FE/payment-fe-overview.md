---
title: TIX-NEXT-PAYMENT-FE overview
repo: TIX-NEXT-PAYMENT-FE
kind: overview
sources:
  - package.json
  - README.md
  - AGENTS.md
  - next.config.ts
  - middleware.page.ts
  - app
  - pages
  - components
  - lib
verified_at: 9e92b20bb
updated: 2026-10-16
status: current
tags: [repo/payment-fe, kind/overview]
---

# TIX-NEXT-PAYMENT-FE overview
> tiket.com's payment web app: the checkout payment page, payment confirmation and completion, payment links and saved payment methods.

## What it is
A Next.js app (`tix-next-payment-fe`, private, v3.0.1 on the baseline) deployed as the `next-payment-fe` service on `payment.tiket.com` / `mpayment.tiket.com` (staging `payment-gatotkaca`, preprod `payment.preprod`). Every vertical's checkout hands off here with `?order_id&order_hash`. The app is also opened inside the native apps as a webview (native bridge in `lib/jsi`, nav-overlay helpers, `isWebView`).

README and AGENTS.md describe it as "Next.js 14 … React Query v3". **The baseline actually runs Next `^16.3.6`, React `^19.2.6` and `@tanstack/react-query ^5.90`.** It builds with webpack (`next build --webpack`).

**It is a hybrid App Router + Pages Router app.** AGENTS.md says "App Router (`app` directory only)", but on main the two biggest flows, the payment landing/confirm/complete (`/payment/**`) and saved methods (`/smart_pay/**`), are Pages Router pages in `pages/` (300 files with `_app`, `_document`, `script.tsx`, `global.scss`). Only payment link, `/l/[id]` and `/api/*` are App Router routes. The app started on the Pages Router in 2021. `app/` arrived with the Next 14 upgrade (2024-09), and new routes have gone there since payment link (2025-11). New code for the Pages routes is written as non-route modules under `app/` (`app/payment`, `app/downpay`). The README's "legacy, being migrated" label and the AGENTS.md rule against new Pages pages describe the intent. The `/payment` and `/smart_pay` routes have not moved. Details and history: [[payment-fe-architecture]].

## Features
| Area | Router | Page |
|---|---|---|
| Payment landing, confirm, complete, callback (`/payment/**`) and its `app/payment` modules (promo, points, installment, linkage) | Pages (+ app modules) | [[payment-fe-payment]] |
| DownPay / flexible payment (modal flow inside the landing) | app module in a Pages route | [[payment-fe-downpay]] |
| Payment link (`/payment-link/**`) | App | [[payment-fe-payment-link]] |
| Short link `/l/[id]` → payment link | App | [[payment-fe-l]] |
| Route handlers `/api/*` (token, log, CSP report) | App | [[payment-fe-api]] |
| `app/(root)` leftover and app root files | App | [[payment-fe-root]] |
| Shared UI (`components/`, 59 folders) | both | [[payment-fe-components]] |
| Saved payment methods `/smart_pay/**` (linking, binding callbacks, OVO top-up, DANA, cards, bank accounts) | Pages | [[payment-fe-smart-pay]] |

Payment flow (README): landing → landing refetch on promo/points/method/installment change → submit (redirect, confirm or complete URL) → status polling via `paid-checker` → success or error with retry.

## Tech stack
- Next.js 16 (App Router for payment link, `/l`, `/api`; Pages Router for `/payment` and `/smart_pay`), React 19, TypeScript 5.9, SCSS modules with passport design tokens (snake_case classes, base + desktop breakpoint per AGENTS.md), react-hook-form + Zod, dayjs, lottie, isomorphic-dompurify, `next-qrcode`.
- Data: React Query v5, `fetchClient` from `@tiket/next`, MSW for mocks.
- Quality: Vitest 4 + RTL, Playwright, Storybook 9, oxlint, oxfmt, stylelint, commitlint, husky, Sonar via Gatekeeper.
- Integrations: Juspay HyperCheckout, Forter, GTM, Apple/Google Pay, e-wallet linkage (OVO, GoPay, DANA, BLU, BliPay, OneKlik), pay-later (Kredivo, BliBli PayLater).

## Internal dependencies
- **@tiket/next** (`^3.0.0`): middleware (locale, currency), `fetchClient`, logger, middleware data, API route handlers, rewrites/asset prefix, SRI plugin, react-cache workaround. It is not one of the six wiki repos.
- **Passport** (`^8.11.1`): [[passport-umbrella|passport]] (core components), [[passport-icons]], [[passport-assets]], [[passport-design-tokens]], [[passport-utils]], [[passport-page-module]] (payment success modules), [[passport-phone-verification]] (Groups), [[passport-info-banner]] (OrderSummary), [[passport-radio]] (payment-link). [[passport-sidebar]] is declared but not imported anywhere on main.
- **React-common:** [[react-common-remote]] (`ReactRemoteProvider`, `RemoteHeader`, `RemoteFooterDesktop`, `RemoteGlobalPopup` from TIX-REACT-REMOTE via [[module-federation]]), [[react-common-storage]], [[react-common-analytic]] + [[react-common-queue]] (SubmitPayment flushes analytics before navigating), [[react-common-utilities]]. [[react-common-ab-test]] and [[react-common-eagle-eye]] are declared in `package.json` but not imported in source (only mentioned in `.cursor/skills/migrate-tiket-packages`). CI also installs [[react-common-gatekeeper]].
- [[react-common-fetch-client]] calls this app's `/api/create-token` and `/api/refresh-token` (see [[payment-fe-api]]).

## Who uses it
End users through every vertical's checkout. In the other repos: TIX-FINTECH-NEXT-FE's `.cursor/rules/technical-solution.mdc` tells authors to reuse existing payment flows and cite TIX-NEXT-PAYMENT-FE paths. TIX-REACT-COMMON's gatekeeper keeps this repo's Sonar config (`packages/react-common-gatekeeper/src/sonar/projects/tix-next-payment-fe.ts`).

## Commands (short)
`pnpm test` (coverage, 90% team rule) · `pnpm run check-all` · `pnpm run type-check` · `pnpm run lint:js` (oxlint) · `pnpm run build`. Agents must not run `pnpm run dev` (AGENTS.md). Full list in [[payment-fe-workflows]].

## Where to read more
- `AGENTS.md` (team-shared rules; partly out of date: the "app directory only" claim, Next 14, React Query v3, `components/Promo`; see [[payment-fe-architecture]] and [[payment-fe-workflows]])
- `README.md` (hosts, old vs new URLs, deployment, Jenkins/Consul/Kibana/Grafana links)
- `docs/` (coding convention, Forter, myBCA auto-redirect, order detail flow)
- [[payment-fe-architecture]] for routing, middleware, providers and the data layer

## Sources
- `package.json`, `README.md`, `AGENTS.md`, `next.config.ts`, `middleware.page.ts`
- `app/`, `pages/`, `components/`, `lib/` (tree listing on `origin/main`), git history of `app/` and `pages/` (see [[payment-fe-architecture]])
- TIX-REACT-COMMON `packages/react-common-gatekeeper/src/sonar/projects/tix-next-payment-fe.ts`, `packages/react-common-fetch-client/src/client/helper.ts` (origin/master)
- TIX-FINTECH-NEXT-FE `.cursor/rules/technical-solution.mdc` (origin/main)
