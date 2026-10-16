---
title: Multi-currency formatting
kind: concept
repos: [TIX-REACT-COMMON, TIX-PASSPORT, TIX-NEXT-PAYMENT-FE, TIX-FINTECH-NEXT-FE, TIX-REACT-REMOTE, TIX-HOMEPAGE-NEXT-FE, TIX-GROWTH-NEXT-FE]
sources:
  - TIX-REACT-COMMON/packages/react-common-utilities/src/createCurrencyFormatter
  - TIX-REACT-REMOTE/src/server/utils/prerender.ts
  - TIX-HOMEPAGE-NEXT-FE/pages/promo/[category]/[slug]/component/InventoryCard/InventoryCard.tsx
  - TIX-HOMEPAGE-NEXT-FE/middleware.page.ts
  - TIX-GROWTH-NEXT-FE/lib/hooks/useCurrencyFormatter.ts
  - TIX-GROWTH-NEXT-FE/middleware.page.ts
verified_at:
  TIX-REACT-COMMON: 14597c4e
  TIX-PASSPORT: 7a33010aca
  TIX-NEXT-PAYMENT-FE: 9e92b20bb
  TIX-FINTECH-NEXT-FE: 5833b842
  TIX-REACT-REMOTE: 281778b
  TIX-HOMEPAGE-NEXT-FE: 408983f6
  TIX-GROWTH-NEXT-FE: d4162e3
updated: 2026-10-16
status: current
tags: [kind/concept, repo/react-common, repo/passport, repo/payment-fe, repo/fintech-fe, repo/react-remote, repo/homepage-fe, repo/growth-fe]
---

# Multi-currency formatting
> Prices are formatted everywhere with one function, `createCurrencyFormatter` from [[react-common-utilities]], so the decimal places, rounding and short "calendar" amounts match across apps and Passport widgets.

## API
`createCurrencyFormatter({ locale, currency, scale })(value)` returns:
- `toString({ rounding?, withCurrencyLabel? })`: `Intl.NumberFormat` with a fixed number of decimals per currency, optionally prefixed with the currency code.
- `toNumber({ rounding? })`.
- `toCalendarString()`: short amounts for date pickers, using `jt`/`rb` (id) or `M`/`K` (en).

`scale` is the number of decimal digits already in `value`: the formatter divides by `10^scale` first. Use it for APIs that send amounts in minor units.

Decimal places come from `DECIMAL_PLACES_BY_CURRENCY`: 0 for IDR and JPY, 2 for USD, EUR, SGD, AUD and the others, and 2 for unknown codes. `rounding: true` rounds to an integer once the value is 10 or more (`ROUNDING_CUTOFF_VALUE`) and then drops the decimals. The utilities README describes it as the rounding for discovery pages.

## Where the currency comes from
The `tiket_currency` cookie, `@tiket/next` `currencyMiddleware`, or `PassportProvider currency`. Defaults differ by URL style: IDR on legacy URLs, USD on [[new-url-structure]] URLs. The react-remote prerender server reads `tiket_currency`, then `x-client-currency`, then `IDR` ([[react-remote-ssr-prerender]]). homepage-fe runs `currencyMiddleware` in its chain. growth-fe keeps it in the chain but disables it with `withConfig(currencyMiddleware, { enable: () => false })`.

## Users
`git grep -l createCurrencyFormatter` on the baselines: 16 files in TIX-PASSPORT across [[passport-global-search]], [[passport-insurance]], [[passport-insurance-pop-up]], [[passport-page-module]], [[passport-pricing-promo]], [[passport-product-card]] and [[passport-search-widget-flight]], 12 in TIX-NEXT-PAYMENT-FE (the most-imported utility there, e.g. [[payment-fe-downpay]]) and 12 in TIX-FINTECH-NEXT-FE. TIX-HOMEPAGE-NEXT-FE has 3 (promo detail flight inventory and inventory cards, [[homepage-fe-promo]]) and TIX-GROWTH-NEXT-FE has 3 (`lib/hooks/useCurrencyFormatter.ts` and the story flight and TTD cards, [[growth-fe-stories]]).

## Gotchas
- Pass `currency` in any case. It is upper-cased for the decimals lookup, but the label prints `params.currency` as given.
- Without `Intl` support (`supportCapability()` false) `toString` returns the raw scaled number.

## Where it shows up
Pages that link here:
- TIX-REACT-COMMON: [[react-common-utilities]]
- concepts: [[new-url-structure]]

## Sources
- TIX-REACT-COMMON `packages/react-common-utilities/src/createCurrencyFormatter/{createCurrencyFormatter,constants,utils}.ts`
- TIX-REACT-REMOTE `src/server/utils/prerender.ts`
- TIX-HOMEPAGE-NEXT-FE and TIX-GROWTH-NEXT-FE `middleware.page.ts`
- Usage counts: `git grep -l createCurrencyFormatter origin/main` in TIX-PASSPORT, TIX-NEXT-PAYMENT-FE, TIX-FINTECH-NEXT-FE, TIX-HOMEPAGE-NEXT-FE and TIX-GROWTH-NEXT-FE (specs, stories and docs excluded)
