---
title: Refund (my-refund v4)
repo: TIX-FINTECH-NEXT-FE
kind: feature
sources:
  - pages/my-refund
  - pages/myorder/smart-refund
  - projects/refund
  - middleware.page.ts
  - next.config.js
verified_at: 5833b842
updated: 2026-10-16
status: current
tags: [repo/fintech-fe, kind/feature]
---

# Refund (my-refund v4)
> Pages Router flow under `/my-refund/v4/refunds/...` where a logged-in user requests a refund (or reschedule cashback) for an order, picks reason and passengers, chooses a refund method, confirms (optionally with OTP), and later tracks the refund.

## What it does
Steps share the path `/my-refund/v4/refunds/{orderId}/{orderDetailId}/{orderHash}/request/<step>` and move by string-replacing the last segment of `router.asPath`:
- `orderDetails` (component `ChooseReason`): order summary, refundability check, reason + passengers (`RefundForm`), estimated amount, reschedule nudges, related orders. Continues to `refundMethod`.
- `refundMethod`: method selection with [[passport-refund-method]] (`RefundMethodEstimation`), bank account/Juspay payout data, OTP when general config `SUBMIT_REFUND_OTP` enables it; also used for the reschedule-cashback variant.
- `refundPreview` → `refundConfirmation`: the V2 flow (`*V2` shared components, `previews/v2`, `e-refund/v2`). Nothing in this repo links into `refundPreview`; it's entered from outside (order pages in another app).
- Catch-all `/my-refund/v4/refunds/{requestHash}/...`: `track` in the path → `RefundDetailPage` (refund progress); `request` → `RefundMiddlewarePage` (verify a refund request hash and route on); anything else renders "Not found".
- `/myorder/smart-refund?order_id=&order_detail_id=&order_hash=` (email deeplink, `pages/myorder/smart-refund/index.page.tsx`): server redirect to `.../request/orderDetails`, keeping a `/{lang}-{country}` prefix and other query params; missing params → `/yourorder`.

## Routes & entry points
`pages/my-refund/v4/refunds/**/index.page.tsx` and `[...params].page.tsx` re-export `{ getServerSideProps, default }` from `@refund/{order-details,refund-method,refund-preview,refund-confirmation,catch-all}`. Each entry sets `Page.getLayout = getRefundLayout` (`shared/lib/layout/getRefundLayout.tsx`): `RefundI18nProvider`, `<Head>` meta, a webview bridge (`window.refreshRefundPage`, `window.hasPopup`, `window.closePopup` for the native apps), `DimensionProvider`, `SessionRequired`, `ErrorBoundary`, `Layout`. GSSP returns `middlewareData`, `device`, `vertical: 'refund'`, `dataLayer: { screenName }`.

Middleware ([[fintech-fe-architecture]]): refund path + `authResult=cancel|failed` → home (PLAT-38603); bare `/my-refund` or `/my-refund/v4` → `/yourorder` minus `utm_section`/`utm_logic`.

## Data & services
All endpoints are under `/tix-refund/external` (`API_ENDPOINT.REFUND_EXTERNAL`, `shared/lib/config.ts`), in `shared/lib/services/*` and `*/hooks`, wrapped as React Query hooks in `*/queries`:

| Area | Endpoints |
|---|---|
| order step | `refundable/{orderId}/{orderDetailId}`, `e-refund/order-review/...`, `refunds/previews?pageId=`, `infos/v2/...`, `price-matrix/...?reasonId=&currency=`, `refunds/payment-method/...`, `term-and-condition`, `refunds/popup` |
| estimation | `refunds/{orderId}/{orderDetailId}/estimation`, `refunds/estimation/v2/{orderId}`, `refunds/{requestHash}/estimation?isForceToBankTransfer=` |
| submit | `refunds/e-refund`, `refunds/e-refund/v2`, `refunds/b2b/draft`, `refunds/{endpointPath}` (OTP) |
| request/track | `refunds/{requestHash}/verify`, `refunds/{requestHash}/track` |
| reschedule | `reschedules/{orderId}/{orderHash}` (order review), `reschedules/{orderId}/{orderHash}/cashback` |
| documents | `refund-document/signed-url`, `/download/{id}`, `/delete/{id}` |
| config | `general-config?configName=` |

- State across steps: zustand stores in `shared/hooks` (`useRefundData`: device, errors, bank accounts, Juspay payout, method data, OTP flags; `useSubmissionData`: reason, preview, estimation, travelers). The stores are in memory only.
- Refund has its own fetch wrapper (`shared/lib/fetch`, `fetchClient` from `@tiket/next/client`), JWT helpers (`shared/lib/jwt`), i18n, device/webview detection via cookies `device_type`, `app_is_webview`, and UNM (account) login helpers (`NEXT_PUBLIC_UNM_URL`, `UNM_TIKET_CLIENT_ID`). Storage via [[react-common-storage]].

## Key components
~55 components in `projects/refund/shared/components`, many in V1/V2 pairs (`OrderDetail`/`OrderDetailV2`, `RefundFormV2`, `RefundMethodEstimation`/`V2`, `SubmitRefund`/`V2`, `DesktopRefundSummary`/`V2`, `BannerV2`…), per-vertical order cards (`OrderDetailFlight`, `Hotel`, `Train`, `Bus`, `Ferry`, `Car`, `AirportTransfer`, `TTD`, `Insurance`), `RefundProgress`, `FormOTP`, `ReasonPassengerDetail`, `OrderBreakdownDetail`. Step-local: `order-details/components/*`, `RescheduleCountdownTimer(V2)`, `refund-preview/components/Loader`.

## Tracking
`shared/hooks/useGTM.ts` (`pushGTMImpression`, `pushGTMClick`), `shared/lib/tracker/{GTM.ts,Analytics.tsx,helper.ts}` with `updatePageVisitTracker`; screen names `refundPolicy`, `refundReview`, `refundDetails`, `refundDeeplink`, `refundSSRR`, `rescheduleCashback`; tracking data cached in sessionStorage key `dataPlatform`.

## Tests
126 spec files across `projects/refund`, `pages/my-refund/__tests__` and `pages/myorder/smart-refund/index.spec.tsx`. `lib/test-utils-refund-providers.tsx` wraps refund providers for tests.

## Gotchas
- **Do not trigger hard navigations between steps**: the zustand store lives in memory, and a full reload loses the chosen reason/method. Next's client router bloom filter gave false positives on refund URLs (e.g. `/en/my-refund/v4/refunds/1200887827`) and forced hard navigations, so `next.config.js` sets `experimental.clientRouterFilter: false`.
- `SessionRequired` redirects guests client-side to `/login?ref=...` without a locale-country prefix, unlike the App Router helper.
- Step URLs are built by `asPath.replace('/orderDetails', '/refundMethod')` etc., so query strings and hashes carry over; `refundConfirmation` strips the hash when going back to `refundPreview`.
- `canvas` is aliased to `false` in webpack because a refund dependency pulls it in.
- Refund was migrated into `projects/refund` (see the commit-message examples in `.claude/rules/commit-messages.md`); it still keeps its own copies of infra (`fetch`, `jwt`, `i18n`, types) instead of the root `lib/`.

## Sources
- `pages/my-refund/v4/refunds/**`, `pages/myorder/smart-refund/index.page.tsx` (+ spec)
- `projects/refund/{catch-all,order-details,refund-method,refund-preview,refund-confirmation}/index.tsx`
- `projects/refund/shared/lib/{config.ts,layout/getRefundLayout.tsx,middlewares/refundRoutes.ts,fetch/fetch.ts}`, `projects/refund/shared/lib/services/*`, `projects/refund/shared/hooks/useRefundData.ts`, `projects/refund/shared/components/SessionRequired`
- `middleware.page.ts`, `next.config.js`
