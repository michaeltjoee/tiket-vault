---
title: SegmentedControl
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-segmented-control"
sources:
  - packages/segmented-control/src
  - packages/segmented-control/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# SegmentedControl
> iOS-style segmented switch. A "floating" selected box slides between options, and options can have an icon and a badge.

Part of [[passport-packages]].

## What it does
It is a controlled component: `value` plus `onChange(newValue)`. A ResizeObserver on the selected button measures its width and x position into CSS variables (`--segmented-controls-selected-width`, `--segmented-controls-selected-x-pos`), and the selected box moves to them with a 333 ms transition. The transition is synced with the SCSS and only runs after a user click, not on first render or idle resizes.

## Public API
`SegmentedControl` (also in [[passport-umbrella]]); types `SegmentedControlProps`, `SegmentedControlSize` (`small` default | `medium`), `SegmentedControlShape` (`squircle` default | `pill`), `SegmentedControlVariant` (`solid` default | `invert`).

`options: { label, value, icon?, badge?, badgeColor?: 'red'|'green' }[]`.

## Usage
```tsx
<SegmentedControl value={tab} onChange={setTab} shape="pill"
  options={[{ label: 'Sekali jalan', value: 'oneway' }, { label: 'Pulang pergi', value: 'roundtrip', badge: 'Hemat' }]} />
```

## Depends on
[[passport-badge]], [[passport-typography]], [[passport-utils]], design-tokens (types).

## Used by
- Inside TIX-PASSPORT: no runtime dependents. [[passport-card-compound]] lists it only as a devDependency.
- No consumers in the other workspace repos.

## Gotchas
- Without `ResizeObserver` (old browsers, some test environments) the selected box is never positioned. Tests need a polyfill or a mock.

## Sources
- packages/segmented-control/src/SegmentedControl.tsx
- packages/segmented-control/package.json
