---
title: TIX-GTM-EXTRAS overview
repo: TIX-GTM-EXTRAS
kind: overview
sources:
  - README.md
  - .github/copilot-instructions.md
  - package.json
  - gulpfile.js
  - scripts
verified_at: 98478af
updated: 2026-10-16
status: current
tags: [repo/gtm-extras, kind/overview]
---

# TIX-GTM-EXTRAS overview
> Marketing-pixel and tracking scripts moved out of the main GTM container into one Gulp-built file, `build/index.js`.

## What it is
This repo holds plain ES2017 browser scripts with no framework, no modules and no tests. Gulp concatenates them, minifies them and wraps the result in one IIFE as `build/index.js`, which Jenkins uploads (see [[gtm-extras-workflows]]). Each script replaces what used to be a GTM custom-HTML tag, and `helpers.js` replaces the GTM variables and trigger conditions those tags used (functions are commented "replacement for CJS - …" / "JSV - …").

The scripts read the page's global `window.gtm` object (filled by the vertical apps: `gtm.vertical`, `gtm.flight.*`, `gtm.hotel.*`, `gtm.user.*`, `gtm.screenName`…) and the GTM container's data model via `google_tag_manager['GTM-PLRJPPQ'].dataLayer.get(...)`. `GTM-PLRJPPQ` is the same container ID that [[react-common-analytic]] loads (`src/getConfig.ts`, every environment) and that TIX-NEXT-PAYMENT-FE sets as `NEXT_PUBLIC_GTM_ID`. How `build/index.js` is injected into pages is configured outside this repo, presumably as a tag in that container.

## Vendors
| Vendor | Page | Scripts |
|---|---|---|
| Meta / Facebook Pixel | [[gtm-extras-facebook]] | `fb-pixel-tag`, `fb-search-tag`, `fb-search-hotel` (commented out), `fb-viewcontent`, `fb-viewcontent-flight-search`, `fb-viewcontent-hotel` |
| TikTok Pixel | [[gtm-extras-tiktok]] | `tiktok-init`, `tiktok-search`, `tiktok-initiatecheckout`, `tiktok-viewcontent-flight`, `tiktok-viewcontent-hotel`, `tiktok-viewcontent` (commented out) |
| Polaris | [[gtm-extras-polaris]] | `handle-polaris-session-source` |
| Ahrefs | [[gtm-extras-ahrefs]] | `seo-ahrefs` |
| Google Optimize | [[gtm-extras-google-optimize]] | `optimize-create-variables` |
| Shared helpers | [[gtm-extras-helpers]] | `helpers`, `temp-tag-gtm-hotel-data-completion` |

The AppsFlyer smart banner (`af-banner.js`) was removed in #34 (98478af). The README intro still mentions AppsFlyer, and `helpers.js` still contains its leftovers (`DISABLED_UTM_SOURCE_FOR_AF_BANNER`, `disableScriptForAffiliatesAndBrands`).

## Coding rules (from README and `.github/copilot-instructions.md`)
- One `.js` per tag in `scripts/`, wrapped in its own IIFE.
- No optional chaining (`?.`). Use `(a || {}).b` chains or `try/catch`.
- Helpers go in `helpers.js`, declared with `var` (bundle order guarantees they exist first).
- Always run `npm run build` and commit `build/index.js`. Jenkins ships the committed file and does not build.
- The README mentions `appendHTML()` / `prependHTML()` helpers, but they do not exist in `helpers.js` at `98478af`.

## Tech stack
Node + npm (`package-lock.json`), gulp 4, gulp-concat, gulp-uglify (`drop_console: false`), gulp-iife, gulp-jsvalidate, gulp-inject-string.

## Commands
`npm install`, `npm run build` (runs `gulp`). Open `build/index.html` to load the bundle in a blank page.

## Sources
- README.md
- .github/copilot-instructions.md
- package.json
- gulpfile.js
- scripts/helpers.js
- TIX-REACT-COMMON packages/react-common-analytic/src/getConfig.ts
