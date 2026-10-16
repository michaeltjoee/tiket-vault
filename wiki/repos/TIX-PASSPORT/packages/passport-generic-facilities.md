---
title: Generic Facilities
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-generic-facilities"
sources:
  - packages/generic-facilities/src
  - packages/generic-facilities/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Generic Facilities
> "Passengers & facilities" section for order-detail pages (flight, hotel, train, car, bus, ferry, airport transfer). It's server-driven through the order composer's section API, with drill-down detail popups.

## What it does
`GenericFacilities` sets up dimension, full-page-loader and tracker contexts, then renders `EntryPoint`. It works either with **data passed in** (`GenericFacilitiesDataProps`, `data`) or with **order query params** (`orderId`, `orderDetailId`, `orderHash`). With params it fetches `GET {origin}/ms-gateway/tix-order-composer/yourorder/v1/section?sectionId=PASSENGERS_AND_FACILITIES&…` and fetches detail sections on demand. It renders pax/facility groups, action cards and buttons, and an adaptive popup ([[passport-bottom-sheet]] on mobile, [[passport-modal]] on desktop) with a stack navigator for nested detail screens. `enablePopupHistory` ties popups to browser history. `withAccordion` collapses groups. `src/mocks/` has entry-point mocks for each vertical.

## Public API
| Export | Notes |
|---|---|
| `GenericFacilities` | `orderType`, `orderStatus` (for tracking, required), plus either `data` or `{ orderId, orderDetailId, orderHash }`. Optional `customStyles`, `enablePopupHistory`, `withAccordion` |
| types (from `types/`) | `GenericFacilitiesDataProps`, `OrderQueryParams`, `PassengersAndFacilities`, `PassengersAndFacilitiesDetailSection`, `APIResponse`… |

## Usage
```tsx
<GenericFacilities orderType="FLIGHT" orderStatus="ISSUED" orderId={id} orderDetailId={detailId} orderHash={hash} enablePopupHistory />
```

## Data & services
- `fetch` with `credentials: 'include'` against **`window.location.origin` + `/ms-gateway`**. It doesn't use `customFetch` or `clientSideServiceEndpoint` (unlike [[passport-custom-fetch]]). Headers come from `getCommonHeaders` in `@tiket/react-common-utilities` ([[react-common-utilities]]).
- GTM through `hooks/useTracker.ts` and `utils/gtm.ts`, with `orderType` and `orderStatus` from context.

## Depends on
[[passport-accordion]], [[passport-assets]], [[passport-bottom-sheet]], [[passport-button]], [[passport-content-loader]], [[passport-dialog]], [[passport-divider]], [[passport-loading-indicator]], [[passport-label]], [[passport-icons]], [[passport-modal]], [[passport-page-module-shared]], [[passport-typography]], [[passport-utils]], `@tiket/react-common-utilities`.

## Used by
- No consumers found in the workspace repos on their baselines. The order-detail app ("yourorder") outside this workspace is the likely consumer.
- Internal: none.

## Gotchas
- It only works on a tiket.com origin that proxies `/ms-gateway`. On localhost or in Storybook, pass `data` instead.
- Not in the umbrella `@tiket/passport`.

## Sources
- `packages/generic-facilities/src/GenericFacilities.tsx`, `src/components/EntryPoint/EntryPoint.tsx`, `src/hooks/useGenericFacilities.ts`, `src/services/getSection.ts`, `src/types/*`
- `packages/generic-facilities/package.json`
