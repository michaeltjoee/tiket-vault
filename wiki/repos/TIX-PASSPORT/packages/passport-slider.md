---
title: Slider (range)
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-slider"
sources:
  - packages/slider/src
  - packages/slider/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Slider
> Range slider with two thumbs (or one) for filters like price ranges. It supports mouse and touch, discrete steps and separator marks.

Part of [[passport-packages]].

## What it does
It is controlled: `value: { from, to }`, and `onDrag(newValue)` fires continuously while a thumb moves (there is no separate "change end" event). It tracks pointer and touch moves (`isTouch` guard), converts positions to values between `min` and `max`, and keeps the thumbs from crossing. With `singleHandle` only the right thumb shows and `value.from` is ignored. With `discrete` plus `step`, values snap. `showSeparator` draws step markers, spaced evenly (`divideSeparatorEqually`, default true) or at `customSeparators` values. `name` prefixes the hidden native inputs for forms.

## Public API
`Slider` (also in [[passport-umbrella]]); types `SliderProps`, `Value`, `Range`, `Position`, the `const enum Thumb`, and the helper `isTouch`.

| Prop | Notes |
|---|---|
| `value`, `onDrag` | required |
| `min`, `max` | track bounds |
| `singleHandle`, `discrete`, `step` | modes |
| `showSeparator`, `divideSeparatorEqually`, `customSeparators` | markers |
| `disabled`, `name`, `className` | |

## Usage
```tsx
<Slider min={0} max={5_000_000} value={{ from, to }} discrete step={100_000}
  onDrag={({ from, to }) => setRange({ from, to })} />
```

## Depends on
[[passport-utils]] (declared). External: `classnames`.

## Used by
- No internal dependents and no consumers in the other workspace repos on baseline. Filter UIs in vertical apps outside the workspace use it.

## Gotchas
- `Thumb` is a `const enum`. Consumers using isolated-module transpilers (Babel, SWC, esbuild) can't import it as a runtime value.
- Debounce `onDrag` yourself before fetching, because it fires on every move.

## Sources
- packages/slider/src/Slider.tsx
- packages/slider/package.json
