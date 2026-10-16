---
title: Remote CorporateInterimModule
repo: TIX-REACT-REMOTE
kind: component
npm: "@tiket/passport-corporate-interim-module"
sources:
  - src/components/corporate-interim-module
  - exposes.config.js
verified_at: 281778b
updated: 2026-10-16
status: current
tags: [repo/react-remote, kind/component]
---

# Remote CorporateInterimModule
> Federated wrapper that serves the B2B corporate booking form from [[passport-corporate-interim-module]].

## What it does
Exposed as module key `corporate-interim-module`. Wraps the Passport component in the standard [[react-remote-wrapper|Wrapper + PassportWrapper]] pair, so it gets `PassportProvider` (locale, country, currency, `customFetch` with `credentials: 'include'`) and `ForwardParamsProvider`. All non-common props are passed straight through to the Passport component. No `getServerSideProps`, so SSR renders it with only the auto-detected common props.

## Public API
| Prop | Default | Notes |
|---|---|---|
| `lang` | `'id'` | from [[react-remote-architecture#Common props]] |
| `country` | `'id'` | |
| `currency`, `isNewURLStructure` | – | auto-filled by the consumer and server |
| `...CorporateInterimModuleProps` | – | forwarded to `CorporateInterimModule` from [[passport-corporate-interim-module]] |

Mount: `mount(el, noHydrate, props)` from `bootstrap.ts` (`generateMountFunction`, no root reuse).

## Usage
Consumers use the typed wrapper from [[react-common-remote]]:
```tsx
import { RemoteCorporateInterimModule } from '@tiket/react-common-remote';
<RemoteCorporateInterimModule {...corporateProps} />
```

## Depends on
[[passport-corporate-interim-module]], [[passport-utils]] (PassportProvider), [[react-common-utilities]] (ForwardParamsProvider), [[react-common-fetch-client]].

## Used by
- TIX-NEXT-PAYMENT-FE `components/providers/AppProvider.tsx` via `RemoteCorporateInterimModule` ([[payment-fe-components]]).

## Sources
- src/components/corporate-interim-module/index.tsx
- src/components/corporate-interim-module/bootstrap.ts
- src/components/wrapper/PassportWrapper/index.tsx
- TIX-REACT-COMMON packages/react-common-remote/src/RemoteCorporateInterimModule/index.tsx
