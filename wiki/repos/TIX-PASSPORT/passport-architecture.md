---
title: TIX-PASSPORT architecture
repo: TIX-PASSPORT
kind: architecture
sources:
  - packages
  - scripts
  - bun-test-config
  - .storybook/main.ts
  - vite.config.ts
  - tsconfig.json
  - bunfig.toml
  - pnpm-workspace.yaml
  - .npmrc
  - .cursor/rules/project-conventions.mdc
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/architecture]
---

# TIX-PASSPORT architecture

> One pnpm workspace package per component. Packages ship untranspiled-CSS ES modules built by plain `tsc`, and an umbrella package re-exports most of them.

## Layout
```
packages/<kebab>/            → @tiket/passport-<kebab>   (130 dirs, see [[passport-packages]])
  index.ts                   export * from './src'
  src/index.ts               barrel
  src/<Component>.tsx + .module.scss + .stories.tsx
  src/{components,hooks,contexts,services,types,__tests__}/
packages/passport/           → @tiket/passport (umbrella, no src/)
scripts/build/build.mjs      per-package build
scripts/scaffolds/           `create:component` generator (package.config.mjs = package.json template)
scripts/icons-generator/     SVG → React for packages/icons
scripts/assets-generator/    cloud-asset.csv → packages/assets/src/index.ts
scripts/ci/                  prerelease helpers (snapshots.js, update-passport-in-remote.js)
bun-test-config/, mocks/, test-utils.tsx, .env.test   test harness
```

## Package anatomy
Every package's `package.json` follows the scaffold template (`scripts/scaffolds/package.config.mjs`):
- `main: dist/index.js`, `source: src/index.ts`, `type: module`, `files: [dist, src]`.
- `sideEffects` lists `*.css *.jpg *.png *.webp *.mp4`, so bundlers keep style imports.
- Internal deps use `workspace:*`. `.npmrc` sets `save-workspace-protocol=rolling` and `save-prefix=''`, so `pnpm add @tiket/passport-x` writes `workspace:*`. The template adds [[passport-utils]] as a dep and [[passport-design-tokens]] as a devDep, because tokens are only consumed by SCSS `@use`.
- `peerDependencies.react: ^19.0.0`. `publishConfig.access: restricted` publishes to `npm.pkg.github.com` (the `@tiket` scope).

## Build
`scripts/build/build.mjs`, run inside each package:
1. `tsc-prog` compiles `packages/<dir>/src` against the root `tsconfig.json` into `dist/` with declarations and maps. It excludes stories, specs and `__examples__/`.
2. `rsync` copies `*.css *.scss` and images or video from `src/` to `dist/`.

No bundling happens and SCSS is **not** compiled. `dist/*.js` still contains `import styles from './X.module.scss'`, so the consuming app must compile SCSS modules and resolve `@use '@tiket/passport-design-tokens/…'`. That's why Next apps transpile `@tiket/passport*` (README) and why packages declare `sass.includePaths: ["./node_modules"]`.

The umbrella `packages/passport` builds with `cp index.js index.d.ts`. `index.js` hand-lists named re-exports per package. `types/<pkg>.d.ts` files are `export type * from '@tiket/passport-<pkg>'`, which gives apps `@tiket/passport/types/<pkg>`.

## Source resolution in dev
`vite.config.ts` puts `source` first in `resolve.mainFields`, so Storybook reads sibling packages from `src/` without building them. CSS module class names are `[name]__[local]__[hash:base64:4]`. `.storybook/main.ts` adds `packages/page-module/node_modules` to the Sass load paths so `@use '@tiket/passport-page-module-shared/…'` resolves. The TS CSS-modules plugin in `tsconfig.json` uses `packages/typography/node_modules` the same way. Both are workarounds for pnpm's isolated `node_modules`.

## Test harness
- `bunfig.toml` sets the test root to `packages` and preloads `bun-test-config/happydom.ts`, which registers happy-dom but restores Bun's native `fetch` so msw can intercept it.
- `bun-test-config/setup.ts` registers a lightningcss style-loader plugin (without it, `styles.link` resolves to `String.prototype.link`). It also stubs canvas for Lottie, starts the msw server from `mocks/msw-server.ts`, and sets the URL to `BASE_URL` from `.env.test` (`https://dummy.tiket.com`). It resets the viewport to 1024×768 before each test.
- Tests import from `@/test-utils` (custom `render` with providers and locale, returns `user`). `@/` maps to the repo root through `tsconfig.json` `paths`.
- `mocks/services/` has shared msw handlers for gift-voucher, global-popup and page-module.
- Details: `docs/testing.md`. Version pitfalls: [[passport-local-tooling]].

## Generated packages
- [[passport-icons]]: `npm run generate:icons` turns `packages/icons/assets/{dynamic,static}-colors/*.svg` into `src/components/Icon*.tsx` through SVGR. Don't edit the output.
- [[passport-assets]]: `npm run generate:assets` turns `packages/assets/src/cloud-asset.csv` into `export const <name> = '<url>'` lines in `src/index.ts`.

## Layering (informal)
1. Foundations: [[passport-design-tokens]], [[passport-utils]], [[passport-icons]], [[passport-assets]], [[passport-typography]], [[passport-date-utils]]
2. Primitives: button, form, card, dialog, bottom-sheet, modal, divider, focus-trap, portal…
3. Composites: calendar, dropdown, picker, tabs, chips-carousel, price-module…
4. Business widgets that fetch data and track events: [[passport-header]], [[passport-footer]], [[passport-global-popup]], [[passport-page-module]], [[passport-insurance]], [[passport-insurance-pop-up]], [[passport-corporate-interim-module]], [[passport-review-widget]], [[passport-wishlist]]

Most-depended-on packages (internal dependents counted from deps and devDeps in `packages/*/package.json`): design-tokens 110, icons 81, button 66, assets 31, divider 28, bottom-sheet 27.

## Gotchas
- `gh` at the repo root is a committed 41 MB Mach-O binary (a GitHub CLI build). It was added in `ad51aa377e` "setup prerelease workflow" and isn't used by any script.
- `lerna.json` is unused. Versioning and publishing are changesets plus pnpm.
- A package-level `tsconfig.json` breaks bun's `@/` alias. See [[passport-local-tooling]].

## Sources
- `scripts/build/build.mjs`, `scripts/scaffolds/package.config.mjs`, `scripts/icons-generator/index.mjs`, `scripts/assets-generator/index.mjs`
- `packages/passport/{package.json,index.js,types/}`, `packages/button/package.json`
- `vite.config.ts`, `.storybook/main.ts`, `tsconfig.json`, `bunfig.toml`, `bun-test-config/*`, `.env.test`, `.npmrc`, `pnpm-workspace.yaml`
- `.cursor/rules/project-conventions.mdc`, `docs/testing.md`
