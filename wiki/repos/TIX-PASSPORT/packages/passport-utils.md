---
title: Utils
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-utils"
umbrella: true
sources:
  - packages/utils/src
  - packages/utils/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Utils
> The shared runtime under every Passport component: the `PassportProvider` context (locale, currency, breakpoint, accessibility, environment, customFetch, wishlist), plus small hooks, timing helpers, body-scroll lock, HTML sanitising and recent-search helpers.

Part of [[passport-packages]].

## What it does
`PassportProvider` holds app-level settings that components read with `usePassport()`. Wrap the app in it once. What it computes:
- **breakpoint**: `{ mobile, desktop }`, from `matchMedia('(min-width: 840px)')` (throttled resize). It is seeded from `ssrEstimatedDeviceType` so the first SSR render can already pick a layout. With no estimate, both values are `false` until the client measures.
- **isAccessibilityOn**: `true` unless the rollout flag `ff-is-accessibility-support-enabled` is `off` (read through [[react-common-ab-test]] from `abTestOnServerResponse`). When on, children get an `accessibility_changes` wrapper class. In iOS and Android webviews (cookie `device_type`) it copies the app's `--font-scale` on `<html>` to `--dynamic-type-scale` and watches for changes. This drives [[passport-accessibility-font-scaling]].
- Defaults: `locale` `id`, `currency` `IDR`, `country` `id`, `environment` `production`.

## Public API
| Area | Exports |
|---|---|
| Context | `PassportProvider`, `PassportContext`, `usePassport`, `getCookie`, `COOKIE_KEY_DEVICE_TYPE`, `DEFAULT_PASSPORT_ENV`; types `PassportContextValue`, `PassportProviderProps`, `PassportLocale` (`en`/`id`), `PassportCountry`, `PassportCurrency` (16 codes), `PassportEnvironment`, `WishlistDataType`, `Wishes`, `Snackbar`, `SnackbarOptions`, `SnackbarType` |
| Provider props | `locale`, `currency`, `country`, `ssrEstimatedDeviceType`, `environment`, `customFetch` (packages use it instead of `fetch` and then skip the `/ms-gateway` prefix), `abTestOnServerResponse`, `wishlistData` (see [[passport-wishlist]]), `dataLayer`, `isLoggedIn`, `isNewURLStructure`, `value` (deprecated) |
| Hooks | `useMounted`, `usePrevious`, `useIntersected`, `useMountTransition`, `useOverflow` / `useOverflowHorizontal`, `useIsomorphicLayoutEffect`, `usePassportEnvironment`, `useForwardParams` + `ForwardParamsProvider` (re-exported from [[react-common-utilities]]), `usePreventScroll` / `getPreventScrollCount` |
| Helpers | `debounce`, `throttle`, `capitalize`, `trimNumber`, `copyTextToClipboard`, `constructFullUrl` / `isFullUrl` / `BASE_URL`, `sanitizeHtml` (isomorphic DOMPurify), `isHtmlString`, `ClientSideOnlySuspense` |
| Types | `WithElementProps<Own, 'div'>` (own props plus the element's props minus the overlapping keys) |
| Recent search | `saveRecentSearch` (also POSTs to `/tix-global-search/recent-search`), `getLocalStorageRecentSearch`, `updateLocalStorageRecentSearch`, `clearLocalStorageRecentSearch`, `validateIsLogin`, `NON_LOGIN_RECENT_SEARCH_ACCOUNT_ID`, recent-search types |

## Usage
```tsx
<PassportProvider locale={lang} currency={currency} ssrEstimatedDeviceType={isMobileUA ? 'mobile' : 'desktop'}
  environment={env} abTestOnServerResponse={abTest} customFetch={apiFetch}>
  <App />
</PassportProvider>

const { breakpoint, locale, isAccessibilityOn } = usePassport();
```

## Depends on
[[passport-assets]], [[react-common-ab-test]] (`AbTestOnServerResponse`, rollout), [[react-common-utilities]] (forward params); `@react-aria/utils`, `isomorphic-dompurify`.

## Used by
- TIX-REACT-REMOTE: [[react-remote-wrapper]] (`PassportWrapper` sets up `PassportProvider` for every remote), [[react-remote-header]] (`PassportCurrency` type), [[react-remote-reviews]].
- TIX-NEXT-PAYMENT-FE: about 18 files under `app/` and `components/`, mostly `useMountTransition` for dialogs (e.g. `DialogWithMountTransition`), plus `.storybook/preview.tsx` ([[payment-fe-payment]], [[payment-fe-components]]).
- TIX-FINTECH-NEXT-FE: [[fintech-fe-gift-card]] (`SenderLayoutWrapper`, `RecipientCard`, `BackConfirmDialog`).
- TIX-REACT-COMMON: [[react-common-error-handler]] mocks it in tests and the README.
- Internal: 124 packages list it as a runtime dependency, more than any other Passport package. Every component reads the context.

## Gotchas
- `breakpoint` is `{ mobile: false, desktop: false }` during SSR without `ssrEstimatedDeviceType`, and components that branch on it (e.g. [[passport-header]], [[passport-image-preview]]) fall back to desktop. Pass the estimate to avoid a layout shift.
- `constructFullUrl` returns the path unchanged when `environment` is unset. Local, development and staging all map to `gatotkaca.tiket.com`.
- `usePreventScroll` is a patched copy of react-aria's (`NOTE-PASSPORT` comments mark the changes). It reference-counts locks across all open overlays.
- `useBreakpoint` and `useRollout` are internal and not exported.

## Sources
- `packages/utils/src/index.ts`, `packages/utils/src/context.tsx`, `packages/utils/src/useBreakpoint.ts`, `packages/utils/src/useRollout.ts`
- `packages/utils/src/constructFullUrl.ts`, `packages/utils/src/types.ts`, `packages/utils/src/body-scroll-lock.ts`, `packages/utils/src/sanitizeHtml.ts`, `packages/utils/src/ClientSideOnlySuspense.tsx`
- `packages/utils/src/recentSearch/`, `packages/utils/package.json`
