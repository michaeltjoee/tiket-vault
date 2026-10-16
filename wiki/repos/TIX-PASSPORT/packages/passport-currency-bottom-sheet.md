---
title: Currency Bottom Sheet
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-currency-bottom-sheet"
sources:
  - packages/currency-bottom-sheet/src
  - packages/currency-bottom-sheet/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Currency Bottom Sheet
> Multi-currency picker. It fetches the user's allowed currencies, lets them pick one (radio list with search), and persists the choice to cookie, account and core attributes.

## What it does
When opened with `isMultiCurrencyAvailable`, `useMultiCurrency` calls `GET /tix-payment-dashboard/multi-currency/config/user?consumer_visible=true` and splits the result into suggested and other currencies plus tickers. If the user's current currency comes back with `userIsActive: false`, it auto-switches to IDR and calls `onDisabledCurrency`. A 404 disables multi-currency and falls back to the locale defaults. On change, for logged-in users, it calls `PUT /tix-member-core/v2/account/currency`. It then sets the `tiket_currency` cookie and calls `window.commonCoreAttributes.updateCoreAttributes({ currency })`. A failed PUT shows a retry [[passport-snackbar]].

## Public API
| Export | Notes |
|---|---|
| `CurrencyBottomSheet` | full-height `BottomSheet` (variant `clean`). Props: `isOpen`, `currency`, `isMultiCurrencyAvailable`, `isLogin`, `dataLayer`, `onClose({ isCurrencyChanged })`, `onChangeCurrency(code, isAuto?)`, `onDisabledCurrency(code)`, `onError`, `onLoading` |
| `CurrencyContent` | loading, error or list body, for embedding in your own sheet or modal (used by [[passport-country-and-currency-modal]] and [[passport-header]]) |
| `CurrencyListSelection` | the radio list with search (500 ms debounce) and currency info popup |
| `useMultiCurrency(props)` | headless state and actions |
| `CURRENCY_OPTIONS_HEADING`, `CURRENCY_OPTIONS_DESCRIPTION`, `CURRENCY_OPTIONS_SEARCH_PLACEHOLDER` | localized strings |
| type `CurrencyBottomSheetProps` | |

## Usage
```tsx
<CurrencyBottomSheet
  isOpen={open} isLogin={isLoggedIn} isMultiCurrencyAvailable
  onChangeCurrency={() => location.reload()} onClose={() => setOpen(false)}
/>
```

## Data & services
- `usePassport().customFetch` is used when provided ([[passport-custom-fetch]]). Requests pass `isCritical: true, isMigrated: true` in `RequestInit`. Those are options for the TIX-REACT-COMMON fetch client ([[react-common-fetch-client]]) and are ignored by plain `fetch`.
- Headers: `X-Audience: tiket.com`, `X-Channel-Id` (device-based), `X-Cookie-Session-V2: true`, `X-Service-Id: gateway`, `X-Store-Id: TIKETCOM`, `X-Request-Id: uuid`, `Accept-Language`.
- Side effects: the `tiket_currency` cookie, and the `window.commonCoreAttributes` global (from [[react-common-core-attributes]]). A missing global is caught and logged.
- GTM through `utils/Trackers.ts`: currency click, info click, warning view. `dataLayer` is merged in.

## Depends on
[[passport-bottom-sheet]], [[passport-modal]], [[passport-radio]], [[passport-search-box]], [[passport-list]], [[passport-figure]], [[passport-notification-banner]], [[passport-error-view]], [[passport-snackbar]], [[passport-loading-indicator]], [[passport-button]], [[passport-icons]], [[passport-assets]], [[passport-typography]], [[passport-utils]], `uuid`.

## Used by
- TIX-REACT-REMOTE `webpack.config.js` lists it in `consumeFromSource`. That aliases `@tiket/passport-currency-bottom-sheet$` to `node_modules/.../src/index.ts`, so the remote bundles the package's **TS source** instead of `dist`. The same applies to language-and-currency-modal, global-search and react-common-utilities. It reaches the remote through [[passport-header]].
- Internal: [[passport-country-and-currency-modal]], [[passport-header]].

## Gotchas
- Data loads only when `isOpen` turns true. The effect depends only on `isOpen`, so changing `isMultiCurrencyAvailable` while open does nothing.
- A user whose saved currency was deactivated by BE is silently switched to IDR the first time the sheet opens.
- Without `SnackbarProvider` mounted, the retry snackbar isn't shown.

## Sources
- `packages/currency-bottom-sheet/src/CurrencyBottomSheet.tsx`, `src/hooks/useMultiCurrency.ts`, `src/services/get-currencies.ts`, `src/services/put-account-currency.ts`, `src/utils/coreAttributes.ts`, `src/components/*`
- `packages/currency-bottom-sheet/package.json`
