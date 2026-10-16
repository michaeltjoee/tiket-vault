---
title: Button Slider
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-button-slider"
sources:
  - packages/button-slider/src
  - packages/button-slider/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Button Slider
> "Swipe to confirm" control. The user drags a knob to the end of the track to trigger an action, such as claiming a voucher.

## What it does
The user drags the arrow knob with mouse or touch. Releasing at 98% or more of the track width snaps it to the end, and after 300 ms it shows a loader and calls `onSwipeComplete`. Otherwise it springs back. Once at the end, the text switches to `completeText`, or `failedText` when `status === 'failed'`. With `resetOnFail`, a failed status resets the knob after 3 s, or immediately with `immediateResetOnFail`. The parent drives `status` from its API call.

## Public API
`ButtonSlider`, plus types `ButtonSliderProps`, `ButtonSliderOwnProps`, `ButtonSliderStatus`, `SliderFailure`, `SliderFailureState`, `SliderWithoutFailureState`.
| Prop | Notes |
|---|---|
| `title` | text before the swipe |
| `status` | `loading`, `fetched`, `static` or `failed` |
| `completeText` | text after the swipe |
| `isDisabled` | required boolean |
| `onSwipeComplete` | fires once when the end is reached |
| `resetOnFail` + `failedText` + `immediateResetOnFail` | all-or-nothing union |
| `truncatedMaxLines`, `className` | |

## Usage
```tsx
<ButtonSlider
  title="Swipe to claim" completeText="Claimed!" status={status} isDisabled={false}
  onSwipeComplete={claim} resetOnFail failedText="Try again" immediateResetOnFail={false}
/>
```

## Depends on
[[passport-loading-indicator]], [[passport-icons]], [[passport-typography]], [[passport-utils]].

## Used by
- No direct use in other repos. It's available through the umbrella `@tiket/passport`.
- Internal: [[passport-action-banner]] (`slider` mode), [[passport-global-popup]], [[passport-kuber-price-dynamic-banner]], [[passport-mission-landing-page]].

## Gotchas
- There's no keyboard path. `role="button"` and `tabIndex` are set, but only mouse and touch drag trigger completion.
- After a successful swipe the knob stays at the end until a `failed` + `resetOnFail` cycle or a remount. There's no reset prop.

## Sources
- `packages/button-slider/src/ButtonSlider.tsx`
- `packages/button-slider/package.json`
