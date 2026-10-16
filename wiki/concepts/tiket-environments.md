---
title: tiket environments and hosts
kind: concept
repos: [TIX-REACT-COMMON, TIX-PASSPORT, TIX-REACT-REMOTE, TIX-NEXT-PAYMENT-FE, TIX-FINTECH-NEXT-FE, TIX-HOMEPAGE-NEXT-FE, TIX-GROWTH-NEXT-FE]
sources:
  - TIX-REACT-COMMON/packages/react-common-env/src/getEnvironment.ts
  - TIX-PASSPORT/packages/utils/src/context.tsx
  - TIX-NEXT-PAYMENT-FE/.env.local.example
  - TIX-FINTECH-NEXT-FE/.env.local.example
  - TIX-REACT-REMOTE/docs/SOP-ENVIRONMENT-VARIABLES.md
  - TIX-HOMEPAGE-NEXT-FE/.env.local.example
  - TIX-HOMEPAGE-NEXT-FE/next.config.ts
  - TIX-GROWTH-NEXT-FE/.env.local.example
  - TIX-GROWTH-NEXT-FE/e2e/playwright.env.ts
verified_at:
  TIX-REACT-COMMON: 14597c4e
  TIX-PASSPORT: 7a33010aca
  TIX-REACT-REMOTE: 281778b
  TIX-NEXT-PAYMENT-FE: 9e92b20bb
  TIX-FINTECH-NEXT-FE: 5833b842
  TIX-HOMEPAGE-NEXT-FE: 408983f6
  TIX-GROWTH-NEXT-FE: d4162e3
updated: 2026-10-16
status: current
tags: [kind/concept, repo/react-common, repo/passport, repo/react-remote, repo/payment-fe, repo/fintech-fe, repo/homepage-fe, repo/growth-fe]
---

# tiket environments and hosts
> The same five environment names (`production`, `preprod`, `staging`, `development`, `local`) appear in react-common and Passport. On the client they are derived from the hostname. Next apps get them from env vars set at build time.

## Host → environment
[[react-common-env]] `getEnvironment()` checks `location.origin`, in this order:

| Host contains | Environment | Notes |
|---|---|---|
| `pegasus.tiket` | `development` | react-remote assets `pegasus.tiket.com/shared-components`, API `lb1-devel.tiket.com` |
| `preprod.tiket` | `preprod` | |
| `gatotkaca.tiket` | `staging` | react-remote assets `gatotkaca.tiket.com/shared-components`, API `lb1-testing.tiket.com`. Also called GK or TEST in Jenkins job names |
| `local.tiket.com`, `dev.tiket.com` | `local` | local dev on a `*.tiket.com` name so cookies work ([[local-https-certs]]) |
| anything else | `production` | react-remote assets `storage.tiket.com/shared-components`, API `tix-react-remote-svc.misc-cluster.tiket.com` |

The result is cached in `window.process.NODE_ENV`. Values derived from it: the [[cross-subdomain-storage]] iframe host, Firebase projects for [[web-push-notifications]], and Mixpanel and Amplitude keys in [[react-common-analytic]].

Passport mirrors the names as `PassportEnvironment` and takes `environment` on `PassportProvider` (default `production`, read with `usePassportEnvironment`; see [[passport-utils]]).

## Build time and run time
- Next apps read `NEXT_PUBLIC_*` (inlined at build time) and server env such as `SERVER_SIDE_SERVICE_ENDPOINT` (`https://lb1-testing.tiket.com` locally, needs VPN). payment-fe keeps deploy config in Consul ([[payment-fe-workflows]]).
- homepage-fe picks the Apple App Site Association file from `NEXT_PUBLIC_NON_PREFIXED_HOSTNAME` in `next.config.ts`: a two-part host (`tiket.com`) is production, a `preprod.` or `gatotkaca.` prefix picks that file, and anything else falls back to `gatotkaca` ([[homepage-fe-architecture]]). growth-fe's Playwright maps `PLAYWRIGHT_APP_ENV` `local`/`staging`/`preprod`/`prod` to `local.tiket.com:3000`, `gatotkaca`, `preprod` and `www` (`e2e/playwright.env.ts`, [[growth-fe-workflows]]).
- TIX-REACT-REMOTE client vars are inlined by `DefinePlugin` at Docker build time and need a Dockerfile `ARG`/`ENV` plus a Jenkins `--build-arg`. The K8s ConfigMap can't change them ([[react-remote-workflows]]).

## Gotchas
- `getEnvironment()` returns `staging` on the **server**, even in production. Use env vars in SSR ([[ab-testing]] uses `NEXT_PUBLIC_AB_TEST_ENV`).
- Unknown hosts, including `localhost` and preview URLs, count as production.
- A bundler shim that sets `window.process.NODE_ENV` first wins over the hostname check.
- Preprod uses the production storage iframe (TODO in [[react-common-storage]]).

## Where it shows up
Pages that link here:
- TIX-GROWTH-NEXT-FE: [[growth-fe-workflows]]
- TIX-HOMEPAGE-NEXT-FE: [[homepage-fe-workflows]]
- TIX-REACT-COMMON: [[react-common-env]]
- concepts: [[cross-subdomain-storage]], [[web-push-notifications]]
- entities: [[tix-image-service]]
- howto: [[local-https-certs]]

## Sources
- TIX-REACT-COMMON `packages/react-common-env/src/getEnvironment.ts`
- TIX-PASSPORT `packages/utils/src/{context.tsx,usePassportEnvironment.ts}`
- TIX-NEXT-PAYMENT-FE `.env.local.example` (react-remote URLs per environment), TIX-FINTECH-NEXT-FE `.env.local.example`
- TIX-REACT-REMOTE `docs/SOP-ENVIRONMENT-VARIABLES.md`
- TIX-HOMEPAGE-NEXT-FE `.env.local.example`, `next.config.ts`; TIX-GROWTH-NEXT-FE `.env.local.example`, `e2e/playwright.env.ts`
