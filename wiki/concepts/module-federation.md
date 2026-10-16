---
title: Module federation (shared remote components)
kind: concept
repos: [TIX-REACT-REMOTE, TIX-REACT-COMMON, TIX-NEXT-PAYMENT-FE, TIX-FINTECH-NEXT-FE, TIX-PASSPORT]
sources:
  - TIX-REACT-REMOTE/webpack.config.js
  - TIX-REACT-REMOTE/exposes.config.js
  - TIX-REACT-REMOTE/config.js
  - TIX-REACT-REMOTE/src/utils/mount.tsx
  - TIX-REACT-COMMON/packages/react-common-remote/src/RemoteComponent
  - TIX-NEXT-PAYMENT-FE/next.config.ts
  - TIX-FINTECH-NEXT-FE/next.config.js
verified_at:
  TIX-REACT-REMOTE: 281778b
  TIX-REACT-COMMON: 14597c4e
  TIX-NEXT-PAYMENT-FE: 9e92b20bb
  TIX-FINTECH-NEXT-FE: 5833b842
updated: 2026-10-16
status: current
tags: [kind/concept, repo/react-remote, repo/react-common, repo/payment-fe, repo/fintech-fe, repo/passport]
---

# Module federation
> TIX-REACT-REMOTE builds the header, footer and other shared widgets once as a webpack Module Federation container. The Next apps load that container at runtime through [[react-common-remote]] instead of bundling those Passport widgets themselves.

## Roles
| Role | Repo | Where |
|---|---|---|
| Container | TIX-REACT-REMOTE | `webpack.config.js`: `ModuleFederationPlugin({ name: 'ReactRemote', filename: 'remoteEntry.js', exposes })`. `exposes.config.js` has 13 keys (header, header-mobile, header-slim, footer, footer-desktop, footer-mobile, scripts, reviews, global-popup, google-one-tap, wishlist-module, corporate-interim-module, country-and-currency-modal). See [[react-remote-architecture]]. |
| Loader | TIX-REACT-COMMON | [[react-common-remote]]: `RemoteComponent` plus one `Remote<Name>` wrapper and `Fallback.tsx` per key. `MODULES_NAME` in `src/types.ts` mirrors `exposes.config.js`. |
| Hosts | TIX-NEXT-PAYMENT-FE, TIX-FINTECH-NEXT-FE | `next.config.*` pushes a client-only `ModuleFederationPlugin({ name: pkg.name })` with no `exposes` or `remotes`. It exists only so the page has a webpack share scope. |
| Content | TIX-PASSPORT | [[passport-header]], [[passport-footer]], [[passport-global-popup]], [[passport-wishlist]], [[passport-review-widget]] and others, compiled into the container. |

## Runtime sequence
1. A `Remote<Name>` component injects `<NEXT_PUBLIC_REACT_REMOTE_URL>/assets/remoteEntry.js?<version>` (default prefix `/shared-components`) through `useDynamicScript`.
2. `loadRemoteComponent` calls `__webpack_init_sharing__('default')`, then `window.ReactRemote.init(__webpack_share_scopes__.default)` and `get(<key>)`.
3. Every exposed `bootstrap.ts` exports `mount(el, noHydrate, props)` from `generateMountFunction` (`src/utils/mount.tsx`). The wrapper passes `noHydrate = !innerHTMLContent`: it hydrates server HTML when [[react-remote-ssr-prerender]] supplied it, and otherwise does a fresh `createRoot`. Props are flat strings, numbers or booleans.
4. `reuseRoot: true` (global-popup, reviews, wishlist-module) keeps one React root per element, so a second `mount` updates props instead of remounting.
5. If the remote fails to load, the wrapper renders its `Fallback.tsx`, which imports the Passport component directly (for example `RemoteReviews/Fallback.tsx` renders `ReviewWidget`).

## Shared scope and versions
Only `react`, `react-dom` and `@tiket/passport-typography` are shared singletons. Everything else, including every other Passport package and react-common, is bundled inside the container. A widget therefore runs the **remote's** Passport version, not the host's: the header on a payment page uses react-remote's exact pin `12.4.2`, while payment-fe itself depends on `^8.11.1`. Shipping a Passport fix to every page means bumping react-remote ([[prerelease-flow]], [[changesets-fixed-versioning]]).

`consumeFromSource` in `webpack.config.js` aliases four packages to their `src/` (react-common-utilities, passport-currency-bottom-sheet, passport-language-and-currency-modal, passport-global-search). An swc rule in `config.js` (`@swc/plugin-transform-imports`) also rewrites `@tiket/passport-<x>` imports to `@tiket/passport-<x>/src`, which is why Passport packages publish `src/` (`files: [dist, src]`).

## Gotchas
- Next 16 Turbopack can't run `ModuleFederationPlugin`, so both hosts build and run dev with `--webpack` ([[fintech-fe-architecture]], [[payment-fe-architecture]]).
- The container inlines its own `NEXT_PUBLIC_*` values at build time. Code that must follow the host, such as the fetch-client `basePrefixForApp`, reads runtime config instead (`setFetchClientConfig`, `window.__TIX_REMOTE_CONFIG__`; see [[react-common-fetch-client]]). Client env vars in the remote need a Docker build arg ([[react-remote-workflows]]).
- Passport modals render through [[passport-portal]] into `document.body`, outside the remote's `.passport` scope. react-remote injects a `:root` block of icon and font colours for them ([[design-tokens]]).
- Adding a remote touches both repos: `pnpm create:component` in react-remote, then `MODULES_NAME` and a `Remote<Name>` wrapper in react-common-remote ([[react-remote-workflows]]).

## Where it shows up
Pages that link here:
- TIX-FINTECH-NEXT-FE: [[fintech-fe-architecture]], [[fintech-fe-overview]]
- TIX-NEXT-PAYMENT-FE: [[payment-fe-architecture]], [[payment-fe-overview]]
- TIX-PASSPORT: [[passport-header]], [[passport-language-and-currency-modal]], [[passport-overview]], [[passport-review-widget]], [[passport-wishlist]]
- TIX-REACT-COMMON: [[react-common-fetch-client]], [[react-common-remote]]
- TIX-REACT-REMOTE: [[react-remote-architecture]], [[react-remote-overview]]
- concepts: [[react-remote-ssr-prerender]]
- entities: [[tix-wishlist-core]]
- howto: [[add-new-passport-package]], [[release-passport-package]]

## Sources
- TIX-REACT-REMOTE `webpack.config.js`, `exposes.config.js`, `src/utils/mount.tsx`, `src/components/*/bootstrap.ts`
- TIX-REACT-COMMON `packages/react-common-remote/src/RemoteComponent/{index.tsx,utils.ts,useDynamicScript.ts}`, `packages/react-common-remote/src/Remote*/Fallback.tsx`
- TIX-NEXT-PAYMENT-FE `next.config.ts`, TIX-FINTECH-NEXT-FE `next.config.js`
