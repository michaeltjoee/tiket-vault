---
title: Remote Wrapper and PassportWrapper
repo: TIX-REACT-REMOTE
kind: component
sources:
  - src/components/wrapper
verified_at: 281778b
updated: 2026-10-16
status: current
tags: [repo/react-remote, kind/component]
---

# Remote Wrapper and PassportWrapper
> Internal shells that every exposed remote renders inside. Not exposed itself (absent from `exposes.config.js`).

## What it does
- **`Wrapper`** (`wrapper/index.tsx`): a `div` with `data-react-remote-version` (the react-remote `package.json` version) and `data-react-remote-component-key`. Use these attributes in DevTools to see which remote version a page is actually running.
- **`PassportWrapper`** (`wrapper/PassportWrapper/index.tsx`): wraps children in `PassportProvider` from [[passport-utils]] and `ForwardParamsProvider` from [[react-common-utilities]], inside a `div` with the scoped `.passport` CSS class. It provides:
  - `locale` (from `lang`), `country`, `currency`, `isNewURLStructure`, `abTestOnServerResponse`, `dataLayer`, `isLoggedIn` (default `false`), `wishlistData`.
  - `customFetch`: wraps [[react-common-fetch-client]] `fetchClient` and forces `credentials: 'include'`, so Passport components call tiket APIs with the user's cookies.
  - `pathOrSearch` for ForwardParamsProvider, set to `window.location.search` after mount. It is empty during SSR on purpose.
- On import it injects a `<style id="passport-icon-color-vars">` with `:root` icon and font color variables.

## Public API
Internal. Props are listed above; see `CommonComponentProps` in `src/types.ts`.

## Depends on
[[passport-utils]], [[passport-design-tokens]] (`variables.css`), [[react-common-utilities]], [[react-common-fetch-client]].

## Used by
Every component in [[react-remote-architecture#Exposed modules]]. [[react-remote-scripts]] uses only `Wrapper`.

## Gotchas
- **Do not remove the injected `:root` style block.** [[passport-portal]] renders modals into `document.body`, outside the `.passport` scope. Without these `:root` values, icons using `fill="var(--icon-color-high-emphasis)"` turn invisible. The hard-coded hex values must be kept in sync with [[design-tokens]] by hand.
- [[react-remote-google-one-tap]] passes the wrong `componentKey` (`global-popup`).

## Sources
- src/components/wrapper/index.tsx
- src/components/wrapper/PassportWrapper/index.tsx
- src/types.ts
