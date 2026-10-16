---
title: page-module-next POC (thin next/dynamic layer)
repos: [TIX-PASSPORT, TIX-HOMEPAGE-NEXT-FE]
kind: decision
branch: feat/page-module-next-poc
sources:
  - TIX-PASSPORT/packages/page-module/src/registry/context.tsx
  - TIX-PASSPORT/packages/page-module-next
  - TIX-HOMEPAGE-NEXT-FE/package.json
  - TIX-HOMEPAGE-NEXT-FE/pages/home/components/HomePageModule/index.tsx
verified_at:
  TIX-PASSPORT: ed0e9b0423
  TIX-HOMEPAGE-NEXT-FE: 408983f6
updated: 2026-10-16
status: branch-only
tags: [repo/passport, repo/homepage-fe, kind/decision]
---

# page-module-next POC

> **Never merge or squash `feat/page-module-next-poc` into `main` or `prerelease`** until the user says the POC has graduated.

**Date:** 2026-10-14 · **Branch:** `feat/page-module-next-poc` (also on origin)

## Context
The goal is a `next/dynamic` variant of [[passport-page-module]] for Next.js consumers. Commit `3189c5e` was a full fork. It was replaced the same day by `271f635`, after the decision that page-module must remain the **single source of truth**.

## Decision
- page-module gained an internal seam with no behavior or public API change. `PageModuleSwitch` reads the module registry from context (`src/registry/context.tsx`). `PageModule` and `PageModuleServerComponent` are `createPageModule(StaticModuleRegistryProvider)` and its server equivalent. The factories are deliberately **not** exported from the root.
- `page-module-next` deep-imports only `@tiket/passport-page-module/src/*`. The root resolves to `dist`, and mixing dist with src duplicates React contexts; eslint enforces this. It provides a `next/dynamic` registry.
  - Its root exports mirror page-module's, enforced by `exports-parity.spec.ts`.
  - deps: page-module and [[passport-page-module-shared|page-module-shared]]. peers: `react` and `next` only.
- Slim and other deep-import surfaces are out of scope. There are no stories.

## Why it must not merge
The package is intentionally **not** `private`, and changesets config has `fixed: [["@tiket/passport*"]]`. Any release from main would publish it. See [[changesets-fixed-versioning]].

## Validation
Validate in TIX-HOMEPAGE-NEXT-FE. Its branch `origin/feat/page-module-next` (head `a15eeeb6`, 3 commits ahead of `main`) replaces `@tiket/passport-page-module` with `@tiket/passport-page-module-next@0.0.0-alpha-3618-20261015075753`, a snapshot from Passport PR #3618. `origin/main` (`408983f6`) still imports the root `@tiket/passport-page-module` `12.5.0` ([[homepage-fe-architecture]]).

## Known follow-up
product-card imports runtime utils from the page-module **root**, which is a circular dependency. That puts about 5 small page-module dist utils in the initial chunk next to the src copies. It's harmless for contexts, because they live in page-module-shared. The fix belongs in [[passport-product-card]].

## Sources
- Branch `feat/page-module-next-poc`: commits `3189c5e`, `271f635`, `ed0e9b0423`
- `.changeset/config.json` on `origin/main`
- TIX-HOMEPAGE-NEXT-FE `package.json` on `origin/feat/page-module-next` and `origin/main`; `git log origin/main..origin/feat/page-module-next`
- Migrated from Claude memory `page-module-next-poc` (2026-10-14)
