---
title: Bottom Tab Navigation
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-bottom-tab-navigation"
umbrella: true
sources:
  - packages/bottom-tab-navigation/src
  - packages/bottom-tab-navigation/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Bottom Tab Navigation
> Fixed mobile bottom nav bar (Home, My Orders, Rewards, Account…) rendered from a BE-provided `navigations` array.

## What it does
It renders one `<a>` per navigation item, with a Lightroom-resized icon (`rsfit4848gsm`), an optional [[passport-badge]] and a title. The active item comes from comparing `window.location` with the item's `link`, or from matching `initialPathname`. The active item gets the active icon and the `activity` text colour. Clicking pushes a GTM event and follows the link with forward params added.

## Public API
`BottomTabNavigation`, plus types `Navigation`, `NavigationIcon`, `NavigationBadge`.
| Prop | Default | Notes |
|---|---|---|
| `navigations: Navigation[]` | — | `{ code, link, title, icon: { active, inactive }, badge?: { content, color, isNotifShown } }` |
| `initialPathname` | `null` | forces the active item, which is useful during SSR |
| `withShadow`, `withFixedPosition` | `true`, `true` | |
| `customTrackersBottomBar` | — | extra fields merged into the click event |

## Usage
```tsx
<BottomTabNavigation navigations={navFromApi} initialPathname="/myaccount" />
```

## Tracking
On click it pushes `{ event: 'click', eventCategory: 'viewMainMenu', eventValue: 'bottomBar', variantName: 'homeResponsive', eventLabel: <code>, ...customTrackersBottomBar }` to `window.dataLayer`.

## Depends on
[[passport-assets]] (`overrideLightroomPreset`), [[passport-badge]], [[passport-typography]], [[passport-utils]] (`PassportContext.isNewURLStructure`, `useForwardParams`).

## Used by
- No direct imports in other repos. It's available through the umbrella `@tiket/passport`. The homepage app outside this workspace is the likely consumer.
- Internal: none.

## Gotchas
- Active detection reads `window.location`, so on the server no item is active unless you pass `initialPathname`. Pass it to avoid a hydration flash.
- `link` must equal one of `https://m.<host><path>`, `https://www.<host><path>`, `https://<host><path>` or `<path>` exactly. With `isNewURLStructure` the link goes through `withForwardParams`, and the query string and trailing slash are stripped before comparing.
- A badge renders only when the item has a `title`.
- `components/ImageRender.tsx` (with a JSON/Lottie fallback) isn't exported or used.

## Sources
- `packages/bottom-tab-navigation/src/BottomTabNavigation.tsx`, `src/utils/index.ts`, `src/trackers.ts`, `src/utils/gtm.ts`, `src/types.ts`
- `packages/bottom-tab-navigation/package.json`
