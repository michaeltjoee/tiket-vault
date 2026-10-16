---
title: Card Compound
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-card-compound"
sources:
  - packages/card-compound/src
  - packages/card-compound/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Card Compound
> Add-on / upsell selection card, such as an extra flight product or insurance. It has a title, ribbon, benefit list, price and an Add/Cancel button.

## What it does
`CardCompound` lays out slots: an optional segmented control, title icon, title with ribbon, benefits, slash price with discount label, price with "/pax", description, and button. `isSelected` changes the price styling (small low-emphasis when selected, bold otherwise) and hides the slash price. Sub-components fill the slots: `CardCompoundBenefit` (list plus text link), `CardCompoundBenefitItem` with `CardCompoundBenefitIcon` (checkmark), `CardCompoundRibbon` ([[passport-label]] ribbon, default red), and `CardCompoundButton`. The button is primary "+ Add" when unselected and secondary "× Cancel" when selected.

## Public API
| Export | Key props |
|---|---|
| `CardCompound` | `title`, `benefit`, `isSelected` (required). `segmentedControl`, `titleIcon`, `ribbon`, `slashPrice`, `discountLabel`, `price`, `paxText` (default "/pax"), `descriptionIcon`, `description`, `button` |
| `CardCompoundBenefit` | `children`, `textLink`, `onClickTextLink` |
| `CardCompoundBenefitItem`, `CardCompoundBenefitIcon` | `icon`, `children` |
| `CardCompoundRibbon` | `color: ProductColor` |
| `CardCompoundButton` | `isSelected`, `text?`, `onClick` |

## Usage
```tsx
<CardCompound
  title="Baggage protection" isSelected={selected} price="Rp25.000"
  ribbon={<CardCompoundRibbon>Recommended</CardCompoundRibbon>}
  benefit={<CardCompoundBenefit textLink="Details" onClickTextLink={open}>
    <CardCompoundBenefitItem icon={<CardCompoundBenefitIcon />}>Up to Rp5jt coverage</CardCompoundBenefitItem>
  </CardCompoundBenefit>}
  button={<CardCompoundButton isSelected={selected} onClick={toggle} />}
/>
```

## Depends on
[[passport-button]], [[passport-label]], [[passport-icons]], [[passport-typography]], [[passport-utils]]. [[passport-segmented-control]] is a devDep used only in stories.

## Used by
- No direct imports in other repos. It's available through the umbrella.
- Internal: none.

## Gotchas
- Every part sets `data-disable-a11y`, so the card ignores OS large-text scaling on mobile.
- The default button text is English only ("Add" / "Cancel"). Pass `text` for ID.

## Sources
- `packages/card-compound/src/components/*.tsx`
- `packages/card-compound/package.json`
