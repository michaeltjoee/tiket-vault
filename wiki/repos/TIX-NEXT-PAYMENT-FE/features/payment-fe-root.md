---
title: app/(root) route group and app root files
repo: TIX-NEXT-PAYMENT-FE
kind: feature
sources:
  - app/(root)
  - app/layout.page.tsx
  - app/not-found.jsx
  - app/globals.scss
  - app/setup-react-cache-workaround.ts
verified_at: 9e92b20bb
updated: 2026-10-16
status: deprecated
tags: [repo/payment-fe, kind/feature]
---

# app/(root) route group and app root files
> `app/(root)/` holds only a leftover stylesheet. The App Router root lives in the files directly under `app/`.

## What it does
`app/(root)/` contains only `globals.scss`, which imports passport design tokens, the font loader and `styles/downpay-globals.scss`. It has no `layout`/`page`, and nothing on `origin/main` imports it. Its history (`git log -- "app/(root)"`) only goes back to the Next 14.2 migration (#1109), DownPay (#1155) and payment link (#1181) commits. It is a leftover; the live global styles are `app/globals.scss`.

The live App Router root files directly under `app/`:
- `layout.page.tsx`: async root layout. It runs `setupServerGlobals()` and reads `getMiddlewareData()` (`@tiket/next/server`), `getDevice()`, `getI18nDict()` and the `x-nonce` header. It renders `MSWInit`, `AppRouterProvider` and `ForterScript` (with the nonce), and sets the viewport (no user scaling, `themeColor #005ACC`).
- `not-found.jsx`: any App Router 404 does `redirect(HOME_URL, RedirectType.replace)`. It is a `.jsx` file because `jsx` is in `pageExtensions`.
- `globals.scss`: passport design tokens + font loader + `styles/payment-disable-text-selection-global.scss`.
- `setup-react-cache-workaround.ts`: `registerCache(cache)` from `@tiket/next/react-cache-workaround`. It is imported first in the layout.

## Routes & entry points
None of its own: `(root)` is a route group with no segments. The App Router routes are [[payment-fe-l]], [[payment-fe-payment-link]] and [[payment-fe-api]].

## Data & services
See [[payment-fe-architecture]] for `AppRouterProvider`.

## Key components
None.

## Tracking
None.

## Tests
`app/__tests__/layout.page.spec.tsx`, `app/__tests__/not-found.spec.tsx`.

## Gotchas
- Don't add styles to `app/(root)/globals.scss`. Nothing loads it.
- `styles/downpay-globals.scss` is loaded by `pages/global.scss` (Pages Router), which is where DownPay actually renders. App Router pages don't get it.

## Sources
- `app/(root)/globals.scss`
- `app/layout.page.tsx`, `app/not-found.jsx`, `app/globals.scss`, `app/setup-react-cache-workaround.ts`
