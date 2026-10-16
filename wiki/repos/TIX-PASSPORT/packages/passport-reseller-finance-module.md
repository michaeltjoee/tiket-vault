---
title: ResellerFinanceModule
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-reseller-finance-module"
sources:
  - packages/reseller-finance-module/src
  - packages/reseller-finance-module/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# ResellerFinanceModule
> Self-contained reseller-dashboard finance report: filters (order type, transaction type, date basis, date range), a paginated table with a grand total, and an asynchronous report download.

Part of [[passport-packages]].

## What it does
Its only prop is `clientSideServiceEndpoint`. Fetching uses `usePassport().customFetch` against `tix-deposit`:
- `GET /tix-deposit/reseller-dashboard/report?...` returns table rows. Loading uses a local `suspend-react` copy and is wrapped in an `ErrorBoundary`.
- `GET /tix-deposit/reseller-dashboard/report/download?...` starts an export, `.../download/status` is polled, and `downloadMultipleFile` saves the files.

The default range is the last 3 days. Filter options come from `RESELLER_ORDER_OPTIONS`, `RESELLER_TYPE_OPTIONS` and `RESELLER_DATE_OPTIONS`. Filters apply on search, with separate draft and applied state. Pagination uses [[passport-pagination]] with `DEFAULT_PAGE_SIZE_OPTION`.

## Public API
`ResellerFinanceModule({ clientSideServiceEndpoint: string })`. Not in [[passport-umbrella]].

## Usage
```tsx
<PassportProvider customFetch={authFetch} {...rest}>
  <ResellerFinanceModule clientSideServiceEndpoint="" />
</PassportProvider>
```
Mock data: `src/mockResellerReport.ts`.

## Depends on
[[passport-pagination]], [[passport-calendar]] (date range), [[passport-dropdown]], [[passport-check]], [[passport-form]], [[passport-card]], [[passport-label]], [[passport-error-view]], [[passport-figure]], [[passport-loading]], [[passport-loading-indicator]], [[passport-snackbar]], [[passport-divider]], [[passport-button]], [[passport-typography]], [[passport-utils]], assets, icons, `@tiket/react-common-utilities`. External: `date-fns`, `uuid`.

## Used by
- No internal dependents and no consumers in the workspace repos. The reseller dashboard app lives elsewhere.

## Gotchas
- It needs `customFetch` in `PassportProvider` for authenticated calls. Without it, the global `fetch` is used.

## Sources
- packages/reseller-finance-module/src/ResellerFinanceModule.tsx
- packages/reseller-finance-module/src/services/get-reseller-report.ts
- packages/reseller-finance-module/src/services/get-reseller-report-download.ts
- packages/reseller-finance-module/package.json
