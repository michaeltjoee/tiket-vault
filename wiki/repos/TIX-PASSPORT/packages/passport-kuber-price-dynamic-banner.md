---
title: Kuber Price Dynamic Banner
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-kuber-price-dynamic-banner"
sources:
  - packages/kuber-price-dynamic-banner/src
  - packages/kuber-price-dynamic-banner/README.md
  - packages/kuber-price-dynamic-banner/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Kuber Price Dynamic Banner
> Turns a Kuber "banner evaluate" API response into a rendered Passport banner (info, notification, action, gradient, voucher or price history), plus the placement info and GTM tracking that go with it.

Part of [[passport-packages]].

## What it does
[[kuber]] is the backend that decides which banner to show where (rule, layer, priority, funnel, placement). This package maps each `BannerEvaluateResponseItem` to a simpler `KuberBannerConfig` (localised `id`/`en` text, colours, background), then `BannerFactory` renders the matching Passport component:

| `banner.type` | Rendered with |
|---|---|
| `INFO` | [[passport-info-banner]] |
| `NOTIFICATION` | [[passport-notification-banner]] |
| `ACTION` | [[passport-action-banner]] (1 action, side by side, or [[passport-button-slider]]) |
| `GRADIENT` | [[passport-gradient-banner]] |
| `VOUCHER` | [[passport-gift-voucher]] |
| `PRICE_HISTORY` | [[passport-price-history-bar]] |

Button and link actions carry a `function`. `copy` and `redirect` are built in (`redirect` takes `openIn: newTab | sameTab` and does nothing inside Storybook). `other` calls `callbacks[detail.functionName](params, controller)`. The `controller` lets a callback set an action banner's slider status (`loading`/`static`/`failed`/`fetched`). Tracking uses `eventCategory: kuberBanner`, with the vertical, rule name, layer, funnel and placement from the response.

## Public API
- `KuberPriceDynamicBanner(data, callbacks?, disableTracking?)`: a **hook** (it calls `useMemo`). It takes one item or an array and returns `BannerRenderResult` (`{ view, placementInfo }`), an array of them, or `null`.
- `KuberPriceDynamicBannerRenderer({ data, callbacks, lang, mobile, disableTracking })`: a pure factory for one item, with no hooks.
- Re-exported building blocks: `factories` (`BannerFactory`, `*BannerItem`), `mappers` (`useKuberBannerConfigMapper`, `createPlacementInfo`, per-type mappers), `utils` (`DynamicBannerFunctionHandler`, built-in functions), `config` (`isValidBannerType`, …).
- Types and constants: `BannerEvaluateResponseItem`, `BannerRenderResult`, `PlacementInfo`, `BannerType`, `PlacementType` (`TOP`, `BOTTOM`, `CENTER`, `FULL_SCREEN`, `POPUP`), `CountdownType` (`FIXED`, `RELATIVE`, `NONE`), `DynamicBannerExternalFunction`, `KuberPriceDynamicBannerCallbacks`, `TRACKER_EVENT_CATEGORY`.

## Usage
```tsx
const callbacks = useMemo(() => ({ applyPromo: (args, ctrl) => apply(args.code) }), []);
const result = KuberPriceDynamicBanner(kuberItems, callbacks);

return Array.isArray(result)
  ? result.filter((b) => b.placementInfo.placement === 'TOP').map((b) => b.view)
  : result?.view;
```

## Depends on
[[passport-info-banner]], [[passport-notification-banner]], [[passport-action-banner]], [[passport-gradient-banner]], [[passport-gift-voucher]], [[passport-price-history-bar]], [[passport-button-slider]], [[passport-button]], [[passport-countdown]], [[passport-image]], [[passport-supergraphic]], [[passport-design-tokens]], [[passport-typography]], [[passport-icons]], [[passport-utils]].

## Used by
- No importers in the other repos, and no internal dependents. It isn't in the umbrella `@tiket/passport` either. It's published on its own for vertical apps and the Kuber dashboard preview.

## Gotchas
- Call `KuberPriceDynamicBanner` at the top level of a render, like any hook. Keep `data` and `callbacks` referentially stable (memoise them). Otherwise `view` changes identity every render. An earlier version that hid hooks inside `useMemo` caused an infinite effect loop in consumers. The current split (pure renderer, then a `KuberPriceDynamicBannerView` element that owns the hooks) is the fix.
- The hook form never passes `lang` or `mobile`. The language falls back to the Passport `locale` (or `id`), and `mobile` is always `false`. Use `KuberPriceDynamicBannerRenderer` if you need either.
- Pass `disableTracking = true` for the Kuber dashboard preview, so analytics aren't polluted.
- Unknown `banner.type` values return `null` and are dropped from arrays without a warning.

## Sources
- `packages/kuber-price-dynamic-banner/src/KuberPriceDynamicBanner.tsx`, `packages/kuber-price-dynamic-banner/src/KuberPriceDynamicBannerRenderer.tsx`, `packages/kuber-price-dynamic-banner/src/KuberPriceDynamicBannerView.tsx`
- `packages/kuber-price-dynamic-banner/src/types/BannerConfig.ts`, `packages/kuber-price-dynamic-banner/src/utils/DynamicBannerFunctionHandler.tsx`, `packages/kuber-price-dynamic-banner/src/utils/functions.ts`
- `packages/kuber-price-dynamic-banner/src/index.ts`, `packages/kuber-price-dynamic-banner/README.md`, `packages/kuber-price-dynamic-banner/package.json`
