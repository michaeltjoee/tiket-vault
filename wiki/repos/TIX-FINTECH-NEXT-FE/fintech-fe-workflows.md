---
title: TIX-FINTECH-NEXT-FE workflows
repo: TIX-FINTECH-NEXT-FE
kind: workflows
sources:
  - package.json
  - README.md
  - Jenkinsfile.dev
  - .github/workflows
  - .changeset
  - .husky
  - .lintstagedrc.js
  - .github/pull_request_template.md
  - .claude/rules
  - vitest.config.mts
  - playwright.config.ts
  - e2e/playwright.env.ts
  - docs/testing.md
  - docs/https-for-local-development.md
  - scripts/migrate-jest-to-vitest.mjs
verified_at: 5833b842
updated: 2026-10-16
status: current
tags: [repo/fintech-fe, kind/workflows]
---

# TIX-FINTECH-NEXT-FE workflows

## Local dev
1. Node 24.14.1 + pnpm 9.15.9 (Volta pins in `package.json`; README's "Node 16 / npm i" is outdated). `GITHUB_TOKEN` with `read:packages` for `@tiket/*` from GitHub Packages.
2. `cp .env.local.example .env.local`. Key vars: `NEXT_PUBLIC_BASE_PREFIX_FOR_APP=fintech`, `SERVER_SIDE_SERVICE_ENDPOINT=https://lb1-testing.tiket.com` (needs VPN), `NEXT_PUBLIC_API_MOCKING=enabled` (MSW in the browser), `NEXT_PUBLIC_WEBVIEW_BRIDGE_MOCKING`, `NEXT_PUBLIC_THIRD_PARTY_URL`, remote-component URLs, feature flags `NEXT_PUBLIC_GIFT_CARD_ENABLED`, `NEXT_PUBLIC_CLAIM_AMOUNT_ENABLED`.
3. HTTPS: generate `local.tiket.com.pem` / `-key.pem` (`docs/https-for-local-development.md`); `pnpm dev` runs `next dev --experimental-https --webpack` on `https://local.tiket.com:3000`. `pnpm start` puts `local-ssl-proxy` on 3001.
4. Start Chrome with `--disable-web-security` for backends that reject CORS.
See also [[passport-local-tooling]] for consuming locally built passport packages.

## Tests
- **Vitest** (`vitest.config.mts`), migrated from Jest with one-shot codemods in `scripts/` (`migrate-jest-to-vitest.mjs`, `fix-next-*-mocks.mjs`); `vitest.jest-compat.ts` and `vitest-jest-shim.d.ts` keep `jest.*` types and globals working. jsdom, `pool: 'threads'`, `@tiket/*` inlined and force-transformed (they ship extensionless ESM/TS source), `passport-assets` replaced by a generated virtual mock.
- `pnpm test` passes `-u`, so it rewrites snapshots silently; CI uses `test:ci` (no `-u`). `docs/testing.md` says avoid snapshots unless the markup is business-critical.
- Coverage thresholds 90/90/91/91 (branches/functions/lines/statements); `coverage.include` is `{app,pages,components,lib}/**` only, so code under `projects/` is not counted, despite the restructure skill saying to add it. `bail: 0` on purpose: bailing leaves Sonar with an almost empty `lcov.info`.
- API mocks with MSW 2: global handlers `lib/mocks/msw-handlers.ts`, team handlers under `projects/{team}/shared/lib/mocks` or `app/gift-card/**/mocks`. `__mocks__/@tiket/*` stubs heavy passport/react-common packages (bottom-sheet, modal, chat-platform, ab-test, remote…).
- **Playwright** (`e2e/`, currently `insurance/claim-center/login.spec.ts`, `insurance/standalone/login.spec.ts`): base URL picked only by `PLAYWRIGHT_APP_ENV` (`local|staging|preprod|prod`) via `e2e/playwright.env.ts`, which loads env with `@next/env` the same way `next dev` does (skips `.env.local` when `NODE_ENV=test`). Chromium only, retries 2 in CI, 180 s nav timeout because locale/session middleware is slow when guest-token calls fail locally. Conventions: `.claude/rules/playwright.md`.

## Commit and push hooks
- commitlint conventional; body lines ≤ 100 chars is the rule that fails most often. Don't add `Co-authored-by` unless asked; Cursor's "Generate Commit Message" ignores the rule files and often breaks both (`.claude/rules/commit-messages.md`).
- pre-commit: lint-staged runs `tsc --noEmit` on any TS change, eslint `--fix`, prettier, stylelint.
- pre-push: `npm run check-all` (type-check, lint, stylelint, prettier, full test run).

## CI
- **Jenkins is the merge gate**, not GitHub Actions (`Jenkinsfile.dev`, README). The pod installs deps with `pnpm i --frozen-lockfile` and runs `tix-gatekeeper` from [[react-common-gatekeeper]] `@3.0.1` (tests, lint, Sonar using the `tix-fintech-next-fe` project config in TIX-REACT-COMMON). Jenkins skips PRs titled `Version Packages`. Sonar needs OpenJDK 21 (#448).
- GitHub Actions: `nextjs_bundle_analysis.yml` (PR/push to main), `prerelease.yml`, `release.yml`.

## Release
The app is versioned with changesets although nothing is published to npm ([[changesets-fixed-versioning]] for the general pattern; this repo has a single package, `fixed: []`).
1. Add a changeset (`pnpm changeset`) in the PR.
2. On push to `main`, `release.yml` runs `changesets/action`: with pending changesets it opens/updates the **Version Packages** PR (commit `ci: version packages`); after that PR merges, `npm run release` (`changeset publish && changeset tag`) creates the git tag. The job is skipped if there are no changesets and `package.json` version equals the latest stable `vX.Y.Z` tag.
3. `.changeset/changelog.cjs` wraps `@changesets/changelog-github` and appends Jira links from the PR description (`Jira: ...` line), falling back to a key in the PR title (`feat(PLAT-123): ...`) or branch name, so release notes can feed the deployment ticket.

**Prerelease** ([[prerelease-flow]]): label a PR `Automate Pre-Release` (or run manually) and `prerelease.yml` pushes a prerelease tag via `anothrNick/github-tag-action` (patch bump by default, minor if a commit has `feat:`), suffix `alpha` by default, `rc` with label `Automate RC Version`, `beta` with `Automate Beta Version`, and comments the tag on the PR.

Deployment is Docker/Kubernetes (`Dockerfile`, `output: 'standalone'`); see [[fintech-fe-architecture]] for the LB path prefix.

## PRs
Template asks for Jira link, description and technical solution, screenshots, type of change and test notes. `.cursor/skills/technical-solution` holds a checklist for writing the technical solution.

## Sources
- `package.json`, `README.md`, `Jenkinsfile.dev`, `.github/workflows/{release,prerelease,nextjs_bundle_analysis}.yml`
- `.changeset/config.json`, `.changeset/changelog.cjs`, `.husky/pre-commit`, `.husky/pre-push`, `.lintstagedrc.js`, `.github/pull_request_template.md`
- `.claude/rules/commit-messages.md`, `.claude/rules/playwright.md`
- `vitest.config.mts`, `playwright.config.ts`, `e2e/playwright.env.ts`, `scripts/migrate-jest-to-vitest.mjs`
- `docs/testing.md`, `docs/https-for-local-development.md`
