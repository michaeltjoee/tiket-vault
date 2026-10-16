---
title: LanguageAndCurrencyModal
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-language-and-currency-modal"
sources:
  - packages/language-and-currency-modal/src
  - packages/language-and-currency-modal/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# LanguageAndCurrencyModal
> Header settings modal where the user picks language, currency and (behind a flag) country, then the page reloads with the new settings.

Part of [[passport-packages]].

## What it does
A self-contained, data-fetching `'use client'` modal. When opened it loads the multi-currency config from the gateway, and country data via `useCountryData` from [[passport-country-and-currency-modal]]. It keeps a draft selection, and on **Save** it:
1. calls the backend for changed values (language: `POST /tix-member-core/v3/account/lang/{lang}`, 2 s timeout, failures swallowed; currency: `PUT /tix-member-core/v2/account/currency`),
2. writes the language/currency cookies on `.tiket.com`,
3. fires GTM tracking,
4. calls `updateUrlAndReload(country, currency, language, urlTransformer)`, a single full navigation.

## Public API
`LanguageAndCurrencyModal` (also re-exported by [[passport-umbrella]]).

| Prop | Notes |
|---|---|
| `isOpen`, `onClose({ isCurrencyChanged })` | controlled open state |
| `currency` | current currency; falls back to the currency cookie, then default |
| `isLogin` | when true, changes are saved to the account APIs |
| `isMultiCurrencyAvailable` (default `false`) | when false, or the BE returns 404, the currency section is disabled |
| `onChangeCurrency`, `onChangeLanguage`, `onDisabledCurrency` | callbacks after a change |
| `onError`, `onLoading` | fetch lifecycle hooks |
| `dataLayer` | extra fields merged into tracking events |
| `urlTransformer` | rewrites the reload URL (e.g. for locale path prefixes) |

Locale and country come from `usePassport()` ([[passport-utils]]), so it must render inside `PassportProvider`.

## Usage
```tsx
<LanguageAndCurrencyModal
  isOpen={open}
  isLogin={isLoggedIn}
  isMultiCurrencyAvailable
  currency={currency}
  onClose={() => setOpen(false)}
/>
```

## Depends on
[[passport-modal]], [[passport-country-and-currency-modal]], [[passport-radio]], [[passport-tabs]], [[passport-search-box]], [[passport-notification-banner]], [[passport-snackbar]], [[passport-loading-indicator]], [[passport-typography]], [[passport-utils]], plus bottom-sheet, button, divider, dropdown, error-view, figure, icons, assets. External: `uuid` (X-Request-Id), `classnames`.

## Used by
- Inside TIX-PASSPORT: [[passport-header]].
- TIX-REACT-REMOTE: `webpack.config.js` lists it in `consumeFromSource`, which aliases the package to `node_modules/@tiket/passport-language-and-currency-modal/src/index.ts`. The remote header bundles it from source instead of `dist`. See [[module-federation]].

## Gotchas
- API calls go through `/ms-gateway/...` unless a `customFetch` is injected internally. On `*local.tiket*` hosts the base becomes `https://gatotkaca.tiket.com`. `X-Channel-Id` is `MOBILE_WEB` when the hostname starts with `m.`, otherwise `DESKTOP`.
- Save always ends in a full page reload, so caller state after `onClose` is short-lived.
- Country content only shows when `countrySettings.showInAccountPage` (from country-and-currency-modal) is true.

## Sources
- packages/language-and-currency-modal/src/LanguageAndCurrencyModal.tsx
- packages/language-and-currency-modal/src/services/
- packages/language-and-currency-modal/src/utils/Common.ts
- packages/language-and-currency-modal/package.json
- TIX-REACT-REMOTE webpack.config.js (origin/main)
