---
title: GTM extras Polaris session source
repo: TIX-GTM-EXTRAS
kind: vendor
sources:
  - scripts/handle-polaris-session-source.js
verified_at: 98478af
updated: 2026-10-16
status: current
tags: [repo/gtm-extras, kind/vendor]
---

# GTM extras Polaris session source
> Copies `polaris_id` query values into `window.gtm.sessionSource` so GTM tags can attribute the session.

## Scripts
| Script | Does |
|---|---|
| `handle-polaris-session-source.js` | Splits `location.search` on `&`. For each pair whose text contains `polaris_id`, it sets `gtm.sessionSource` to the value, or appends `,<value>` if a source already exists. |

## GTM data read and written
- Reads the URL query, plus `window.gtm.sessionSource`.
- Writes `window.gtm.sessionSource`, creating `window.gtm` if needed. Nothing is pushed to the dataLayer. No code in the six workspace repos reads `sessionSource` (git grep on the baselines), so the consumer is presumably a GTM variable inside container `GTM-PLRJPPQ`.

## Gotchas
- The match is `includes('polaris_id')`, so any key or value containing that text matches (e.g. `x_polaris_id`).
- The value is not URL-decoded.
- The first check `((window.gtm||{}).sessionSource||{}) === 'undefined'` compares an object to a string and is always false. Only the empty-string check decides between set and append.
- The repo does not say what Polaris is. Treat it as an internal attribution source and confirm with the tracking team (`#ask-tracking`).

## Sources
- scripts/handle-polaris-session-source.js
