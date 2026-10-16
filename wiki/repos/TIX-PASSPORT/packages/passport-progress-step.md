---
title: ProgressStep
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-progress-step"
sources:
  - packages/progress-step/src
  - packages/progress-step/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# ProgressStep
> Step indicators in three shapes: a horizontal numbered stepper, a vertical timeline with check, cross or number indicators, and a vertical dotted timeline with solid, dash and end segments.

Part of [[passport-packages]].

## What it does
- `ProgressStep` (horizontal): `steps: string[]` and a 1-based `activeStep`. Steps before the active one show as filled checks. The last step shows an icon or a number (`lastStepState`). The fill is animated by `LineFillingAnimation` and `CircleFillingAnimation`.
- `ProgressStepVertical`: steps `{ title, content? }`. `activeFinalStepState: 'check'|'cross'` turns the final step blue or red. `indicatorVariant` is `default`, `all-numeric` or `all-icons`. Also `finalStepIndicator`, `completedTextEmphasis` and `allCompleted`. Payment and claim flows use it for "how to pay / how to claim" lists.
- `ProgressStepVerticalDots`: steps `{ title, content?, type: 'solid'|'dash'|'end', onClick? }`. `activeStepIndex` is **0-based**, and there are emphasis controls (`activatedTextEmphasis`, `initialAndCompletedTextEmphasis`) plus `showDynamicContent`. It is used for order or route timelines.

## Public API
`ProgressStep`, `ProgressStepVertical`, `ProgressStepVerticalDots` (all in [[passport-umbrella]]), with their props types. `IndicatorVariant` and `FinalStepIndicator` are exported from `ProgressStepVertical`. Horizontal-only props: `wrapItemsOnDesktop`, `color: 'transparent'|'N0'`, and the CSS variable `--progress-step-horizontal-padding` set through `style` (default `--edge-padding`).

## Usage
```tsx
<ProgressStep steps={['Isi data', 'Bayar', 'Selesai']} activeStep={2} />
<ProgressStepVertical activeStep={3} indicatorVariant="all-numeric"
  steps={[{ title: 'Buka aplikasi' }, { title: 'Pilih bayar' }, { title: 'Masukkan kode' }]} />
```

## Depends on
[[passport-typography]], [[passport-utils]], icons.

## Used by
- TIX-NEXT-PAYMENT-FE (via `@tiket/passport`): `ProgressStepVertical` in `app/downpay/components/DownPayBills/DownPayBillsNudge.tsx`, `components/PriceDetailV4/FlexiblePaymentSection.tsx` and `components/PriceDetailV4/components/DownPayDetails/DownPayDetails.tsx`; `ProgressStepVerticalDots` in `components/OrderSummary/components/TrainV4/TrainReservationDetail/TrainReservationDetail.tsx`. See [[payment-fe-downpay]].
- TIX-FINTECH-NEXT-FE: `ProgressStep` (insurance `ClaimFormStep`, refund `Banner`/`BannerV2`), `ProgressStepVertical` (gift-card `HowToUseList`, insurance `HowToClaim`) and `ProgressStepVerticalDots` (refund order-details). `vitest.setup.tsx` mocks `@tiket/passport-progress-step` with `__mocks__/@tiket/passport-progress-step/index.js`, which falls back to the real export when it can be required.

## Gotchas
- `ProgressStep` and `ProgressStepVertical` use a 1-based `activeStep`, but `ProgressStepVerticalDots` uses a 0-based `activeStepIndex`.

## Sources
- packages/progress-step/src/ProgressStep.tsx
- packages/progress-step/src/ProgressStepVertical.tsx
- packages/progress-step/src/ProgressStepVerticalDots.tsx
- packages/progress-step/src/types.ts
- packages/progress-step/package.json
