---
title: TIX-GROWTH-NEXT-FE workflows
repo: TIX-GROWTH-NEXT-FE
kind: workflows
sources:
  - package.json
  - README.md
  - .npmrc
  - jest.config.mjs
  - jest.setup.js
  - jest.polyfills.js
  - lib/test-utils.tsx
  - lib/mocks
  - playwright.config.ts
  - e2e
  - .env.local.example
  - .env.test
  - Jenkinsfile.dev
  - Dockerfile
  - sonar-project.properties
  - .github/workflows
  - .github/pull_request_template.md
  - .changeset
  - .husky
  - .lintstagedrc.js
  - .cursor/rules
  - .agents/skills
verified_at: d4162e3
updated: 2026-10-16
status: current
tags: [repo/growth-fe, kind/workflows]
---

# TIX-GROWTH-NEXT-FE workflows
> Node 24 with pnpm 9. Jest runs the unit tests and Playwright the E2E tests. Jenkins runs `tix-gatekeeper` on PRs, changesets versions the app, and PR labels cut prerelease git tags. Local dev needs HTTPS on `local.tiket.com`.

## Commands
| Command | What it does |
|---|---|
| `pnpm dev` | `source .env.local && next dev --webpack --experimental-https` with `SSL_KEY_FILE`/`SSL_CERT_FILE` |
| `pnpm build` / `pnpm start` | `next build --webpack` / `next start` plus `local-ssl-proxy` 3001 → 3000 |
| `pnpm test` / `test:watch` | `jest --coverage --verbose` |
| `pnpm e2e` / `e2e:ui` | Playwright (`e2e/`), see below |
| `pnpm type-check`, `lint:js` (`eslint .`), `lint:css`, `format` (`prettier . --write`) | |
| `pnpm check-all` | type-check + lint:js + lint:css + format + test |
| `pnpm analyze` | build with `@next/bundle-analyzer` |
| `pnpm docker:build:sonar` / `sonar:scan` | run the Sonar scanner locally in Docker (`docker/Sonar.Dockerfile`) |
| `pnpm changeset` / `pnpm release` | add a changeset / `changeset publish && changeset tag` (CI only) |

`prepare` runs husky and `msw init ./public`.

## Tooling versions
Volta and `.npmrc` (`use-node-version`) pin Node `24.14.1`. Jenkins, GitHub Actions and the Dockerfile all install **pnpm 9**. There is no `packageManager` field, despite what the README says. A comment in `nextjs_bundle_analysis.yml` mentions a root `pnpm-workspace.yaml`, but none exists on `main`. Local pnpm pitfalls: [[passport-local-tooling]].

## Local development
- Copy `.env.local.example` to `.env.local`. It sets `BASE_URL=https://local.tiket.com:3000`, `NEXT_PUBLIC_BASE_PREFIX_FOR_APP=growth`, `SERVER_SIDE_SERVICE_ENDPOINT=https://lb1-testing.tiket.com`, the remote URL (staging), the affiliate cluster hosts, the Blibli affiliate URL and the metasearch tuning vars. HTTPS setup: [[local-https-certs]].
- The affiliate cluster hosts (`*.test-misc-cluster.tiket.com`) only resolve inside the cluster or VPN. Without them the affiliate SSR calls fail locally.
- **API mocking:** with `NEXT_PUBLIC_API_MOCKING=enabled`, `_app` loads `lib/mocks/msw-init` in the browser, and `instrumentation.page.ts` calls `registerFetchMock` from `@tiket/next/instrumentation` for server-side fetches. Both use `lib/mocks/msw-handlers.ts`. The README walks through the Google Flights book flow on mocks (fixtures in `lib/mocks/data/b2b/`), see [[growth-fe-affiliate]].

## Unit tests (Jest)
- `next/jest` config with `jest-environment-jsdom`, v8 coverage, `@/` alias. `transformIgnorePatterns` is overridden so that `@tiket/*` packages inside pnpm's store get transformed. `e2e/` is ignored.
- `jest.setup.js` mocks `next/router` with `next-router-mock`. Its dynamic-route parser list is still the starter's commented example, so `[slug]` routes are not parsed. The global **`mswServer.listen()` is commented out**: only `resetHandlers()` and `close()` run. A spec that needs MSW must call `mswServer.listen()` itself.
- `lib/test-utils.tsx` gives a custom `render` (returns `user`), and re-exports Testing Library, `mockRouter`, `mswServer` and `http`. Its wrapper is empty. `.cursor/rules/unit-test.mdc` (copied from TIX-NEXT-FE) mentions `useQueryClient` and `useLocaleProvider` render options that this `render` **does not implement**, so pass your own `wrapper`.
- Conventions (`unit-test.mdc`): `*.spec.ts(x)` in `__tests__/` next to the subject.
- `.env.test` sets `BASE_URL=http://mockable.tiket.com:3000` and the prefix `core`.
- Coverage ignores `lib/mocks`, `lib/types`, `_app`, `layout`, `document`, `middleware`. Sonar additionally excludes services, types, i18n, fetch, config and `app/api` (`sonar-project.properties`). Cross-repo summary: [[run-tests-per-repo]].

## E2E (Playwright)
- `playwright.config.ts`: `testDir: e2e`, Chromium only, `locale: 'id-ID'`, 180 s timeouts (the guest-token calls in middleware can be slow locally), 2 retries on CI.
- `PLAYWRIGHT_APP_ENV` = `local` (default, `https://local.tiket.com:3000`), `staging` (gatotkaca), `preprod` or `prod` picks the base URL (`e2e/playwright.env.ts`). It loads env with `@next/env` the same way `next dev` does. That's why `@next/env` 14.2.35 is a dev dependency next to Next 16.
- `webServer` runs `npx next dev -p 3000` (plain HTTP, no `--webpack` flag) unless `PLAYWRIGHT_SKIP_WEBSERVER` is set. It waits on the port, not on `/`, because a GET to `/` can block on middleware. When you run against staging, preprod or prod, set `PLAYWRIGHT_SKIP_WEBSERVER`.
- Specs: `e2e/affiliate/{book-flight,c-cobrand,r-redirect}.spec.ts`, `e2e/metasearch/{checkout,redirect}.spec.ts`. No CI workflow runs them on `main`.

## Git hooks and commits
- husky `pre-commit` → `lint-staged` (`.lintstagedrc.js`: a project-wide `tsc --noEmit`, `eslint --fix`, `prettier --write`, `stylelint --fix`), `commit-msg` → commitlint (conventional).
- `pre-push` → `npm run check-all`. That includes `prettier . --write`, so a push can **rewrite files** in the working tree without committing them. Check `git status` after a push.
- PR template: JIRA link, description and technical solution, screenshots, type of change.

## CI
- **Jenkins** (`Jenkinsfile.dev`): pod on `node:24.14.1-alpine` (4 CPU / 12 Gi) with host aliases for `gatotkaca.tiket.com` and `lb1-testing.tiket.com`. It writes `.npmrc` for GitHub Packages, activates pnpm 9, installs `@tiket/react-common-gatekeeper@3.0.1` and runs `tix-gatekeeper -s prepare`, sets up a native sonar-scanner 4.7 with the system JRE, runs `pnpm i` with `.env.local` copied from the example, then `tix-gatekeeper`. It is skipped for the "Version Packages" PR. See [[gatekeeper-ci]] and [[react-common-gatekeeper]].
- **GitHub Actions:**
  - `release.yml` (push to `main`): runs `changesets/action` only when changeset files exist or the `package.json` version differs from the latest stable `vX.Y.Z` tag. It opens or updates the "Version Packages" PR (`ci: version packages`), and once that PR merges, `npm run release` tags the version. It disables `prepare` before install.
  - `prerelease.yml`: on PRs labelled **Automate Pre-Release** (or manual dispatch), `github-tag-action` pushes a prerelease tag (`-alpha` by default, `-beta`/`-rc` with the **Automate Beta Version**/**Automate RC Version** labels). `feat:` bumps minor, anything else bumps patch. See [[prerelease-flow]].
  - `nextjs_bundle_analysis.yml`: builds with mocking disabled and comments the size diff against the base branch.
- A long-lived `origin/prerelease` branch exists (`prerelease` → `main` PR). See [[prerelease-squash-merge]].

## Versioning (changesets)
Single private package, `"access": "restricted"`, `fixed: []`, `baseBranch: main`, changelog via `@changesets/changelog-github` (`tiket/TIX-GROWTH-NEXT-FE`). The version is the app's release number (CHANGELOG `## 1.2.1`), not an npm publish. See [[changesets-fixed-versioning]].

## Deployment
- Docker (`Dockerfile`): `deps` (`npm install -g pnpm@9 && pnpm i --frozen-lockfile`, because Corepack key checks failed) → `builder` (ARGs `DEPLOYMENT_TAG`, `BASE_URL`, `NEXT_PUBLIC_BASE_PREFIX_FOR_APP`, `SERVER_SIDE_SERVICE_ENDPOINT`, `git` for `next-build-id`) → `runner` (`.next/standalone` + `static`, `node server.js` on `$PORT`, k8s default 7777).
- `.env.local.example` says every env var must also be a Dockerfile `ARG`. Most `NEXT_PUBLIC_*` vars (affiliate hosts, metasearch tuning, GTM id, remote URL) are **not** ARGs on main, so the pipeline must provide them some other way before they can be inlined at build time. Check that before you add a new public env var.
- Environment names by hostname: [[tiket-environments]].

## Security note
`sonar-project.properties` on `main` contains a committed `sonar.login` token. Don't copy it anywhere. Rotate it and move it to CI credentials if you touch Sonar config.

## Agent tooling in the repo
`.cursor/rules/` holds `components.mdc`, `unit-test.mdc`, `playwright.mdc`, `next-config-next16.mdc` (remotePatterns, `(phase) =>` config, `--webpack` for Module Federation) and `next-scripts-pnpm-webpack.mdc`. Several are copied from TIX-NEXT-FE and use its conventions. `.agents/skills/` holds a single `react-next-19-16-migration` skill (React 19 / Next 16 / TanStack v5 / ESLint 10 targets).

## Sources
- `package.json`, `README.md`, `.npmrc`, `.env.local.example`, `.env.test`, `sonar-project.properties`
- `jest.config.mjs`, `jest.setup.js`, `lib/test-utils.tsx`, `lib/mocks/**`, `instrumentation.page.ts`
- `playwright.config.ts`, `e2e/playwright.env.ts`, `e2e/**`
- `Jenkinsfile.dev`, `Dockerfile`, `docker/Sonar.Dockerfile`
- `.github/workflows/release.yml`, `prerelease.yml`, `nextjs_bundle_analysis.yml`, `.github/pull_request_template.md`
- `.changeset/config.json`, `CHANGELOG.md`
- `.husky/pre-commit`, `.husky/commit-msg`, `.husky/pre-push`, `.lintstagedrc.js`
- `.cursor/rules/*.mdc`, `.agents/skills/SKILL.md`
- `git branch -r` on the repo (prerelease branch)
