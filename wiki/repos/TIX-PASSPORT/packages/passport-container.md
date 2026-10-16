---
title: Container
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-container"
umbrella: true
sources:
  - packages/container/src
  - packages/container/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Container
> Centered page-width wrapper that applies the design system's responsive edge padding and max width.

## What it does
It's a `div` with `margin: 0 auto`, `padding-inline: var(--edge-padding)` and `max-width: var(--container-max-width)` (`box-sizing: content-box`). Both variables come from the global CSS of [[passport-design-tokens]]. Without that CSS loaded, the container does nothing.

## Public API
`Container` (forwardRef to `HTMLDivElement`; accepts all `div` props). Types: `ContainerProps`, `ContainerOwnProps`.

## Usage
```tsx
<Container className={styles.page}>
  <PageContent />
</Container>
```

## Depends on
[[passport-utils]], `classnames`. CSS variables from [[passport-design-tokens]].

## Used by
- Through the umbrella `@tiket/passport`: TIX-NEXT-PAYMENT-FE (about 19 files, e.g. [[payment-fe-payment-link]] success and confirm pages) and TIX-FINTECH-NEXT-FE (about 51 files, e.g. `app/error.page.tsx`, [[fintech-fe-gift-card]] pages).
- Internal: 13 packages (header, footer, page-module, page-module-shared, insurance, insurance-pop-up, review-widget, seo…).

## Sources
- `packages/container/src/Container.tsx`, `src/Container.module.scss`
- `packages/container/package.json`
