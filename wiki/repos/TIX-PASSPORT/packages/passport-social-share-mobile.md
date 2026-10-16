---
title: SocialShareMobile (shim)
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-social-share-mobile"
sources:
  - packages/social-share-mobile/src/index.ts
  - packages/social-share-mobile/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# SocialShareMobile (shim)
> Compatibility package. Its whole source is `export { SocialShareMobile } from '@tiket/passport-social-share'`.

Part of [[passport-packages]].

## What it does
It has no code of its own. It keeps the old package name working after the mobile share sheet moved into [[passport-social-share]]. Its `package.json` still has the template description "Passport {TODO} Component". It isn't marked deprecated, but new code should import from `@tiket/passport-social-share`, or from `@tiket/passport`.

## Public API
`SocialShareMobile`. Same component and props as in [[passport-social-share]]. Not in [[passport-umbrella]] under this name.

## Usage
```tsx
import { SocialShareMobile } from '@tiket/passport-social-share';
```

## Depends on
[[passport-social-share]], [[passport-utils]].

## Used by
- No consumers found in the workspace.

## Sources
- packages/social-share-mobile/src/index.ts
- packages/social-share-mobile/package.json
