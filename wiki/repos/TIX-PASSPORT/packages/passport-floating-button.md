---
title: Floating Button
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-floating-button"
umbrella: true
sources:
  - packages/floating-button/src
  - packages/floating-button/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Floating Button
> Fixed floating action button (FAB). It can be a single icon/illustration button or an "extended" pill of several labelled buttons, with optional show-after-scroll and hide-while-scrolling behaviour.

## What it does
It renders a fixed container (`position` left, center or right) in one of four background colours. In single mode it shows one round button with `icon` or `illustration`. With `isExtended` it shows `extendedButtons` as text buttons separated by dividers. `useDetectScroll` (throttled 200 ms, stop-detection 200 ms) adds two behaviours: `showAfterScroll` fades the button in after `showAfterScrollPx` (default 150), and `hideWhenScrolling` slides it out towards its side while the user scrolls. Optional `isShaking` and `extendedShimmer` animations draw attention.

## Public API
`FloatingButton`, plus types `FloatingButtonProps`, `FloatingButtonOwnProps`, `BackgroundColor` (`blue | white | black | purple`), `Extended` (`{ icon?, text, onClick }`).
| Prop | Default |
|---|---|
| `icon`, `illustration`, `onClick` | — |
| `backgroundColor` | `blue` |
| `size` | `regular` (or `mini`) |
| `position` | `right` |
| `isExtended`, `extendedButtons` | `false`, `[]` |
| `showAfterScroll`, `showAfterScrollPx`, `hideWhenScrolling` | —, `150`, `false` |
| `isShaking`, `extendedShimmer` | `false` |
Rest props go to the container `div`.

## Usage
```tsx
<FloatingButton isExtended position="center" hideWhenScrolling
  extendedButtons={[{ text: 'Sort', icon: <IconSort />, onClick: openSort }, { text: 'Filter', icon: <IconFilter />, onClick: openFilter }]} />
```

## Depends on
[[passport-button]], [[passport-divider]], [[passport-typography]], [[passport-utils]] (`throttle`, `debounce`). It imports `IconSize` from the deep path `@tiket/passport-icons/src/types` (see [[passport-icons]]).

## Used by
- Through the umbrella `@tiket/passport`: TIX-NEXT-PAYMENT-FE `app/downpay/components/DownPayConfirmation/DownPayConfirmation.tsx` ([[payment-fe-downpay]]).
- Internal: [[passport-insurance-pop-up]].

## Gotchas
- Scroll listeners are attached only when `showAfterScroll` or `hideWhenScrolling` is set. Initial `scrollY` is read on mount so Next.js scroll restoration works.
- The icon colour is automatic (high-emphasis on white, invert otherwise) unless the icon sets `color`.

## Sources
- `packages/floating-button/src/FloatingButton.tsx`, `src/useDetectScroll.ts`
- `packages/floating-button/package.json`
