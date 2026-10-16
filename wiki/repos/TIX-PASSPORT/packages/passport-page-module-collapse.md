---
title: PageModuleCollapse
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-page-module-collapse"
umbrella: true
sources:
  - packages/page-module-collapse/src
  - packages/page-module-collapse/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# PageModuleCollapse
> Wraps [[passport-page-module]] so that a leading `BANNER_GRID` with `interactionType: 'EXPAND_COLLAPSE'` renders as a collapsed strip. An "expand" button opens the rest of the modules in a portaled overlay panel.

Part of [[passport-packages]].

## What it does
It takes the same `data` as `PageModule`:
- If `data[0]` is **not** an expand/collapse `BANNER_GRID`, it renders a plain `PageModule` for all of `data`.
- Otherwise `data[0]` becomes the heading (`CollapseHeading`) with a `CollapseButton`. Expanding measures the heading's bounding rect, locks body scroll, shows an overlay in `#page-module-collapse`, and renders `PageModule` for `data.slice(1)` inside `CollapseContentPortal`. That inner `PageModule` gets `aboveTheFoldIndex=3`, `forceRender=false`, `enableContainerQueries` and `noBottomDivider`.

It re-measures on resize (rAF-throttled) and fires GTM impression, expand and collapse events (`trackPageModuleCollapse`).

## Public API
`PageModuleCollapse` (also in [[passport-umbrella]]). Props are all `PageModuleProps` plus:

| Prop | Default | Notes |
|---|---|---|
| `attributes: PageModuleCollapseAttribute` | required | `expandText`, `collapseText`, `expandIconUrl`, `collapseIconUrl`, `backgroundColor`, `textColor` |
| `withHeading` | `true` | when false, the panel starts below the heading instead of over it |
| `offsetTop` | `{mobile:0, desktop:0}` | minimum top, e.g. under a sticky header |
| `offsetBottom` | `48` | px kept free at the bottom |
| `portalId` | `'page-module-collapse'` | |
| `defaultExpanded` | `false` | auto-expands after 150 ms |
| `onExpand`, `onCollapse` | | |
| `carouselVisibleItems` | `{base:2, large…xxxlarge:4}` | |

## Usage
```tsx
<PageModuleCollapse data={modules} attributes={collapseAttrs}
  screenName="homepage" screenOwner="home" offsetTop={{ mobile: 56, desktop: 72 }} />
```
More examples: `stories/PageModuleCollapse.stories.tsx`.

## Depends on
[[passport-page-module]], [[passport-portal]], [[passport-utils]] (`useMountTransition`, `usePreventScroll`, `usePassport().breakpoint`), [[passport-typography]], assets, icons.

## Used by
- No consumers found in the other workspace repos. The homepage, outside this workspace, is the expected host.

## Gotchas
- Detection relies only on the first module's `templateCode` and `moduleDetail.interactionType`. The CMS ordering matters.
- It renders `CollapseButtonSprite` (inline SVG defs) for every instance.

## Sources
- packages/page-module-collapse/src/PageModuleCollapse.tsx
- packages/page-module-collapse/src/types.ts
- packages/page-module-collapse/package.json
