---
title: Top Nav SRP
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-top-nav-srp"
sources:
  - packages/top-nav-srp/src
  - packages/top-nav-srp/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Top Nav SRP
> The mobile search-results-page top bar: a back button, a two-part route title (e.g. "Jakarta → Bali") with a chevron that reopens the search form, a sub-line, and up to two action icons.

Part of [[passport-packages]].

## What it does
`TopNavSrp` lays out a back button (`IconBack`), a title block and an action area. When both `title1` and `title2` are shown, a route icon goes between them, chosen by `arrowIconType`: `departure`, `return` or `left-right` (round trip). A chevron-down "more" affordance always follows the titles. With `onTitleClick`, the whole title and sub-text block becomes one button, typically opening the search form ([[passport-search-form-display]] territory). `variant="invert"` switches text and icons to white for coloured or transparent headers. `actionIcon1`/`actionIcon2` are any nodes, each wrapped in a button that is disabled unless its click handler is set.

## Public API
`TopNavSrp`; type `TopNavSrpProps` (`WithElementProps<…, 'div'>`).
| Prop | Notes |
|---|---|
| `title1` | required |
| `title2`, `showTitle2` (default `true`) | second half of the route |
| `arrowIconType` | `departure` (default), `return`, `left-right` |
| `subText` | e.g. date and passengers |
| `variant` | `default` or `invert` |
| `actionIcon1`, `actionIcon2` | icon nodes |
| `onBackClick`, `onTitleClick`, `onIcon1Click`, `onIcon2Click` | |
| rest | outer `div` props |

## Usage
```tsx
<TopNavSrp
  title1="Jakarta"
  title2="Denpasar-Bali"
  arrowIconType="left-right"
  subText="Fri, 20 Nov · 1 pax · Economy"
  onBackClick={router.back}
  onTitleClick={openSearchForm}
  actionIcon1={<IconFilter />}
  onIcon1Click={openFilter}
/>
```

## Depends on
[[passport-icons]] (`IconBack`, `IconChevronDown`, `IconDeparture`, `IconReturn`, `IconLeftRight`), [[passport-typography]], [[passport-design-tokens]] (types), [[passport-utils]] (types).

## Used by
- No importers in the other repos and no internal dependents. It isn't in the umbrella `@tiket/passport`, so import it by its own name (vertical SRP apps).

## Gotchas
- The back button always renders, even without `onBackClick` (it just isn't styled as clickable). Hide it with CSS if a page has no back action.
- The chevron shows even when the title isn't clickable.
- The arrow icon only appears when both titles are visible.

## Sources
- `packages/top-nav-srp/src/TopNavSrp.tsx`, `packages/top-nav-srp/src/constant.ts`
- `packages/top-nav-srp/package.json`
