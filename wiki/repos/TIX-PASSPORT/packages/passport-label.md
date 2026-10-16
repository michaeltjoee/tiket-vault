---
title: Label
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-label"
sources:
  - packages/label/src
  - packages/label/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Label
> Small tag or pill (`Label`) in general and product (ribbon) styles, plus `LabelCampaign`, a pill that rotates through several gradient labels.

Part of [[passport-packages]].

## What it does
`Label` renders a `Text` from [[passport-typography]] as a `div`, with an optional `prefix` icon. There are two families:
- **General** variants `default` (filled) and `outline`. Sizes `medium` (text `b3`) or `small` (text `sm`). Colours `gray`, `green` (default), `blue`, `red`, `orange`, `yellow`, `pink`, `purple`, `turqoise`, and the campaign families `campaign`, `non_campaign`, `social_nudges`, `new_products` (each with a `_gradient` version) and `lpg_gradient`.
- **Product** variants `ribbon` and `emphasized`. They're always `sm` text, have no size, and have a folded-corner colour. Colours are red, green, blue, orange and the campaign families. `isShimmer` animates them.

In accessibility mode the content is clamped to `truncatedMaxLines`, and ribbons get an accessibility style. `LabelCampaign` cycles its `labels` every 1.5 s, switching the background and sliding the text. If you give it exactly two labels, it duplicates them so the rotation works.

## Public API
`Label`, `LabelCampaign`, and the constants `generalColorConfig`, `productColorConfig`, `generalVariants`, `productVariants`, `variants`, `sizes` (CSS-module values, so the colours can be reused). Types: `LabelProps`, `MainProps`, `GeneralColor`, `GeneralVariant`, `GeneralSize`, `ProductColor`, `ProductVariant`, `CustomColorStyle`, `LabelCampaignProps`.
| Prop | Notes |
|---|---|
| `variant` | `default`, `outline`, `ribbon`, `emphasized` |
| `color`, `size` | see above. `size` is `never` for product variants |
| `prefix` | icon element |
| `isShimmer` | product variants only |
| `style` | also takes `--label-color`, `--label-bg-color`, `--label-border-color`, `--label-ribbon-fold-color` for custom colours |
| `fontSize` (`b3`), `fontWeight` (`regular`/`bold`), `paddingLeft`/`paddingRight` (`4px`/`8px`/`12px`), `truncatedMaxLines` | |

## Usage
```tsx
<Label variant="default" color="blue" size="small" prefix={<IconInfo size="xxs" />}>Refundable</Label>
<Label variant="ribbon" color="campaign_gradient" isShimmer>Flash Sale</Label>
<LabelCampaign labels={[{ text: 'Lowest Price Guarantee', background: 'linear-gradient(90deg,#18dc9b,#6e54ef)' }, …]} />
```

## Depends on
[[passport-typography]], [[passport-utils]] (`usePassport().isAccessibilityOn`, `WithElementProps`).

## Used by
- TIX-NEXT-PAYMENT-FE, through the umbrella `@tiket/passport`: e.g. `components/CoBrandingCardBanner/CoBrandingCardLabel.tsx` and the order-summary passenger rows ([[payment-fe-components]]).
- Internal: [[passport-card-compound]], [[passport-corporate-interim-module]], [[passport-generic-facilities]], [[passport-gift-voucher-claim-widget]], [[passport-global-search]], [[passport-insurance-pop-up]] (its `GeneralColor` type drives discount and cashback labels), [[passport-page-module-shared]], [[passport-pricing-promo]], [[passport-product-card]], [[passport-reseller-finance-module]], and the umbrella.

## Gotchas
- Defaults are `variant="default"`, `color="green"`, `size="medium"`. A product variant with a general-only colour (e.g. `gray`) gets no matching colour class.
- `fontSize="b3"` is a temporary override. The comment says `small` will eventually move to `b3` by default.
- `LabelCampaign` restarts its rotation only when the number of labels changes, not when their content does.

## Sources
- `packages/label/src/components/Label/Label.tsx`, `packages/label/src/components/Label/constants.ts`
- `packages/label/src/components/LabelCampaign/LabelCampaign.tsx`, `packages/label/src/components/LabelCampaign/README.md`
- `packages/label/src/index.ts`, `packages/label/package.json`
