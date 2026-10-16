---
title: SearchBox
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-search-box"
umbrella: true
sources:
  - packages/search-box/src
  - packages/search-box/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# SearchBox
> Search input with a clear button, an optional leading nav icon, a trailing action button or link, and an optional rotating ("running") placeholder.

Part of [[passport-packages]].

## What it does
It is a controlled `<input>` (`value`, `onChange`, `onClear`). With `isRunningPlaceholder` and `placeholders[]`, the placeholder text cycles through the list and pauses on focus. `onFocus` and `onClick` then also receive `activePlaceholderIndex`, so you can track which suggestion the user saw. Slots: `navIcon` + `onNavClick` (e.g. a back arrow), `actionButtonText` + `onActionButtonClick`, `linkText` / `linkIcon` + `onLinkClick`. It adapts to the accessibility mode from `usePassport()` unless `noSearchBoxAccessibility` or `data-disable-a11y` is set.

## Public API
`SearchBox` (also in [[passport-umbrella]]); types `SearchBoxOwnProps`, `SearchBoxProps` (input props via `WithElementProps`).

| Prop | Notes |
|---|---|
| `value`, `onChange`, `onClear` | required |
| `placeholder` / `placeholders` + `isRunningPlaceholder` | static or rotating |
| `size` | `sm`, `md` (default), `desktop_dropdown` |
| `lightBackground` | for use on colored headers |
| `navIcon`, `onNavClick`, `actionButtonText`, `onActionButtonClick`, `linkText`, `linkIcon`, `onLinkClick` | slots |
| `onFocus(e, idx?)`, `onClick(e, idx?)` | `idx` only with a running placeholder |
| `noSearchBoxAccessibility`, `data-disable-a11y` | opt out of a11y sizing |

## Usage
```tsx
<SearchBox value={q} onChange={(e) => setQ(e.target.value)} onClear={() => setQ('')}
  placeholder="Cari bank" size="sm" />
```

## Depends on
[[passport-button]], [[passport-typography]], [[passport-utils]], icons.

## Used by
- Inside TIX-PASSPORT: 8 packages: [[passport-language-and-currency-modal]], [[passport-refund-method]], [[passport-page-module]], [[passport-global-search]], [[passport-header]], [[passport-country-list-selection]], [[passport-currency-bottom-sheet]], corporate-interim-module.
- TIX-NEXT-PAYMENT-FE: `pages/smart_pay/components/BankAccount/BankList/index.tsx`. TIX-FINTECH-NEXT-FE: insurance claim-form `DropdownInput` and `PhoneNumberInput/CountryList`. Both import through `@tiket/passport`.

## Sources
- packages/search-box/src/SearchBox.tsx
- packages/search-box/package.json
