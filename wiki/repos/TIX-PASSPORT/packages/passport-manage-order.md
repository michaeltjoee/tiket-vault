---
title: ManageOrder
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-manage-order"
umbrella: true
sources:
  - packages/manage-order/src
  - packages/manage-order/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# ManageOrder
> The "Manage order" action grid on order-detail pages (e-ticket, receipt, calendar, refund, reschedule, edit booking), driven by the order-composer section API.

Part of [[passport-packages]].

## What it does
It renders a titled row or column of action buttons from `listOfActions`. Clicking a known action:
1. shows a full-page loader,
2. pushes a GTM event, merging per-action `trackers` from the API with the `commonTrackers` prop,
3. after **1500 ms**, so the tracker request isn't aborted by navigation, calls `GET /tix-order-composer/yourorder/v1/section` with `orderId`, `orderHash`, `orderDetailId` and `sectionId`,
4. acts on the response: opens a URL, calls a native JSI in a WebView, or shows one of its own popups (choose multi-order item, e-ticket language, edit booking, section bottom-sheet dialog).

Known action ids are `OPEN_RECEIPT`, `OPEN_ETICKET`, `OPEN_CALENDAR`, `OPEN_EDIT_BOOKING`, `OPEN_REFUND`, `OPEN_RESCHEDULE`, the `*_MULTI_ORDER` variants and `OPEN_BOTTOMSHEET_SECTION`. Any other id goes to `onFallbackAction(actionId)`.

## Public API
Root exports: `ManageOrder` (memoized), all popup components (`ActionButton`, `AdaptivePopup`, `ChooseETicketLangPopup`, `ChooseMultiOrderItem`, `ChooseMultiOrderPopup`, `EditBookingPopup`, `LoadingFullPage`, `SectionModuleDialog`), `getSection`, all types, and the GTM helpers from `utils/gtm`. The umbrella [[passport-umbrella]] re-exports only `ManageOrder`.

Key `ManageOrderProps`: `title`, `listOfActions: ActionItem[]` (`{ id, title, subTitle?, iconUrl?, iconMenu?, isEnable?, action: { type, id, trackers? } }`), `orderDetailProps` (`orderId`, `orderHash`, `orderDetailId`, `orderType`), `commonTrackers`, `variant` (`horizontal`|`vertical`), `size` (`regular`|`sm`), `origin`, `onFallbackAction`, `disablePopupHistory`, `experimentHeaders` (forwarded to section API calls), `coachmarkClassName`.

## Usage
```tsx
<ManageOrder
  title="Manage Order"
  listOfActions={actions}
  orderDetailProps={{ orderId, orderHash, orderDetailId, orderType: 'FLIGHT' }}
  commonTrackers={{ vertical: 'flight' }}
  onFallbackAction={(id) => router.push(fallbackUrl(id))}
/>
```

## Depends on
[[passport-umbrella]] (`@tiket/passport` for `Text`, `Dialog`, `Radio`, `LoadingIndicator`, `usePassport`), [[passport-bottom-sheet]], [[passport-modal]], [[passport-radio]], [[passport-snackbar]], [[passport-typography]], [[passport-utils]], `@tiket/react-common-utilities` (`getCommonHeaders`) and `@tiket/react-common-navigator-permission` (see [[react-common-utilities]], [[react-common-navigator-permission]]).

## Used by
- No direct consumers found on the baselines of the other workspace repos. It is reachable through `@tiket/passport`, but no app grep hit `ManageOrder`. The order-detail pages that use it live outside this workspace.

## Gotchas
- **Circular package dependency:** it imports `@tiket/passport`, and the umbrella depends on `@tiket/passport-manage-order`. The same pattern exists in [[passport-search-widget-flight]] and [[passport-search-widget-ttd]].
- Popups use URL hash history. On mount it strips any existing `#hash` unless `disablePopupHistory` is set. Set it on pages that rely on hashes.
- Native behavior depends on WebView detection and the app-version / device-type cookies (`utils/webview.ts`, `utils/cookie.ts`).

## Sources
- packages/manage-order/src/ManageOrder.tsx
- packages/manage-order/src/hooks/useActionButton.ts
- packages/manage-order/src/hooks/useJSI.ts
- packages/manage-order/src/services/getSection.ts
- packages/manage-order/src/types/manage-order.ts
- packages/manage-order/package.json
