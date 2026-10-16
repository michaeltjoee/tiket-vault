---
title: Remote CountryAndCurrencyModal
repo: TIX-REACT-REMOTE
kind: component
npm: "@tiket/passport-country-and-currency-modal"
sources:
  - src/components/country-and-currency-modal
verified_at: 281778b
updated: 2026-10-16
status: current
tags: [repo/react-remote, kind/component]
---

# Remote CountryAndCurrencyModal
> Federated wrapper around the country/currency picker modal from [[passport-country-and-currency-modal]].

## What it does
Exposed as module key `country-and-currency-modal`. Renders `CountryAndCurrencyModal` with no props of its own; everything the modal needs comes from `PassportWrapper` context: `lang`, `country`, `currency`, `isNewURLStructure`, plus `dataLayer` and `isLoggedIn`, which only this component and nothing else forwards into `PassportProvider`. Also imports `@tiket/passport-design-tokens/variables.css` directly.

## Public API
`Partial<CommonComponentProps>`: `lang` (default `'id'`), `country` (default `'id'`), `currency`, `isNewURLStructure`, `dataLayer`, `isLoggedIn` (default `false`).

## Usage
```tsx
import { RemoteCountryAndCurrencyModal } from '@tiket/react-common-remote';
<RemoteCountryAndCurrencyModal />
```
The consumer wrapper in [[react-common-remote]] fills `isLoggedIn` from `ReactRemoteContext.sessionData.isLogin` and `dataLayer` from the context.

## Depends on
[[passport-country-and-currency-modal]], [[passport-design-tokens]], [[react-remote-wrapper]].

## Used by
- TIX-NEXT-PAYMENT-FE `components/providers/AppProvider.tsx` ([[payment-fe-components]]).

## Gotchas
- The webpack config resolves `@tiket/passport-currency-bottom-sheet` and `@tiket/passport-language-and-currency-modal` from their `src/index.ts` (`consumeFromSource` in `webpack.config.js`), so changes there ship only when react-remote rebuilds against a new Passport version.

## Sources
- src/components/country-and-currency-modal/index.tsx
- webpack.config.js
- TIX-REACT-COMMON packages/react-common-remote/src/RemoteCountryAndCurrencyModal/index.tsx
