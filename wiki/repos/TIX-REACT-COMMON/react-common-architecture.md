---
title: TIX-REACT-COMMON architecture
repo: TIX-REACT-COMMON
kind: architecture
sources:
  - package.json
  - pnpm-workspace.yaml
  - tsconfig.json
  - jest.config.ts
  - jest.constant.ts
  - scripts/scaffolds
  - packages/react-common-analytic/build.js
  - packages/react-common-remote/package.json
verified_at: 14597c4e
updated: 2026-10-16
status: current
tags: [repo/react-common, kind/architecture]
---

# TIX-REACT-COMMON architecture
> Flat `packages/*` workspace; each package builds and publishes independently, linked to its siblings with `workspace:*`.

## Workspace
- `pnpm-workspace.yaml`: `packages/*`, `nodeLinker: hoisted` (flat node_modules to avoid phantom-dependency breakage), `linkWorkspacePackages: true`, and `onlyBuiltDependencies: [esbuild, @swc/core]` (pnpm 10 blocks other postinstall scripts).
- Internal deps use `workspace:*`; changesets rewrites them on publish and bumps dependents with `updateInternalDependencies: patch`.
- Every package publishes to GitHub Packages (`publishConfig.registry: https://npm.pkg.github.com/`, `access: restricted`).

## Internal dependency graph

```
env  <- ab-test, analytic, core-attributes, push-notif, storage
queue <- ab-test, analytic
jsi  <- analytic, core-attributes, eagle-eye, navigator-permission
storage <- analytic, core-attributes
eagle-eye <- fetch, fetch-client
utilities <- fetch-client, remote
fetch-client <- core-attributes, error-handler, navigator-permission, push-notif, remote
core-attributes <- analytic
```
Leaf packages with no internal deps: `env`, `queue`, `jsi`, `utilities`, `gatekeeper`, `openapi`, `script`.

## Four build styles

| Style | Packages | Output | How |
|---|---|---|---|
| esbuild bundle + `tsc --emitDeclarationOnly` (CJS + ESM) | analytic, core-attributes, eagle-eye, env, push-notif, queue, script, storage, gatekeeper (CJS only) | `lib/cjs`, `lib/es` | per-package `build.js` |
| esbuild ESM + d.ts | fetch-client, jsi, navigator-permission; the `create:package` scaffold | `dist/` | `build.js` with `format: 'esm'`, only react/react-dom external |
| esbuild CJS + ESM, two entries | ab-test (`index` + `server`) | `dist/cjs`, `dist/esm` | `build.js` with an explicit `external` list |
| plain `tsc --project` + rsync of `.scss` | remote, error-handler, utilities | `dist/` | `exports` map with `types` + `default: [dist, src]` |
| Babel | fetch (legacy) | `lib/` | `babel src --out-dir lib` |

Gotchas:
- esbuild `bundle: true` inlines any workspace dep not listed in `external`. `analytic/build.js` externalises env, queue and core-attributes but **not** jsi or storage; `fetch-client`, `jsi` and `navigator-permission` externalise only react/react-dom, so fetch-client carries its own copy of eagle-eye and utilities, and navigator-permission carries jsi and fetch-client. A fix in a bundled dep reaches consumers only after the bundling package is rebuilt and released (changesets' internal-dependency patch bump does this when the dep is released).
- `remote`, `error-handler` and `ab-test` expose a `./server` subpath. Import server-only helpers from there in Next server components.
- `exports.default` lists `./src/index.ts` after `./dist/index.js` as a fallback, and `src` is published (`files: [dist, src]`).

## Testing seam
- Root `jest.config.ts` builds one Jest *project* per entry in `jest.constant.ts` `projects` (14 packages; `fetch`, `openapi`, `push-notif`, `script` are excluded). Tests match `packages/<name>/**/*.spec.ts(x)`.
- `jsDomEnvPackages` get `testEnvironment: jsdom`; `needsTiketPackageTransforms` (core-attributes, remote, error-handler, analytic) transform `node_modules/@tiket/*`.
- Passport (`@tiket/passport`) is intentionally **mocked** for remote and error-handler; transpiling it is commented out because it slows compile a lot.
- `@tiket/react-common-utilities` is mapped to its `src/index.ts`, so tests don't need a utilities build. `remote`'s `test:prepare` still builds utilities.
- `fetch` keeps its own `jest src` script and coverage path (also wired into Sonar).

## Scaffolding
`scripts/scaffolds/createNewPackage.mjs` creates `packages/react-common-<name>` with package.json (`type: module`, `main: dist/index.js`, esbuild ESM build), tsconfig, build.js, README, `index.ts` re-exporting `./src`, and appends the name to `jest.constant.ts`.

## Sources
- package.json, pnpm-workspace.yaml, tsconfig.json
- jest.config.ts, jest.constant.ts
- scripts/scaffolds/*.mjs
- packages/*/package.json, packages/*/build.js
