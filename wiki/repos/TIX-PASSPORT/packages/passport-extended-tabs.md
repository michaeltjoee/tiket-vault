---
title: Extended Tabs
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-extended-tabs"
sources:
  - packages/extended-tabs/src
  - packages/extended-tabs/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Extended Tabs
> Horizontally scrollable tab bar whose tabs carry a title, subtext and content line, e.g. date tabs with prices. It has desktop arrow navigation and auto-scroll to the selected tab.

## What it does
`ExtendedTabs` is controlled through `selectedIndex` and `onTabChange`. It clones each `ExtendedTabItem` child with the resolved `state` (`selected`, `unselected` or `disabled`) and its `onClick`. `useExtendedTabs` handles overflow detection, prev/next scrolling, and keeping the selected tab in view. A big index jump fades the bar out (0.15 s), jumps to an estimated position, then smooth-scrolls after the fade-in. That ordering works around an iOS WebKit bug where a smooth scroll during an opacity transition gets dropped. `unscrollable` makes tabs share the width equally.

## Public API
| Export | Key props |
|---|---|
| `ExtendedTabs` | `children`, `selectedIndex`, `onTabChange(index)`, `align: left \| center`, `unscrollable`, `showNavigation` (default true), `showNavigationOnHover`, `renderIcon` + `onIconClick` (trailing icon), `className`, `containerClassName` |
| `ExtendedTabItem` | `title`, `showTitle`, `subtext`, `showSubtext`, `content`, `state`, `fill`, `weight: { title, content }` (unselected weights; selected is always bold), plus `button` props |
| `useExtendedTabs` | the scroll and overflow logic, if you need a custom bar |
Types: `ExtendedTabsProps`, `ExtendedTabsAlignment`, `ExtendedTabItemProps`, `ExtendedTabItemState`, `ExtendedTabItemWeight`.

## Usage
```tsx
<ExtendedTabs selectedIndex={idx} onTabChange={setIdx}>
  {dates.map((d) => (
    <ExtendedTabItem key={d.key} title={d.day} subtext={d.date} content={d.price} state={d.soldOut ? 'disabled' : undefined} />
  ))}
</ExtendedTabs>
```

## Depends on
[[passport-button]], [[passport-icons]], [[passport-typography]], [[passport-utils]] (`useOverflow`).

## Used by
- No consumers found in other repos on their baselines. It's available through the umbrella.
- Internal: none.

## Gotchas
- Tab text uses `noAccessibilitySize`, so it doesn't scale with OS large text.
- Nav arrows have `tabIndex={-1}` and English aria-labels. Keyboard users move between tabs with roving `tabIndex` (only the selected tab is focusable).
- `.tabs_container` transition timing must match the JS fade constant in `useExtendedTabs.ts`.

## Sources
- `packages/extended-tabs/src/components/ExtendedTabs.tsx`, `src/components/ExtendedTabItem.tsx`, `src/useExtendedTabs.ts`
- `packages/extended-tabs/package.json`
