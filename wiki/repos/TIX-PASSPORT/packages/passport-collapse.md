---
title: Collapse
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-collapse"
sources:
  - packages/collapse/src
  - packages/collapse/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Collapse
> Animated show and hide by height (`max-height` transition), safe for nested collapses.

## What it does
On expand it moves `max-height` from 0 to the content's `scrollHeight`, then to `none` after `transitionend`, so content that grows later (or nested Collapses) isn't clipped. On collapse it goes from the pixel height to 0 one tick later. There's no animation on the initial mount. It sets `aria-hidden={!expanded}`, and `overflow: hidden` while collapsed.

## Public API
`Collapse`, plus types `CollapseProps` and `CollapseOwnProps`.
| Prop | Default |
|---|---|
| `expanded` (required) | — |
| `withTransition` | `true` |
| `className`, `style`, `children` | |

## Usage
```tsx
<Button onClick={() => setOpen(!open)}>Details</Button>
<Collapse expanded={open}>…</Collapse>
```

## Depends on
[[passport-utils]] (`useIsomorphicLayoutEffect`, `usePrevious`).

## Used by
- Through the umbrella `@tiket/passport`: TIX-NEXT-PAYMENT-FE (6 files, e.g. `components/CollapsibleCard/CollapsibleCard.tsx`, `components/Installment/index.tsx`; [[payment-fe-components]]) and TIX-FINTECH-NEXT-FE (3 files, e.g. `projects/insurance/shared/components/CollapsibleCard`).
- Internal: 7 packages ([[passport-accordion]], [[passport-card]] stories, gift-voucher-claim-widget, info-banner, mission-landing-page, notification-banner, search-form-display).

## Gotchas
- Children stay mounted when collapsed. They're only hidden, so effects and queries inside keep running.
- Only `className`, `style` and `children` reach the DOM. Other `div` props in the type (e.g. `id`, `onClick`) are dropped.

## Sources
- `packages/collapse/src/Collapse.tsx`
- `packages/collapse/package.json`
