---
title: Shared components
repo: TIX-FINTECH-NEXT-FE
kind: feature
sources:
  - components
  - app/not-found.jsx
  - app/layout.page.tsx
  - pages/_app.page.tsx
verified_at: 5833b842
updated: 2026-10-16
status: current
tags: [repo/fintech-fe, kind/feature]
---

# Shared components
> Repo-wide UI and script components in root `components/`, imported as `@/components/*` by every team. Team-specific UI lives in `projects/{team}/shared/components` or `app/gift-card/components` instead ([[fintech-fe-architecture]]).

## What it does
Thin wrappers over [[passport-overview|passport]] primitives (responsive modal/bottom sheet, date/time pickers, image, error dialog) plus the script and provider components that the root layouts mount. `docs/storybook.md` says root components should stay UI-only, though no Storybook setup exists on the baseline.

## Components
| Component | What it is | Used by |
|---|---|---|
| `providers/AppProvider` | Pages Router provider stack (middleware data, locale, `PassportProvider` with `customFetch`, `ForwardParamsProvider`, `ReactRemoteProvider`, snackbar, device, analytics, React Query + hydration) | `pages/_app.page.tsx` |
| `providers/AppRouterProvider` | App Router provider stack, also runs `usePageVisitAnalytics` for `/gift-card` and `/insurance-claim` | gift-card, `(external)`, insurance-claim layouts |
| `CustomScripts/GTMScripts` | injects GTM bootstrap and `window` analytics attributes for a `vertical` (needs `NEXT_PUBLIC_GTM_ID` / `NEXT_PUBLIC_UA_TRACKING_ID`) | `_app`, all App Router route layouts |
| `CustomScripts/MiddlewareDataAppRouterScripts` | writes `middlewareData` into `window.__NEXT_DATA__.props.pageProps` under App Router | gift-card, `(external)`, insurance-claim layouts |
| `CustomScripts/ServiceWorkerScripts` | registers `NEXT_PUBLIC_SW_PATH` if set | `_app`, insurance-claim layout |
| `CustomScripts/MSWInit` | starts the MSW browser worker when `NEXT_PUBLIC_API_MOCKING=enabled` | `app/layout.page.tsx`, `_app` |
| `ErrorBoundary` | class boundary that logs via `createLogger('error-boundary')` + `standardizedLogData` and shows passport `ErrorView` | `_app` |
| `NotFound` | passport `Figure` with `tds_si_no_result`, copy by locale | `app/not-found.jsx` |
| `Image` | `next/image` wrapper: Lightroom loader for tiket Lightroom hosts (forces the high preset), fallback image on error, always `unoptimized`; also `initLightroomLoader(src, width)` | ~90 files across gift-card, insurance, refund |
| `ModalBottomSheetResponsive` | renders passport `BottomSheet` when `isMobile === true`, else `Modal` | gift-card, insurance claim center |
| `DatePicker`, `TimePicker` | dropdown + [[passport-picker]] desktop/mobile pickers for forms | gift-card checkout (`useDynamicForm`) |
| `GeneralErrorDialog` | passport `Dialog` with `tds_si_error_unknown`, primary button reloads | gift-card checkout |
| `StickyMobileHeader` | sticky title bar with left/right icons | `(external)` gift-card order |
| `Dot`, `Separator` | small layout primitives | insurance (claim center, shared, standalone) |

## Depends on
`@tiket/passport`, [[passport-picker]], `@tiket/passport-icons`, `@tiket/passport-assets`, `@tiket/next` (client, logger, types), [[react-common-remote]].

## Gotchas
- `MiddlewareDataAppRouterScripts` exists because code written for Pages Router reads middleware data from `window.__NEXT_DATA__` (client `standardizedLogData`, `app/error.page.tsx`, remote components). App Router has no `__NEXT_DATA__`, so each App Router layout must mount this script or that code silently gets `undefined`.
- `Image` sets `unoptimized` on every image to avoid CPU spikes from failed writes to `.next/cache` (Slack thread linked in the source). Don't rely on Next image optimization in this app.
- `ModalBottomSheetResponsive` treats `isMobile` `undefined` as desktop, so pass the device flag explicitly.
- `MSWInit` does not gate rendering on the worker being ready (that would blank SSR HTML), so the first client requests can race the mock worker.
- Tests: specs next to most components (`__tests__`, `*.spec.tsx`), including `providers/*.spec.tsx` and `CustomScripts/__tests__`.

## Sources
- `components/providers/AppProvider.tsx`, `components/providers/AppRouterProvider.tsx`
- `components/CustomScripts/{GTMScripts,MiddlewareDataAppRouterScripts,ServiceWorkerScripts,MSWInit}.tsx`
- `components/ErrorBoundary/index.tsx`, `components/NotFound/index.tsx`, `components/Image/Image.tsx`, `components/ModalBottomSheetResponsive/ModalBottomSheetResponsive.tsx`, `components/DatePicker/DatePicker.tsx`, `components/TimePicker/TimePicker.tsx`, `components/GeneralErrorDialog/GeneralErrorDialog.tsx`, `components/StickyMobileHeader/StickyMobileHeader.tsx`, `components/Dot`, `components/Separator`
- `app/not-found.jsx`, `app/layout.page.tsx`, `pages/_app.page.tsx`, `docs/storybook.md`
