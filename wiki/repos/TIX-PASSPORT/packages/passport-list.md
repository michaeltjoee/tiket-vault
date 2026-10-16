---
title: List
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-list"
sources:
  - packages/list/src
  - packages/list/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# List
> A single list row: optional left slot, title and description, optional link, a right slot (children), and an optional divider.

Part of [[passport-packages]].

## What it does
Renders one row, not a list container. Stack several to build a list. The title and description can highlight a search term case-insensitively (`highlightedString`), which is why search-style selectors (country list, currency sheet) use it.

## Public API
`List` (also in [[passport-umbrella]]). Props are `ListOwnProps` merged with `div` props via `WithElementProps`.

| Prop | Default | Notes |
|---|---|---|
| `title` | required | `b1` bold, or `b2` regular when `isRegularTitle` |
| `description` | | `b2`, variant from `descriptionTextVariant` (default `lowEmphasis`) |
| `left` / `children` | | left slot / right slot |
| `link` | | rendered as `activity` bold text below the description |
| `highlightedString`, `shouldHighlight.{title,description}` | `''`, both true | term highlighting |
| `withDivider`, `dividerVariant` | `false`, `'default'` | bottom [[passport-divider]] |
| `horizontalPadding` | `'default'` | `'none'` removes side padding |
| `titleOpenTypeFeature` | | passed to `Text` |

## Usage
```tsx
<List title="Jakarta" description="Indonesia" highlightedString={query} withDivider>
  <QuantityEditor min={0} max={5} step={1} onChange={() => {}} />
</List>
```

## Depends on
[[passport-typography]], [[passport-divider]], [[passport-utils]]. [[passport-quantity-editor]] is a devDependency, used only in stories.

## Used by
- Inside TIX-PASSPORT: [[passport-country-list-selection]], [[passport-currency-bottom-sheet]], [[passport-otp-unm]], [[passport-refund-method]].
- TIX-NEXT-PAYMENT-FE and TIX-FINTECH-NEXT-FE import `List` from `@tiket/passport` (e.g. FINTECH `projects/insurance/claim-center/claim-form/components/Form/PhoneNumberInput/CountryList.tsx`).

## Gotchas
- `HighlightedString` strips every character except `\w`, whitespace, `.`, `&` and `-` from the search term, then builds a RegExp from it. The `.` is left unescaped, so it matches any character.

## Sources
- packages/list/src/List.tsx
- packages/list/src/HighlightedString.tsx
- packages/list/package.json
