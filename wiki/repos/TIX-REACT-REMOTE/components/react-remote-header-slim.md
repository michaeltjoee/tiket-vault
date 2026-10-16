---
title: Remote HeaderSlim
repo: TIX-REACT-REMOTE
kind: component
npm: "@tiket/passport-header"
sources:
  - src/components/header-slim
verified_at: 281778b
updated: 2026-10-16
status: current
tags: [repo/react-remote, kind/component]
---

# Remote HeaderSlim
> Logo-only slim header (`SlimHeader` from [[passport-header]]) served over module federation.

## What it does
Exposed as `header-slim`. Renders `SlimHeader` with `DEFAULT_TIKET_LOGO` inside `PassportWrapper`. It takes no props besides the common ones and has no SSR hooks. Unlike the other components it sets no defaults for `lang` or `country`.

## Public API
`CommonComponentProps`: `lang`, `country`, `currency`, `isNewURLStructure`, all forwarded to `PassportWrapper`.

## Usage
```tsx
import { RemoteHeaderSlim } from '@tiket/react-common-remote';
<RemoteHeaderSlim />
```

## Depends on
[[passport-header]], [[react-remote-wrapper]].

## Used by
No direct usage found in TIX-NEXT-PAYMENT-FE or TIX-FINTECH-NEXT-FE baselines. A server-component variant exists in [[react-common-remote]] (`ServerComponents/RemoteHeaderSlim`).

## Sources
- src/components/header-slim/index.tsx
- TIX-REACT-COMMON packages/react-common-remote/src/RemoteHeaderSlim/index.tsx
