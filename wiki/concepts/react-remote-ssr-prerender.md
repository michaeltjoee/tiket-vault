---
title: Remote component SSR (prerender API)
kind: concept
repos: [TIX-REACT-REMOTE, TIX-REACT-COMMON, TIX-FINTECH-NEXT-FE, TIX-NEXT-PAYMENT-FE]
sources:
  - TIX-REACT-REMOTE/src/server/index.ts
  - TIX-REACT-REMOTE/src/server/utils/prerender.ts
  - TIX-REACT-REMOTE/src/server/utils/cache.ts
  - TIX-REACT-COMMON/packages/react-common-remote/src/fetcher
  - TIX-REACT-COMMON/packages/react-common-remote/src/ServerComponents
  - TIX-FINTECH-NEXT-FE/projects/insurance/shared/lib/utils/getReactRemotePropsForDevice.ts
verified_at:
  TIX-REACT-REMOTE: 281778b
  TIX-REACT-COMMON: 14597c4e
  TIX-FINTECH-NEXT-FE: 5833b842
  TIX-NEXT-PAYMENT-FE: 9e92b20bb
updated: 2026-10-16
status: current
tags: [kind/concept, repo/react-remote, repo/react-common, repo/fintech-fe, repo/payment-fe]
---

# Remote component SSR (prerender API)
> A host page can ask the TIX-REACT-REMOTE server to render remote widgets to HTML before sending the page, then hydrate them on the client through [[module-federation]]. The contract is one batch HTTP endpoint plus a set of whitelisted props.

## Contract
- **Endpoint:** `GET <NEXT_PUBLIC_REACT_REMOTE_API_URL>/api/v1.0/prerender?json=<encoded>`, a batch body such as `{ header: [{ props, alias? }], footer: [...] }`. It returns `{ status, data: { <alias|key>: { content, props, styles, criticalStyles, version } } }`. The single-component `/api/prerender/:component` route is deprecated.
- **Client side ([[react-common-remote]]):** `enableSsrRemoteModule` / `getReactRemoteProps` for the Pages Router, `Remote*ServerComponent` + `serverComponentFetcher` for the App Router (header, header-mobile, header-slim, footer, reviews). Timeout 4 s. It forwards `user-agent`, the session cookies and `tiket_currency`, and the `x-client-*` headers, and always sends `x-client-version-flag: 2.0`.
- **Server side ([[react-remote-architecture]]):** derives `device`, `currency`, `country` and `isNewURLStructure` from headers, filters props to the whitelist, renders with a loadable `ChunkExtractor`, and computes `criticalStyles` with PurgeCSS from `css-map.json`.
- **Hydration:** `ReactRemoteProvider` carries the result to `RemoteComponent`, which mounts with `noHydrate = !innerHTMLContent`. If the call fails, every module falls back to client rendering.

## Prop whitelist
Only `device`, `lang`, `currency`, `country`, `isNewURLStructure` and each component's `getSsrCacheConfig().additionalWhitelistedSsrProps` survive. While the render cache is on, other props are **dropped from the render itself**, not just from the cache key. A new prop that changes server markup must be added to the component's whitelist, or SSR and client output differ.

## Cache
The render cache is in-process `node-cache` with TTL 0 (never expires), keyed by component and sorted props. It is cleared by a deploy or by `GET {prefix}/api/cache/flush`. `/api/cache/info` dumps it. Neither route has auth.

## Who uses it
- **TIX-FINTECH-NEXT-FE** insurance standalone pages (landing, search, PDP, checkout) call `getReactRemoteProps` through `projects/insurance/shared/lib/utils/getReactRemotePropsForDevice.ts` ([[fintech-fe-insurance-standalone]]).
- **TIX-NEXT-PAYMENT-FE** wraps pages in `ReactRemoteProvider` but never calls the prerender API on its baseline, so its remotes render on the client only ([[payment-fe-architecture]]).
- Components with server data hooks: [[react-remote-header]] (forces `useDeprecatedHeader=false` when `clientVersion === '2.0'`) and [[react-remote-reviews]] (`getServerSideProps` reads `MS_GATEWAY_BASE_URL`).

## Gotchas
- The server ignores `x-client-locale`. `lang` must come in props (the App Router fetcher fills it in).
- Without SSR, the `remoteEntry.js` version falls back to `Date.now()` at module load, which defeats browser caching.
- Cached HTML lives until the pod restarts, so data that changes (for example review counts) can be stale. Turn caching off per component with `getSsrCacheConfig().enableRenderCache = false`.

## Where it shows up
Pages that link here:
- TIX-REACT-COMMON: [[react-common-remote]]
- concepts: [[module-federation]], [[multi-currency]], [[new-url-structure]]

## Sources
- TIX-REACT-REMOTE `src/server/index.ts`, `src/server/utils/{prerender,cache}.ts`, `src/constants/common.ts` (`BASE_WHITELISTED_SSR_PROPS`), `docs/ssr.puml`
- TIX-REACT-COMMON `packages/react-common-remote/src/fetcher/{fetcher,enableSsrRemoteModule,getReactRemoteProps}.ts`, `packages/react-common-remote/src/ServerComponents/fetcher/serverComponentFetcher.tsx`
- TIX-FINTECH-NEXT-FE `projects/insurance/shared/lib/utils/getReactRemotePropsForDevice.ts`, `projects/insurance/standalone/*/index.tsx`
- TIX-NEXT-PAYMENT-FE: `git grep getReactRemoteProps origin/main` (only a mock and a skill doc)
