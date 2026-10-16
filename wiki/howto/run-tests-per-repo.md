---
title: Run tests in each repo
kind: howto
repos: [TIX-PASSPORT, TIX-REACT-COMMON, TIX-REACT-REMOTE, TIX-NEXT-PAYMENT-FE, TIX-FINTECH-NEXT-FE, TIX-GTM-EXTRAS, TIX-HOMEPAGE-NEXT-FE, TIX-GROWTH-NEXT-FE]
sources:
  - TIX-PASSPORT/package.json
  - TIX-PASSPORT/bunfig.toml
  - TIX-PASSPORT/docs/testing.md
  - TIX-PASSPORT/.github/workflows/ci.yml
  - TIX-REACT-COMMON/package.json
  - TIX-REACT-COMMON/jest.config.ts
  - TIX-REACT-COMMON/jest.constant.ts
  - TIX-REACT-REMOTE/package.json
  - TIX-REACT-REMOTE/jest.config.js
  - TIX-NEXT-PAYMENT-FE/package.json
  - TIX-NEXT-PAYMENT-FE/vitest.config.mts
  - TIX-FINTECH-NEXT-FE/package.json
  - TIX-FINTECH-NEXT-FE/vitest.config.mts
  - TIX-GTM-EXTRAS/package.json
  - TIX-HOMEPAGE-NEXT-FE/package.json
  - TIX-HOMEPAGE-NEXT-FE/vitest.config.mts
  - TIX-GROWTH-NEXT-FE/package.json
  - TIX-GROWTH-NEXT-FE/jest.config.mjs
  - TIX-GROWTH-NEXT-FE/playwright.config.ts
verified_at:
  TIX-PASSPORT: 7a33010aca
  TIX-REACT-COMMON: 14597c4e
  TIX-REACT-REMOTE: 281778b
  TIX-NEXT-PAYMENT-FE: 9e92b20bb
  TIX-FINTECH-NEXT-FE: 5833b842
  TIX-GTM-EXTRAS: 98478af
  TIX-HOMEPAGE-NEXT-FE: 408983f6
  TIX-GROWTH-NEXT-FE: d4162e3
updated: 2026-10-16
status: current
tags: [kind/howto, repo/passport, repo/react-common, repo/react-remote, repo/payment-fe, repo/fintech-fe, repo/gtm-extras, repo/homepage-fe, repo/growth-fe]
---

# Run tests in each repo
> Each repo uses a different runner and enforces coverage in a different place. Use the command in the first column and expect the gate in the last one.

## Unit tests
| Repo | Command | Runner | Where coverage is enforced |
|---|---|---|---|
| TIX-PASSPORT | `./node_modules/.bin/bun test` (`npm test` = `bun test --coverage`); one file: `./node_modules/.bin/bun test packages/<pkg>` | bun 1.3.6 + happy-dom + msw + RTL via `@/test-utils`; root `packages`, preloads `bun-test-config/*` | **No threshold.** `bunfig.toml` only emits lcov, there is no Sonar, and the gate is just that `ci.yml` (`npm test && npm run check-all`) passes |
| TIX-REACT-COMMON | `pnpm test` = `test:root` (`jest --coverage`, one Jest project per name in `jest.constant.ts`) + `test:packages` (each package's own `test` script) | Jest 29 + ts-jest, jsdom for listed packages | Sonar quality gate through [[gatekeeper-ci]] (`tix-react-common`). No Jest thresholds |
| TIX-REACT-REMOTE | `pnpm test` (`jest --coverage`) | Jest + `@swc/jest`, jsdom, CSS through `identity-obj-proxy` | Sonar through Gatekeeper (`tix-react-remote`). Sonar excludes `src/components/**` and `src/server/**`, so most shipped code is outside the gate |
| TIX-NEXT-PAYMENT-FE | `pnpm test` or `pnpm test:ci` (both `vitest run --coverage`) | Vitest 4 + RTL + MSW, jsdom, `*.spec.ts(x)` | **90% team rule** (AGENTS.md), checked by Sonar in Gatekeeper on lcov. `vitest.config.mts` has no `thresholds`, so local runs never fail on coverage |
| TIX-FINTECH-NEXT-FE | `pnpm test:ci`. `pnpm test` adds `-u` and silently rewrites snapshots | Vitest (migrated from Jest, `vitest.jest-compat.ts`), jsdom, threads | Vitest thresholds 90/90/91/91 (branches/functions/lines/statements), plus Sonar in Gatekeeper. `coverage.include` is `{app,pages,components,lib}/**`, so `projects/` is not counted |
| TIX-HOMEPAGE-NEXT-FE | `pnpm test` (`vitest run --coverage --reporter=verbose`); one file: `pnpm vitest run <spec>` | Vitest (migrated from Jest in 4.7.0), jsdom, `pool: 'vmThreads'` (required for `@tiket` `.scss` imports), istanbul coverage | Vitest thresholds only 10% on `{pages,components,lib}/**`, plus Sonar in Gatekeeper (`tix-homepage-next-fe`) ([[homepage-fe-workflows]]) |
| TIX-GROWTH-NEXT-FE | `pnpm test` (`jest --coverage --verbose`) | Jest 30 via `next/jest`, jsdom, v8 coverage, MSW 2 | No Jest thresholds. Sonar in Gatekeeper (`tix-growth-next-fe`) ([[growth-fe-workflows]]) |
| TIX-GTM-EXTRAS | none. `npm run build` only runs `jsvalidate` (syntax) | — | none, and there is no CI ([[gtm-extras-workflows]]) |

## Mocks that change what a test proves
- **TIX-NEXT-PAYMENT-FE** aliases `@tiket/passport`, `@tiket/passport-assets` and `@tiket/next/server` to local mocks. Tests never render real Passport. Add new Passport exports to `__mocks__/@tiket/passport.tsx` ([[payment-fe-workflows]]).
- **TIX-FINTECH-NEXT-FE** stubs heavy `@tiket/*` packages in `__mocks__/@tiket/*` and replaces `passport-assets` with a generated virtual mock ([[fintech-fe-workflows]]).
- **TIX-HOMEPAGE-NEXT-FE** renders Passport and react-common **for real** (prebundled), but aliases `@tiket/react-common-ab-test` and `@tiket/react-common-remote` to stubs and partially mocks `@tiket/passport-page-module` (a fake `PageModule`) and `@tiket/passport-utils` ([[homepage-fe-workflows]]).
- **TIX-GROWTH-NEXT-FE** comments out the global `mswServer.listen()` in `jest.setup.js`, so MSW handlers do nothing unless a spec calls `listen()` itself ([[growth-fe-workflows]]).
- **TIX-REACT-COMMON** mocks `@tiket/passport` for remote and error-handler, because transpiling it is too slow ([[react-common-architecture]]).
- **TIX-PASSPORT** runs msw against Bun's native `fetch` (happy-dom's is replaced) and sets the URL to `https://dummy.tiket.com` from `.env.test` ([[passport-architecture]]).

## E2E
| Repo | Command | Notes |
|---|---|---|
| TIX-NEXT-PAYMENT-FE | `pnpm e2e` (Playwright UI, Chromium) | `e2e/start-web-server.sh` builds if `.next/BUILD_ID` is missing. The GitHub workflow is manual only |
| TIX-FINTECH-NEXT-FE | `PLAYWRIGHT_APP_ENV=local\|staging\|preprod\|prod pnpm exec playwright test` | base URL comes only from `PLAYWRIGHT_APP_ENV`. Navigation timeout is 180 s because locale/session middleware is slow locally |
| TIX-GROWTH-NEXT-FE | `pnpm e2e` (`playwright test`, Chromium) | same `PLAYWRIGHT_APP_ENV` scheme and 180 s timeouts. Set `PLAYWRIGHT_SKIP_WEBSERVER` against staging/preprod/prod. No CI workflow runs it |

## Hooks that run tests for you
- TIX-PASSPORT `pre-push`: `npm test && npm run check-all`.
- TIX-REACT-REMOTE `pre-push`: `pnpm test`.
- TIX-NEXT-PAYMENT-FE `pre-push`: `check-all-fmt-staged` (type-check, lint, tests).
- TIX-FINTECH-NEXT-FE `pre-push`: `check-all` (type-check, lint, stylelint, prettier, tests).
- TIX-HOMEPAGE-NEXT-FE `pre-push`: `prepush-check` (type-check, lint:js, tests).
- TIX-GROWTH-NEXT-FE `pre-push`: `check-all`, which includes `prettier . --write` and can leave reformatted, uncommitted files.

## Gotchas
- TIX-PASSPORT: use the repo bun, not the global one ([[passport-local-tooling]]). Prefer `findBy*` and `waitForElementToBeRemoved` over `waitFor`, which bun does not handle reliably. `IntersectionObserver` needs `IntersectionObserverMock` from `@/mocks/intersection-observer` (`docs/testing.md`).
- TIX-PASSPORT: a package-level `tsconfig.json` breaks the `@/` alias in specs.
- Gatekeeper calls `npm run test`, so the `test` script must work under npm in every Gatekeeper repo.

## Sources
- TIX-PASSPORT `package.json`, `bunfig.toml`, `bun-test-config/*`, `docs/testing.md`, `.github/workflows/ci.yml`, `.husky/pre-push`
- TIX-REACT-COMMON `package.json`, `jest.config.ts`, `jest.constant.ts`
- TIX-REACT-REMOTE `package.json`, `jest.config.js`, `sonar-project.properties`, `.husky/pre-push`
- TIX-NEXT-PAYMENT-FE `package.json`, `vitest.config.mts`, `AGENTS.md`, `playwright.config.ts`, `.husky/pre-push`
- TIX-FINTECH-NEXT-FE `package.json`, `vitest.config.mts`, `playwright.config.ts`, `e2e/playwright.env.ts`, `.husky/pre-push`
- TIX-GTM-EXTRAS `package.json`, `gulpfile.js`
- TIX-HOMEPAGE-NEXT-FE `package.json`, `vitest.config.mts`, `.husky/pre-push`
- TIX-GROWTH-NEXT-FE `package.json`, `jest.config.mjs`, `jest.setup.js`, `playwright.config.ts`, `e2e/playwright.env.ts`, `.husky/pre-push`
