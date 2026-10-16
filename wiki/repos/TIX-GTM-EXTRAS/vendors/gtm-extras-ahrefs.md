---
title: GTM extras Ahrefs verification
repo: TIX-GTM-EXTRAS
kind: vendor
sources:
  - scripts/seo-ahrefs.js
verified_at: 98478af
updated: 2026-10-16
status: current
tags: [repo/gtm-extras, kind/vendor]
---

# GTM extras Ahrefs verification
> Injects the Ahrefs site-verification meta tag on every page that loads the bundle.

## Scripts
| Script | Does |
|---|---|
| `seo-ahrefs.js` | Appends `<meta name="ahrefs-site-verification" content="5ec46143…5d92">` to `<head>`. |

## GTM data read / dataLayer keys
None.

## Gotchas
- The tag is added by JavaScript after load, so Ahrefs must render JS for verification to work. A server-rendered meta tag would be more reliable.
- The comments ("robots", "noindex, follow", "using jQuery") were copied from a template and do not describe what the code does.
- It runs after the FB scripts in bundle order, so an exception in [[gtm-extras-facebook]] (e.g. the `getTodoCategory` bug) skips it.

## Sources
- scripts/seo-ahrefs.js
