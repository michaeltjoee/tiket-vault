---
title: Chat Box
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-chat-box"
sources:
  - packages/chat-box/src
  - packages/chat-box/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Chat Box
> Pill-shaped auto-growing text input with a send/search button, for chat or AI-prompt style entry.

## What it does
It's a controlled `<textarea>` inside a clickable container. The textarea grows with content, and the container radius switches from 999px to 16px once it's taller than one line. The search button appears when there's a value or `status === 'loading'`. On submit it runs `validate(value)` if provided and stops if that returns false. Otherwise it calls `onClickSearch`, then clears the value by calling `onChange` with `{ target: { value: '' } }`. Clicking outside deactivates the outline.

## Public API
`ChatBox`, plus types `ChatBoxProps`, `ChatBoxStatus` (`loading | static`), `outlineProps` (`GB100 | default | none`), `TextAreaProps`.
| Prop | Notes |
|---|---|
| `value`, `onChange` | controlled. `onChange` receives a fake event on reset |
| `placeholder` | |
| `searchIcon` (required), `icon` | cloned with size and colour defaults |
| `status` | `loading` shows the button with the high-emphasis colour |
| `outline` | active-state border style |
| `disabled`, `validate(value)`, `onClickSearch()` | |

## Usage
```tsx
<ChatBox
  value={q} onChange={(e) => setQ(e.target.value)} placeholder="Ask anything"
  icon={<IconSparkle />} searchIcon={<IconSendOval />} status={busy ? 'loading' : 'static'}
  onClickSearch={() => send(q)}
/>
```

## Depends on
[[passport-icons]], [[passport-typography]], [[passport-utils]]. Pairs with [[passport-bubble-chat]].

## Used by
- No consumers found in other repos on their baselines.
- Internal: none.

## Gotchas
- `onClickSearch` takes no argument. Read the current value from your own state before the component clears it.
- Enter in the textarea inserts a newline. It doesn't submit. Only the button submits.
- Not in the umbrella `@tiket/passport`.

## Sources
- `packages/chat-box/src/ChatBox.tsx`, `src/components/StaticPlaceholderInput.tsx`
- `packages/chat-box/package.json`
