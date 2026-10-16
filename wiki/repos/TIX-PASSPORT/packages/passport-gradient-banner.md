---
title: Gradient Banner
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-gradient-banner"
umbrella: true
sources:
  - packages/gradient-banner/src
  - packages/gradient-banner/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Gradient Banner
> Slim, token-coloured promo or info strip (icon, text, optional timer, chevron or button). `GradientBannerContainer` turns several of them into an auto-rotating keen-slider carousel.

## What it does
`GradientBanner` renders one banner. The text is `children` (string or element), with an optional `subtitle` and link. The icon is a URL string or an element, or the built-in animated wishlist GIF via `leftIconVariant="wishlistIcon"`. An optional `timeLeft` (ms) countdown calls `onTimeUp`. On the right sits a chevron or a button (`actionBtnTypeOnMobile`, `buttonText`). With `href` the whole banner is a link. With only `onClick` it's a clickable div. `GradientBannerContainer` paints the background of the *active* child's `color` (solid or gradient token through `computeSolidAndGradientBgStyle`). It auto-advances every `transitionInterval`, horizontally or `vertical`, shows arrows on desktop, and shows [[passport-page-control]] dots for big variants.

## Public API
| Export | Key props |
|---|---|
| `GradientBanner` (forwardRef div) | `color: SolidAndGradientToken` (required, read by the container), `children`, `variant: small \| smallRounded \| bigRounded \| bigRectangle`, `icon`, `iconAlt`, `leftIconVariant`, `subtitle`, `href`, `onClick`, `buttonText`, `actionBtnTypeOnMobile: button \| chevron`, `showRightIcon`, `rightIconColor`, `textVariant` (default `invert`), `bodyTextSize: b2 \| b3`, `timeLeft` + `onTimeUp` + `showMilliseconds`, `linkText`, `linkHref`, `onLinkClick`, `backgroundImage`, `truncatedMaxLines`, `buttonMaxLines`, `style` (`--gradient-banner-icon-size-{mobile,desktop}`) |
| `GradientBannerContainer` | `children` (GradientBanner elements), `transitionInterval`, `vertical`, `variant`, `borderTopRadius`, `borderBottomRadius` (0/2/4/8/16), `pageControlColor: white \| blue`, `className`. `gradientBannerClassname` is deprecated |
| `variants`, `leftIconVariants`, `leftIconVariantsMapping` | constants |
| types | `GradientBannerProps`, `GradientBannerVariants`, `GradientBannerContainerProps`, `TimerProps`, `IconProps`, … |

## Usage
From TIX-NEXT-PAYMENT-FE `app/payment/components/PaymentLoginBanner/PaymentLoginBanner.tsx`:
```tsx
<GradientBannerContainer borderBottomRadius={8} borderTopRadius={8}>
  <GradientBanner color="purple" buttonText="" href="" icon={<Image src={tds_ic_bt_point_onecolor_blue} width={32} height={32} alt="" />}>
    Log in to earn points
  </GradientBanner>
</GradientBannerContainer>
```

## Depends on
[[passport-button]], [[passport-countdown]], [[passport-page-control]], [[passport-icons]], [[passport-typography]], [[passport-utils]], [[passport-design-tokens]] (runtime: `computeSolidAndGradientBgStyle`), `keen-slider`.

## Used by
- Through the umbrella `@tiket/passport`: TIX-NEXT-PAYMENT-FE `app/payment/components/PaymentLoginBanner/PaymentLoginBanner.tsx` ([[payment-fe-payment]]) and `pages/payment/components/LpgBanner/index.tsx`.
- Internal: [[passport-kuber-price-dynamic-banner]], [[passport-mission-landing-page]].

## Gotchas
- With `href`, the link always opens in a **new tab** (`target="_blank"`).
- Always wrap banners in `GradientBannerContainer`, even a single one. The background colour is painted by the container, not by the banner.
- `timeLeft` is in **milliseconds**, while [[passport-countdown]]'s `second` is in seconds.
- The wishlist GIF is resolved with `new URL('./assets/wishlist.gif', import.meta.url)`, so the consumer's bundler has to support asset URLs (webpack 5, Vite and Next do).

## Sources
- `packages/gradient-banner/src/GradientBanner.tsx`, `src/components/GradientBannerContainer.tsx`, `src/components/KeenSliderPlugins.ts`, `src/constants.ts`
- `packages/gradient-banner/package.json`
- TIX-NEXT-PAYMENT-FE `app/payment/components/PaymentLoginBanner/PaymentLoginBanner.tsx` (9e92b20bb)
