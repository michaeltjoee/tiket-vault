---
title: Accordion
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-accordion"
umbrella: true
sources:
  - packages/accordion/src
  - packages/accordion/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Accordion
> Compound components for expandable sections. Each item owns its own open state.

## What it does
`AccordionItem` holds an `expanded` state in context. `AccordionButton` toggles it on click or Enter and closes on Escape. `AccordionPanel` animates through [[passport-collapse]], and `AccordionIcon` rotates a chevron. Items are independent: there's no "only one open" mode and no controlled `expanded` prop.

## Public API
| Export | Key props |
|---|---|
| `Accordion` | plain wrapper `div` (`className`, `style`) |
| `AccordionItem` | `defaultOpen` (initial only) |
| `AccordionButton` | `onClick(isExpanded)`, `truncatedMaxLines` |
| `AccordionPanel` | children rendered inside `Collapse` |
| `AccordionIcon` | `color`, `size` (IconProps) |
Types: `AccordionProps`, `AccordionItemProps`, `AccordionButtonProps`, `AccordionPanelProps`, `AccordionIconProps`.

## Usage
```tsx
<Accordion>
  <AccordionItem defaultOpen>
    <AccordionButton onClick={(open) => track(open)}>
      <Text>Terms</Text>
      <AccordionIcon />
    </AccordionButton>
    <AccordionPanel>…</AccordionPanel>
  </AccordionItem>
</Accordion>
```

## Depends on
[[passport-collapse]], [[passport-icons]], [[passport-typography]], [[passport-utils]] (`usePassport`).

## Used by
- Through the umbrella `@tiket/passport`: TIX-NEXT-PAYMENT-FE (8 files, e.g. `app/downpay/.../DownPayInstallmentPicker.tsx`, `components/Installment/...`; see [[payment-fe-downpay]], [[payment-fe-components]]) and TIX-FINTECH-NEXT-FE `projects/refund/shared/components/RefundMethodEstimation*/…/Tnc*`.
- TIX-FINTECH-NEXT-FE `vitest.require-alias.cjs` aliases the package for tests.
- Internal: [[passport-generic-facilities]], [[passport-otp-unm]], [[passport-price-summary]], [[passport-seo]].

## Gotchas
- When `usePassport().isAccessibilityOn` is true, `AccordionButton` walks its children and adds a line-clamp class plus `--max-truncate-line` to every `Text` it detects. Detection is a heuristic that also matches any component with no `displayName`, so custom children can get the class too.
- `'use client'`: this is a client component.

## Sources
- `packages/accordion/src/Accordion.tsx`
- `packages/accordion/src/AccordionContext.tsx`
- `packages/accordion/package.json`
