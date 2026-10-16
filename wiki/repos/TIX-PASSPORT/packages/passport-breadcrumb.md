---
title: Breadcrumb
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-breadcrumb"
umbrella: true
sources:
  - packages/breadcrumb/src
  - packages/breadcrumb/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Breadcrumb
> Horizontally scrollable breadcrumb trail with overflow arrows and a pluggable link renderer, for example for `next/link`.

## What it does
`Breadcrumb` is a `<nav><ol>` that detects horizontal overflow (`useOverflow`). It shows left and right arrow buttons that scroll by 300 px, with a gradient overlay in `overlayColor`. Arrow aria-labels are localized for `en` and `id`. `BreadcrumbItem` renders an `<li>` and a chevron separator. Items with `href` are links and render regular weight. The item without `href` is treated as the current page and renders bold, with no separator.

## Public API
| Export | Props |
|---|---|
| `Breadcrumb` | `children`, `overlayColor` (default `var(--color-N100)`) |
| `BreadcrumbItem` | `href?`, `width?` (max-width px), `disabled?`, `showSeparator?` (default true), `linkRenderer?({ href, children, className, style })` |
Types: `BreadcrumbProps`, `BreadcrumbItemProps`, `LinkRendererProps`.

## Usage
```tsx
<Breadcrumb>
  <BreadcrumbItem href="/" linkRenderer={({ href, ...p }) => <Link href={href!} {...p} />}>Home</BreadcrumbItem>
  <BreadcrumbItem href="/insurance">Insurance</BreadcrumbItem>
  <BreadcrumbItem>Travel insurance</BreadcrumbItem>
</Breadcrumb>
```
`src/WithNextLink.mdx` documents the `next/link` pattern.

## Depends on
[[passport-button]], [[passport-icons]], [[passport-typography]], [[passport-utils]] (`useOverflow`, `usePassport().locale`).

## Used by
- TIX-FINTECH-NEXT-FE `projects/insurance/standalone/pdp/components/Breadcrumbs/Breadcrumbs.tsx` (direct dep `^12.4.3`).
- Internal: none.

## Gotchas
- Whether an item is "last" depends on `href`, not on position. An item without `href` in the middle renders bold with no separator.
- Disabled items with `href` render as plain text, not as a disabled link.

## Sources
- `packages/breadcrumb/src/components/Breadcrumb.tsx`, `src/components/BreadcrumbItem.tsx`, `src/WithNextLink.mdx`
- `packages/breadcrumb/package.json`
