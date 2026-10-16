---
title: SearchFormDisplay
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-search-form-display"
umbrella: true
sources:
  - packages/search-form-display/src
  - packages/search-form-display/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# SearchFormDisplay
> The tappable "field" rows of a search form (origin, destination, dates, pax), with stacking, a swap button, and content helpers for split text, icon counts, toggles and placeholders.

Part of [[passport-packages]].

## What it does
- `SearchFormDisplay` is one row: `icon`, `content` (a string or element), `auxiliary` (right side), and an optional clear cross (`closeIcon`, `handleClickCross`). `onClick(content, name)` handles clicks. A `selectionPopUp` element can be passed: it is cloned with an `onSelect` and opened through `handleOpenPopup` or `openContent`. `variant` is `default` or `transparent` (no fill, 0 radius, `horizontalPadding` 0 or 12). Other props: `disabled`, `contentFilled`, `truncatedMaxLines`.
- `SearchFormDisplayStack` groups rows with dividers. With `swappable` and `onSwap` it shows a `SwapButton` between the first two rows, e.g. origin and destination.
- Content helpers: `SFDSplitText`, `SFDDualIconWithCount` (e.g. adult and child counts), `SFDToggleWithLabel` (uses [[passport-toggle]]), `SFDPlaceholderText`, `SFDAttributedText`.

## Public API
All of the above (in [[passport-umbrella]] except `SFDAttributedText`), plus the types `SearchFormDisplayProps`, `SearchFormDisplayStackProps` and `SearchFormDisplayVariant`.

## Usage
From `SearchFormDisplay.stories.tsx`:
```tsx
<SearchFormDisplayStack swappable onSwap={swap}>
  <SearchFormDisplay content="Jakarta" icon={<IconBusStart />} />
  <SearchFormDisplay content="Bandung" icon={<IconBusFinish />}
    auxiliary={<SFDDualIconWithCount first={{ icon: <IconBabyChair />, count: 1 }} second={...} />} />
</SearchFormDisplayStack>
```

## Depends on
[[passport-collapse]], [[passport-toggle]], [[passport-typography]], [[passport-utils]], icons.

## Used by
- No internal dependents and no consumers in the other workspace repos on baseline. The vertical search widgets that use it live outside the workspace.

## Sources
- packages/search-form-display/src/SearchFormDisplay.tsx
- packages/search-form-display/src/SearchFormDisplayStack.tsx
- packages/search-form-display/src/types.ts
- packages/search-form-display/src/SearchFormDisplay.stories.tsx
- packages/search-form-display/package.json
