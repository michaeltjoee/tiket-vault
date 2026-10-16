---
title: Gift card
repo: TIX-FINTECH-NEXT-FE
kind: feature
sources:
  - app/gift-card
  - lib/services/gift-card.ts
  - lib/mocks/handlers/gift-card.ts
  - components/providers/AppRouterProvider.tsx
  - .env.local.example
verified_at: 5833b842
updated: 2026-10-16
status: current
tags: [repo/fintech-fe, kind/feature]
---

# Gift card
> App Router flow to buy a tiket.com gift card for someone (landing → recipient form → sender form → payment) and to redeem a received code (scratch card → choose split → claim).

## What it does
- **Landing** (`/gift-card`): server-renders a CMS-like page from the backend (hero, occasion inventories, USP sections). Picking an occasion goes to checkout.
- **Checkout, step 1** (`/gift-card/checkout?occasion=`): recipient form. The fields come from backend `bookingForms` config and are rendered by `useDynamicForm` (react-hook-form + zod schemas in `checkout/schema`, passport inputs plus the repo's `DatePicker`/`TimePicker`). Submitting creates a cart and `router.push`es to `/gift-card/checkout/{cartId}?cs={cartSecret}`.
- **Checkout, step 2** (`/gift-card/checkout/[id]?cs=`): sender form, inventories and T&C (versioned by `bookingData.tncVersion`). Submit calls cart checkout and does a full `location.href` jump to `order.paymentUrl` (payment app, see [[payment-fe-overview]]). Missing `id`/`cs` or cart → `notFound()`.
- **Redeem** (`/gift-card/redeem/[code]`): server redirects guests to login (with forward params and the original URL as ref). Logged-in users get `RedeemPageContainer`: onboarding scratch/flip animation (`.lottie` assets), then `SplitVoucherContainer` to pick a split option (`voucherCount × amount`) and claim. After a successful claim it `router.replace`s with `?claimed=1`.
- The bought-card **order detail** page lives under the `(external)` route group: [[fintech-fe-external]].

## Routes & entry points
| Route | File |
|---|---|
| `/gift-card` | `app/gift-card/page.page.tsx` |
| `/gift-card/checkout` | `app/gift-card/checkout/page.page.tsx` → `containers/CheckoutFormContainer.tsx` |
| `/gift-card/checkout/[id]` | `app/gift-card/checkout/[id]/page.page.tsx` → `containers/SenderFormContainer.tsx` |
| `/gift-card/redeem/[code]` | `app/gift-card/redeem/[code]/page.page.tsx` → `containers/RedeemPageContainer.tsx` |
| layout | `app/gift-card/layout.page.tsx`: `AppRouterProvider`, `MiddlewareDataAppRouterScripts`, gift-card `I18nProvider`, `PageVisitTracker`, `ErrorProvider` + `CommonErrorHandler`, `GTMScripts vertical="giftCard"`, `RemoteScripts` |

Each page exports `generateMetadata` using `buildPathnameWithLocale` + `generateTiketMetadataAlternates` from `@tiket/next/server` (hreflang alternates).

## Data & services
All calls go to service `tix-gift-card` through `apiGateway: 'krakend-gateway-promo'` (`PROMO_GATEWAY`), not the default gateway.

| Endpoint (`/tix-gift-card/gift-card/v1/...`) | Used for | File |
|---|---|---|
| `page/landing` | landing content (server) | `services/server/landing-page.ts` |
| `inventories/search` | checkout inventories/config | `checkout/services/{server,client}/inventory.ts` |
| `carts` (POST), `carts/{id}` | create cart, cart details | `checkout/services/*/cart.ts` |
| `carts/{id}/orders` | checkout → `paymentUrl` | `checkout/services/client/cart.ts` |
| `page/tnc` | T&C by version | `checkout/services/*/tnc.ts`, `lib/services/gift-card.ts` |
| `booking/details/{code}` | redeem lookup (`isCritical`, `isMigrated`) | `redeem/services/client/redeem.ts` |
| `claim` (POST `{redeemCode, splitCount}`) | claim split vouchers | `redeem/services/client/redeem.ts` |
| `orders/details/{orderId}?orderHash=` | order detail | `lib/services/gift-card.ts` |

- React Query: `queries/useRedeemCode.ts` (`RQ_REDEEM_CODE`, `retry: false`, 5 min stale). `useMutateRedeemCode` (landing bottom-sheet redeem) seeds the same cache key so the redeem page doesn't refetch.
- Redeem error codes: `INVALID_REDEEMED_CODE_ERROR`, `SOFT_BLOCK_ERROR`, `ALREADY_REDEEMED_CODE_ERROR`, each with its own dialog in `redeem/[code]/components`.
- Errors: server pages wrap content in `SSRErrorBoundary error={response}`; when the response has `errorData` it renders nothing and pushes the error into `ErrorContext`, and `CommonErrorHandler` from [[react-common-error-handler]] shows it via `ssrAPIResponse` (no event dispatch, so no race). Client errors go through `useCentralError` (actions `RETRY_API`, back to `/gift-card`, login) or `useGeneralError`.
- i18n: `i18n/server.ts` (`registerI18n` from `@tiket/next/server`) and `i18n/client.ts` (`createI18nContext`), dictionaries `en.ts`/`id.ts`.
- MSW handlers for every endpoint (`checkout/mocks`, `redeem/mocks`, `mocks/`), aggregated in `lib/mocks/handlers/gift-card.ts`.

## Key components
`app/gift-card/components`: `GiftCardHeader`, `GiftCardFigure`, `GiftCardCode`, `GiftCardSombrero`, `HowToUse`, `DetailTermsAndConditions`, `BackConfirmDialog`, `NavigationBack`, `NavigationConfirmModal`, `SSRErrorBoundary`, `ErrorHandlerProvider`. Landing: `GiftHeroImage`, `OccasionSection`, `DynamicUspSection` (`STATIC_USP_BANNER` vs list), `RedeemButton`/`RedeemDialog`/`RedeemLoginDialog`. Checkout: `RecipientDynamicForm`, `Recipients`, `SenderDynamicForm`, `SenderTnc`, `GiftCardCarousel` (keen-slider), `ModalResponsivePrice`. Redeem: `CardFlipWrapper`, `RedeemGiftCardFigure`, `OnboardingRedeemGiftCard`, `SplitVoucherForm`, `GiftCardMessage`.

## Tracking
- `tracking/PageVisitTracker.tsx` fires page-visit events for exact paths: `/gift-card` (`visitGiftCard`, `giftCardLandingPage`) and `/gift-card/checkout` (`visitBookingForm`, `giftCardRecipientForm`), after stripping a `/{lang}-{country}` prefix. `tracking/helper.ts` adds new-URL-structure fields (`eventLabel` oldURL/newURL, `localeOnURL`, `localeOnPreference` from cookies, `localeOnDetection`, `localeOutput`).
- `AppRouterProvider` separately runs `usePageVisitAnalytics` for `^/gift-card` (vertical `giftCard`).
- Clicks/submits use `submitElement('giftCard', {...})` from `@/lib/gtm` (e.g. split voucher: `eventCategory: redeemGiftCard`, `eventLabel: giftCard:{count}x{amount}`).

## Tests
84 spec files colocated under `app/gift-card/**` (`__tests__`, `*.spec.tsx`), plus `layout.page.spec.tsx` and `page.page.spec.tsx`; MSW for API.

## Gotchas
- Not migrated: gift-card is the one team still keeping feature code in `app/` (alias `@gift-card/*` → `app/gift-card/*`); moving to `projects/gift-card` is pending ([[fintech-fe-architecture]]).
- Server actions for cart create/checkout were moved to client components; the old code is left commented in the page files "for reference".
- The cart secret travels in the `cs` query param; both steps need it.
- Recipient form state (`inventoryId`, `passengers`) persists in `sessionStorage` key `giftCard.checkout.formData` (`useCheckoutFormPersistence`) so going back from step 2 restores it, including the chosen template image (PR #427).
- Step 2 enforces login only when the cart says `loginRequired`; the backend can still reject checkout with `NON_LOGIN_NOT_ALLOWED`, which sends the user to login with the current URL as ref.
- `NEXT_PUBLIC_GIFT_CARD_ENABLED` is in `.env.local.example` but nothing reads it on the baseline.
- `RedeemPageContainer` renders `null` while loading or when there's no data; the desktop footer only shows after the onboarding step.

## Sources
- `app/gift-card/layout.page.tsx`, `app/gift-card/page.page.tsx`, `app/gift-card/constants/index.ts`
- `app/gift-card/checkout/page.page.tsx`, `app/gift-card/checkout/[id]/page.page.tsx`, `app/gift-card/checkout/[id]/containers/SenderFormContainer.tsx`, `app/gift-card/checkout/hooks/*`
- `app/gift-card/redeem/[code]/page.page.tsx`, `app/gift-card/redeem/[code]/containers/*`, `app/gift-card/redeem/services/client/redeem.ts`
- `app/gift-card/queries/useRedeemCode.ts`, `app/gift-card/services/server/landing-page.ts`, `app/gift-card/i18n/*`, `app/gift-card/tracking/*`, `app/gift-card/components/{SSRErrorBoundary,ErrorHandlerProvider}`
- `lib/services/gift-card.ts`, `lib/mocks/handlers/gift-card.ts`, `components/providers/AppRouterProvider.tsx`, `.env.local.example`
