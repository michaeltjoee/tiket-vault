---
title: Country List Selection
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-country-list-selection"
sources:
  - packages/country-list-selection/src
  - packages/country-list-selection/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Country List Selection
> Searchable country list for phone-code or nationality pickers, meant to sit inside a BottomSheet, a dropdown or a Modal.

## What it does
It renders a sticky [[passport-search-box]] above a [[passport-list]] of countries (flag, name, ISD code). Search filters by name or ISD code, case-insensitively, and highlights the match. The selected country gets a check icon. When `selectedCountryId` is a **number**, that country is moved to the top once at mount, and again only when the `data` reference changes, so the list doesn't jump. An empty result shows a localized "no result" illustration. The search box gets a sticking style when it pins to the top of a [[passport-bottom-sheet]] (IntersectionObserver against `[data-bottom-sheet-scrollable-element]`).

## Public API
| Export | Notes |
|---|---|
| `CountryListSelection` | `data: CountryObject[]`, `onSelect(country, idx)` (required). `selectedCountryId`, `onSearchChange`, `onClear`, `searchInputRef`, `searchInputPlaceholder`, `countryImageRenderer`, `noResultImageRenderer`, `wrapperClassName`, `searchBoxClassName`, `countryListClassName` |
| `CountryListSelectionModalWrapper` | sizing wrapper for use inside [[passport-modal]] |
| types `CountryObject` (`countryId`, `countriesName`, `countriesIsoCode`, `countriesIsdCode`, `countriesImage`), `CountryListSelectionProps`, `ImageRenderer`, `NoResultProps` | |

## Usage
```tsx
<BottomSheet isOpen={open} onClose={close} title="Country code">
  <CountryListSelection data={countries} selectedCountryId={selected?.countryId} onSelect={(c) => { setSelected(c); close(); }} />
</BottomSheet>
```

## Depends on
[[passport-search-box]], [[passport-list]], [[passport-assets]] (`tds_si_no_result`), [[passport-icons]], [[passport-typography]], [[passport-utils]].

## Used by
- Through the umbrella `@tiket/passport`: TIX-NEXT-PAYMENT-FE `components/CountryField/CountryField.tsx` ([[payment-fe-components]]) and TIX-FINTECH-NEXT-FE `app/gift-card/checkout/[id]/containers/SenderFormContainer.tsx` and `app/gift-card/checkout/components/RecipientForm/RecipientForm.tsx` ([[fintech-fe-gift-card]]). FINTECH also uses `CountryListSelectionModalWrapper`.
- Internal: [[passport-form]] (`PhoneNumberInput`), [[passport-phone-verification]].

## Gotchas
- The country data isn't fetched here. Callers pass it in. `src/dummyData.tsx` is for stories only.
- String IDs are never moved to the top. Only numeric `selectedCountryId` triggers the sort.
- The search box size uses the client-side breakpoint (`sm` on desktop, `md` otherwise), which can flip after hydration.

## Sources
- `packages/country-list-selection/src/CountryListSelection.tsx`, `src/HighlightedString.tsx`, `src/utils/useStickyRef.ts`, `src/utils/constants.ts`
- `packages/country-list-selection/package.json`, `packages/passport/index.js`
