---
title: Card
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-card"
umbrella: true
sources:
  - packages/card/src
  - packages/card/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Card
> Surface container (`Card` + header/body/footer) and `CardWithNudge`, a card with a coloured top or bottom "nudge" strip that can rotate between messages.

## What it does
`Card` renders `div`, `a` or `button` (with `type="button"` forced) with a shadow, outline or blurred variant and padding from none to large. `CardHeader` and `CardFooter` add optional separators. `CardWithNudge` wraps content under a header strip whose background is a solid or gradient token (`computeSolidAndGradientBgStyle`). With `multiCards` it cycles header text, colour and icons every `multiCardsInterval` ms (default 4000) with a 400 ms background animation. `CardWithNudgeBottom` is the bottom-strip variant. `CARD_WITH_NUDGE_PRESETS` gives the common colour and text pairs.

## Public API
| Export | Key props |
|---|---|
| `Card` (forwardRef) | `as: 'div' \| 'a' \| 'button'`, `variant: shadow (default) \| outline \| blurred`, `padding: none \| small \| medium (default) \| large` |
| `CardHeader`, `CardFooter` | `separator?` |
| `CardBody` | plain div |
| `CardWithNudge` (forwardRef) | `text`, `color: SolidAndGradientToken`, `textColor` (default `invert`), `icon`, `iconRight`, `iconSize` (default `sm`), `withOutline`, `elevation: 0 \| 1`, `multiCards`, `multiCardsInterval`, `textSize`, `textWeight`, `textAndIconAlignment`, `textMaxLine`, `withHeader`, `truncatedMaxLines` |
| `CardWithNudgeBottom` | `text`, `color` (required), `icon`, `textSize`, `textWeight`, `textAndIconAlignment`, `iconSize` |
| `CARD_WITH_NUDGE_PRESETS`, `PresetName`, `CardWithNudgePreset` | `OrangeHighEmphasis`, `ToscaLowEmphasis`, `GreenLowEmphasis`, `DarkBlueHighEmphasis`… |
Types: `CardProps`, `CardContainerVariant`, `CardContainerPadding`, `CardWithNudgeProps`, `CardWithNudgeMultiCardsProps`, `CardWithNudgeBottomProps`, `IconSize`.

## Usage
```tsx
<Card variant="outline" padding="small">
  <CardHeader separator><Text weight="bold">Order</Text></CardHeader>
  <CardBody>…</CardBody>
</Card>

<CardWithNudge {...CARD_WITH_NUDGE_PRESETS.GreenLowEmphasis} text="You save Rp50.000" icon={<IconPromo />}>
  …
</CardWithNudge>
```

## Depends on
[[passport-design-tokens]] (runtime dep: colour tokens and `computeSolidAndGradientBgStyle`), [[passport-icons]] (`SIZES`), [[passport-typography]], [[passport-utils]]. Peer deps `react` and `react-dom` (`flushSync`).

## Used by
- Through the umbrella `@tiket/passport`: TIX-NEXT-PAYMENT-FE (about 26 files for `Card`, plus `CardHeader`/`CardBody` in `components/CollapsibleCard`, and `CardWithNudge` in `app/downpay/components/DownPayBills/DownPayBillsNudge.tsx` and `components/PriceDetailV4/FlexiblePaymentSection.tsx`; see [[payment-fe-downpay]], [[payment-fe-components]]). TIX-FINTECH-NEXT-FE uses it in about 86 files (e.g. [[fintech-fe-gift-card]], `projects/refund/.../EstimatedRefundAmount`).
- Internal: 17 packages (header, insurance, global-popup, page-module, product-card, review-widget…).

## Gotchas
- `Card as="button"` always sets `type="button"`, while [[passport-button]] doesn't set a type.
- `react-dom` is a peer dep only because `CardWithNudge` uses `flushSync` for the multi-card animation.

## Sources
- `packages/card/src/Card.tsx`, `src/CardWithNudge/CardWithNudge.tsx`, `src/CardWithNudge/CardWithNudgeBottom.tsx`, `src/CardWithNudge/card-with-nudge-presets.ts`
- `packages/card/package.json`
