---
title: ProgressStepper
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-progress-stepper"
umbrella: true
sources:
  - packages/progress-stepper/src
  - packages/progress-stepper/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# ProgressStepper
> Simple vertical status timeline where each entry has a title, subtitle and description, and a status of `initial`, `in_progress` or `achieved`.

Part of [[passport-packages]].

## What it does
It maps `data` to timeline rows. An `achieved` row shows an inline checkmark SVG. A row that isn't `initial` shows its title in high emphasis. It has no interactivity and no active-index prop: each item carries its own status. For richer step UIs see [[passport-progress-step]].

## Public API
`ProgressStepper({ data: { title, subtitle, description?, status }[] })` (also in [[passport-umbrella]]). The props types aren't exported.

## Usage
```tsx
<ProgressStepper data={[
  { title: 'Refund diajukan', subtitle: '12 Okt', status: 'achieved' },
  { title: 'Diproses maskapai', subtitle: 'Estimasi 14 hari', status: 'in_progress' },
  { title: 'Dana dikembalikan', subtitle: '-', status: 'initial' },
]} />
```

## Depends on
[[passport-container]] (declared), [[passport-typography]], [[passport-utils]].

## Used by
- No internal dependents and no consumers in the other workspace repos on baseline.

## Gotchas
- Rows are keyed by `title`, so duplicate titles cause React key warnings.
- `StepperProps` and `ElementProps` are not exported. Use `React.ComponentProps<typeof ProgressStepper>`.

## Sources
- packages/progress-stepper/src/ProgressStepper.tsx
- packages/progress-stepper/package.json
