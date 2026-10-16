---
title: TIX-PASSPORT overview
repo: TIX-PASSPORT
kind: overview
sources:
  - README.md
  - CONTRIBUTING.md
  - package.json
  - packages/passport
  - .changeset/config.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/overview]
---

# TIX-PASSPORT overview

> tiket.com's React component library ("Passport" design system), published as ~130 `@tiket/passport-*` packages to the GitHub npm registry.

## What it is
A pnpm monorepo with one package per component or shared utility under `packages/*`. It holds design-system primitives (button, text, card, dialog), shared building blocks (design tokens, icons, assets, utils), and complete business widgets that call tiket APIs themselves (header, footer, global popup, page module, insurance, corporate interim module, review widget). See [[passport-packages]] for the full catalog.

All packages share one version (12.8.1 at `verified_at`) because changesets uses a single `fixed` group over `@tiket/passport*`. See [[changesets-fixed-versioning]].

## Who consumes it
| Consumer | How | Version pinned on baseline |
|---|---|---|
| TIX-REACT-REMOTE | header, footer, global popup, Google One Tap, wishlist, country/currency modal, corporate interim module, reviews, exposed through [[module-federation]] | `12.4.2`, exact pins in `package.json` |
| TIX-FINTECH-NEXT-FE | gift card, insurance, refund UIs. Mostly through the umbrella `@tiket/passport` | `^12.4.3` |
| TIX-NEXT-PAYMENT-FE | payment, payment link, downpay UIs. Mostly through the umbrella | `^8.11.1` (four majors behind) |
| TIX-REACT-COMMON | [[react-common-remote]] fallbacks (Header, Footer, Reviews, Wishlist) and [[react-common-error-handler]] (Dialog, ErrorView, snackbar) | prerelease snapshot `0.0.0-alpha-3045-…` |
| TIX-NEXT-FE (not in this workspace) | named in the README as coming pre-installed with Passport | — |

TIX-GTM-EXTRAS doesn't use Passport.

## Tech stack
- React 19 (`peerDependencies.react: ^19.0.0`) and TypeScript 5.3.3. Packages ship tsc output plus raw SCSS/CSS modules, with no bundler.
- SCSS CSS Modules with `classnames`, and tokens from [[passport-design-tokens]].
- Storybook 8.5 on Vite for dev. Chromatic hosts the published Storybook (`https://main--61d7bc0ea20987003a1c49f3.chromatic.com`).
- bun test with happy-dom, msw for API mocks, and React Testing Library through `@/test-utils`.
- pnpm 10 workspaces (lerna.json is vestigial) and changesets for versioning.

## Key commands
| Command | What |
|---|---|
| `npm run dev` | Storybook on :6006 (`dev:https` serves `local.tiket.com` with a local cert) |
| `npm test` | `bun test --coverage` (root `packages`, preloads `bun-test-config/*`) |
| `npm run check-all` | `tsc` + eslint + stylelint |
| `npm run build` | wipes `packages/*/dist`, then runs each package's `build` with concurrency 2 |
| `npm run create:component <kebab-name>` | scaffolds a new package. Don't hand-create packages |
| `npm run generate:icons` / `generate:assets` | regenerate [[passport-icons]] / [[passport-assets]] sources |

Local setup has pitfalls: the machine's global pnpm and bun versions break installs and tests. Read [[passport-local-tooling]] first.

## Where to go next
- [[passport-architecture]]: package layout, build, umbrella package, test harness
- [[passport-workflows]]: dev loop, PR checks, prerelease and release
- [[passport-packages]]: every package with a one-liner
- [[page-module-next-poc]]: branch-only experiment that wraps page-module for Next

## Gotchas
- Import types from `@tiket/passport/types/<pkg>`, not from `@tiket/passport-<pkg>`. Unless the app installs the sub-package directly, nested `node_modules` make the direct import fail (README "Importing types").
- In Next.js, `Global CSS cannot be imported from within node_modules` means a nested `@tiket/passport/node_modules/@tiket/passport-*` copy exists. Reinstall to flatten it, or add that nested path to the transpile list (README).
- Several docs are out of date. CONTRIBUTING says Node 20 and pnpm 9, `.nvmrc` says v20.10.0, but CI uses Node 24 and pnpm 10 and Volta pins 24.14.1. `.cursor/rules/project-conventions.mdc` still says "React 18".

## Sources
- `README.md`, `CONTRIBUTING.md`, `package.json`, `.changeset/config.json`, `packages/passport/package.json`
- TIX-REACT-REMOTE `package.json` (281778b), TIX-FINTECH-NEXT-FE `package.json` (5833b842), TIX-NEXT-PAYMENT-FE `package.json` (9e92b20bb), TIX-REACT-COMMON `packages/react-common-{remote,error-handler,utilities}/package.json` (14597c4e)
