---
title: Coachmark
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-coachmark"
umbrella: true
sources:
  - packages/coachmark/src
  - packages/coachmark/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Coachmark
> Multi-step onboarding tour. It dims the page, spotlights a target element found by CSS selector, and shows a step pane with Skip/Next/Done.

## What it does
For the current `index` it finds `document.querySelector(step.selector)`, positions a "focus" cut-out over that element, scrolls it into view if needed (IntersectionObserver), and places a `StepPane` with an arrow pointer. The pane uses `defaultPlacement` when there's room, otherwise the first side that fits. It portals into the page and locks scroll while shown. Button labels are localized (en: Skip/Next/Done/OK, id: Lewati/Lanjut/Selesai/Oke). Navigation is controlled by the parent.

## Public API
`Coachmark`, plus type `CoachmarkProps`. `CoachmarkStep` is declared but not re-exported from the entry, so derive it as `CoachmarkProps['steps'][number]`.
| Prop | Notes |
|---|---|
| `steps: { selector, title?, image?, content, defaultPlacement: 'left'\|'right'\|'top'\|'bottom' }[]` | |
| `index` | current step (controlled) |
| `onProgress(steps, nextIndex)` | Next was clicked. Set `index = nextIndex` |
| `onClose()` | Skip or Done |
| `doneButtonText` | overrides the localized Done/OK |
| `isHideSkipButton`, `focusWrapperClassName`, `truncatedMaxLines` | |

## Usage
```tsx
{showTour && (
  <Coachmark
    steps={[{ selector: '#pay-later', title: 'New!', content: 'Pay later is here', defaultPlacement: 'bottom' }]}
    index={i} onProgress={(_, next) => setI(next)} onClose={() => setShowTour(false)}
  />
)}
```

## Depends on
[[passport-button]], [[passport-portal]], [[passport-typography]], [[passport-utils]] (`usePassport`, `usePreventScroll`, `throttle`, and a deep import of `src/context.module.scss`).

## Used by
- Through the umbrella `@tiket/passport`: TIX-NEXT-PAYMENT-FE `pages/smart_pay/components/DanaItemTile/DanaItemTile.tsx` and `pages/smart_pay/components/Items/index.tsx`.
- Internal: none.

## Gotchas
- It calls `document.querySelector` **during render** and **throws** `Target element <selector> is not found` if the element is missing. Render it only on the client, after the targets have mounted.
- `package.json` `description` is still the scaffold placeholder "Passport {TODO} Component".

## Sources
- `packages/coachmark/src/Coachmark.tsx`, `src/StepPane.tsx`, `src/utils.ts`, `src/constants.ts`
- `packages/coachmark/package.json`
