---
title: External gift card order detail
repo: TIX-FINTECH-NEXT-FE
kind: feature
sources:
  - app/(external)/gift-card
  - lib/services/gift-card.ts
  - lib/types/entities
verified_at: 5833b842
updated: 2026-10-16
status: current
tags: [repo/fintech-fe, kind/feature]
---

# External gift card order detail
> The `(external)` App Router route group: the buyer-facing gift card order detail page at `/gift-card/order/detail`, with its own lighter layout.

## What it does
Shows a bought gift card order: delivery detail, card figure, each recipient with amount, message and redeem code, a share action (copy, WhatsApp, native share), and T&C. `(external)` is a Next route group, so it adds no URL segment; it exists to give this page a separate layout from the rest of [[fintech-fe-gift-card]] (no `ErrorProvider`/`CommonErrorHandler`, no `PageVisitTracker`). The layout comment says the two layouts could later share a base layout.

## Routes & entry points
| Route | File |
|---|---|
| `/gift-card/order/detail?orderId=&orderHash=` | `app/(external)/gift-card/order/detail/page.page.tsx` (RSC) |
| layout | `app/(external)/gift-card/layout.page.tsx`: `AppRouterProvider`, `MiddlewareDataAppRouterScripts`, gift-card `I18nProvider`, `GTMScripts vertical="giftCard"`, `RemoteScripts` |

Middleware treats it as an App Router path because it starts with `/gift-card` ([[fintech-fe-architecture]]).

## Data & services
- `getGiftCardOrderDetail(orderId, orderHash)` → `GET /tix-gift-card/gift-card/v1/orders/details/{orderId}?orderHash=` and `getGiftCardTnC(tncVersion)` → `page/tnc`, both in `lib/services/gift-card.ts` via `@/lib/fetch/app-router/server` with `apiGateway: 'krakend-gateway-promo'`.
- Response handling: `BUSINESS_ERROR` with `errorCode: LOGIN_REQUIRED` → renders `OrderLoginDialog`; any other non-`SUCCESS` → `notFound()`.
- `helper/order.ts#normalizeRecipient` joins `passengers` with `inventories[0].bookingItems` by `paxId`; passengers without a booking item are dropped.
- Types in `lib/types/entities/gift-card` (root `lib`, not `@gift-card`).

## Key components
`app/(external)/gift-card/order/components`: `OrderDetailClientComponent`, `DeliveryDetail`, `RecipientItem`, `ShareLink` (uses `shareFilesWithContent` from [[react-common-navigator-permission]] and `generateWhatsappURL`), `GiftCardTnC`, `Collapsible`, `OrderLoginDialog`, `OrderNavigationLayout`. Reuses `GiftCardFigure` and `GiftCardSombrero` from `@gift-card/components`.

## Tracking
`OrderDetailClientComponent` fires `impressionElement('giftCard', { eventCategory: 'bookingConfirmation', eventDescription: 'reservationDetail', screenName: 'giftCardOrderPage', paymentStatus })`, where `paymentStatus` maps `ISSUED` → Issued, `PAID` → On Process, anything else → Waiting for Payment. `clickElement` on share actions. The `giftCard` vertical is also handled in TIX-GTM-EXTRAS `scripts/helpers.js` (reads `gtm.giftCard.designName`).

## Tests
11 spec files under `app/(external)/gift-card`.

## Gotchas
- Only the first inventory (`inventories[0]`) is shown; an order with several inventories would lose the rest.
- The page does not validate that `orderId`/`orderHash` are present; it calls the API with whatever is in the query and relies on a non-SUCCESS → 404.

## Sources
- `app/(external)/gift-card/layout.page.tsx`
- `app/(external)/gift-card/order/detail/page.page.tsx`
- `app/(external)/gift-card/order/helper/order.ts`
- `app/(external)/gift-card/order/components/OrderDetailClientComponent/OrderDetailClientComponent.tsx`, `.../ShareLink/ShareLink.tsx`
- `lib/services/gift-card.ts`
- TIX-GTM-EXTRAS `scripts/helpers.js`
