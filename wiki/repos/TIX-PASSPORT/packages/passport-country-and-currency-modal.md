---
title: Country and Currency Modal
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-country-and-currency-modal"
umbrella: true
sources:
  - packages/country-and-currency-modal/src
  - packages/country-and-currency-modal/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Country and Currency Modal
> A self-triggering popup that asks the user to confirm their country and currency when the URL doesn't match their stored preferences. It also exports the country picker pieces the header reuses.

## What it does
`CountryAndCurrencyModal` takes **no props**. After the A/B-test data loads it reads the `user_preference_mismatch` cookie, which FE middleware sets when stored preferences differ from the URL. The cookie holds JSON `{ country, currency, detectedCurrency }`. The modal opens once per distinct cookie value: it remembers the value in `localStorage` under the same key, and clears the cookie on close. The country selector only appears when the feature flags allow it. Applying a choice rewrites the `/<lang>-<country>/` path prefix and the `currency` query, then reloads (`updateUrlAndReload`). It renders a [[passport-bottom-sheet]] on mobile and a [[passport-modal]] on desktop.

## Public API
| Export | Notes |
|---|---|
| `CountryAndCurrencyModal` | no props. Mount once near the app root |
| `CountryBottomSheet`, `CountryList`, `CountryDropdown` | reusable country pickers (used by [[passport-header]] settings) |
| `useCountryData()` | `{ countryList, countrySettings, isLoading, userCountryData }` from feature flags |
| `updateUrlAndReload(country?, currency?, language?, urlTransformer?)` | `/en-us/hotel?currency=IDR` becomes `/en-my/hotel?currency=MYR` |
| `sanitizeLocaleTrackerData(lang, country, currency)` | gives `"EN;MY;MYR"` for tracking |
| `COUNTRY_LABEL`, types `CountryListPayload`, `CountrySettingsPayload` | |

## Usage
```tsx
// once per page, inside PassportProvider and the AB-test provider
<CountryAndCurrencyModal />
```

## Data & flags
- Country list and visibility come from `@tiket/react-common-ab-test` `useExperiment().getVariant()` with flags `ff-member-country-code-list` (payload `contentRegions`) and `ff-member-country-settings-visibility` (payload `countrySelector.showInPopupCountryCurrency`, and so on). If both flags are off, the list is empty and only currency is offered. See [[react-common-ab-test]].
- Cookies: `user_preference_mismatch` (read and cleared), `country_code`, `tiket_currency`, `userlang`. `setCookie` writes them on `.tiket.com`.
- The currency list comes from [[passport-currency-bottom-sheet]].

## Depends on
[[passport-bottom-sheet]], [[passport-modal]], [[passport-currency-bottom-sheet]], [[passport-dropdown]], [[passport-radio]], [[passport-button]], [[passport-divider]], [[passport-icons]], [[passport-assets]], [[passport-typography]], [[passport-utils]], `@tiket/react-common-ab-test` (TIX-REACT-COMMON).

## Used by
- TIX-REACT-REMOTE `src/components/country-and-currency-modal/index.tsx` exposes it as a remote ([[react-remote-country-and-currency-modal]]), pinned `12.4.2`.
- TIX-REACT-COMMON `packages/react-common-remote/src/RemoteCountryAndCurrencyModal/Fallback.tsx` imports it from the umbrella as the SSR/failed-remote fallback ([[react-common-remote]]).
- Internal: [[passport-header]], [[passport-language-and-currency-modal]].

## Gotchas
- It needs the AB-test provider from `@tiket/react-common-ab-test` above it. Without one, `useExperiment` has no data and the modal never decides to open.
- Nothing shows unless the middleware sets the mismatch cookie, so local testing needs that cookie set by hand.
- `updateUrlAndReload` skips paths starting with `/to-do` because the locale regex excludes them.

## Sources
- `packages/country-and-currency-modal/src/CountryAndCurrencyModal.tsx`, `src/hooks/useCountryData.ts`, `src/common/utils.ts`, `src/common/constants.ts`, `src/index.ts`
- `packages/country-and-currency-modal/package.json`
- TIX-REACT-COMMON `packages/react-common-remote/src/RemoteCountryAndCurrencyModal/Fallback.tsx` (14597c4e)
