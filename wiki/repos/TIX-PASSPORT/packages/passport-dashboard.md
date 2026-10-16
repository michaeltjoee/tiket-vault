---
title: Dashboard
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-dashboard"
sources:
  - packages/dashboard/src
  - packages/dashboard/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Dashboard
> Data `Table` for back-office and B2B dashboards: sortable columns, sticky left and right columns, row-span, loading skeleton, empty state and built-in pagination.

## What it does
`Table` renders a `<table>` from `columns` and `data`. A cell's content is `row[col.key]`, so preformat values or pass JSX in the row objects. The first `fixedLeftNumber` and last `fixedRightNumber` columns are sticky. Their offsets are measured with `offsetLeft` in a layout effect. Sortable headers call `onSort(columnKey)`. The table is controlled: you pass `sortValue` and `sortDirection` (`'' | 'ASC' | 'DESC'`). `loading` shows skeleton rows. With empty data and an `emptyConfig`, it renders either `renderElement` instead of the table or an in-table empty row (`showOnRow`). `paginationConfig` renders `DashboardPagination` (prev/next or numbered, "x - y of N" count) under the table.

## Public API
Only `Table` (forwardRef `HTMLDivElement`) is exported.
| Prop | Notes |
|---|---|
| `columns: { key, title, sortable?, width?, className?, hide?, allowToRowSpan? }[]` | |
| `data: object[]` | row objects keyed by column `key`. `rowSpan` is read from the row when `allowToRowSpan` is set |
| `fixedLeftNumber`, `fixedRightNumber` | sticky column counts |
| `onSort`, `sortValue`, `sortDirection` | controlled sort |
| `loading`, `emptyConfig: { renderElement, showOnRow?, colAllSpan?, className? }` | |
| `paginationConfig` | `{ offset, limit, count, onChange(pageIndex), withCount, withoutNumber, withLimit, loading, pagitinationPosition }` plus [[passport-pagination]] props |
| `withOddEven`, `withBorderTHeader`, `withBorderTBody`, `withFullBorder`, `containerClassName`, `tableClassName` | styling |

## Usage
```tsx
<Table
  columns={[{ key: 'date', title: 'Date', sortable: true }, { key: 'amount', title: 'Amount' }]}
  data={rows} loading={isLoading} sortValue={sortKey} sortDirection={dir} onSort={toggleSort}
  paginationConfig={{ offset, limit: 10, count: total, withCount: true, onChange: (p) => setOffset(p * 10) }}
/>
```

## Depends on
[[passport-button]], [[passport-content-loader]], [[passport-pagination]], [[passport-icons]], [[passport-typography]], `uuid`. [[passport-dropdown]] is listed as a dependency, but the rows-per-page dropdown isn't implemented.

## Used by
- No consumers found in other repos on their baselines.
- Internal: none. [[passport-reseller-finance-module]] builds its own table.

## Gotchas
- Prop and column types (`TTableProps`, `TableColumnProp`) aren't exported from the entry. Use `React.ComponentProps<typeof Table>`.
- `withLimit` renders the placeholder text "TBA waiting Dropdown Dashboard Component" instead of a dropdown.
- Pagination `onChange` receives a zero-based page index, not an offset, despite the inline comments.
- `useTableSortQueryParams` exists in `components/table/hooks` but isn't exported.
- Not in the umbrella `@tiket/passport`.

## Sources
- `packages/dashboard/src/components/table/Table.tsx`, `src/components/table/types.ts`, `src/components/table/components/*`, `src/components/pagination/*`, `src/index.ts`
- `packages/dashboard/package.json`
