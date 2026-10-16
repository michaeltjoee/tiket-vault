---
title: Sidebar (My Account)
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-sidebar"
umbrella: true
sources:
  - packages/sidebar/src
  - packages/sidebar/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Sidebar (My Account)
> Desktop "My Account" sidebar: profile header (name, verified badge, loyalty tier, points with an expiring-points countdown) and the account menu (account, payment methods, reviews, wishlist, orders, point history, passengers, help center, settings).

Part of [[passport-packages]].

## What it does
It renders a fixed menu config. Links go through `withForwardParams`, and `activeMenu` highlights the current item: `/myaccount`, `/smart_pay`, `/myreview`, `/wishlist` (only when `wishlistEnabled`), `/yourorder`, `/myaccount/passengers`, `/help-center`, `/myaccount/settings`, plus point history and direct assistance. `useGetPointHistory` calls `/tix-loyalty-core/v1/point-extension/check` (through `usePassport().customFetch`) to show extendable points and their expiry, using [[passport-countdown]]. The bottom shows an Account Center (UNM) entry pointing at `accountCenterUrl`. It is hidden for B2B users and needs the URL. Menu clicks fire GTM (`useSidebarTrackers(screenName)`).

## Public API
`Sidebar` (also in [[passport-umbrella]]); types `SidebarProps`, `MenuId`, `TierType` (`LV1`–`LV4`).

| Prop | Notes |
|---|---|
| `activeMenu: MenuId` | `account`, `paymentMethod`, `yourReviews`, `yourOrders`, `pointHistory`, `savePassengersData`, `loyaltyPartners`, `helpCenter`, `settings`, `directAssistance`, `wishlist` |
| `fullName`, `tier`, `point`, `verified` | profile header |
| `screenName`, `eventLabel` | tracking |
| `hasAccountCenter` (default true), `accountCenterUrl`, `isUserB2b` | UNM account-center entry |
| `wishlistEnabled`, `hasQueryParamsDirectAssitance` (sic) | |

## Usage
```tsx
<Sidebar activeMenu="paymentMethod" fullName={name} tier="LV2" point={1200}
  verified screenName="smartPay" eventLabel="smartPay" accountCenterUrl={unmUrl} />
```

## Depends on
[[passport-badge]], [[passport-countdown]], [[passport-content-loader]], [[passport-logo]], [[passport-typography]], [[passport-utils]], assets, icons, `@tiket/react-common-utilities`. External: `uuid`.

## Used by
- TIX-NEXT-PAYMENT-FE (`^8.11.1`, direct dependency): `pages/smart_pay/index.page.tsx`, the saved payment methods page. See [[payment-fe-smart-pay]].
- TIX-FINTECH-NEXT-FE: `projects/refund/shared/components/Layout/components/LayoutWrapper/index.tsx`.
- Inside TIX-PASSPORT: no runtime dependents. [[passport-insurance]], [[passport-page-module]] and [[passport-page-module-collapse]] list it only as a devDependency (stories).

## Gotchas
- The prop name is misspelled: `hasQueryParamsDirectAssitance`.

## Sources
- packages/sidebar/src/Sidebar.tsx
- packages/sidebar/src/types/sidebar.ts
- packages/sidebar/src/services/get-point-history.ts
- packages/sidebar/package.json
