---
title: ProgressBar
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-progress-bar"
umbrella: true
sources:
  - packages/progress-bar/src
  - packages/progress-bar/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# ProgressBar
> Minimal horizontal progress bar: the fill width is `progress` percent.

Part of [[passport-packages]].

## What it does
It renders a wrapper `div` with an inner bar whose inline `width` is `${progress}%`. There is no clamping, no ARIA role and no label. For multi-step progress use [[passport-progress-step]] or [[passport-progress-stepper]].

## Public API
`ProgressBar({ progress: number, style?, className? })` (also in [[passport-umbrella]]).

## Usage
```tsx
<ProgressBar progress={(uploaded / total) * 100} />
```

## Depends on
[[passport-utils]] (declared). External: `classnames`.

## Used by
- Inside TIX-PASSPORT: [[passport-file-upload]]. [[passport-coachmark]] lists it only as a devDependency.
- No direct consumers in the other workspace repos.

## Gotchas
- Values outside 0–100 are not clamped, so the bar can overflow. It has no `role="progressbar"` or `aria-valuenow`, so wrap it yourself for accessibility.

## Sources
- packages/progress-bar/src/ProgressBar.tsx
- packages/progress-bar/package.json
