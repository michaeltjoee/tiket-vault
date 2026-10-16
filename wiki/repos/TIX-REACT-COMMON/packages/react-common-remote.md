---
title: react-common-remote
repo: TIX-REACT-COMMON
kind: package
npm: "@tiket/react-common-remote"
sources:
  - packages/react-common-remote/src
  - packages/react-common-remote/package.json
  - packages/react-common-remote/README.md
verified_at: 14597c4e
updated: 2026-10-16
status: current
tags: [repo/react-common, kind/package]
---

# react-common-remote
> Host-side loader for the shared [[react-remote-overview|TIX-REACT-REMOTE]] components (header, footer, scripts, reviews, global popup…), consumed in Next.js apps through webpack [[module-federation]], with optional SSR prerender.

## What it does
**Client:** `<RemoteComponent module=… fallback=… />` injects `${NEXT_PUBLIC_REACT_REMOTE_URL ?? '/shared-components'}/assets/remoteEntry.js?<version>` once per URL. It then calls `__webpack_init_sharing__('default')`, `window.ReactRemote.init(shareScope)` and `.get(module)`, and runs the module's `mount(el, noHydrate, props)` into a wrapper `div`. It retries the mount 3 times, 100 ms apart. If the script fails to load or `mount` throws, it renders `fallback` (typically the matching [[passport-overview|Passport]] component). `country`, `currency`, `isNewURLStructure` and `lang` come from `usePassport()` and are always passed as props.
**SSR (pages router):** `getReactRemoteProps(modules, ctx)` or the HOF `enableSsrRemoteModule(modules, getSsr)` calls `${NEXT_PUBLIC_REACT_REMOTE_API_URL}/api/v1.0/prerender?json=…` (4 s timeout), forwarding session cookies, `tiket_currency`, locale/country headers and `x-client-version-flag: 2.0`. The response (`innerHTMLContent`, `styles`, `criticalStyles`, `props`, `version`) goes into `pageProps`; `<ReactRemoteProvider value={pageProps}>` exposes it, and the component hydrates the server HTML (`noHydrate = false`).
**SSR (App Router):** `Remote*ServerComponent`s (from the main entry) call `serverComponentFetcher` with `next/headers` cookies and `@tiket/next/server` middleware data. See [[react-remote-ssr-prerender]].

## Public API
| Group | Exports |
|---|---|
| core | `RemoteComponent` (`module`, `fallback`, `props?`, `contentLoader?`, `alias?`, `styles?`, `criticalStyles?`, `innerHTMLContent?`, `isCritical` = true, `useFallback?`, `useUniqueWrapperKey?`) |
| context | `ReactRemoteProvider`, `ReactRemoteContext` (`ContextData`: `remoteModuleSsrProps`, `remoteModuleVersion`, `sessionData`, `dataLayer`, `abTestOnServerResponse`, `locale`, `country`, `isNewURLStructure`) |
| SSR | `getReactRemoteProps`, `enableSsrRemoteModule`, `fetcher` |
| boilerplates (`'use client'`) | `RemoteHeader`, `RemoteHeaderMobile`, `RemoteHeaderSlim`, `RemoteFooter`, `RemoteFooterDesktop`, `RemoteFooterMobile`, `RemoteScripts`, `RemoteReviews`, `RemoteGlobalPopup`, `RemoteGoogleOneTap`, `RemoteWishlistModule`, `RemoteCorporateInterimModule`, `RemoteCountryAndCurrencyModal` |
| server components | `RemoteHeaderServerComponent`, `RemoteHeaderMobileServerComponent`, `RemoteHeaderSlimServerComponent`, `RemoteFooterServerComponent`, `RemoteReviewsServerComponent` |
| types | `Modules`, `MODULES_NAME`, `RemoteModuleSsrProps`, `ContextData`, `RemoteComponentCommonProps`, `RemoteHeaderProps`… |

`MODULES_NAME` maps 1:1 to TIX-REACT-REMOTE `src/components/*`: [[react-remote-header]], [[react-remote-header-mobile]], [[react-remote-header-slim]], [[react-remote-footer]], [[react-remote-footer-desktop]], [[react-remote-footer-mobile]], [[react-remote-scripts]], [[react-remote-reviews]], [[react-remote-global-popup]], [[react-remote-google-one-tap]], [[react-remote-wishlist-module]], [[react-remote-corporate-interim-module]], [[react-remote-country-and-currency-modal]].

## Usage
```tsx
// simplified from TIX-FINTECH-NEXT-FE app/error.page.tsx (client)
import { ReactRemoteProvider, RemoteFooterDesktop, RemoteHeader } from '@tiket/react-common-remote';
<ReactRemoteProvider value={pageProps}>
  <RemoteHeader />
  {children}
  <RemoteFooterDesktop />
</ReactRemoteProvider>

// pages router SSR
export const getServerSideProps = enableSsrRemoteModule<Props>(['header', 'footer'], async () => ({ props: {} }));
```

## Depends on
- [[react-common-utilities]] (server cookie/header helpers, `Country`), [[react-common-fetch-client]] (used by `RemoteReviews/getReviews.ts` and the header/header-mobile fallbacks), `date-fns`
- Peers: `next` ^16, React 19. Imported at runtime but **only devDependencies**: `@tiket/passport` (`usePassport`, fallback components) and `@tiket/next/server` (`getMiddlewareData` in server components).
- Env: `NEXT_PUBLIC_REACT_REMOTE_API_URL` (required for SSR), `NEXT_PUBLIC_REACT_REMOTE_URL` (required locally; defaults to same-origin `/shared-components`).

## Used by
- TIX-NEXT-PAYMENT-FE: `components/providers/AppProvider.tsx`, `lib/providers/AppRouterProvider.tsx`, payment-link complete (`RemoteHeader`, `RemoteFooterDesktop`, `RemoteGlobalPopup`). See [[payment-fe-components]], [[payment-fe-payment-link]].
- TIX-FINTECH-NEXT-FE: gift-card and insurance-claim layouts (`RemoteScripts`), gift-card wrappers (`RemoteHeader`/`RemoteFooter`), `app/error.page.tsx`, `getReactRemoteProps`. See [[fintech-fe-gift-card]], [[fintech-fe-insurance-claim]].

## Gotchas
- The `./server` export exists (`src/server.ts`), but it **only re-exports types**. The server components themselves are exported from the main entry.
- Without SSR data, `remoteModuleVersion` defaults to `Date.now()` at module load, so every page load busts the `remoteEntry.js` cache. Pass SSR props to get a stable version.
- React 19: the `dangerouslySetInnerHTML` object is memoised on purpose. A new object on each render would clear the DOM owned by the federated root (fix in #1167). Don't inline it.
- App Router needs `useUniqueWrapperKey` (the server components set it). It re-keys with `Math.random()` on every render, which remounts the wrapper.
- Prerender failures are swallowed: you get empty entries per module and the client mounts with CSR only, so the page still renders.
- The host webpack must expose `__webpack_init_sharing__`/`__webpack_share_scopes__` (Next.js does). The container global is hard-coded to `window.ReactRemote`.
- Next 12 needs `next-transpile-modules` for this package (README). The types still import from `next12`/`next14` dev aliases.
- Tests mock `@tiket/passport` and `next`; `test:prepare` builds utilities first.

## Sources
- packages/react-common-remote/src/{index,server,types}.ts, src/context/index.ts, src/hooks/useWithSsrProps.ts
- packages/react-common-remote/src/RemoteComponent/*, src/RemoteHeader/index.tsx, src/RemoteScripts/index.tsx
- packages/react-common-remote/src/fetcher/*, src/ServerComponents/*
- packages/react-common-remote/README.md, package.json
