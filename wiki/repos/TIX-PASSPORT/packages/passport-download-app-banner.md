---
title: Download App Banner
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-download-app-banner"
sources:
  - packages/download-app-banner/src
  - packages/download-app-banner/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Download App Banner
> "Get the tiket.com app" promo banners that link to the OneLink smart download URL.

## What it does
- `DownloadAppBanner` is a dismissible top strip with a discount image, localized title and an inverted "Download" button. It renders nothing when `isOpen` is false. The caller owns dismissal and persistence.
- `DownloadAppBannerSectional` is an in-page section with the app image, a heading and text (defaults are localized), a "Download" button and a QR image.

Both link to `https://onelink.to/am3tju` (`utils/config.ts`).

## Public API
| Export | Props |
|---|---|
| `DownloadAppBanner` | `isOpen`, `onClose` |
| `DownloadAppBannerSectional` | `heading?`, `text?` (string or JSX) |
Types: `DownloadAppBannerProps`, `SectionalBannerProps`.

## Usage
```tsx
<DownloadAppBanner isOpen={!dismissed} onClose={() => setDismissed(true)} />
<DownloadAppBannerSectional />
```

## Depends on
[[passport-assets]] (`tds_mi_bt_tiket_apps`), [[passport-button]], [[passport-divider]], [[passport-icons]], [[passport-typography]], [[passport-utils]] (`locale`).

## Used by
- No consumers found in other repos on their baselines.
- Internal: none.

## Gotchas
- `src/AppRedirectionBanner/` (an "Open app" card with confetti) has a story but **isn't exported**.
- The OneLink URL is hard-coded. There's no prop to change it or add tracking parameters.
- Not in the umbrella `@tiket/passport`.

## Sources
- `packages/download-app-banner/src/DownloadAppBanner.tsx`, `src/DownloadAppBannerSectional.tsx`, `src/AppRedirectionBanner/AppRedirectionBanner.tsx`, `src/utils/config.ts`, `src/utils/constants.ts`
- `packages/download-app-banner/package.json`
