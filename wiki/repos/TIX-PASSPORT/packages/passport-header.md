---
title: Header
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-header"
sources:
  - packages/header/src
  - packages/header/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Header
> The tiket.com site header: desktop top bar plus verticals row, mobile app-style bar, and slim, booking-page and auto-hiding variants.

Part of [[passport-packages]].

## What it does
`Header` picks `HeaderDesktop` or `HeaderMobile`. `breakpoint` from `usePassport()` (see [[passport-utils]]) overrides the `device` prop when set. Both trees are wrapped in `desktop_only` / `mobile_only` CSS classes. Desktop renders a top row (co-brand logo, login/user menu, language and currency) and a lazily loaded `HeaderBottom` (logo, verticals, [[passport-global-search]], wishlist, messages) inside `Suspense`. Mobile renders left column (back button or logo, page title) and right column (search, promo, unread messages, hamburger menu bottom sheet). The mobile currency comes from the Passport context first, then `userData.currency`.

## Public API
Components: `Header`, `HeaderDesktop`, `HeaderMobile`, `BookingPageHeaderDesktop`, `SlimHeader` (logo only), `AutoHidingHeader` (fixed wrapper that shows its children after `scrollPxToShow`, default 48 px), `MobileBackButton`, `DeprecatedHeaderDesktop`. Static copy is exported from `data/` (default, `en`, `id`, multicurrency `en`/`id`). Types: `HeaderProps`, `HeaderDesktopProps`, `HeaderMobileProps`, `Verticals`, `Variant`, `LayoutVariantCode`, `Device`, `User`, `SlimHeaderProps`, `AutoHidingHeaderProps`, `BookingPageHeaderProps`.

| `HeaderProps` | Notes |
|---|---|
| `device` | `desktop` (default) or `mobile`; ignored when the context breakpoint is set |
| `variant` | `default` or `transparent` (no divider on desktop) |
| `isLogin`, `userData`, `unreadMessages` | user menu, PNV state, message badge |
| `verticals` | product row items (`Verticals[]`) |
| `layoutVariantCode` | `001` default, `002` no global search, `003` no search and no verticals, `004` transparent |
| `hideGlobalSearch`, `showGlobalSearchTooltip`, `wishlistEnabled`, `textAfterLogo`, `withDivider`, `activeMenu` | desktop |
| `showBackIcon`, `showSearchIcon`, `onSearchIconClick`, `pageTitle`, `rightIcons`, `hideLogo` | mobile |
| `isMultiCurrencyAvailable` | shows the currency picker |
| `dataLayer` | extra GTM fields for header tracking |
| `clientSideServiceEndpoint` | base URL the bottom row uses for client-side calls |
| `useDeprecatedHeader`, `hideBottom` | old desktop header only |

## Usage
```tsx
<Header
  isLogin={!!user}
  userData={user}
  verticals={verticals}
  isMultiCurrencyAvailable
  layoutVariantCode="002"
/>
```

## Depends on
[[passport-badge]], [[passport-bottom-sheet]], [[passport-button]], [[passport-card]], [[passport-container]], [[passport-content-loader]], [[passport-currency-bottom-sheet]], [[passport-country-and-currency-modal]], [[passport-language-and-currency-modal]], [[passport-dialog]], [[passport-divider]], [[passport-dropdown]], [[passport-global-search]], [[passport-icons]], [[passport-loading-indicator]], [[passport-modal]], [[passport-notification-banner]], [[passport-portal]], [[passport-radio]], [[passport-search-box]], [[passport-snackbar]], [[passport-tabs]], [[passport-tooltip]], [[passport-typography]], [[passport-utils]], [[passport-assets]]; [[react-common-utilities]]; `uuid`.

## Used by
- TIX-REACT-REMOTE: [[react-remote-header]], [[react-remote-header-mobile]], [[react-remote-header-slim]] and `src/utils/header`. These are the [[module-federation]] remotes most apps load instead of importing the package.
- TIX-REACT-COMMON: [[react-common-remote]] (`RemoteHeader/Fallback.tsx`, `RemoteHeaderMobile/types.ts`).
- TIX-FINTECH-NEXT-FE lists it in `package.json`.
- Internal runtime dependency of [[passport-insurance-pop-up]], [[passport-mission-landing-page]] and the umbrella `@tiket/passport`. [[passport-insurance]], [[passport-page-module]] and [[passport-page-module-collapse]] list it only as a devDependency, for stories.

## Gotchas
- `layoutVariantCode` values are spread **over** the props, so they win over `hideGlobalSearch`, `verticals` and `variant` that you pass.
- `hideBottom` only affects the deprecated desktop header. `hideRightColumn` is in `HeaderProps` but `Header` doesn't forward it; use `HeaderMobile` directly.
- `src/index.ts` lists most exports by name instead of `export *` because of a Parcel CSS-modules bundling bug ([[parcel-bundling]]).
- Desktop mounts its own `SnackbarProvider`.

## Sources
- `packages/header/src/Header.tsx`, `packages/header/src/types/Header.ts`, `packages/header/src/constants.ts`
- `packages/header/src/desktop/HeaderDesktop.tsx`, `packages/header/src/SlimHeader.tsx`, `packages/header/src/components/auto-hiding-header/AutoHidingHeader.tsx`
- `packages/header/src/index.ts`, `packages/header/package.json`
