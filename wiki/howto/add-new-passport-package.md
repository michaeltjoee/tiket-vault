---
title: Add a new Passport package
repo: TIX-PASSPORT
kind: howto
sources:
  - scripts/scaffolds/createUIComponentPackage.mjs
  - scripts/scaffolds/package.config.mjs
  - scripts/scaffolds/component-template.mjs
  - scripts/scaffolds/storybook-template.mjs
  - packages/passport/index.js
  - packages/passport/types
  - docs/dependency-management.md
  - .npmrc
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/howto]
---

# Add a new Passport package
> Run `npm run create:component <kebab-name>`. It scaffolds `packages/<kebab-name>` as `@tiket/passport-<kebab-name>` and also wires the package into the umbrella `@tiket/passport`. Don't create package folders by hand.

## Steps
1. **Pick a name.** Use kebab-case, for example `price-badge`. The package becomes `@tiket/passport-price-badge`, and the component name is the PascalCase form, `PriceBadge`.
2. **Scaffold** from the repo root: `npm run create:component price-badge`. `scripts/scaffolds/createUIComponentPackage.mjs`:
   - writes `packages/price-badge/{package.json,README.md,index.ts}` and `src/{index.ts,PriceBadge.tsx,PriceBadge.module.scss,PriceBadge.stories.tsx}`. `package.json` comes from `package.config.mjs`: version `0.0.0`, `main: dist/index.js`, `source: src/index.ts`, `files: [dist, src]`, `sideEffects` for CSS and media, deps `classnames` and [[passport-utils]], devDeps [[passport-design-tokens]] and React, peer `react ^19`, `publishConfig.access: restricted`, `sass.includePaths`, and `build: node ../../scripts/build/build.mjs`.
   - runs `pnpm add @tiket/passport-price-badge` inside `packages/passport`, appends `export { PriceBadge } from '@tiket/passport-price-badge';` (after a `// TODO: please re-arrange by alphabetical package name'` comment) to `packages/passport/index.js`, and writes `packages/passport/types/price-badge.d.ts`.
   - runs prettier on the new folder, then `pnpm i`.
3. **Tidy the umbrella.** Move the new export to its alphabetical place in `packages/passport/index.js` and delete the TODO line. If the package should *not* be in the umbrella (heavy business widgets such as [[passport-page-module]] aren't), revert the three umbrella changes ([[passport-umbrella]]).
4. **Add dependencies** from inside the package folder ([[passport-workflows]], `docs/dependency-management.md`):
   - `pnpm add @tiket/passport-button` for a runtime dep. `.npmrc` makes it `workspace:*`.
   - `pnpm add -D @tiket/passport-icons` for a dep used only for types or only in stories.
   - `pnpm add classnames` for an external dep, and `pnpm add <pkg> -w` (`-D -w` for dev) for the root.
5. **Build the component.** Use SCSS modules with `@use '@tiket/passport-design-tokens/breakpoint' as *;` and token variables ([[design-tokens]]). For data fetching, follow the `customFetch` pattern ([[passport-custom-fetch]]). Read flags with `useRollout` ([[ab-testing]]).
6. **Write specs** in `src/__tests__/*.spec.tsx` importing from `@/test-utils`, with msw handlers for APIs ([[run-tests-per-repo]]). Check it in Storybook with `npm run dev`.
7. **Add a changeset** and release ([[release-passport-package]]). The package starts at `0.0.0`. Because it matches the `@tiket/passport*` fixed group, the first release should publish it at the group's new version ([[changesets-fixed-versioning]]).

## Gotchas
- The scaffold shells out to the `pnpm` on your `PATH`. With the machine's global pnpm 9.15 it rewrites `pnpm-lock.yaml` and drops `overrides` ([[passport-local-tooling]]). Put pnpm 10 first on `PATH` before you run it, or run `npx pnpm@10 install` afterwards and check the lockfile diff.
- Don't add a package-level `tsconfig.json`. It breaks the `@/` alias in bun tests. Name it `tsconfig.<purpose>.json` if you need one.
- Errors are only logged ("🟥 ERROR!"), and the script still exits 0. Check the output and `git status` before you commit.
- Packages ship uncompiled SCSS, so consumers need Sass and `transpilePackages` ([[passport-architecture]]).
- TIX-REACT-REMOTE compiles Passport from `src/`, so keep `src` in `files` ([[module-federation]]).

## Sources
- `scripts/scaffolds/{createUIComponentPackage,package.config,component-template,storybook-template}.mjs`
- `packages/passport/{index.js,types/,package.json}`
- `docs/dependency-management.md`, `.npmrc`, `.changeset/config.json`, `package.json` (`create:component`)
