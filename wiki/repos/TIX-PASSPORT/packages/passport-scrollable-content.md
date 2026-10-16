---
title: ScrollableContent
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-scrollable-content"
sources:
  - packages/scrollable-content/src
  - packages/scrollable-content/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# ScrollableContent
> Vertically scrollable box that adds top and bottom shadows while content overflows, with options for scrollbar side and hover-only visibility.

Part of [[passport-packages]].

## What it does
It wraps `children` in an overflow element and uses `useOverflow` from [[passport-utils]] to detect `hasOverflowTop` and `hasOverflowBottom`. It toggles the `shadow_top` and `shadow_bottom` classes, and the `scrollable` class when either is true. The container's height or max-height comes from your `className`. The scrollbar is on the left by default (`scrollBarOnTheRight` moves it), and `showScrollBarOnlyOnHover` hides it until hover in Chrome and macOS Safari.

## Public API
`ScrollableContent` (also in [[passport-umbrella]]); `ScrollableContentProps` = `div` props plus `className`, `overflowElementClassName`, `showScrollBarOnlyOnHover` (default false), `scrollBarOnTheRight` (default false).

## Usage
```tsx
<ScrollableContent className={styles.faq_answer /* max-height: 240px */} scrollBarOnTheRight>
  <div dangerouslySetInnerHTML={{ __html: answer }} />
</ScrollableContent>
```

## Depends on
[[passport-utils]] (`useOverflow`, `WithElementProps`), [[passport-typography]] (declared).

## Used by
- Inside TIX-PASSPORT: [[passport-seo]].
- No consumers in the other workspace repos.

## Gotchas
- The default scrollbar position is **left**. Pass `scrollBarOnTheRight` for the usual placement.

## Sources
- packages/scrollable-content/src/ScrollableContent.tsx
- packages/scrollable-content/package.json
