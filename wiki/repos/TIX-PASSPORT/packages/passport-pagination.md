---
title: Pagination
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-pagination"
sources:
  - packages/pagination/src
  - packages/pagination/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Pagination
> Numbered page navigator with previous/next chevrons and ellipses. It can render plain buttons or SEO-friendly links through `linkRenderer`.

Part of [[passport-packages]].

## What it does
`usePagination` (adapted from MUI) computes the items with 1 boundary page and 1 sibling on each side, inserting `start-ellipsis` / `end-ellipsis`. By default each item is a button that calls `onChange(page)`. With `linkRenderer`, each item is rendered by the caller (e.g. Next `<Link href=/page-N>`), so crawlers see real links. The prev/next aria-labels are localized from `usePassport().locale`.

## Public API
`Pagination` (also in [[passport-umbrella]]); types `PaginationProps`, `LinkRendererProps`.

| Prop | Notes |
|---|---|
| `count` | total pages |
| `page` | current, 1-based |
| `onChange(page)` | optional with `linkRenderer` (e.g. for tracking) |
| `disabled` | disables everything |
| `linkRenderer({ page, className, children, onClick })` | custom anchor |

## Usage
From `src/WithLinkRenderer.mdx`:
```tsx
<Pagination count={20} page={page}
  linkRenderer={({ page, children, ...rest }) => (
    <Link {...rest} href={`/testing/page-${page}`}>{children}</Link>
  )} />
```

## Depends on
[[passport-typography]], [[passport-utils]], icons, design-tokens (types).

## Used by
- Inside TIX-PASSPORT: [[passport-dashboard]], [[passport-reseller-finance-module]].
- No direct consumers in the other workspace repos.

## Sources
- packages/pagination/src/Pagination.tsx
- packages/pagination/src/usePagination.ts
- packages/pagination/src/WithLinkRenderer.mdx
- packages/pagination/package.json
