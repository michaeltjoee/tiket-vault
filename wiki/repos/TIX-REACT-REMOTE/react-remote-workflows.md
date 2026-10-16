---
title: TIX-REACT-REMOTE workflows
repo: TIX-REACT-REMOTE
kind: workflows
sources:
  - README.md
  - docs/SOP-ENVIRONMENT-VARIABLES.md
  - package.json
  - Dockerfile
  - Jenkinsfile.dev
  - vercel.json
  - .github/workflows
  - .husky
  - sonar-project.properties
  - .npmrc
  - pnpm-workspace.yaml
verified_at: 281778b
updated: 2026-10-16
status: current
tags: [repo/react-remote, kind/workflows]
---

# TIX-REACT-REMOTE workflows

## Local development
1. Node 24.14.1 and `corepack enable` (pnpm 10.28.2 is pinned in `packageManager`). Export a `GITHUB_TOKEN` with read access to GitHub Packages; `.npmrc` reads `${GITHUB_TOKEN}`.
2. `cp .env.example .env`, then `pnpm install` and `pnpm dev`. The server listens on `PORT` (default 3003). Check `http://localhost:3003/api/prerender/footer`.
3. In the consumer Next app set `NEXT_PUBLIC_REACT_REMOTE_API_URL=http://localhost:3003` and `NEXT_PUBLIC_REACT_REMOTE_URL=http://localhost:3003`.
4. Optional HTTPS: `pnpm ssl-proxy` proxies 3005 to 3004 using `SSL_KEY_FILE`/`SSL_CERT_FILE` from `.env`.

`pnpm dev` rebuilds both bundles on every `src` change through nodemon. There is no HMR.

## Testing a Passport change before release
The usual change is a Passport fix. The flow is: release or prerelease the Passport packages (see [[prerelease-flow]]), bump every `@tiket/passport*` dependency here to the same version, and run `pnpm install`. Recent history is almost entirely `chore: bump @tiket/passport to X` commits. Because Passport is compiled from `src` (swc import rewrite), the Passport package must publish its `src/`. Git tags such as `v2.0.29-0`…`-2` show prerelease versions of this service being cut for testing.

## Adding a component
`pnpm create:component` → enter a kebab-case key. It writes `src/components/<key>/{index.tsx,bootstrap.ts}` and rewrites `exposes.config.js` and `src/server/components.ts` (sorted). Then add the key to `MODULES_NAME` and a `Remote<Name>` wrapper in [[react-common-remote]] (TIX-REACT-COMMON), and release that package.

## Environment variables
Follow `docs/SOP-ENVIRONMENT-VARIABLES.md`. In short:
- **Client-bundle vars** are inlined at build time by `DefinePlugin`. Each one needs an entry in `webpack.config.js`, `ARG` + `ENV` in the Dockerfile `builder` stage, a line in `.env.example`, and a Jenkins/Kaniko `--build-arg` (ask DevOps). Values are strings, so compare with `'true'`. The K8s ConfigMap `tix-react-remote-runtime-env` cannot change them. The SOP was written after `IS_AMPLITUDE_ENABLED`/`IS_MIXPANEL_ENABLED` showed `undefined` after deploying v2.0.17.
- **Server-only vars** are read at runtime from the pod env: `PORT`, `BASE_PREFIX_URL`, `MS_GATEWAY_BASE_URL` (used by [[react-remote-reviews]]).

## Build and deploy
- `Dockerfile` has 4 stages. `deps`: `pnpm install --no-frozen-lockfile --ignore-scripts` with `GITHUB_TOKEN`. `builder`: analytics build args, then `pnpm run build`. `runtime-deps`: installs only `isomorphic-dompurify@3.12.0`. `runner`: copies `api`, `public`, `dist`, `package.json`, exposes port 7777 and runs `node ./api`.
- The deploy pipeline (Kaniko image build, upload of `dist/client/assets` to `gs://general-gatotkaca-static-files/shared-components/assets/`) is **not in this repo**. Platform/DevOps owns it.
- `Jenkinsfile.dev` does **not** deploy. It installs, runs SonarQube, and runs `tix-gatekeeper` (`@tiket/react-common-gatekeeper`, see [[react-common-gatekeeper]]) using GitHub App credentials. It writes the GitHub Packages token literally into `.npmrc`, because pnpm will not expand `${GITHUB_TOKEN}` from a committed project `.npmrc`.
- `vercel.json` + `api/index.js` allow a Vercel deploy that rewrites `/api/*` to the Express app.
- Version: bump `package.json` with `npm version` in the PR (e.g. `2.0.33` in #378). Prerelease tags look like `vX.Y.Z-N`.

## CI on pull requests
- `.github/workflows/bundle-analyzer.yml` builds the base and head branches and posts a webpack bundle-size comparison from `dist/client/stats.json`.
- `.github/workflows/pr_lint.yml` requires a semantic PR title (`feat:`, `fix:`, `chore:`…).
- PR template asks for a JIRA link, a description and a testing checklist.

## Git hooks
Husky: `pre-commit` runs `lint-staged` (prettier on all staged files). `pre-push` runs `pnpm test`.

## Gotchas
- Sonar excludes `src/components/**`, `src/server/**`, `src/utils/header/**` and `mount.tsx`, so the coverage gate barely covers the shipped code.
- `sonar-project.properties` contains a committed `sonar.login` token.
- Installs use `--no-frozen-lockfile` everywhere (Docker, Jenkins, CI), so the lockfile can drift silently.

## Sources
- README.md
- docs/SOP-ENVIRONMENT-VARIABLES.md
- package.json
- Dockerfile
- Jenkinsfile.dev
- vercel.json
- .github/workflows/bundle-analyzer.yml
- .github/workflows/pr_lint.yml
- .github/pull_request_template.md
- .husky/pre-commit
- .husky/pre-push
- sonar-project.properties
- scripts/create-component.ts
