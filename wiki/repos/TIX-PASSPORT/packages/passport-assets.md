---
title: Assets
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-assets"
sources:
  - packages/assets
  - scripts/assets-generator
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Assets
> Registry of tiket's cloud-hosted design images as named URL constants, plus Lightroom image-loader helpers.

## What it does
`src/index.ts` (about 4,890 lines) is generated from `src/cloud-asset.csv`. Each row becomes `export const <filename_without_ext> = '<https://s-light.tiket.photos/...>'`. Names follow the DS prefix convention: `tds_si_*` for spot illustrations, `ot_*` and so on. The package also exports Lightroom helpers from `src/lightroom.ts` that rewrite the preset segment of a tiket Lightroom URL. Next apps use them as a custom `next/image` loader.

## Public API
| Export | Purpose |
|---|---|
| `<asset_name>` constants | image URL strings, e.g. `tds_si_no_result`, `tds_si_flight_luggage_hours` |
| `lightroomLoader({ src, width })` | `next/image` loader. Maps width to a preset (`w400h0sh1`, `w640h0`…`w1600h0`, or `rsfit1212gsm`/`w62h62`/`thumb` for small sizes) |
| `overrideLightroomPreset(src, preset)` | replaces path segment 5 if the host is a tiket Lightroom host |
| `isTiketLightroom(src)` | host check against `s-light`, `s-gk`, `s-pg`, `s-preprod` `.tiket.photos` |
| `makeSrcset({ src, widths })` | builds a `srcset` string |
| types `ImageLoader`, `ImageLoaderProps`, `LightroomPreset`, `LightroomImageWidth` | |
| `@tiket/passport-assets/config.cjs` | CommonJS `deviceSizes`, `imageSizes`, `TIKET_LIGHTROOM_HOSTNAMES` for `next.config` `images` |

## Usage
```ts
import { tds_si_no_result, lightroomLoader } from '@tiket/passport-assets';
<Image src={tds_si_no_result} loader={lightroomLoader} width={400} … />
```

## Depends on
Nothing at runtime. `sideEffects: false`, and `config.cjs` is shipped through `files`.

## Used by
- TIX-NEXT-PAYMENT-FE: `next.config.ts` and `components/Image/Image.tsx` (the Lightroom loader), plus illustration constants in [[payment-fe-downpay]] and [[payment-fe-payment-link]]. It's pinned at `^8.11.1`.
- TIX-FINTECH-NEXT-FE: `next.config.js`, `components/Image/Image.tsx`, and gift-card illustrations ([[fintech-fe-gift-card]]).
- TIX-REACT-REMOTE: `src/constants/common.ts`.
- Internal: 31 packages, including most business widgets plus [[passport-utils]].

## Gotchas
- **Regenerating can drop the Lightroom exports.** `scripts/assets-generator/index.mjs` rewrites `src/index.ts` from the CSV and doesn't emit `export * from './other-exports'`. The committed file has that line added by hand. Re-add it after `npm run generate:assets`, or `lightroomLoader` and the other helpers disappear.
- The CSV comes from the DS team (per `CONTRIBUTING.md`, PIC: Fawwazy) and is exported from a Google Cloud bucket. Replace the whole file and don't hand-edit constants.
- Keep `config.cjs` sizes in sync with `getPreset` in `lightroom.ts`. Both files say so, but nothing enforces it.
- Not re-exported by the umbrella `@tiket/passport`. Install it directly.

## Sources
- `packages/assets/src/index.ts`, `packages/assets/src/lightroom.ts`, `packages/assets/src/other-exports.ts`, `packages/assets/config.cjs`
- `packages/assets/CONTRIBUTING.md`, `packages/assets/package.json`
- `scripts/assets-generator/index.mjs`
