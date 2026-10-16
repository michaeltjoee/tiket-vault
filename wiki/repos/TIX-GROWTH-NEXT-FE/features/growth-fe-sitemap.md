---
title: Flight SEO sitemap (/sitemap via /pesawat, /flights rewrites)
repo: TIX-GROWTH-NEXT-FE
kind: feature
sources:
  - pages/sitemap
  - lib/services/seo/getFlightSitemap.ts
  - lib/config/apiUrl.ts
  - rewrite-path-config.js
  - next.config.js
  - components/SEOPageHead
  - lib/i18n/en.ts
  - lib/i18n/id.ts
verified_at: d4162e3
updated: 2026-10-16
status: current
tags: [repo/growth-fe, kind/feature]
---

# Flight SEO sitemap (/sitemap via /pesawat, /flights rewrites)
> Server-rendered link lists for flight SEO hubs (airlines, routes, destinations, an airline's destinations). They are reached only through Next rewrites from `/pesawat/*` and `/flights/*`. Data comes from `tix-flight-seo/site-map`.

Part of [[growth-fe-overview]]. Migrated from the gamification app in PR #23 (with stories and blibli-affiliate, see [[growth-fe-stories]], [[growth-fe-blibli-affiliate]]).

## What it does
Renders the remote header, a breadcrumb, an `h1` title for the category, a flat list of `<a>` links (title → url) and footer, plus an `ItemList` JSON-LD block. The category is derived from the **original request path**, not from a query param.

## Routes & entry points
- `pages/sitemap/index.page.tsx` is the only page. `next.config.js` spreads `SEO_PATH_REWRITE_RULES` from `rewrite-path-config.js` into `rewrites()`:

| Public path | Category (`ROUTE_PATTERN`) | API `categories=` | Title key |
|---|---|---|---|
| `/pesawat/maskapai`, `/flights/airlines` | `AIRLINE` | `airline` | `pages.sitemap.flight.title.airline` |
| `/pesawat/rute`, `/flights/route` | `ROUTE` | `route` | `…title.route` |
| `/pesawat/tujuan`, `/flights/to` | `DESTINATION` | `destination` | `…title.destination` |
| `/pesawat/maskapai/:slug/tujuan`, `/flights/airlines/:slug/to` | `AIRLINE_DESTINATION` | `airlineDestination` | `…title.airline_destination` |

  Rules for bare `/tujuan` and `/to` are commented out.
- `getServerSideProps`: `getServerSidePropsMiddlewareData` → `getReactRemoteProps` (header with only `isLogin` 0/1, per NCT-2554; footer) → strip query/hash from `ctx.req.url` → `generateSitemapParams` (trims slashes, tests the patterns in the order ROUTE, AIRLINE, DESTINATION, AIRLINE_DESTINATION) → `notFound` if nothing matches → `getFlightSitemap`. `originUrl = NEXT_PUBLIC_NON_PREFIXED_HOSTNAME + path` feeds the breadcrumb and the JSON-LD `@id`.
- No `getLayout`. Middleware applies (locale rewrite), see [[growth-fe-app-shell]].

## Data & services
| Function | Endpoint | Notes |
|---|---|---|
| `getFlightSitemap(ctx, query)` (`lib/services/seo/getFlightSitemap.ts`) | `GET /tix-flight-seo/site-map?categories=<cat>&lang=<middleware locale>` | Server-side through `@/lib/fetch` (`@tiket/next` `apiFetch`, default gateway). Resolves `{code:'SUCCESS', data}`. Any non-OK status, non-`SUCCESS` code or exception resolves `{code:'RUNTIME_ERROR', data:null}` and never throws |

- `data` is `TSitemap = Record<'airline'|'route'|'airlineDestination'|'destination', {title,url}[]>`. The page flattens every non-null category for both the list and the JSON-LD.
- Copy: `pages.sitemap.*` in `lib/i18n/{en,id}.ts` (titles, breadcrumb labels, JSON-LD name/description).

## Key components
- `blocks/ItemList.tsx`: Passport `Text as="a"` links (plain anchors, `key={item.title}`).
- `blocks/Breadcrumbs`: [[passport-breadcrumb]]. It understands an optional `xx-yy` lang-country segment ([[new-url-structure]]), maps `flights/pesawat`, `airlines/maskapai`, `route/rute`, `to/tujuan` to i18n labels, and capitalizes any other segment (the airline slug).
- `JsonLd.tsx`: `<script type="application/ld+json">` `ItemList` with `ListItem` positions.
- Shared: `components/RemoteHeader` (`MainRemoteHeader`), `RemoteFooter` from [[react-common-remote]], `components/SEOPageHead` (`device="desktop"`), see [[growth-fe-components]].

## Tracking
None. The page pushes no GTM event.

## Tests
`pages/sitemap/__tests__/{index,helper,JsonLd}.spec.tsx`, `blocks/__tests__/{Breadcrumbs,ItemList}.spec.tsx` (about 30 cases: notFound, query building `categories=airline&lang=id`, originUrl stripping, regex matching including `/_next/data/...` paths).

## Gotchas
- **`/sitemap` itself returns 404.** The category comes from `ctx.req.url`, which still holds the pre-rewrite public path, so a direct request to `/sitemap` matches no pattern.
- **The airline slug is never sent to the API.** `/flights/airlines/:slug/to` only sends `categories=airlineDestination&lang=…`. Every airline gets the same list; only the breadcrumb shows the slug.
- Only the hub paths are rewritten. `/flights/airlines/:slug` and `/flights/route/:slug` are not rewritten here (although `ROUTE_PATTERN` comments mention slugs), so they are served by another app.
- **Backend failure renders a 200 page with no list**, because `getFlightSitemap` swallows errors. The page is not a 404 or 500, so crawlers index an empty hub.
- `SEOPageHead` gets no `title`/`description`, so `<title>` and the meta description are the generic `meta.*` strings. `pages.sitemap.meta.*` is used only inside the JSON-LD.
- On a client-side transition `req.url` is `/_next/data/<build>/<locale>/….json`. The `AIRLINE` pattern ends in `$` and fails on `.json` (404), and `originUrl` would contain the data path. Links on the page are plain `<a>`, so normal visits are full page loads.
- **`BTM_PATH_REWRITE_RULES`** (`/dynamic-content-module/btm-mini-pdp` → `/btm-mini-pdp`) is exported from `rewrite-path-config.js` but **imported nowhere**: `next.config.js` takes only `SEO_PATH_REWRITE_RULES`. No `btm-mini-pdp` page exists in this repo or in homepage-fe. It looks like a leftover from the gamification migration (the file's only commit is #23).
- `SITEMAP_VERTICAL = ['flights']` in `types.ts` is unused.

## Sources
- `pages/sitemap/index.page.tsx`, `helper.ts`, `types.ts`, `JsonLd.tsx`, `blocks/ItemList.tsx`, `blocks/Breadcrumbs/index.tsx`, `__tests__/*`, `blocks/__tests__/*`
- `lib/services/seo/getFlightSitemap.ts`, `lib/config/apiUrl.ts` (`SEO_SITEMAP`)
- `rewrite-path-config.js`, `next.config.js` (`rewrites()`)
- `components/SEOPageHead/{index.tsx,useSEOData.ts}`, `lib/i18n/{en,id}.ts`
- `CHANGELOG.md` (#23 migration)
