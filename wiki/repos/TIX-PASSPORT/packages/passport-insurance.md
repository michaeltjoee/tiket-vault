---
title: Insurance
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-insurance"
sources:
  - packages/insurance/src
  - packages/insurance/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Insurance
> Insurance product cards (`InsuranceProtectionCard`) and a self-contained cross-sell carousel widget (`InsuranceProtection`) that adds a protection to the standalone insurance cart and redirects to checkout.

Part of [[passport-packages]].

## What it does
`InsuranceProtectionCard` renders one or more insurance products from the backend `ProtectionResponseData`. When `controls` is present, the products sit behind [[passport-tabs]], one tab per control image and label. Each product shows a logo, title, benefit list, price (formatted with `createCurrencyFormatter`, default currency from `constants.ts`), an optional nudge banner and an optional [[passport-countdown]]. An Add/Cancel button toggles `isAdded`. When the countdown ends, the card disables itself and can show an "expired" [[passport-dialog]] (`withCountdownDialog`). Clicking details navigates to `pdpPath` with forwarded params.

`InsuranceProtection` (ProtectionSection) wraps a list of cards in the page-module `Carousel` from [[passport-page-module-shared]], with a title and a "see all" action. In `live` mode, "add" POSTs `insuranceData` plus the chosen product to `/ms-gateway/tix-insurance-core/insurances/standalone/cart` and then calls `window.location.assign(redirectPath)`. On failure it shows an error state with `onReload`. `preview` mode disables the call. It shows a skeleton while `isLoading`, and an expired state once a countdown runs out.

## Public API
| Export | Notes |
|---|---|
| `InsuranceProtectionCard` | `ProtectionCardProps`: `controls`, `contents`, `addedItem` (productIds), `loadingId`, `withCountdownDialog`, `onAdd(tabIndex, data)`, `onClickDetails(tabIndex, data)`, `onCountdownEnd`, `onReload` |
| `InsuranceProtection` | `ProtectionSectionProps`: `mode` (`live`/`preview`), `isLoading`, `title`, `actionText`/`actionLink`/`actionPath`, `data: ProtectionCardProps[]`, `insuranceData` (`orderId`, `title`, `totalPax`), `additionalTrackers`, `visibleItems`, `isMobile`, `onReload` |
Types: `ProtectionCardData` (one product: `productId`, `productName`, `logo`, `benefitList`, `price`, `priceSuffix`, `nudge`, `countdown`, `pdpLink`/`pdpPath`, `tracker`, …), `ProtectionCardProps`, `ProtectionResponseData`.

## Usage
```tsx
<InsuranceProtectionCard
  {...productGroup}
  addedItem={selected.map((s) => s.productId)}
  onAdd={(tabIndex, card) => toggle(card)}
  onClickDetails={(tabIndex, card) => trackDetails(card)}
/>
```

## Depends on
[[passport-tabs]], [[passport-card]] (`CardWithNudge`), [[passport-countdown]], [[passport-dialog]], [[passport-button]], [[passport-divider]], [[passport-content-loader]], [[passport-page-module-shared]] (`Carousel`, `VisibleItemsProps`), [[passport-typography]], [[passport-icons]], [[passport-assets]], [[passport-design-tokens]], [[passport-utils]]; [[react-common-utilities]] (`createCurrencyFormatter`, `getCommonHeaders`). Backend: [[tix-insurance-core]].

## Used by
- TIX-FINTECH-NEXT-FE: [[fintech-fe-insurance-standalone]]. `projects/insurance/standalone/search/components/Insurances` renders `InsuranceProtectionCard`, and `shared/lib/types/standalone/srp.ts` re-uses `ProtectionResponseData`.
- Internal: nothing, not even the umbrella `@tiket/passport`. Import it by its own name.

## Gotchas
- With `customFetch` in the Passport context, the cart call goes to the bare path `/tix-insurance-core/...`. Without it, the call is prefixed with `/ms-gateway` (and `https://gatotkaca.tiket.com` on `local.tiket*` hosts).
- The card copies `isAdded`/`isDisabled` into local state and re-syncs it when the props change. A countdown expiry sets them locally, and the parent isn't told except through `onCountdownEnd`.
- The widget's GTM trackers use `additionalTrackers` (screen name, vertical, event labels per content). In `live` mode the types expect it in full.

## Sources
- `packages/insurance/src/index.ts`
- `packages/insurance/src/components/ProtectionCard/ProtectionCard.tsx`, `packages/insurance/src/components/ProtectionCard/types.ts`
- `packages/insurance/src/widgets/ProtectionSection/ProtectionSection.tsx`, `packages/insurance/src/widgets/ProtectionSection/types.ts`, `packages/insurance/src/widgets/ProtectionSection/hooks/useProtection.ts`, `packages/insurance/src/widgets/ProtectionSection/services/post-cart.ts`, `packages/insurance/src/widgets/ProtectionSection/utils/common.ts`
- `packages/insurance/package.json`
