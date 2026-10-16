---
title: Remote GoogleOneTap
repo: TIX-REACT-REMOTE
kind: component
npm: "@tiket/passport-google-one-tap"
sources:
  - src/components/google-one-tap
verified_at: 281778b
updated: 2026-10-16
status: current
tags: [repo/react-remote, kind/component]
---

# Remote GoogleOneTap
> Federated wrapper around the Google One Tap sign-in prompt from [[passport-google-one-tap]].

## What it does
Exposed as `google-one-tap`. Wraps `GoogleOneTap` in `PassportWrapper` (forwarding `abTestOnServerResponse`) and passes every other prop through. No SSR props.

## Public API
`GoogleOneTapProps & CommonComponentProps`. `lang` and `country` default to `'id'`. Types come from `@tiket/passport-google-one-tap/dist/utils/types`.

## Usage
```tsx
import { RemoteGoogleOneTap } from '@tiket/react-common-remote';
<RemoteGoogleOneTap />
```

## Depends on
[[passport-google-one-tap]], [[react-remote-wrapper]].

## Used by
- TIX-NEXT-PAYMENT-FE `components/providers/AppProvider.tsx` ([[payment-fe-components]]).

## Gotchas
- The outer `Wrapper` is given `componentKey="global-popup"`, not `google-one-tap`. The DOM attribute `data-react-remote-component-key` is therefore wrong for this component; selectors or monitoring keyed on it will confuse it with [[react-remote-global-popup]].
- Type import from `dist/` means a Passport build-layout change breaks this file's types.

## Sources
- src/components/google-one-tap/index.tsx
- TIX-REACT-COMMON packages/react-common-remote/src/RemoteGoogleOneTap/index.tsx
