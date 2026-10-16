---
title: Saved payment methods (/smart_pay)
repo: TIX-NEXT-PAYMENT-FE
kind: feature
sources:
  - pages/smart_pay
  - lib/services/payment-methods.ts
  - lib/hooks/useSaveHistoryLength.tsx
  - lib/hooks/useCheckKromLinkageStatus.ts
  - components/OneKlik/index.tsx
  - components/AnalyticsProvider/index.tsx
  - next.config.ts
  - e2e/scenarios/smart_pay
verified_at: 9e92b20bb
updated: 2026-10-16
status: current
tags: [repo/payment-fe, kind/feature]
---

# Saved payment methods (/smart_pay)
> The member's saved payment methods page ("SPM"): list, link and unlink e-wallets, pay-later, OneKlik, saved cards and bank accounts, plus the callback page that third-party linking flows return to. Pages Router only.

## What it does
A member-only page that lists the user's saved and linkable payment methods, grouped as the backend returns them. From it the user can link OVO, GoPay, DANA, BLU, Kredivo and BCA OneKlik, save a credit card (with OTP), add or delete an ATM-transfer bank account, open a per-method detail page (balance or limit, T&C, top-up for OVO) and unlink. Users reach it from the tiket.com account menu (desktop `Sidebar` with `activeMenu="paymentMethod"`) and from the payment landing ([[payment-fe-payment]]), whose `components/OneKlik` sends the user to `/smart_pay?type=…&orderId&orderHash&paymentNewPageType` to set up OneKlik.

All code lives in `pages/smart_pay/` (pages, its own `components/` and a small `lib/`). It has no `app/` counterpart and no migration in progress (see [[payment-fe-architecture]]).

## Routes & entry points
| URL (after middleware locale rewrite) | File | Notes |
|---|---|---|
| `/smart_pay` | `index.page.tsx` | List page. `getServerSideProps` = `getServerSidePropsMiddlewareData` only. Wrapped in `withPaymentPageProvider`. Also handles legacy return params: `response` (OVO linkage JSON), `referenceId` (BLU, polls status each second up to `MAX_CHECK_PAYMENT_CHANCE`), `paymentCode=GOPAY&authCode`, and `*Disconnected=SUCCESS|…` snackbars after unlink. |
| `/smart_pay/{method}` | `[method]/index.page.tsx` | Detail page for `ovo`, `blu`, `gopay`, `kredivo`, `oneKlik` (OneKlik passes `id`, `acc`, `limit` in the query). For `method === 'dana'` it renders `DanaAccountDetailPage` instead. |
| `/smart_pay/{method}/binding` | `[method]/binding/index.page.tsx` | Callback target for third-party linking: `gopay`, `blu`, `dana`, `kredivo`, `ovo`, `creditcard`. Runs the matching callback in `binding/helper.ts` once, then `goBackToEntry()`. Not wrapped in `withPaymentPageProvider`; uses `createI18n(locale)` directly. |
| `/smart_pay/ovo/topUp` | `[method]/topUp/index.page.tsx` | OVO top-up menu from `/tix-payment-core/ovo/top-up`; items open partner URLs with `hideToolbar=false` added. |
| `/smart_pay/{method}/dana` | `[method]/dana.page.tsx` | Unintended route, see Gotchas. |

`next.config.ts` rewrites the legacy `/next/smart_pay/:method*` to `/smart_pay/:method*`. README lists the URL as `/{locale}/smart_pay` in both the old and new URL structure.

## Data & services
All calls go through `lib/services/payment-methods.ts` (`fetchClient`), mostly plain promises in `useState`/`useEffect`, not React Query. The newer DANA code is the exception (`lib/queries/useGetDanaAccountDetail`, `lib/mutations/useUnlinkPaymentMethod`).
- **List:** `getSavedPaymentMethod` → `/tix-payment-core/saved-payment-method` (`callback: 'home'`, corporate/employee IDs from `b2bCorporateResponseData`). Response `data.groups[].paymenMethods[]` (sic) plus `notes`.
- **E-wallets:** `/tix-payment-e-wallet/gopay/account/{binding,unbinding,credit-limit}`, `/tix-payment-e-wallet/blu/{binding,check-status}` and `DELETE /tix-payment-e-wallet/blu`, `/tix-payment-e-wallet/dana` (GET detail, DELETE unlink) and `/dana/binding` (finalize), `/tix-payment-core/ovo/account` (GET detail, PUT linkage, DELETE unlink), `/tix-payment-e-wallet/ovo/{binding,web-view-url}`.
- **Pay-later / bank:** `/tix-payment-core/kredivo/{connect,v2/detokenize}`, `/tix-payment-core/bca/oneklik/{registration,credential}`.
- **Cards and bank accounts:** `/tix-credit-card/payment/saveCard`, `/tix-credit-card/token/check-status`, plus `API_ENDPOINT` entries from `lib/config.ts` for delete card, bank list, bank verification, save and delete bank account. OTP comes from `generateMemberOtp`/`verifyMemberOtp` and `lib/hooks/useMemberPhoneOtp`.
- **IP address:** `lib/services/getIpAddress.ts` calls `https://api.ipify.org` from the browser and passes the IP down to the tiles.
- **Return-to-entry:** `binding/helper.ts` stores `history.length` in the `__payment_linkage_history` cookie (domain `.tiket.com`) through `saveHistoryLength()` before leaving for a partner. After the callback, `goBackToEntry()` does `history.go(prev - now)` after the snackbar (3 s), or `location.replace('/smart_pay')` when there is no usable value. BLU and card status are polled every 6 s, at most 10 times. A successful link sets the `coachmark` cookie (`OVO`, `GOPAY`, `BLU`, `DANA`, `CREDITCARD`) so the list shows a coachmark on the new tile.
- **Back button:** `components/Layout` reads the `items` key from [[react-common-storage]]. When the user came from the payment page (`isPaymentPage` + `orderId`/`orderHash`), back goes to `/payment?order_id&order_hash` on the new domain or `NEXT_PUBLIC_LINK_PAYMENT` on the old one. Otherwise it goes to `{NEXT_PUBLIC_LINK_HOME}/myaccount`.
- **Two unlink paths per method.** Unlinking from the list tile (swipe or dropdown → `Items.unlinkAccount`) calls the API and refetches in place. Unlinking from the detail page (`[method]/index.page.tsx` `unLink`) calls the same API, then pushes `/smart_pay?{method}Disconnected={code}`, and the list page's `handleUnlinkage` shows the snackbar. DANA uses neither: both its tile and its detail page call `useUnlinkPaymentMethod` (`DELETE /tix-payment-e-wallet/dana`). That hook's generic branch, `DELETE /tix-payment-core/{method}`, has no other caller yet.
- **Guest guard:** login is enforced client-side. A guest is sent to `/login?ref=…`, and after 5 s (or immediately in a legacy webview, `getIsLegacyWebview`) a `Failed` view with a reload button appears. The code comment explains why this is not an SSR redirect: an SSR redirect gave a blank page after login in the LW webview.

## Key components
`pages/smart_pay/components/`: `Layout` (memoized header: `RemoteHeader` on desktop, custom back header on mobile), `PaymentMethod` (groups, "see all" for more than 3 cards), `MethodTile` → `Items` (~1.2k lines: per-method connect, unlink, coachmarks, phone verification via [[passport-phone-verification]], bank account and card popups), `DanaItemTile`, `SavedCardPopup` (card form from `components/CardComponent` + OTP, react-hook-form + Zod), `BankAccount/{BankList,NewAccount}`, `PendingPayLaterActivation` (pending pay-later activation steps), `SwipeableTile`, `RemoveBindingDropdown`, `RemoveMethodDialog`, `CommonUnlinkageDialog`, `AccountDetail`, `AccountInfoTooltip`, `Navigation`, `Notes`, `Failed`, `PageLoader`, `SidebarLoader`.
From the shared `components/` ([[payment-fe-components]]): `TnC` (`smartPay` variant), `Image`, `CommonItemTileContent`, `OTP/FormOtp`, `BottomSheetOrModal`, `CardComponent`. Passport `Sidebar` and [[react-common-remote]] `RemoteFooterDesktop` on desktop.
Webview: `showNativeHeader`, `sendAppsPaymentTitle`, `show/hideAppsNavOverlay` from `lib/utils` drive the native app chrome. `hideToolbar=true` is appended to most internal navigations.

## Tracking
No GTM events of its own. `components/AnalyticsProvider` sets `window.eventProperties` from the path, and `/smart_pay` matches no rule, so `screenName` and `vertical` stay empty. `SmartPayContext` (`lib/context`) would save `gtmEventProperties` to localStorage, but nothing mounts it.

## Tests
35 Vitest specs under `pages/smart_pay/` (list page, detail, DANA, binding page and helper, every component; `Items` alone has 8). Playwright: `e2e/scenarios/smart_pay/smart_pay.spec.ts` with saved-payment-method mocks (initial, after linkage, corporate, error, unlinked, pending pay-later), and linkage journeys in `e2e/scenarios/infinity/scenario-fixtures/{BLU,DANA,GOPAY,UATAAOVOGOPAY}` that simulate partner returns to `/smart_pay?referenceId=…` and `/smart_pay/{method}/binding`. `e2e/fixtures/payment-linkage-history-cookie.ts` mirrors the cookie name and domain.

## Gotchas
- **OneKlik unlink from the detail page calls the wrong URL.** `[method]/index.page.tsx` `unlinkOneklik` passes a string to `unlinkMethod`, which expects `{ flag }`. `flag` is then `undefined`, so the request is `DELETE /tix-payment-core/undefined`, and the user lands on `/smart_pay?oneKlikDisconnected=<error code>`. TypeScript misses it because `unlinkMethod(params: any)`, and the detail spec mocks `unlinkMethod` without checking its arguments. The list tile (`Items`) passes `{ flag: 'bca/oneklik/credential?xcoId=…' }` correctly.
- **The legacy card return can hang.** On `/smart_pay`, an `order_id` without `referenceId` sets `checkingSavedCardStatus`, but the poll only runs when `referenceId` is present. Nothing then clears the loading state. The newer return, `/smart_pay/creditcard/binding?order_id=…`, polls correctly. The backend chooses which one the 3DS (`acsUrl`) flow returns to, and the FE code doesn't show which.
- **`dana.page.tsx` is a route.** `pageExtensions` includes `page.tsx`, so `[method]/dana.page.tsx` is served at `/smart_pay/{anything}/dana` without `withPaymentPageProvider` or `getServerSideProps`. It is only meant to be imported by `[method]/index.page.tsx`. Name non-route files in `pages/` without `.page.` (as `components/` and `binding/helper.ts` already are).
- Two return paths exist for the same partners. Legacy flows come back to `/smart_pay` itself with `response`, `referenceId` or `paymentCode`, and the list page handles them. Newer flows use `/smart_pay/{method}/binding`. Both call the same services, so a fix in one may be needed in the other.
- **The `coachmark` cookie is written on two domains.** `binding/helper.ts` sets it with `domain: .tiket.com`. `index.page.tsx` (OVO, BLU, GOPAY), `NewAccount` (ATM_TRANSFER) and `Items` (ONEKLIK) set it host-only. These are two separate cookies with the same name. A host-only write does not replace a `.tiket.com` one. js-cookie 3 `get` returns the first match in `document.cookie`, which is usually the older cookie, so `MethodTile` can show the coachmark on a stale method. The `.tiket.com` cookie is cleared only when an `Items` coachmark closes (`clearAllCoachmarks`), and that coachmark only runs on mobile. So a link made from the payment page, or on desktop, leaves its cookie behind. On `prerelease` (e609a125a), Krom's `useCheckKromLinkageStatus` sets `KROM` host-only. After an earlier BLU link through `/smart_pay/blu/binding`, the coachmark then shows on BLU instead of Krom.
- `pages/smart_pay/lib/context` (`SmartPayContext`) and `lib/hooks` (`useBottomSheet`) are dead code: nothing imports them. The smart_pay components import `useBottomSheet` from root `@/lib/hooks` instead.
- Shared code depends on this route folder: `lib/hooks/useSaveHistoryLength.tsx` imports `saveHistoryLength` from `@/pages/smart_pay/[method]/binding/helper`, and `lib/hooks/usePreventPageLeave` calls that hook. The payment landing's `PageLeaveDialog` and confirm/complete pages use `usePreventPageLeave`, and App Router payment-link code imports a constant from the same module. Moving or deleting `pages/smart_pay` breaks both routers.
- `[method]/dana.page.tsx` and `DanaItemTile` use `useRouter` from `next/navigation`; the other pages use `next/router`.
- The `items` storage key and the `isAccountPage` branch carry a "remove after PLP enhancement is ALL DONE" comment, so they are temporary.
- `lib/core/const.ts` exports `REGEX_SAVE_PAYMENT_METHOD = /(smart_pay)/`, but nothing uses it.

## Sources
- `pages/smart_pay/index.page.tsx`, `pages/smart_pay/[method]/{index,dana}.page.tsx`, `pages/smart_pay/[method]/binding/{index.page.tsx,helper.ts}`, `pages/smart_pay/[method]/topUp/index.page.tsx`
- `pages/smart_pay/components/{Items,PaymentMethod,MethodTile,Layout,SavedCardPopup,DanaItemTile,BankAccount}/*`, `pages/smart_pay/lib/*`
- `lib/services/payment-methods.ts`, `lib/hooks/useSaveHistoryLength.tsx`, `lib/core/const.ts`
- `components/OneKlik/index.tsx`, `components/AnalyticsProvider/index.tsx`
- `next.config.ts` (rewrites), `README.md` (URL table)
- `e2e/scenarios/smart_pay/`, `e2e/scenarios/infinity/scenario-fixtures/*`, `e2e/fixtures/payment-linkage-history-cookie.ts`
- git history: `b05eb5f14` "feat: adding spm (#573)", `9e2249e09`/`761dec77f` OVO SPM enhancement (#982, #1007), `58a967f11` save card OTP (#1547)
