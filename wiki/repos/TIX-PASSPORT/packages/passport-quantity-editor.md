---
title: QuantityEditor
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-quantity-editor"
umbrella: true
sources:
  - packages/quantity-editor/src
  - packages/quantity-editor/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# QuantityEditor
> A − / value / + stepper with `min`, `max` and `step`, optionally with a typeable value.

Part of [[passport-packages]].

## What it does
The minus button is disabled when `current - step < min` and plus when `current + step > max`. It works in two modes:
- **uncontrolled**: internal string state seeded from `initialQuantity` (default 0),
- **controlled**: pass `controlledQuantity`, a number. The component then shows that value and only reports changes.

With `enableQtyTextEdit`, the value is an `<input>`. Clearing it and blurring resets it to `min`, using an `onBlurTimeout` workaround so a click on a button right after clearing doesn't apply the step.

## Public API
`QuantityEditor` (also in [[passport-umbrella]]); `QuantityEditorProps`: `min`, `max`, `step`, `onChange(newQty)` (all required), `initialQuantity?`, `controlledQuantity?`, `enableQtyTextEdit?` (default false).

## Usage
```tsx
<QuantityEditor min={0} max={5} step={1} onChange={setPax} />
```

## Depends on
[[passport-typography]], [[passport-utils]], icons.

## Used by
- Inside TIX-PASSPORT: [[passport-list]] (devDependency, stories only).
- No consumers in the other workspace repos.

## Gotchas
- The source carries a TODO to rethink the controlled/uncontrolled design. Don't switch between the two modes during the component's lifetime.

## Sources
- packages/quantity-editor/src/QuantityEditor.tsx
- packages/quantity-editor/package.json
