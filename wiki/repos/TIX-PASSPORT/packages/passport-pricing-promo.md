---
title: Pricing & Promo
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-pricing-promo"
sources:
  - packages/pricing-promo/src
  - packages/pricing-promo/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Pricing & Promo
> Shared pricing and promo building blocks for verticals: a server-templated `PricingDisplay`, a `PricingFilter` sheet, and the promo UI (`PromoSection`, `PromoList`, `PromoCard`) with helpers for promo API responses.

Part of [[passport-packages]].

## What it does
- **PricingDisplay** renders a price block from a **server-defined template**. Templates for a `verticalId` are fetched from `/tix-kuber/v1/price-module-templates`. They are cached in memory and in IndexedDB (`idb-keyval`), revalidated with ETag, max age 24 h by default, 5 s timeout, and up to 3 retries on 408, 429 or 5xx. While the first revalidation is in flight, the snapshot withholds templates and shows a skeleton. On a cold failure it falls back to `DEFAULT_PRICING_TEMPLATE` when the data supports it. Pass `templates` to skip fetching. The ref handle exposes `getValueByFieldId` and `getActiveTemplateKey`. `usePricingDisplayRefresh(verticalId)` forces a revalidation. Fetches use `customFetch` from `usePassport()`.
- **PricingFilter** is a bottom-sheet filter built from `groups` of type `GRID` / `CHIPS` / `TOGGLE` / `RADIO`. Linked groups appear only when their `parentId` option is selected. Working state stays internal until Apply, which emits `PricingFilterResult` (`{ [groupId]: optionId | boolean }`). Reset restores the `groups` defaults.
- **Promo**: `PromoSection` is the checkout entry point, with applied and not-applied variants and a "check other promos" CTA. `PromoList` is the full list sheet (best-promo banner, manual code input, T&C view). `PromoCard` is one promo. Helpers normalize the promo API (`transformPromoResponse`, `flattenGroupPromos`, `flattenSinglePromos`, `mapPromoToCardProps`, `configurePromoDisplay`, `resolveAppliedPromo`, `PROMO_STRUCTURE`). Popups use URL-hash navigation (`usePopUpNavigator`) unless `disablePopupHistory` is set. GTM trackers are configured through `trackerConfig`.

## Public API
See `src/index.ts`. Components: `PricingDisplay`, `PricingFilter`, `PromoSection`, `PromoList`, `PromoCard`. Hook: `usePricingDisplayRefresh`. Functions: `toPricingDisplayViewParam`, `ensureTemplates`, the promo helpers above, and the `PRICING_FONT_*` constants. Many types. [[passport-umbrella]] re-exports only `PricingFilter`, `PricingDisplay` and `usePricingDisplayRefresh`.

Key props:
- `PricingDisplayProps`: `verticalId`, `placement`, `dynamicPricingData`, `currency`, `templateKeys?`, `templates?`.
- `PromoListProps`: `data: PromoResponseData`, `onToggleApply(promo) => () => void|Promise`, `appliedPromoId`, `promoCode`, `manualCodeInput`, `isOpen`, `onClose`, `trackerConfig`, `refId`, `disablePopupHistory`. `PromoSection` adds `elevated` and `clientId`.

## Usage
```tsx
<PricingDisplay ref={priceRef} verticalId="HOTEL" placement="SRP_CARD"
  dynamicPricingData={pricing} currency={currency} />
<PromoSection data={promoData} appliedPromoId={applied} onToggleApply={(p) => () => apply(p)} />
```
Stories: `src/components/promo-journey/PromoJourney.stories.tsx` walks through the full promo flow.

## Depends on
[[passport-bottom-sheet]], [[passport-modal]], [[passport-card]], [[passport-chips]], [[passport-radio]], [[passport-toggle]], [[passport-form]], [[passport-countdown]], [[passport-qr-popup]], [[passport-snake-animation]], [[passport-content-loader]], [[passport-label]], [[passport-image]], [[passport-design-tokens]], [[passport-typography]], assets, icons, `@tiket/react-common-utilities`. External: `idb-keyval`, `@react-aria/utils`. Peer: [[passport-utils]], `react`.

## Used by
- No internal dependents and no consumers in the other workspace repos on baseline. It was added by PR #3502 ("Pricing & Promo Shared Components").

## Gotchas
- The template cache is per `verticalId` and module-global. Once a revalidation fails, `hasSessionFailure` stops automatic retries for the rest of the session. Use `usePricingDisplayRefresh` to retry manually.
- `sideEffects` also lists `*.gif`, unlike most packages.
- No README. Docs live only in the stories and tests.

## Sources
- packages/pricing-promo/src/index.ts
- packages/pricing-promo/src/components/pricing-display/PricingDisplay.tsx
- packages/pricing-promo/src/components/pricing-display/store.ts
- packages/pricing-promo/src/components/pricing-display/types.ts
- packages/pricing-promo/src/components/pricing-filter/types.ts
- packages/pricing-promo/src/components/promo-list/PromoList.tsx
- packages/pricing-promo/src/components/promo-section/PromoSection.tsx
- packages/pricing-promo/package.json
