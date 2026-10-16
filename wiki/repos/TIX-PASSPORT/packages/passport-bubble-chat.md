---
title: Bubble Chat
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-bubble-chat"
sources:
  - packages/bubble-chat/src
  - packages/bubble-chat/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Bubble Chat
> Presentational chat message bubble with left or right alignment and an optional attachment.

## What it does
It renders `children` as `b2` text in a bubble. `primary` uses inverted text on the brand colour and `secondary` uses high-emphasis text. A string `attachment` ending in an image extension renders as `<img>`. Any other attachment value renders as given. There's no state and no logic beyond that.

## Public API
`BubbleChat`, plus types `BubbleChatProps`, `Alignment` (`right | left`), `Variant` (`primary | secondary`).
| Prop | Default |
|---|---|
| `variant` | `primary` |
| `alignment` | `right` |
| `bold`, `italic` | — |
| `attachment` | `JSX.Element \| string \| null` |
| `className`, `children` | |

## Usage
```tsx
<BubbleChat alignment="left" variant="secondary" attachment="https://…/photo.jpg">
  Hi, how can we help?
</BubbleChat>
```

## Depends on
[[passport-typography]], [[passport-utils]]. Pairs with [[passport-chat-box]].

## Used by
- No consumers found in other repos on their baselines.
- Internal: none.

## Gotchas
- Not in the umbrella `@tiket/passport`. Install it directly.
- Exported type names `Variant` and `Alignment` are generic and clash easily with other packages' types. Alias them on import.

## Sources
- `packages/bubble-chat/src/BubbleChat.tsx`
- `packages/bubble-chat/package.json`
