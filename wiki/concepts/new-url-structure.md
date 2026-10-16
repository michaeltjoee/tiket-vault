---
title: New URL structure (/{lang}-{country}/)
kind: concept
repos: [TIX-REACT-COMMON, TIX-PASSPORT, TIX-REACT-REMOTE, TIX-NEXT-PAYMENT-FE, TIX-FINTECH-NEXT-FE]
sources:
  - TIX-REACT-COMMON/packages/react-common-utilities/src/isNewURLStructure
  - TIX-REACT-COMMON/packages/react-common-fetch-client/src/client/mandatoryFetchHeaders.ts
  - TIX-REACT-COMMON/packages/react-common-core-attributes/src
  - TIX-REACT-COMMON/packages/react-common-remote/src/fetcher/fetcher.ts
  - TIX-REACT-REMOTE/src/server/utils/prerender.ts
  - TIX-PASSPORT/packages/utils/src/context.tsx
  - TIX-FINTECH-NEXT-FE/middleware.page.ts
  - TIX-NEXT-PAYMENT-FE/middleware.page.ts
verified_at:
  TIX-REACT-COMMON: 14597c4e
  TIX-PASSPORT: 7a33010aca
  TIX-REACT-REMOTE: 281778b
  TIX-NEXT-PAYMENT-FE: 9e92b20bb
  TIX-FINTECH-NEXT-FE: 5833b842
updated: 2026-10-16
status: current
tags: [kind/concept, repo/react-common, repo/passport, repo/react-remote, repo/payment-fe, repo/fintech-fe]
---

# New URL structure
> tiket is moving from implicit locale (Indonesian, IDR, Indonesia) to explicit `/{lang}-{country}/...` URLs such as `/en-id/gift-card` or `/id-sg/payment`. Every layer carries an `isNewURLStructure` flag, and many defaults flip on it.

## Detection
`isNewURLStructure(pathname)` in [[react-common-utilities]] is `/^\/(?!to-do)[a-z]{2}-[a-z]{2}(\/|$)/`. The negative lookahead keeps `/to-do` (the things-to-do vertical) from matching. `inspectUrlStructure`, `getNewUrlStructure` and the `get{Locale,Country,Currency}ByPriority` resolvers build on it. In the Next apps the flag reaches components as `middlewareData.isNewURLStructure` from the `@tiket/next` middleware ([[tiket-next-core]]).

## What changes with the flag
| Layer | Legacy URL | New URL |
|---|---|---|
| [[react-common-fetch-client]] headers | language `id`, currency `IDR`, `X-Country-Code: IDN` | middleware locale (fallback `en`), currency (fallback `USD`), detected country |
| [[react-common-core-attributes]] | `window.__data` (`ID`/`IDR`/`id`) | middleware data (`en`/`USD`/`us` defaults) |
| [[react-common-remote]] → react-remote | sends `x-client-is-new-url-structure` | the prerender server passes `isNewURLStructure` into every widget, and it is a whitelisted SSR prop ([[react-remote-ssr-prerender]]) |
| Passport | `PassportProvider isNewURLStructure` | [[passport-header]], [[passport-country-and-currency-modal]], [[passport-global-popup]], [[passport-wishlist]], [[passport-bottom-tab-navigation]] build prefixed links |
| TIX-FINTECH-NEXT-FE | — | middleware rewrites `/{lang}-{country}/<app-router-path>` to the unprefixed path, login redirects add the prefix, refund keeps it, gift-card tracking reports `oldURL`/`newURL` ([[fintech-fe-architecture]], [[fintech-fe-refund]], [[fintech-fe-gift-card]]) |
| TIX-NEXT-PAYMENT-FE | — | local URLs look like `/id-sg/payment?...` ([[payment-fe-workflows]]) |

## Gotchas
- Currency is not part of the path. It comes from the `tiket_currency` cookie or the middleware, and the defaults differ by URL style (IDR vs USD). See [[multi-currency]].
- core-attributes has an operator-precedence bug, so the `userlang`/`tiket_currency`/`country_code` cookies are never used as values ([[analytics-core-attributes]]).
- `X-Country-Code` is `IDN` for every legacy URL, while `X-Country-Id` always uses the detected country.

## Where it shows up
Pages that link here:
- TIX-REACT-COMMON: [[react-common-utilities]]
- concepts: [[analytics-core-attributes]], [[multi-currency]], [[tiket-next-core]]

## Sources
- TIX-REACT-COMMON `packages/react-common-utilities/src/isNewURLStructure/isNewURLStructure.ts`, `packages/react-common-fetch-client/src/client/mandatoryFetchHeaders.ts`, `packages/react-common-core-attributes/src/initialize.ts`, `packages/react-common-remote/src/fetcher/fetcher.ts`
- TIX-REACT-REMOTE `src/server/utils/prerender.ts`
- TIX-PASSPORT `packages/utils/src/context.tsx`; `git grep -l isNewURLStructure origin/main -- packages`
- TIX-FINTECH-NEXT-FE `middleware.page.ts`, `lib/middlewares/validateSessionAppRouter.ts`, `app/gift-card/tracking/helper.ts`
- TIX-NEXT-PAYMENT-FE `middleware.page.ts`, `package.json` (`codegen:*` URLs)
