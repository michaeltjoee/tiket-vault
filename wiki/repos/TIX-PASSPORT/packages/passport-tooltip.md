---
title: Tooltip
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-tooltip"
sources:
  - packages/tooltip/src
  - packages/tooltip/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Tooltip
> A dark tooltip with an arrow that appears on hover or focus of its children. It has 12 placements, can render in place or through a portal, and narrows itself when it would overflow the viewport.

Part of [[passport-packages]].

## What it does
`Tooltip` wraps `children` in a reference `div`. In uncontrolled mode, mouse-over or focus shows it, and blur or mouse-leave of the whole wrapper (tooltip included) hides it. Passing `isVisible` makes it fully controlled and turns off all those handlers. Position is computed from bounding rects after the tooltip mounts, and applied as a `translate`. It is relative to the wrapper with `renderTarget="attachToElement"`, or to the document with `"portal"` (via [[passport-portal]], recomputed on window scroll). The maximum width is 280 px. For side and corner placements, if the tooltip would overflow the viewport it shrinks (keeping an 8 px gap, minimum 100 px), and it renders a second time to fix its vertical position. String `content` is rendered as inverted `b3` text, and elements are rendered as-is.

## Public API
`Tooltip`; type `TooltipProps`.
| Prop | Notes |
|---|---|
| `content` | `string` or element |
| `placement` | `up`, `up_left`, `up_right`, `down`, `down_left`, `down_right`, `left`, `left_top` (default), `left_bottom`, `right`, `right_top`, `right_bottom` |
| `offset` | extra gap in px beyond the 5 px arrow (typed as required, default 0) |
| `renderTarget` | `attachToElement` (default) or `portal` |
| `isVisible` / `onVisibilityChange` | controlled mode, or a callback in uncontrolled mode |
| `tooltipClassName`, `contentClassName` | wrapper and bubble classes |
| rest | spread onto the reference `div` |

## Usage
```tsx
<Tooltip content={popupDescription ?? ''} offset={5} placement="right_top">
  <IconInfo size="xs" />
</Tooltip>
```
(from TIX-NEXT-PAYMENT-FE `components/PriceDetailV4/index.tsx`)

## Depends on
[[passport-portal]], [[passport-typography]]. `@tiket/passport-utils` is declared.

## Used by
- TIX-NEXT-PAYMENT-FE, through the umbrella `@tiket/passport`: `components/PriceDetailV4`, `components/PaymentTile`, `components/Groups/.../PaymentGroup` ([[payment-fe-components]]) and `app/payment/components/InfinityTiketPoints` ([[payment-fe-payment]]).
- TIX-FINTECH-NEXT-FE: `projects/insurance/shared/components/PriceDetails` and the refund estimated-amount components ([[fintech-fe-refund]]).
- Indirectly through [[passport-header]] (the global-search tooltip), and so through [[react-remote-header]].
- Internal: [[passport-header]], [[passport-mission-landing-page]], [[passport-product-card]], and the umbrella.

## Gotchas
- The bubble has `data-disable-a11y`, which opts it out of the accessibility font scaling handled by [[passport-utils]].
- In-place mode (`attachToElement`) positions the bubble relative to the wrapper. An ancestor with `overflow: hidden` clips it, so use `portal` inside scroll containers and cards.
- Hover-only: there's no tap-to-toggle on touch devices beyond the focus event. For mobile, control it with `isVisible`.
- `up` and `down` aren't overflow-corrected.

## Sources
- `packages/tooltip/src/Tooltip.tsx`, `packages/tooltip/src/utils.ts`
- `packages/tooltip/package.json`
