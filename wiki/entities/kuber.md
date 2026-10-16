---
title: Kuber (banner and price-template rules backend)
kind: entity
repos: [TIX-PASSPORT, TIX-REACT-COMMON]
sources:
  - TIX-PASSPORT/packages/kuber-price-dynamic-banner
  - TIX-PASSPORT/packages/pricing-promo/src/components/pricing-display/store.ts
  - TIX-REACT-COMMON/packages/react-common-core-attributes/src/utils/getTagParams.ts
verified_at:
  TIX-PASSPORT: 7a33010aca
  TIX-REACT-COMMON: 14597c4e
updated: 2026-10-16
status: current
tags: [kind/entity, repo/passport, repo/react-common]
---

# Kuber
> Kuber (`tix-kuber`) is a rules backend that decides which banner or price layout to show where, by rule, layer, priority, funnel and placement. Passport has two clients for it. Its source is not in this workspace.

## Endpoints seen in the FE
| Endpoint | Client | What it returns |
|---|---|---|
| `POST /tix-kuber/v2/rule/evaluate` | the caller, per the [[passport-kuber-price-dynamic-banner]] README. The package itself only renders. | `BannerEvaluateResponseItem[]`: banner type (`INFO`, `NOTIFICATION`, `ACTION`, `GRADIENT`, `VOUCHER`, `PRICE_HISTORY`), localised text, colours, placement, countdown, actions |
| `GET /tix-kuber/v1/price-module-templates` | [[passport-pricing-promo]] `PricingDisplay` store | server-defined price-block templates per `verticalId`, revalidated with `ETag` and cached in memory and IndexedDB for up to 24 h |

## Notes
- Banner tracking uses `eventCategory: kuberBanner` with the rule name, layer, funnel and placement from the response ([[gtm-datalayer-tracking]]).
- Banner colours come as token names and go through the colour mappers in [[passport-design-tokens]] ([[design-tokens]]).
- A `tag_kuber` URL parameter is one of the `tag_*` params that [[react-common-core-attributes]] collects and forwards. How Kuber uses it is not visible in these repos.
- No app in this workspace imports either package directly on its baseline. Consumers are verticals outside the workspace.

## Where it shows up
Pages that link here:
- TIX-PASSPORT: [[passport-kuber-price-dynamic-banner]]

## Sources
- TIX-PASSPORT `packages/kuber-price-dynamic-banner/{README.md,src/types/BannerConfig.ts,src/DynamicBanner.data.ts}`, `packages/pricing-promo/src/components/pricing-display/store.ts`
- TIX-REACT-COMMON `packages/react-common-core-attributes/src/utils/getTagParams.ts`
