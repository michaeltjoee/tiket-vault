---
title: TIX-REACT-COMMON overview
repo: TIX-REACT-COMMON
kind: overview
sources:
  - README.md
  - CONTRIBUTING.md
  - package.json
  - pnpm-workspace.yaml
  - packages
verified_at: 14597c4e
updated: 2026-10-16
status: current
tags: [repo/react-common, kind/overview]
---

# TIX-REACT-COMMON overview
> pnpm-workspace monorepo of shared, mostly non-UI React/browser utilities (fetch, analytics, A/B test, env, storage, JSI bridge, remote-component loader, CI gatekeeper), published as `@tiket/react-common-*` to GitHub Packages.

Baseline branch is **`origin/master`** (not `main`). Despite older docs calling it a Lerna repo, there is no `lerna.json`: it is pnpm workspaces + [[changesets-fixed-versioning|changesets]] (independent versions, `fixed: []`). See [[react-common-architecture]] and [[react-common-workflows]].

## Packages (18)

| Package | Version | Purpose |
|---|---|---|
| [[react-common-ab-test]] | 5.0.2 | A/B test / feature-flag lookup backed by Mixpanel; has `./server` entry |
| [[react-common-analytic]] | 5.0.8 | Amplitude + Mixpanel tracking, user properties; also a CDN bundle |
| [[react-common-core-attributes]] | 3.0.6 | Core tracking attributes (device id, session id, cookies, external party) |
| [[react-common-eagle-eye]] | 3.0.1 | Fetch performance logger ("Eagle Eye") |
| [[react-common-env]] | 1.2.1 | Detect environment from the browser domain |
| [[react-common-error-handler]] | 2.0.9 | Central error handling for Next apps; has `./server` entry |
| [[react-common-fetch-client]] | 3.2.1 | Current fetch client (successor of `react-common-fetch`) |
| [[react-common-fetch]] | 2.0.2 | Legacy Babel-built fetch with auth handling, Tix React App only |
| [[react-common-gatekeeper]] | 4.0.4 | `tix-gatekeeper` CLI that runs CI quality gates (Sonar, GitHub checks) |
| [[react-common-jsi]] | 2.0.1 | JSI bridge for calls between webview and native app |
| [[react-common-navigator-permission]] | 2.0.4 | Browser/webview permissions and Cross App Routing (C.A.R) |
| [[react-common-openapi]] | 2.0.1 | Generates API controllers/contracts with openapi-generator-cli |
| [[react-common-push-notif]] | 1.3.7 | Firebase web push notifications |
| [[react-common-queue]] | 1.1.1 | Small queue used to defer calls until a SDK is ready |
| [[react-common-remote]] | 3.0.5 | Next.js loader for remote components (header, footer, reviews…) from [[react-remote-overview|TIX-REACT-REMOTE]]; has `./server` entry |
| [[react-common-script]] | 2.0.3 | `update-react-common` CLI; published under the **`@tiket-com`** scope |
| [[react-common-storage]] | 2.0.1 | Local storage shared across tiket subdomains (iframe) |
| [[react-common-utilities]] | 4.2.0 | Grab-bag of helpers; the most widely consumed package |

The README's support matrix only covers 9 of these and is out of date.

## Who consumes it (baselines, 2026-10-16)

- **TIX-PASSPORT**: `react-common-utilities` (23 packages), `react-common-ab-test` (6), `react-common-analytic` (global-search), `react-common-navigator-permission` (manage-order). See [[passport-overview]].
- **TIX-REACT-REMOTE**: `analytic`, `fetch-client`, `push-notif`, `utilities`, pinned to exact versions. See [[react-remote-overview]].
- **TIX-NEXT-PAYMENT-FE**: `ab-test`, `analytic`, `eagle-eye`, `queue`, `remote`, `storage`, `utilities`. See [[payment-fe-overview]].
- **TIX-FINTECH-NEXT-FE**: `core-attributes`, `eagle-eye`, `error-handler`, `fetch-client`, `navigator-permission`, `remote`, `storage`, `utilities`. See [[fintech-fe-overview]].
- **TIX-GTM-EXTRAS**: none.
- No other workspace repo uses `fetch`, `env` (directly), `gatekeeper` (used in CI via `npm i -g`), `jsi` (directly), `openapi` or `script`.

## Tech stack

Node 24.14.1 (`.nvmrc`, Volta), pnpm 10.28.2 (`packageManager`, corepack), TypeScript 5.3.3, React 19 (peer `^19`), Next 16 (peer for remote/error-handler), esbuild + `tsc` declaration emit for most packages, Jest 28 + ts-jest, ESLint 8, Prettier 2, husky + commitlint (conventional commits).

## Commands

| Command | Does |
|---|---|
| `pnpm build` | Builds every package sequentially (`--workspace-concurrency=1`) |
| `pnpm test` | Root Jest (`test:prepare` then `jest --coverage`) plus each package's own `test` script |
| `pnpm create:package <name>` | Scaffolds `packages/react-common-<name>` (package.json, tsconfig, build.js, README, jest constants) |
| `pnpm remove-dist` | Deletes `dist`, `lib`, `build-artifact` in all packages |
| `pnpm lint` / `pnpm format` | ESLint fix / Prettier write |
| `pnpm exec changeset` | Add a changeset (required for a prerelease or release) |

Local dev also expects Verdaccio as an npm proxy (CONTRIBUTING.md). For cross-repo tooling versions see [[passport-local-tooling]].

## Sources
- README.md, CONTRIBUTING.md, package.json, pnpm-workspace.yaml, .nvmrc
- packages/*/package.json
- Consumer greps on TIX-PASSPORT, TIX-REACT-REMOTE, TIX-NEXT-PAYMENT-FE, TIX-FINTECH-NEXT-FE, TIX-GTM-EXTRAS at origin/main
