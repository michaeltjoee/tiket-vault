---
title: PromoCodePopup
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-promo-code-popup"
sources:
  - packages/promo-code-popup/src
  - packages/promo-code-popup/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# PromoCodePopup
> Promo-code detail popup with a copy-to-clipboard code, a CTA, T&C HTML and quota rulesets. It is a BottomSheet on mobile and a medium Modal on desktop.

Part of [[passport-packages]].

## What it does
It opens from the promo-code page modules (`PROMO_CODE_GRID`, `PROMO_CODE_CAROUSEL`) in [[passport-page-module]]. The title is fixed per locale ("Mantul! Kode promo siap dipakai saat pembayaran."). `PromoCode` copies the code with `copyTextToClipboard` from [[passport-utils]], scoped to the container class `promo-code-bottomsheet-clipboard` or `promo-code-modal-clipboard`. The CTA is an anchor whose `href` goes through `withForwardParams(ctaUrl)`, and links inside `usageTerms` also get forward params through `forwardParamsRef`. `PromoQuota` lists `rulesets`.

## Public API
`PromoCodePopup` (also in [[passport-umbrella]]) and the constants `CONTAINER_CLIPBOARD_CLASSNAME_BOTTOMSHEET`, `CONTAINER_CLIPBOARD_CLASSNAME_MODAL`.

| Prop | Notes |
|---|---|
| `isOpen`, `onClose` | |
| `promoCode?` | |
| `onSuccessPromoCodeCopy` | e.g. show a snackbar |
| `ctaUrl`, `ctaTitle`, `onCtaClick` | |
| `usageTerms` | **HTML string**, rendered with `dangerouslySetInnerHTML` |
| `rulesets: RuleSet[]` | type from [[passport-page-module-shared]] |
| `customPromoCodePopupQuotaText`, `className` | |

## Usage
```tsx
<PromoCodePopup isOpen={open} onClose={close} promoCode="TIKETHEMAT"
  onSuccessPromoCodeCopy={() => snackbar('Kode disalin')}
  ctaUrl="/pesawat" ctaTitle="Pakai sekarang" onCtaClick={track}
  usageTerms={tncHtml} rulesets={rules} />
```

## Depends on
[[passport-bottom-sheet]], [[passport-bottom-app-bar]], [[passport-modal]], [[passport-card]], [[passport-button]], [[passport-page-module-shared]], [[passport-typography]], [[passport-utils]], icons.

## Used by
- Inside TIX-PASSPORT: [[passport-page-module]], [[passport-global-popup]].
- No direct consumers in the other workspace repos.

## Gotchas
- It renders **nothing** until `usePassport().breakpoint` resolves to mobile or desktop, and it chooses the variant from the breakpoint, not from CSS.
- `usageTerms` is not sanitized here. The caller must pass trusted HTML.

## Sources
- packages/promo-code-popup/src/PromoCodePopup.tsx
- packages/promo-code-popup/src/PromoCode.tsx
- packages/promo-code-popup/src/PromoQuota.tsx
- packages/promo-code-popup/package.json
