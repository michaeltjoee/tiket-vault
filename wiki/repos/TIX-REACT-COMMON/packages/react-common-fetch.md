---
title: react-common-fetch
repo: TIX-REACT-COMMON
kind: package
npm: "@tiket/react-common-fetch"
sources:
  - packages/react-common-fetch/src
  - packages/react-common-fetch/package.json
  - packages/react-common-fetch/babel.config.js
verified_at: 14597c4e
updated: 2026-10-16
status: deprecated
tags: [repo/react-common, kind/package]
---

# react-common-fetch
> Legacy isomorphic `fetch` with session-token handling for the old Express-based "Tix React App". It is superseded by [[react-common-fetch-client]].

## What it does
`fetch(url, options, req?, res?)` uses `isomorphic-fetch` on the client and `node-fetch` + bluebird on the server. It reads `session_access_token`/`session_refresh_token` cookies (server: from `req`), adds `Authorization: Bearer`, `X-Request-id`, `X-Country-Code` (default `IDN`), `X-Channel-Id` (`DESKTOP`), `X-Store-Id` (`TIKETCOM`) and common headers, and wraps the call in [[react-common-eagle-eye]]. On the server, with no token, it first creates a guest token. On 401 it creates a guest token for `MISSING_ACCESS_TOKEN`, otherwise it refreshes (up to 2 retries) and sets the new token via `setTokenAndRetry`. The README marks it "Tix React App only, no Next.js support". Status `deprecated`: no consumers in the workspace and no package.json `deprecated` flag.

## Public API
- `fetch(url, options?, req?, res?)`. Options: `skipAuth`, `accessToken`, `retry`, `timeout`, `createSession`, `disableCookieSessionV2`, `countryCode`, `'X-Audience'`, `'X-Channel-Id'`, `'X-Store-Id'`, `gql`, plus `RequestInit`
- `getOrCreateDeviceId`, `isWebviewEnv` (from `src/deviceId`)
- Not exported from the root, but shipped in `lib/`: `middlewares/cookieMiddleware` (Express middleware that re-sets token cookies on `.tiket.com` for 15 days) and `graphql/graphql.client`

## Usage
```js
import { fetch } from '@tiket/react-common-fetch';
// server side: pass Express req/res so tokens can be read and re-set
const result = await fetch(url, { method: 'POST', body: JSON.stringify(payload) }, req, res);
```

## Depends on
- [[react-common-eagle-eye]]; `isomorphic-fetch`, `node-fetch` (root dep), `bluebird`, `isomorphic-cookie`, `express-http-context`, `fbjs`
- A global `CONFIG.Hostname` (webpack `DefinePlugin` in the host app) for relative URLs on the server. `src/config` picks `development|staging|production|sandbox` from `NODE_ENV` (default staging).

## Used by
No consumer in TIX-PASSPORT, TIX-REACT-REMOTE, TIX-NEXT-PAYMENT-FE, TIX-FINTECH-NEXT-FE or TIX-GTM-EXTRAS on baseline.

## Gotchas
- `options.timeout` does nothing: `fetch.client.js` creates the abort timer only **after** the response arrives and clears it at once.
- Plain JS built with Babel to `lib/`, with no type declarations. It is the only package with its own `jest src` test script and its own Sonar coverage path. The root Jest projects skip it.
- `publishConfig.access: public` but no registry override; root `.npmrc` still routes `@tiket` to GitHub Packages.

## Sources
- packages/react-common-fetch/src/{index.js,fetch/index.js,fetch/fetch.client.js,fetch/fetch.server.js,fetch/createGuestToken.js,middlewares/cookieMiddleware.js,graphql/graphql.client.js,config/index.js}
- packages/react-common-fetch/package.json, README.md (root)
