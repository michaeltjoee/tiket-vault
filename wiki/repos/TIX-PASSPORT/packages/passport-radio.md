---
title: Radio / RadioGroup
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-radio"
umbrella: true
sources:
  - packages/radio/src
  - packages/radio/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Radio / RadioGroup
> Context-based radio buttons. `RadioGroup` owns `name`, `value`, `disabled` and `onChange`, and each `Radio` compares its `value` with the group's.

Part of [[passport-packages]].

## What it does
`RadioGroup` provides `{ name, value, disabled, onChange }` through `RadioGroupContext` and renders an optional `errorMessage` below the radios. A `Radio` is checked when `JSON.stringify(radio.value) === JSON.stringify(group.value)`. That means values can be **objects or booleans**, not just strings (`RadioGroupValue = string | number | object | boolean`). Selecting a radio calls `onChange(value, name)`. Radio-specific options: `radioPosition` (`left`/`right`), `block`, `isError`, `marginVariant` (`default`/`none`), and `wrapperProps` for the outer `<label>`.

## Public API
`Radio`, `RadioGroup` (both in [[passport-umbrella]]); types `RadioProps`, `RadioOwnProps`, `RadioPosition`, `RadioGroupProps`, `RadioGroupValue`, plus `RadioGroupContext`. Apps also import `@tiket/passport/types/radio` for `RadioGroupValue`.

## Usage
```tsx
<RadioGroup name="installment" value={selected} onChange={(v) => setSelected(v as Plan)}>
  {plans.map((p) => (
    <Radio key={p.id} value={p} radioPosition="right" block>{p.label}</Radio>
  ))}
</RadioGroup>
```

## Depends on
[[passport-typography]], [[passport-utils]].

## Used by
- Inside TIX-PASSPORT: 10 packages at runtime, including [[passport-language-and-currency-modal]], [[passport-manage-order]], [[passport-pricing-promo]], [[passport-refund-method]], [[passport-wishlist]] and header. dropdown, group-field-v2 and search-form-display list it only as a devDependency.
- TIX-NEXT-PAYMENT-FE: a direct dependency (`^8.11.1`). It imports from `@tiket/passport-radio` in `app/payment-link/components/PaymentMethodSelector/PaymentMethodSelector.tsx`, and through `@tiket/passport` in about 9 files (installment lists in `app/downpay`, `components/CardComponent*`, `app/payment/components/InfinityTiketPoints`).
- TIX-FINTECH-NEXT-FE (about 15 files: gift-card checkout and redeem forms, insurance claim-method forms).

## Gotchas
- Equality goes through `JSON.stringify`, so object key order matters, and functions and `undefined` fields are ignored.
- A `Radio` outside a `RadioGroup` is never checked, because the context value is `undefined`.

## Sources
- packages/radio/src/Radio.tsx
- packages/radio/src/RadioGroup/RadioGroup.tsx
- packages/radio/src/RadioGroup/RadioGroupContext.tsx
- packages/radio/package.json
