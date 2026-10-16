---
title: TIX-REACT-REMOTE overview
repo: TIX-REACT-REMOTE
kind: overview
sources:
  - README.md
  - package.json
  - exposes.config.js
  - docs/SOP-ENVIRONMENT-VARIABLES.md
verified_at: 281778b
updated: 2026-10-16
status: current
tags: [repo/react-remote, kind/overview]
---

# TIX-REACT-REMOTE overview
> An Express + webpack [[module-federation]] service that serves tiket.com's shared chrome (header, footer, popups, analytics scripts) as remote React components, with an SSR prerender API.

## What it is
`tix-react-remote` (v2.0.33 at `281778b`) has two jobs:
1. **Client remote.** It builds `remoteEntry.js` (federation container `ReactRemote`) plus chunks and CSS. In deployed environments these are uploaded to GCS (`gs://general-gatotkaca-static-files/shared-components/assets/`). Each exposed module exports `mount(el, noHydrate, props)`.
2. **SSR API.** An Express server renders the same components to HTML for consumers' `getServerSideProps` or server components. It returns `content`, CSS file names, PurgeCSS critical CSS and the version, and caches renders in memory.

Most components are thin wrappers over `@tiket/passport-*` packages (all pinned to the same Passport version, currently 12.4.2, see [[changesets-fixed-versioning]]). A Passport fix reaches every consumer page after react-remote bumps Passport and redeploys, without the consumer apps redeploying. This is the main reason the repo exists.

## Who consumes it
Next.js apps load it through [[react-common-remote]] (`RemoteComponent` and the `Remote*` wrappers, `enableSsrRemoteModule` / `getReactRemoteProps`, and server components in `@tiket/react-common-remote/server`). See [[react-remote-architecture#How consumers load remotes]].

| Consumer | What it mounts |
|---|---|
| TIX-NEXT-PAYMENT-FE (`components/providers/AppProvider.tsx`, smart_pay, payment complete) | header, footer, footer-desktop, scripts, global-popup, google-one-tap, wishlist-module, country-and-currency-modal, corporate-interim-module |
| TIX-FINTECH-NEXT-FE (gift-card, insurance, refund, error page) | header, footer, footer-desktop, scripts |

Consumer env vars: `NEXT_PUBLIC_REACT_REMOTE_API_URL` (the SSR API) and `NEXT_PUBLIC_REACT_REMOTE_URL` (static assets). Values from `.env.local.example` in the consumers:

| Env | API URL | Assets URL |
|---|---|---|
| devel | `https://lb1-devel.tiket.com/shared-components` | `https://pegasus.tiket.com/shared-components` |
| testing | `https://lb1-testing.tiket.com/shared-components` | `https://gatotkaca.tiket.com/shared-components` |
| prod | `https://tix-react-remote-svc.misc-cluster.tiket.com/shared-components` | `https://storage.tiket.com/shared-components` |
| local | `http://localhost:3003` | `http://localhost:3003` |

## Exposed components
| Key | Page | Wraps |
|---|---|---|
| `corporate-interim-module` | [[react-remote-corporate-interim-module]] | [[passport-corporate-interim-module]] |
| `country-and-currency-modal` | [[react-remote-country-and-currency-modal]] | [[passport-country-and-currency-modal]] |
| `footer` / `footer-desktop` / `footer-mobile` | [[react-remote-footer]], [[react-remote-footer-desktop]], [[react-remote-footer-mobile]] | [[passport-footer]] |
| `global-popup` | [[react-remote-global-popup]] | [[passport-global-popup]] |
| `google-one-tap` | [[react-remote-google-one-tap]] | [[passport-google-one-tap]] |
| `header` / `header-mobile` / `header-slim` | [[react-remote-header]], [[react-remote-header-mobile]], [[react-remote-header-slim]] | [[passport-header]] |
| `reviews` | [[react-remote-reviews]] | [[passport-review-widget]] |
| `scripts` | [[react-remote-scripts]] | [[react-common-analytic]], [[react-common-push-notif]] |
| `wishlist-module` | [[react-remote-wishlist-module]] | [[passport-wishlist]] |
| (internal) | [[react-remote-wrapper]] | [[passport-utils]] PassportProvider |

The README table is out of date: it lists only 9 components and is missing global-popup, google-one-tap, wishlist-module and country-and-currency-modal.

## Tech stack
Node 24.14.1 (Volta / `.nvmrc`), pnpm 10.28.2 via Corepack with `nodeLinker: hoisted`, React 19, webpack 5 with `ModuleFederationPlugin`, swc-loader, `@loadable/component` + `@loadable/server`, Express 4, node-cache, PurgeCSS, Sass CSS modules, Jest + Testing Library. `@tiket/*` packages come from GitHub Packages (needs `GITHUB_TOKEN`).

## Commands
| Command | Does |
|---|---|
| `pnpm dev` | runs `watch:api` (rebuild server and `node api` on `src` change) and `watch:assets` (rebuild client) together; open `http://localhost:3003/api/prerender/footer` |
| `pnpm build` | `build:web` (client + `stats.json` + `css-map.json`) then `build:api` (server bundle) |
| `pnpm start` | `node ./api` (requires `dist/server`) |
| `pnpm test` | Jest with coverage |
| `pnpm create:component` | scaffolds `src/components/<key>` and adds it to `exposes.config.js` |
| `pnpm test:build:docker` | local Docker build with the analytics build args |

See [[react-remote-architecture]] and [[react-remote-workflows]].

## Sources
- README.md
- package.json
- exposes.config.js
- docs/SOP-ENVIRONMENT-VARIABLES.md
- TIX-NEXT-PAYMENT-FE .env.local.example
- TIX-FINTECH-NEXT-FE .env.local.example
- TIX-REACT-COMMON packages/react-common-remote/README.md
