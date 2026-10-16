---
title: TIX-HOMEPAGE-NEXT-FE workflows
repo: TIX-HOMEPAGE-NEXT-FE
kind: workflows
sources:
  - package.json
  - AGENTS.md
  - vitest.config.mts
  - vitest.setup.ts
  - lib/test-utils.tsx
  - __mocks__
  - lib/mocks
  - .env.local.example
  - .env.test
  - Jenkinsfile.dev
  - Dockerfile
  - .github/workflows
  - .github/pull_request_template.md
  - .changeset
  - .husky
  - .lintstagedrc.js
  - .lintstagedrc.mjs
  - instrumentation.page.ts
  - docs/testing.md
  - docs/deployment.md
  - docs/https-for-local-development.md
  - .cursor/skills/testing/SKILL.md
  - .agents/skills
  - .claude/skills
verified_at: 408983f6
updated: 2026-10-16
status: current
tags: [repo/homepage-fe, kind/workflows]
---

# TIX-HOMEPAGE-NEXT-FE workflows
> Use pnpm 10 on Node 24. Vitest (vmThreads + istanbul) runs the tests, Jenkins runs `tix-gatekeeper` on PRs, changesets versions the app, and PR labels cut prerelease git tags. Local dev needs HTTPS on `local.tiket.com`.

## Commands
| Command | What it does |
|---|---|
| `pnpm dev` | `source .env.local && next dev --experimental-https` with `SSL_KEY_FILE`/`SSL_CERT_FILE`, webpack |
| `pnpm build` / `pnpm start` | `next build --webpack` / `NEXT_MANUAL_SIG_HANDLE=true next start` |
| `pnpm test` | `vitest run --coverage --reporter=verbose` |
| `pnpm test:watch`, `pnpm test:slow` | watch with coverage / per-test timing via `scripts/slow-tests-reporter.ts` (report in `reports/`) |
| `pnpm vitest run <spec>` | one spec (`.cursor/skills/testing`) |
| `pnpm type-check`, `lint:js` (eslint), `lint:css` (stylelint), `format` (prettier --write) | |
| `pnpm check-all` | type-check + lint:js + lint:css + format + test |
| `pnpm prepush-check` | type-check + lint:js + test (husky `pre-push`) |
| `pnpm analyze` | build with `@next/bundle-analyzer` |
| `pnpm detect-unused-i18n` | `scripts/detect-unused-i18n-keys.ts` |
| `pnpm changeset` / `pnpm release` | add a changeset / `changeset publish && changeset tag` (CI only) |
| `pnpm ctx …`, `index:repo`, `sync:claude-skills`, `session:summary` | agent toolkit (`.cursor/scripts/`), see AGENTS.md |

`postinstall` regenerates `.cursor/indexes/` and re-syncs `.claude/skills` symlinks. `prepare` runs husky and `msw init ./public`.

## Tooling versions
`packageManager: pnpm@10.25.0`, Volta/`.nvmrc` Node `24.14.1`. Jenkins activates `pnpm@10`, but the **Dockerfile still runs `corepack prepare pnpm@9`** for install and build (lockfile v9 works with both). For local pnpm/bun pitfalls see [[passport-local-tooling]].

## Local development
- Copy `.env.local.example` to `.env.local`. It sets `BASE_URL=https://local.tiket.com:3000`, `NEXT_PUBLIC_BASE_PREFIX_FOR_APP=homepage-v4`, `SERVER_SIDE_SERVICE_ENDPOINT=https://lb1-testing.tiket.com`, the remote URLs and `NEXT_PUBLIC_API_MOCKING=enabled`.
- HTTPS is required so that MSW's service worker runs on a custom domain and `*.tiket.com` session cookies are sent (docs/https-for-local-development.md): map `local.tiket.com` in `/etc/hosts` and create `local.tiket.com(-key).pem` with mkcert in the repo root. See [[local-https-certs]].
- The doc says to visit `https://local.tiket.com:3001` through `local-ssl-proxy`. The current `dev` script uses Next's built-in `--experimental-https` on the default port, matching `BASE_URL` `:3000`, and `next.config.ts` lists `allowedDevOrigins: ['local.tiket.com']`.
- **API mocking:** with `NEXT_PUBLIC_API_MOCKING=enabled`, `_app` loads `lib/mocks/msw-init` in the browser, and `instrumentation.page.ts` calls `registerFetchMock` from `@tiket/next/instrumentation` with `lib/mocks/msw-handlers` for server-side fetches. Handlers are grouped under `lib/mocks/handlers/{core,home,explore,promo-detail,cross-sell-trip,…}` with fixtures in `lib/mocks/data/`. The `pr-visual-diff` skill (in the user's Claude setup, not the repo) screenshots PRs against these mocks.

## Testing (Vitest)
Migrated from Jest in 4.7.0 (#1437). Read `vitest.config.mts` and `vitest.setup.ts` before changing test infra; their comments explain each choice.
- `pool: 'vmThreads'` is **required**: the @tiket packages' `.scss` imports only go through Vite's CSS pipeline under that loader. `fsModuleCache: true`, `maxWorkers: 4` on CI.
- Passport and react-common packages render **for real**, prebundled by the client optimizer (`PREBUNDLED_PACKAGES`). The prebundle is skipped for `-t`/`--testNamePattern` single-test runs. `server.deps.inline: [/@tiket\//]` covers deep `dist/` imports.
- Aliased stubs (reach inside the prebundle): `@tiket/react-common-ab-test` → `lib/mocks/ab-test-stub.ts`, `@tiket/react-common-remote` → `lib/mocks/remote-stub.tsx`. Partial `vi.mock`s with the real module plus `__mocks__/` overrides: `@tiket/passport-page-module` (a fake `PageModule` that fires `onIntersect`/`onFirstModuleAppear` on mount) and `@tiket/passport-utils`. Full mocks: search-widget-flight/ttd and social-share.
- `clearMocks` + `mockReset` before every test. So set `mockReturnValue`/`mockImplementation` inside a test or `beforeEach`, never at module level or in `beforeAll`.
- Fake timers have `shouldAdvanceTime` (so `waitFor` polls). `TZ=UTC` must match `.env.test`. `.env.test` sets `BASE_URL=http://mockable.tiket.com:3000`.
- `next/router` → `next-router-mock` with a dynamic-route parser list that has to be kept in sync with `pages/`. `next/dynamic` is wrapped so that tests await pending imports.
- SSR specs opt into `// @vitest-environment node`.
- Always import from `@lib/test-utils` (AGENTS.md), which also wraps the context providers.
- Coverage: istanbul (much faster than v8 under vmThreads), `include: {pages,components,lib}/**`, thresholds only 10%. `lib/services`, `lib/fetch`, `lib/i18n`, `lib/jsi`, `lib/session`, `lib/mocks`, `_app` and similar are excluded, and Sonar excludes the same areas (`sonar-project.properties`). Keep `@vitest/coverage-istanbul` pinned to the exact Vitest version.
- `docs/testing.md` is from the old starter: it shows MSW v1 `rest.get(..., (req,res,ctx))` handlers, which MSW 2 (`http`) no longer supports. `.agents/skills/testing` still says Jest. Follow `.cursor/skills/testing` and `create-unit-test` instead. Cross-repo summary: [[run-tests-per-repo]].
- `patches/jsdom@26.1.0.patch` (mockable `window.location`) is **not applied**, see [[homepage-fe-architecture]].

## Git hooks and commits
- husky `pre-commit` → `lint-staged`, `commit-msg` → commitlint (conventional), `pre-push` → `prepush-check`.
- Two lint-staged configs exist (`.lintstagedrc.js` with a `tsc --noEmit` gate, `.lintstagedrc.mjs` with eslint, `.cursor/indexes` regeneration, stylelint and prettier). lint-staged loads only one of them, so check which is active before relying on the tsc gate.
- PR template: JIRA link, description and technical solution, before/after screenshots, type of change, testing checklist.

## CI
- **Jenkins** (`Jenkinsfile.dev`): a pod on `node:24.14.1-alpine` (4 CPU / 12 Gi). It writes `.npmrc` for GitHub Packages, installs `@tiket/react-common-gatekeeper@3.0.1` globally, runs `tix-gatekeeper -s prepare` and `pnpm i --frozen-lockfile` (with `.env.local` copied from the example), then `tix-gatekeeper`. It's skipped for the "Version Packages" PR. See [[gatekeeper-ci]] and [[react-common-gatekeeper]].
- **GitHub Actions:**
  - `release.yml` (push to `main`): runs `changesets/action` only if changeset files exist or `package.json` version ≠ latest stable `vX.Y.Z` tag. It opens or updates the "Version Packages" PR (`ci: version packages`), and after that merges `npm run release` tags the version. It disables `prepare` (husky/msw) before install.
  - `prerelease.yml`: on PRs labelled **Automate Pre-Release** (or manual dispatch), `github-tag-action` pushes a prerelease tag (`-alpha` by default, `-beta`/`-rc` with the **Automate Beta Version**/**Automate RC Version** labels). `feat:` bumps minor, else patch. The bot comments the tag on the PR. See [[prerelease-flow]].
  - `nextjs_bundle_analysis.yml`: builds with mocking disabled and compares bundle size with the base branch.
  - `removeStalePr.yml`: PRs go stale after 180 days and close 15 days later.
- Long-lived `origin/prerelease` (plus `prerelease_sprint89`, `prerelease_sprint90`) branches exist. See [[prerelease-squash-merge]] for the squash-merge procedure used across the app repos.

## Versioning (changesets)
Single private package, `"access": "restricted"`, `fixed: []`, `baseBranch: main`, changelog via `@changesets/changelog-github`. The version is the app's release number (CHANGELOG `## 4.7.0`), not an npm publish. See [[changesets-fixed-versioning]].

## Deployment
- Docker (`Dockerfile`): `deps` (pnpm install, copies `patches/`) → `builder` (build args `BASE_URL`, `NEXT_PUBLIC_BASE_PREFIX_FOR_APP`, `SERVER_SIDE_SERVICE_ENDPOINT`, GTM/UA ids, Firebase/FCM keys; mocking forced `disabled`; `git` installed for `next-build-id`) → `runner` (`.next/standalone` + `static`, `node server.js` on `$PORT`, k8s default 7777).
- `.env.local.example` says every env var that affects the build must also be a Dockerfile `ARG`. The remote URLs and `NEXT_PUBLIC_POST_LOG_PATH` are not ARGs on main, so check how the pipeline provides them before relying on them at build time.
- LB routing (docs/deployment.md): register `/{prefix}/_next/:splat` and `/_next/data/{prefix}__:splat` for the app. Here `{prefix}` = `NEXT_PUBLIC_BASE_PREFIX_FOR_APP` (`homepage-v4` in the example env, `home` in `.env.test`).
- Environments are named by hostname (`gatotkaca` staging, `preprod`, production): see [[tiket-environments]].

## Agent tooling in the repo
`AGENTS.md` (Cursor + Claude Code) requires starting multi-file work with `pnpm ctx classify|build`, reading files in chunks, and logging decisions with `pnpm ctx decide`. Skills are authored in `.cursor/skills/` (create-page-feature, create-api-service, create-unit-test, nextjs-conventions, passport-ui, pr-review, jira-to-code, git-commit, and `migrate-*` for the Next 16 / React 19 / RQ v5 / Vitest migrations). `.claude/skills/*` symlinks to them. `.agents/skills/` holds copies installed from `tiket/TIX-NEXT-FE` (`skills-lock.json`).

## Sources
- `package.json`, `AGENTS.md`, `skills-lock.json`, `.env.local.example`, `.env.test`, `sonar-project.properties`
- `vitest.config.mts`, `vitest.setup.ts`, `__mocks__/@tiket/**`, `lib/mocks/**`, `instrumentation.page.ts`
- `Jenkinsfile.dev`, `Dockerfile`
- `.github/workflows/release.yml`, `prerelease.yml`, `nextjs_bundle_analysis.yml`, `removeStalePr.yml`, `.github/pull_request_template.md`
- `.changeset/config.json`, `CHANGELOG.md`
- `.husky/pre-commit`, `.husky/commit-msg`, `.husky/pre-push`, `.lintstagedrc.js`, `.lintstagedrc.mjs`
- `docs/testing.md`, `docs/deployment.md`, `docs/https-for-local-development.md`
- `.cursor/skills/testing/SKILL.md`, `.agents/skills/testing/SKILL.md`, `.claude/skills/*`
- `git branch -r` on the repo (prerelease branches)
