---
title: GTM extras Google Optimize
repo: TIX-GTM-EXTRAS
kind: vendor
sources:
  - scripts/optimize-create-variables.js
verified_at: 98478af
updated: 2026-10-16
status: deprecated
tags: [repo/gtm-extras, kind/vendor]
---

# GTM extras Google Optimize
> Exposes the active Google Optimize experiment as `window.optimize`. Very likely dead code.

Part of [[gtm-extras-overview]].

## Scripts
| Script | Does |
|---|---|
| `optimize-create-variables.js` | If `gaData` exists, it reads `gaData[<trackingId of ga.getAll()[0]>].experiments` and sets `window.optimize = {experimentId, variantId}` from the first experiment. |

## GTM data read / written
- Reads the Universal Analytics globals `gaData` and `ga`.
- Writes `window.optimize.{experimentId, variantId}`, which GTM variables can read. Nothing is pushed to the dataLayer.

## Gotchas
- Google shut down Google Optimize and Universal Analytics in 2023 (external fact, not from the repo). `gaData` is normally absent, so the script returns immediately. It is a candidate for removal.
- If `gaData` exists but `ga` does not, it throws `ReferenceError`, which aborts later scripts in the bundle.
- The local `var optimize` default is never used.

## Sources
- scripts/optimize-create-variables.js
