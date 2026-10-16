---
title: Insurance claim center
repo: TIX-FINTECH-NEXT-FE
kind: feature
sources:
  - app/insurance-claim
  - projects/insurance/claim-center
  - projects/insurance/shared/lib/services/claim-center.ts
  - projects/insurance/shared/lib/configs
  - projects/insurance/shared/lib/hooks/useHideToolbar.ts
  - projects/insurance/shared/lib/i18n/claim-center
  - lib/middlewares/validateSessionAppRouter.ts
  - e2e/insurance/claim-center
verified_at: 5833b842
updated: 2026-10-16
status: current
tags: [repo/fintech-fe, kind/feature]
---

# Insurance claim center
> App Router section at `/insurance-claim` where a user sees their insured orders, opens policy detail and FAQ, files a claim through a multi-step form, and tracks claim status.

## What it does
- **Landing** `/insurance-claim[?orderId=]`: order section (insured orders, or one order when `orderId` is given), a [[passport-page-module]] section from page-module code `CLAIM_CENTER_PAGE`, more-info links and footer. Public.
- **Insurance detail** `/insurance-claim/detail/[transactionDetailId]`: policy/benefit detail and the entry point to start a claim (`InitClaimForm`).
- **FAQ** `/insurance-claim/faq/[transactionDetailId]`: per-product FAQ. Payment pages deep-link here inside webviews with `?hideToolbar=true` (TIX-NEXT-PAYMENT-FE mock `order-composer.json`).
- **Claim form** `/insurance-claim/form?claimId=`: multi-step dynamic form (`pages/ClaimForm.tsx` steps, then `pages/FormSummary.tsx`), with typed inputs (date, time, dropdown, select, checkbox/radio, phone with verification, account number, file upload), claim method (select or add bank account) and optional claim amount.
- **Claim list** `/insurance-claim/claim-list`: all claims (`all-claim`, POST) and history.
- **Claim detail** `/insurance-claim/claim-detail/[claimId]` and **claim general** `/insurance-claim/claim-general/[claimId]`: claim status/progress, two backend shapes (`claim/detail` vs `claim/general`).

All sub-pages are private.

## Routes & entry points
`app/insurance-claim/**/page.page.tsx` are one-line re-exports (`export { default, generateMetadata } from '@insurance/claim-center/<feature>'`) checked by `app/insurance-claim/__tests__/pages.spec.tsx`. Feature entries are `projects/insurance/claim-center/{landing,insurance-detail,faq,claim-form,claim-list,claim-detail,claim-general}/index.tsx`.

`app/insurance-claim/layout.page.tsx` is the only logic in `app/`: it loads claim-center i18n, wraps `AppRouterProvider`, mounts `GTMScripts vertical="insurance"`, `ServiceWorkerScripts`, `RemoteScripts`, and for guests calls `validateSessionForPrivatePage(['/insurance-claim'])`, which redirects every path except the landing to `/login?ref=<x-url>` ([[fintech-fe-architecture]] for `x-url`).

## Data & services
Except the landing's page-module fetch, pages are server shells around a client context provider (`*Provider` in each feature's `contexts/`) that fetches with React Query. Services: `projects/insurance/shared/lib/services/claim-center.ts`, all under `/tix-insurance-core/insurances/claim-center/`:

| Endpoint | Function |
|---|---|
| `landing` | `getLandingPage` |
| `insurance/detail/{transactionDetailId}` | `getInsuranceDetail` |
| `claim/general/{claimId}`, `claim/detail/{claimId}` | `getClaimGeneral`, `getClaimDetail` |
| `all-claim` (POST), `history` | `postClaimList`, `getClaimHistory` |
| `init-form` (POST), `{subscriptionCode}/preparation` (POST) | `getInitClaimForm`, `postPreClaimForm` |
| `form` (POST) | `postClaimForm` (loads the form for a `claimId`) |
| `{subscriptionCode}/claims/{claimId}/fill` (POST), `.../submit` (POST) | `postFillingClaimForm` (save step), `postSubmitClaimForm` |
| `form/get-bank` (POST), `bank`, `form/add-bank` (POST) | bank accounts, bank list, add bank |
| `order/item-details/{orderId}` | `getOrderItemDetails` |

Landing page module: `landing/controllers/page-module.ts` → `getPageModule` in `lib/services/home.ts`, code `CLAIM_CENTER_PAGE`, platform `MOBILE_WEB`/`WEB` from device, currency forced to `IDR` (product requirement).

Claim form state (`claim-form/context/claim-form.tsx`): reducer state plus React Query `['getClaimForm', claimId]` with `gcTime: 0`. Step position is kept in `sessionStorage` (`insurance:claim_form_step`, with `claimId`, `current/next/previous`, `isRevision`); `insurance:claim_form_result` carries the success flag to the next page, `insurance:claim_form_previous_page` the return URL (`shared/lib/configs/storage-keys.ts`).

## Key components
Feature-local components under each feature's `components/`. Shared ones from `projects/insurance/shared/components`: `InitClaimForm` (54 files), `OrderDetails`, `OrderList`, `OrderCard`, `ClaimCard`, `ClaimFormStep`, `ClaimAmountDetails`, `DocumentInfo`, `InsuranceDetails`, `Header`, `Navigation`, `Layout`, `Footer`, `ErrorFullPage`/`ErrorDialog`/`ErrorBottomSheetModal`, `TermsAndConditions`, `EncryptedWarning`. Shared hooks: `useCreateClaimForm`, `useCustomRouter`, `useHideToolbar`, `usePopUpNavigator`, `useGenericContent`.

## Tracking
`VERTICAL = 'insurance'` (`shared/lib/configs/tracker.ts`); per-feature `tracker.ts` files (claim-general, claim-form `pages/tracker.ts`, `hooks/tracker.ts`, `ClaimMethod/tracker.ts`, `FileUploadInput/tracker.ts`, `ReviewClaimAmount/tracker.ts`). Page visits come from `AppRouterProvider` (`^/insurance-claim` → screen `insurance-claim`, vertical `insurance`).

## Tests
133 spec files under `projects/insurance/claim-center` (80 more in `projects/insurance/shared`), the route re-export spec, and Playwright `e2e/insurance/claim-center/login.spec.ts`.

## Gotchas
- **Revision flow**: if the claim form response has a field marked for revision and the user comes back to the same `claimId`, the form jumps to that step (`getStepByRevision`); `isRevision` in session stops it re-jumping on refresh. A different `claimId` resets the step to 0.
- `/insurance-claim/detail/[id]` with an id shorter than 15 chars is treated as a legacy order id (old push/email links): it logs and redirects to `/insurance-claim?orderId=<id>&hideToolbar=true` with forward params.
- `hideToolbar` (`useHideToolbar`): in a webview the native app header is hidden when `hideToolbar=true`; in a non-legacy webview the FE header is always shown. In webviews `hideToolbar=true` is propagated to links.
- Claim amount UI on the summary step is behind `NEXT_PUBLIC_CLAIM_AMOUNT_ENABLED === '1'` (default `0` in `.env.local.example`).
- Base paths are configurable: `NEXT_PUBLIC_CLAIM_CENTER_BASE_PATH` (default `insurance-claim`), `NEXT_PUBLIC_INSURANCE_POPUP_BASE_PATH`, `NEXT_PUBLIC_UNM_BASE_URL` (`shared/lib/configs/url.ts`).
- The claim form context file is `/* istanbul ignore file */`, and `projects/` is outside `coverage.include` anyway ([[fintech-fe-workflows]]).
- [[passport-header]] links to `/insurance-claim` from its menu, so the landing path must stay stable.

## Sources
- `app/insurance-claim/layout.page.tsx`, `app/insurance-claim/**/page.page.tsx`
- `projects/insurance/claim-center/*/index.tsx`, `projects/insurance/claim-center/landing/controllers/page-module.ts`, `projects/insurance/claim-center/claim-form/context/claim-form.tsx`
- `projects/insurance/shared/lib/services/claim-center.ts`, `projects/insurance/shared/lib/configs/{storage-keys,url,tracker}.ts`, `projects/insurance/shared/lib/hooks/useHideToolbar.ts`
- `lib/middlewares/validateSessionAppRouter.ts`, `e2e/insurance/claim-center/login.spec.ts`
- TIX-NEXT-PAYMENT-FE `lib/mocks/data/standalone-insurance/order-composer.json`; TIX-PASSPORT `packages/header/src/utils/Constants.ts`
