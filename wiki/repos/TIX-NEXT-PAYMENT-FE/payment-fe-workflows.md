---
title: TIX-NEXT-PAYMENT-FE workflows
repo: TIX-NEXT-PAYMENT-FE
kind: workflows
sources:
  - package.json
  - AGENTS.md
  - README.md
  - vitest.config.mts
  - sonar-project.properties
  - Jenkinsfile.dev
  - .github/workflows
  - .changeset/config.json
  - .husky
  - .lintstagedrc.js
  - playwright.config.ts
  - e2e
  - docs
  - .npmrc
verified_at: 9e92b20bb
updated: 2026-10-16
status: current
tags: [repo/payment-fe, kind/workflows]
---

# TIX-NEXT-PAYMENT-FE workflows

> Local setup (Node 24, HTTPS dev server, MSW mock mode), check commands, git hooks, tests, CI (Jenkins merge gate plus GitHub Actions) and the changesets release with label-driven prereleases. Adds what AGENTS.md leaves out.

AGENTS.md is the team-shared guide for agents and humans (commands, contexts, endpoint list, styling, i18n, testing rules). Read it before changing code. This page adds what it leaves out, and notes where it is out of date.

## Local setup
- Node **24.14.1** (`volta.node`, `.npmrc` `use-node-version`). README still says 20.11.1. pnpm: CI uses **pnpm 9** (`corepack prepare pnpm@9`, `pnpm/action-setup version: 9`).
- `@tiket/*` comes from GitHub Packages: `.npmrc` needs `GITHUB_TOKEN` in the environment.
- `cp .env.local.example .env.local`. `pnpm run dev` runs `source .env.local` and then needs `SSL_KEY_FILE`/`SSL_CERT_FILE` (HTTPS dev server, `allowedDevOrigins: ['local.tiket.com']`). It also runs `typed-scss-modules` in watch mode to generate `*.module.scss.d.ts`. **AGENTS.md says agents must never run `pnpm run dev`.**
- Mock mode: `NEXT_PUBLIC_API_MOCKING=enabled` plus `NEXT_PUBLIC_MOCK_PRODUCT_TYPE` (flight, car, train, gift-card, hotel, insurance, downpay). `NEXT_PUBLIC_WEBVIEW_BRIDGE_MOCKING` fakes the native bridge. `prepare` runs `msw init ./public`.
- Example local URL (from `codegen:*`): `http://local.tiket.com:3000/id-sg/payment?order_id=…&order_hash=…&pagePreventInitialized=true`.

## Commands
| Command | What |
|---|---|
| `pnpm test` / `test:ci` | `vitest run --coverage` |
| `pnpm run test:watch` | watch with coverage |
| `pnpm run check-all` | type-check + oxlint + stylelint + `oxfmt --check` + tests |
| `pnpm run check-all-fmt-staged` | type-check + lint + tests; format check only on files changed vs `origin/main` (used by pre-push) |
| `pnpm run type-check` | `tsc --noEmit` (the build skips type errors, so this is the only type gate) |
| `lint`, `lint:js`, `lint:fix` | **oxlint** (not ESLint; `eslint` is still a devDependency) |
| `fmt`, `fmt:check` | **oxfmt** |
| `lint:css` | stylelint (`stylelint-config-standard-scss`) |
| `build` / `analyze` | `next build --webpack`; `ANALYZE=true` for the bundle analyzer |
| `e2e`, `codegen:desktop`, `codegen:mobile` | Playwright UI / codegen |
| `storybook`, `build-storybook` | Storybook 9 (`@storybook/nextjs`) |
| `generate-css-modules-types` | typed-scss-modules (aliases for `@tiket/passport-design-tokens` and `@`) |
| `changeset`, `release` | changesets |
| `sonar:scan`, `docker:build:sonar` | local Sonar via `docker/Sonar.Dockerfile` |

## Git hooks
- `pre-commit`: `lint-staged`. On staged files it runs `tsc --noEmit` (whole project), `oxlint --fix`, `stylelint --fix`, and `oxfmt` **only for `app/**`**.
- `commit-msg`: commitlint with `@commitlint/config-conventional`.
- `pre-push`: `npm run check-all-fmt-staged`, i.e. the full test suite with coverage runs on every push.

## Testing
- **Vitest 4** + React Testing Library + MSW, jsdom, `*.spec.ts(x)` only, `testTimeout: 15000`, `clearMocks`/`restoreMocks`. Coverage provider v8 (lcov for Sonar).
- **90% coverage** is a team rule (AGENTS.md, README). `vitest.config.mts` has **no `thresholds`**, so a local run never fails on coverage. The bar is checked downstream on the lcov report (Sonar `sonar.javascript.lcov.reportPaths`, run in the Jenkins Gatekeeper stage). Sonar excludes `lib/services/**`, `lib/mocks/**`, `lib/i18n/**`, `lib/logger/**`, `lib/jsi/**` and `lib/middlewares/**`, and the comment there says the list must match the vitest coverage excludes.
- **Passport is mocked.** `vitest.config.mts` aliases `@tiket/passport` → `__mocks__/@tiket/passport.tsx`, and also aliases `@tiket/passport-assets`, `@tiket/next/server`, `server-only`, `*.lottie` and some passport type paths. Unit tests never render real passport components. If you use a passport export the mock doesn't have, tests break until you add it to the mock.
- Test utils: `@/lib/test-utils-app-router` for App Router code, `@/lib/test-utils` for Pages Router. Use `const { user } = render(...)` with `vi.useFakeTimers({ shouldAdvanceTime: true })`. Don't mock `useI18n`, because real `en.ts` strings are provided (AGENTS.md).
- Conventions: AAA, describe/it wording, file layout in `docs/CODING_CONVENTION.md` and `.cursor/rules/unit-test.mdc`.
- **E2E:** Playwright (`playwright.config.ts`). `webServer` runs `e2e/start-web-server.sh`, which builds if `.next/BUILD_ID` is missing and then runs `pnpm start`. Scenarios: `e2e/scenarios/clean/` (landing, promo, points, groups, confirm, complete, callback, DownPay, flexible payment, order summary, travel policy), `e2e/scenarios/infinity/` (BLU, DANA, GoPay/OVO linkage, PL/PL36 pay-later, DOWNPAY, TixPoints; see its README), and `e2e/scenarios/smart_pay/`. API fixtures and builders live in `e2e/fixtures/api/*`. The `@e2e/*` alias is defined in `tsconfig.base.json`. Cursor rules `.cursor/rules/e2e*.mdc` and skill `.cursor/skills/e2e-test-case` describe how to write them.
- The **Playwright GitHub workflow is disabled** (`workflow_dispatch` only, per its header comment), so E2E runs only locally or on demand.

## CI
- **Jenkins** (`Jenkinsfile.dev`, job linked in README): Kubernetes pod on `node:24.14.1-alpine` (4 CPU / 12 Gi limit). It is skipped for PRs titled `Version Packages`. Stages: Checkout → Prepare (writes `.npmrc` with the GitHub token, `pnpm i`, installs JDK 21 and sonar-scanner 4.7, runs `tix-gatekeeper -s prepare` from `@tiket/react-common-gatekeeper@3.0.1`) → **Gatekeeper** (`tix-gatekeeper`). Its README in TIX-REACT-COMMON (`packages/react-common-gatekeeper/README.md`) lists Build, Test and Sonar stages, each reported as a GitHub PR status. Sonar runs PR analysis (new code only) for PRs into `main`, and full branch analysis only for PRs *from* `main`. Gatekeeper's Sonar sources and exclusions for this repo are hard-coded in TIX-REACT-COMMON at `packages/react-common-gatekeeper/src/sonar/projects/tix-next-payment-fe.ts`. That list nearly matches the local `sonar-project.properties` but also excludes `lib/types/**`. Changing coverage exclusions here alone does not change what Gatekeeper measures. See [[react-common-gatekeeper]].
- **GitHub Actions:**
  - `nextjs_bundle_analysis.yml`: builds with mocking disabled on PRs to `main` and on pushes to it, and reports bundle size (skipped for `Version Packages`).
  - `release.yml`: on push to `main` (see Release).
  - `prerelease.yml`: see Release.
  - `playwright.yml`: manual only.

## Release
Changesets, single private package (`tix-next-payment-fe`, `access: restricted`, changelog via `@changesets/changelog-github`). See [[changesets-fixed-versioning]].
- **Production:** merge PRs with a changeset to `main`. `release.yml` runs `changesets/action`, which opens or updates the **"Version Packages"** PR (commit `ci: version packages`). Merging it bumps `package.json` and `CHANGELOG.md`, and the next run executes `npm run release` (`changeset publish && changeset tag`), which creates the `vX.Y.Z` git tag. The workflow skips when there are no changesets and the version equals the latest stable tag. Deployment from the tag happens on Jenkins (README).
- **Staging / prerelease:** add the label **`Automate Pre-Release`** to a PR (or run `workflow_dispatch`). `prerelease.yml` uses `anothrNick/github-tag-action` to push a prerelease tag (`-alpha` by default; label `Automate Beta Version` gives `-beta`, `Automate RC Version` gives `-rc`; a `feat:` commit bumps minor, otherwise patch) and comments the tag on the PR. README's older text describes this as "push to `origin/prerelease` → automatic tag → trigger Jenkins". See [[prerelease-flow]].
- Env config lives in Consul (`inca.ggwp.red/ui/tiket/kv/payment`, README). Logs are in Kibana and metrics in Grafana (`service_name=next-payment-fe`).

## Repo docs (read in place)
- `AGENTS.md`: agent rules (commands, contexts, endpoints, SCSS, i18n, testing). Out of date in places: it says Next.js 14 and React Query v3.39.2 (the code uses Next 16 and v5), its promo section points to `components/Promo` (removed), and it lists v1 promo endpoints (the code uses v2).
- `docs/CODING_CONVENTION.md`: test structure, lint/format, container/logic/data component architecture and file naming.
- `docs/FORTER_INTEGRATION.md`: Forter fraud SDK integration plan (env vars `NEXT_PUBLIC_FORTER_SITE_ID`, `NEXT_PUBLIC_FORTER_ENABLED`).
- `docs/mybca-auto-redirect-flow.md`: myBCA auto-redirect in `components/SubmitPayment#handleGeneralRedirection`, with the required backend behaviour and fallbacks.
- `docs/order-detail-flow.md`: order detail and summary APIs and components per vertical (gift card, standalone insurance…).
- Agent tooling in the repo: `.agents/skills/` (oxfmt/oxlint migration, Vercel React best practices), `.claude/skills/vercel-react-best-practices`, and `.cursor/rules/*.mdc` plus `.cursor/skills/migrate-*` (Next 16, React 19, React Query v5, ESLint flat config, Jest→Vitest, tiket packages). There is **no `learn/` directory** on `origin/main`.

## Sources
- `package.json`, `.npmrc`, `.env.local.example`
- `AGENTS.md`, `README.md`, `docs/*.md`
- `vitest.config.mts`, `sonar-project.properties`, `playwright.config.ts`, `e2e/start-web-server.sh`, `e2e/scenarios/infinity/README.md`
- `Jenkinsfile.dev`, `.github/workflows/{release,prerelease,playwright,nextjs_bundle_analysis}.yml`, `.changeset/config.json`
- `.husky/{pre-commit,pre-push,commit-msg}`, `.lintstagedrc.js`, `commitlint.config.js`
