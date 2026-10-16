---
title: TIX-REACT-REMOTE architecture
repo: TIX-REACT-REMOTE
kind: architecture
sources:
  - webpack.config.js
  - webpack.server.config.js
  - config.js
  - exposes.config.js
  - src/server
  - src/utils/mount.tsx
  - src/types.ts
  - src/constants/common.ts
  - scripts/css-mapper
  - docs/ssr.puml
  - api/index.js
verified_at: 281778b
updated: 2026-10-16
status: current
tags: [repo/react-remote, kind/architecture]
---

# TIX-REACT-REMOTE architecture

> How the Express + module federation service is wired: the exposes map and server registry that must list the same keys, the client and server webpack builds, the mount contract, SSR prerender and caching, and how hosts load remotes.

## Layout
```
exposes.config.js        key → ./src/components/<key>/bootstrap  (the federation "exposes" map)
config.js                shared webpack rules (swc, css modules, images) + Loadable/MiniCssExtract plugins
webpack.config.js        client build → dist/client/assets (remoteEntry.js, chunks, loadable-stats.json)
webpack.server.config.js extends client config, target node, entry src/server → dist/server/index.js
scripts/css-mapper       post-build: dist/client/css-map.json (component key → CSS files)
scripts/create-component scaffolds a component + rewrites exposes.config.js and src/server/components.ts
src/components/<key>/    index.tsx (component + optional SSR hooks), bootstrap.ts (exports mount)
src/server/              Express app, component registry, prerender + cache
src/utils/               mount, header hooks, footer data, GTM tracker, cookie helper
api/index.js             require('../dist/server'): entry for `node ./api` and for Vercel
```

## Exposed modules
`exposes.config.js` and `src/server/components.ts` must list the same 13 keys: corporate-interim-module, country-and-currency-modal, footer, footer-desktop, footer-mobile, global-popup, google-one-tap, header, header-mobile, header-slim, reviews, scripts, wishlist-module. The first map feeds the browser container, the second feeds SSR. `pnpm create:component` updates both. The consumer list `MODULES_NAME` in [[react-common-remote]] (`src/types.ts`) is a third copy and must be updated in TIX-REACT-COMMON separately.

## Client build (module federation)
- `ModuleFederationPlugin` `name: 'ReactRemote'`, `filename: 'remoteEntry.js'`. Shared singletons: `react`, `react-dom`, `@tiket/passport-typography`. See [[module-federation]].
- **Passport is compiled from source.** swc `@swc/plugin-transform-imports` rewrites `@tiket/passport-<x>` to `@tiket/passport-<x>/src`, and the loader `exclude` lets `node_modules/@tiket/passport-*` and `@tiket/react-common-utilities` through. `consumeFromSource` aliases `@tiket/react-common-utilities`, `passport-currency-bottom-sheet`, `passport-language-and-currency-modal` and `passport-global-search` to `src/index.ts`.
- CSS modules use `localIdentName: 'rr___[name]__[local]___[hash:base64:5]'`, so remote class names never collide with the host's. Global-search CSS chunks are forced into a `gs-style` chunk group (5–50 KB).
- `DefinePlugin` inlines `IS_AMPLITUDE_ENABLED` / `IS_MIXPANEL_ENABLED` at build time (see [[react-remote-workflows#Environment variables]]).
- In development, `HtmlWebpackPlugin` serves `public/index.html`, and `generateMountFunction` auto-mounts into `#tix-react-remote-root`.

## Mount contract
Every `bootstrap.ts` exports `mount = generateMountFunction(Component, { reuseRoot? })` (`src/utils/mount.tsx`):
- `mount(el, noHydrate, props)`. When `noHydrate` is true it calls `createRoot().render`, otherwise `hydrateRoot` over the SSR HTML.
- `reuseRoot: true` keeps a `WeakMap<HTMLElement, Root>`, so later calls re-render instead of remounting. It is used by [[react-remote-global-popup]], [[react-remote-reviews]] and [[react-remote-wishlist-module]].

## Common props
`CommonComponentProps` (`src/types.ts`): `lang`, `country`, `currency`, `isNewURLStructure`, `abTestOnServerResponse`, `dataLayer`, `isLoggedIn`, `reactCommonRemoteFetcherVersion`. Components pass them to [[react-remote-wrapper|PassportWrapper]], which supplies `PassportProvider` and a credentialed `customFetch`.

## SSR and caching
Endpoints (all under `BASE_PREFIX_URL`, except health check):

| Route | Purpose |
|---|---|
| `GET /api/health-check` | `{status:'OK'}`, no prefix |
| `GET {prefix}/api/v1.0/prerender?json=<encoded>` | batch: `{ footer: [{props, alias?}], header: [...] }` → `{status, data: {<alias or key>: PrerenderData}}`; 400 on error |
| `GET {prefix}/api/prerender/:component?<props>` | deprecated single-component form |
| `GET {prefix}/api/cache/info` / `/api/cache/flush` | dump or flush the in-memory cache |
| `{prefix}/assets/*` | static `dist/client/assets` (local and dev; production assets come from GCS) |

`getPrerenderData` (`src/server/utils/prerender.ts`) for each requested component:
1. Derives `device` (MobileDetect on `user-agent`), `currency` (`tiket_currency` cookie → `x-client-currency` → `IDR`), `country` (`x-client-country` → `id`), `isNewURLStructure` (`x-client-is-new-url-structure`) and `clientVersion` (`x-client-version-flag`).
2. Filters props to the whitelist `device, lang, currency, country, isNewURLStructure` plus the component's `getSsrCacheConfig().additionalWhitelistedSsrProps`. **Non-whitelisted props are dropped from SSR**, not only from the cache key, whenever the render cache is on.
3. Cache key = `<key>-<JSON of sorted props>`. On a hit it returns the cached render. On a miss it runs optional `getServerSideProps({props, req})` (with its own cache), then `renderToString` inside a loadable `ChunkExtractor`.
4. Looks up `css-map.json[key]` for `styles`. PurgeCSS against the rendered HTML gives `criticalStyles`, cached by `getCriticalCssCacheKey` when defined. `/Button-module__/` is safelisted because client-only modifiers would otherwise be purged.
5. Returns `{content, props, styles, criticalStyles, version}`. TTL defaults to 0 (never expires) and node-cache has `checkperiod: 0`.

`docs/ssr.puml` diagrams the same flow.

## How consumers load remotes
Implemented in [[react-common-remote]] (TIX-REACT-COMMON):
1. **SSR (pages router):** `enableSsrRemoteModule([...modules], getSsr)` or `getReactRemoteProps` calls the batch prerender endpoint at `NEXT_PUBLIC_REACT_REMOTE_API_URL` with a 4 s abort timeout. It forwards `user-agent`, `x-client-version-flag: 2.0`, locale, currency, country and URL-structure headers, plus the `session_access_token`, `session_refresh_token` and `tiket_currency` cookies and `token`/`accessToken` headers. The result goes into page props as `remoteModuleSsrProps` and `remoteModuleVersion`. If the call fails, each module gets an empty entry and the page falls back to CSR.
2. **App Router:** `@tiket/react-common-remote/server` exports `Remote*ServerComponent`s (header, header-mobile, header-slim, footer, reviews) that call `serverComponentFetcher`, built on `next/headers` cookies and headers and `getMiddlewareData` from `@tiket/next/server`.
3. **Client:** `ReactRemoteProvider` holds the SSR data. `RemoteComponent` renders the SSR HTML with `dangerouslySetInnerHTML` (memoized for React 19), preloads `styles`, and inlines `criticalStyles` when `isCritical`. It injects `${NEXT_PUBLIC_REACT_REMOTE_URL || '/shared-components'}/assets/remoteEntry.js?<version>` once per URL, calls `__webpack_init_sharing__('default')` and `window.ReactRemote.init/get(module)`, then `mount(wrapper, !innerHTMLContent, {country, currency, isNewURLStructure, lang, ...ssrProps, ...props})`. It retries 3 times at 100 ms intervals. On script or mount error it renders the consumer's `fallback` (usually a local Passport component).
4. `useWithSsrProps` merges the server-returned `props` (including any `getServerSideProps` output such as `reviewData`) under the client props, so hydration sees the same data.

## Gotchas
- `@tiket/passport-typography` is a shared singleton but is not in `package.json` dependencies, so `requiredVersion` resolves to `undefined`.
- Without SSR, `version` falls back to `Date.now()` at module load, which busts the `remoteEntry.js` cache on every page load.
- `/api/cache/info` and `/api/cache/flush` have no auth. `info` returns all cached renders.
- The server ignores `x-client-locale`; `lang` must come in props (the App Router fetcher auto-fills it).
- The server bundle externalizes `isomorphic-dompurify` (jsdom can't be bundled), so the Docker runner installs it separately.

## Sources
- webpack.config.js
- webpack.server.config.js
- config.js
- exposes.config.js
- src/server/index.ts
- src/server/components.ts
- src/server/utils/prerender.ts
- src/server/utils/cache.ts
- src/utils/mount.tsx
- src/types.ts
- src/constants/common.ts
- scripts/css-mapper/index.ts
- scripts/create-component.ts
- docs/ssr.puml
- TIX-REACT-COMMON packages/react-common-remote/src (RemoteComponent, fetcher, ServerComponents, hooks/useWithSsrProps.ts)
