---
title: Metasearch redirect and DCO checkout (/metasearch/**)
repo: TIX-GROWTH-NEXT-FE
kind: feature
sources:
  - pages/metasearch
  - lib/services/metasearch.ts
  - lib/types/metasearch.ts
  - lib/hooks/useRetryScheduler.ts
  - lib/utils/backoff.ts
  - lib/utils/url.ts
  - lib/utils/env.ts
  - lib/utils/query.ts
  - lib/gtm/harvesterEventWatcher.ts
  - middleware.page.ts
  - .env.local.example
  - e2e/metasearch
  - docs/flow/metasearch-redirect.md
  - docs/flow/metasearch-checkout.md
verified_at: d4162e3
updated: 2026-10-16
status: current
tags: [repo/growth-fe, kind/feature]
---

# Metasearch redirect and DCO checkout (/metasearch/**)
> Landing pages for metasearch partners (TikTok, Shopback). `/metasearch/r/{slug}` validates the partner and target, stamps `tag_meta*` tracking params and redirects. `/metasearch/c/{dcoCartId}` books a TikTok hotel direct-checkout cart, waits for the harvester `pageVisit` to leave the page, and redirects to payment, with retry/backoff error dialogs.

Part of [[growth-fe-overview]]. Sibling flows: [[growth-fe-affiliate]] (affiliate `/affiliate/r`, `/affiliate/book`).

## What it does
- **Redirect** `/metasearch/r/{slug}?ref=<tiket url>&ttoclid=…&tag_ttoclid=…&tag_mx_cid=…`: makes no backend call. In SSR it checks that `slug` is in `WHITELISTED_PARTNERS` (`100055197`, `100003637`, `100166838`) and that `ref` is a tiket / `tiket.onelink` URL. It then picks a partner handler by the `utm_source` **inside the `ref` URL**, lets the handler add `tag_meta*` / `utm_term` params, and adds `t=<now>` (cache-buster) and `clearTop=false`. On the client it writes `tag_meta*` to `sessionStorage` and navigates. Every failure path returns a 302 to `NEXT_PUBLIC_HOME_PAGE`.
- **Checkout** `/metasearch/c/{dcoCartId}?error_url=…&tag_*=…&utm_*=…`: SSR only resolves device info and passes the query through as props. The client pushes a GTM `pageVisit`, POSTs the book call with every remaining query param forwarded as a request header, and on `SUCCESS` calls `location.replace(withForwardParams(payment_url))`. Errors render a non-dismissible Passport `Dialog` in one of three variants (retry / noRoom / default).

## Routes & entry points
- `pages/metasearch/r/[slug].page.tsx`: `getServerSideProps` → `parseRef` → `DOMPurify.sanitize` → `isRedirectWhitelistDomain` + whitelist → `PARTNER_CONFIGS[utm_source].serverSideFn` → `getDeviceInfo`. Renders `LoadingWithIllustration` ("Relax and take a breath").
- `pages/metasearch/c/[dcoCartId].page.tsx` + `useMetasearchCheckoutPage.ts`: all checkout logic is in the hook. Dialog copy, images and button actions are in `config/error.ts` (`CHECKOUT_DIALOG_CONFIG`).
- Partner handlers (`r/config/partner.ts`, `r/utils/*`, abstract `PartnerRedirection` in `r/types/partnerRedirection.ts`), keyed by `utm_source`:

| `utm_source` | Class | URL params added | `redirectFn` |
|---|---|---|---|
| `aff-tiktok` | `TTDTiktok` | `tag_meta=meta`, `tag_meta_id=100037161` (fixed), `tag_meta_type=tiktok-ttd`, click id | `location.replace`. `ttd_package_code` is moved from the query to the `#hash` |
| `tiktok-hotel` | `TiktokHotel` | `tag_meta_id=<slug>`, `tag_meta_type=tiktok-hotel`, click id | webview: `location.href`, else `location.replace` |
| `shopback-hotel`, `shopback-ttd`, `shopback-flight` | `ShopbackHotel` (all three) | `tag_meta_id=<slug>`, `tag_meta_type=<outer utm_source>`, click id from `tag_mx_cid` | same as tiktok-hotel |

  The TikTok click id is `tag_ttoclid` unless it is empty or `'none'`, otherwise `ttoclid`. It is written to both `utm_term` and `tag_meta_click_id`.
- No layout or `getLayout`: both pages render only their loader or dialog inside the `_app` shell ([[growth-fe-app-shell]]), which still mounts `RemoteScripts` and `GTMScripts`.

## Data & services
| Function | Endpoint | Notes |
|---|---|---|
| `postMetasearchBook` / `useMetasearchBookMutation` (`lib/services/metasearch.ts`) | `POST /meta/partner/tk2/hotel/carts/{dcoCartId}/book` | Goes through `@/lib/fetch` (`@tiket/next` `apiFetch`) with no `apiGateway`, so the default gateway applies. The repo doc gives the full path as `/ms-gateway/partner-gateway/meta/…`. `credentials: 'include'`, `priority: 'low'`. Returns `{ status, retryAfterSeconds, response }` |

- Request headers: the forwarded query params (`queryToHeaders`, first value of arrays, empty values dropped), then the fixed `content-type`, `accept-language: id`, `x-channel-id: WEB` and a fresh `x-request-id` (uuid v4) per call. The fixed headers come last, so a query param can't override them.
- Response type `MetasearchBookApiResponse` (`lib/types/metasearch.ts`): on success, `payment_url`, `navigation_url`, `success_url`, `error_url`, `order_id`, `order_hash`, `booking_expired_time`. Error payloads may carry `data.error_url`. Only `payment_url` and `error_url` are used.
- Error-code mapping (`getDialogVariant`):

| Variant | Codes | Buttons |
|---|---|---|
| `retry` | `E_HOTEL_PREBOOK_FAILED`, `E_HOTEL_BOOKING_FAILED`, `E_DCO_DUPLICATE_IN_PROGRESS` | Retry |
| `noRoom` | `E_HOTEL_ROOM_UNAVAILABLE`, `E_HOTEL_CONTACT_EMAIL_NOT_ALLOWED`, `DUPLICATE_GUEST_NAME`, `BIND_ERROR`, `E_DCO_FORM_ALREADY_USED`, `E_DCO_CART_EXPIRED`, `E_DCO_INVALID_STATE_TRANSITION` | See other rooms |
| `default` | anything else, network error, missing `dcoCartId`, invalid `payment_url`, retry cap reached | See other rooms, Refresh |

  Retry and noRoom append "(Code: {HTTP status})" to the description.
- **Retry:** clicking Retry closes the dialog, shows the loader, waits, and only then re-POSTs. The wait is the last `Retry-After` (numeric seconds only), or `getExponentialBackoffSeconds(attempt)` = `base × 2^(attempt-1)`, capped at max (`lib/utils/backoff.ts`). `useRetryScheduler` counts attempts, toggles `canRetry` and clears its timer on unmount. When a retryable code arrives with `attempt >= MAX_RETRY_ATTEMPTS`, the default dialog is shown instead.
- **"See other rooms"** goes to `data.error_url` from the book response if present, else the query `error_url`. Either is sanitized and must pass `isCheckoutErrorRedirectWhitelistDomain` (tiket / onelink, or the `NEXT_PUBLIC_METASEARCH_ALLOW_PARTNER_DOMAIN_REDIRECT` regex). Otherwise it goes to `/`.
- **Harvester wait** (`lib/gtm/harvesterEventWatcher.ts`): before pushing `pageVisit`, `waitForHarvesterEvent('pageVisit', timeout)` proxies `window.fetch`. It settles when a request to `/cancer/harvester/event` whose JSON body has `identifier.event_name === 'pageVisit'` gets a response (or fails), or when the timeout passes. The success redirect is chained on that promise. The harvester is loaded by `RemoteScripts` ([[react-remote-scripts]]); the endpoint is the one `postUserAttributes` in [[react-common-core-attributes]] posts to.
- Envs (`.env.local.example`; all are `NEXT_PUBLIC_`, so they are inlined at build time):

| Env | Default in code | Use |
|---|---|---|
| `NEXT_PUBLIC_METASEARCH_CHECKOUT_MAX_RETRY` | 5 | retry cap |
| `NEXT_PUBLIC_METASEARCH_CHECKOUT_BACKOFF_BASE_SECONDS` | 1 | backoff base |
| `NEXT_PUBLIC_METASEARCH_CHECKOUT_BACKOFF_MAX_SECONDS` | 60 | backoff cap |
| `NEXT_PUBLIC_METASEARCH_CHECKOUT_BYPASS_HARVESTER_WAIT` | false | `'true'` skips the fetch proxy and redirects immediately (local/dev) |
| `NEXT_PUBLIC_METASEARCH_CHECKOUT_HARVESTER_TIMEOUT_MS` | 5000 | upper bound on the redirect hold |
| `NEXT_PUBLIC_METASEARCH_ALLOW_PARTNER_DOMAIN_REDIRECT` | unset | one regex source added to the checkout error-URL allowlist. The example is `^aweme:\/\/poi\/` (TikTok app deep link) |
| `NEXT_PUBLIC_METASEARCH_API_ENDPOINT` | — | in the example file but **read nowhere** |
| `NEXT_PUBLIC_HOME_PAGE`, `NEXT_PUBLIC_AFFILIATE_ID`, `NEXT_PUBLIC_DEBUG` | — | redirect fallback; `affiliateId` override; `'true'` turns on SSR `createLogger` logs (headers without cookie, cookies, query) |

## Key components
- Passport: `LoadingWithIllustration`, `Dialog` (`withCloseButton={false}`) ([[passport-umbrella|passport]]). Images: `tds_si_error_too_many_requests`, `tds_si_hotel_no_room`, `tds_si_hotel_time_out` from [[passport-assets]].
- `useForwardParams` from [[passport-utils]] (provider mounted in `AppProvider`) adds the forwarded params to `payment_url`.
- `lib/navigation/windowLocation.ts` wraps `location.replace/reload` and `history.back` so Jest can mock them.

## Tracking
- Checkout: `pageVisit('growth', { screenName: 'metasearchCheckoutPage', vertical: 'growth', screenOwner: 'growth', tag_dco_cart_id })` in a `useLayoutEffect` once `router.isReady`. It goes to `window.gtm.growth` and `dataLayer` ([[gtm-datalayer-tracking]]).
- Redirect: no GTM push. Attribution travels as `tag_meta*` / `utm_term` URL params, which the landing page's core attributes pick up through `getTagParams` ([[react-common-core-attributes]]), plus the `sessionStorage` keys `tag_meta`, `tag_meta_id`, `tag_meta_type`, `tag_meta_click_id`. These are not the TikTok Pixel scripts in [[gtm-extras-tiktok]].

## Tests
- Jest: `pages/metasearch/c/__tests__/` (page, hook with 24 cases including the harvester bypass), `c/config/__tests__/error.spec.ts`, `lib/services/__tests__/metasearch.spec.tsx`, `lib/hooks/__tests__/useRetryScheduler.spec.ts`, `lib/utils/__tests__/backoff.spec.ts`, `lib/gtm/__tests__/harvesterEventWatcher.spec.ts`, `lib/utils/__tests__/url.spec.ts`. **`/metasearch/r` and the partner classes have no unit tests.**
- Playwright (`pnpm e2e`, Jest ignores `e2e/`): `e2e/metasearch/redirect.spec.ts` (non-whitelisted slug, foreign ref, unknown `utm_source`, aff-tiktok hotel, TTD package hash, tiktok-hotel PDP) and `checkout.spec.ts` (book endpoint mocked with `page.route('**/hotel/carts/*/book')`: success redirect, retry, noRoom, default, See other rooms). The base URL comes from `PLAYWRIGHT_APP_ENV` (local `https://local.tiket.com:3000`, staging, preprod, prod) in `e2e/playwright.env.ts`. The config starts `next dev -p 3000` unless `PLAYWRIGHT_SKIP_WEBSERVER` is set. See [[growth-fe-workflows]].

## Gotchas
- **`middleware.page.ts` skips `/metasearch/r`** (`isApplicationRoute`, together with `affiliate/book` and `b2b-gateway`). That path gets no locale/currency middleware, no `/{locale}` rewrite and no middleware data. `/metasearch/c` does go through the middleware.
- **`ref` swallows the rest of the query.** `parseRef` takes everything after the first `ref=` in the raw URL (and decodes it if it is encoded). Partner links put `utm_source`, `utm_*` after `ref`, unencoded, so they end up in the target URL, and that is where the partner is looked up. Params placed after `ref` are also still visible to Next's `query` (e.g. the Shopback `utm_source`, `ttoclid`).
- **The domain allowlist is a regex over the whole string, not a hostname check.** `isTiketDomain` is `^(https?://)?([^/]+\.)?tiket\.com.*$`, so `https://tiket.com.evil.io/x` and `https://evil.com?.tiket.com` pass. `isTiketOneLink` matches `tiket.onelink` anywhere in the string. The same check guards `ref` and the checkout `payment_url`.
- Partner selection uses `utm_source` from `ref`. The `slug` only has to be whitelisted: for `aff-tiktok` the `tag_meta_id` is hard-coded `100037161` whatever the slug.
- `ShopbackHotel` handles `shopback-ttd` and `shopback-flight` too. Its URL `tag_meta_type` uses the outer query `utm_source`, but its `storageSet` writes `shopback-hotel` for anything that isn't exactly `shopback-hotel`.
- `PartnerRedirection.isCheckVisibility` is set by each class but never read. `affiliateId` (`NEXT_PUBLIC_AFFILIATE_ID || slug`) is passed to `storageSet` but no handler uses it. No baseline repo in the workspace reads the `tag_meta*` sessionStorage keys.
- Webview back-navigation: both pages add a `visibilitychange` listener that becomes active after 300 ms. When the user comes back to the tab, `/r` goes to `/` and `/c` calls `history.back()`.
- **The flow doc is out of date on the GTM gate.** `docs/flow/metasearch-checkout.md` says a throwing `pageVisit` stops the book call. In code, `pageVisit` runs in its own `useLayoutEffect`, and the `try/catch` (whose log still says "pageVisit push failed") only wraps `runCheckout`.
- **Error URL param name:** SSR reads `error_url`, but the doc and the e2e spec send `errorUrl`. Both work, because the rest of the query is spread after `errorUrl` in the props, so `?errorUrl=` overrides `error_url`. Neither one is forwarded as a header. Every other query param (including `utm_*` with underscores) is forwarded as a header **and** serialized into `__NEXT_DATA__`.
- `getPositiveNumberEnv` rejects `0`, so retries can't be turned off with `MAX_RETRY=0`; it falls back to 5. A `Retry-After` given as an HTTP date is ignored, and exponential backoff is used instead.
- `harvesterEventWatcher` patches `window.fetch` once per page lifetime with a `Proxy` and never restores it. The timeout comment notes that on staging the event lands about 2.9–3.1 s after navigation, so a successful checkout normally holds the redirect for about 3 s.
- The flight b2b "metasearch cart" (`/tix-flight-cart/v5/b2b/metasearch/cart` in `lib/services/b2b.ts`) belongs to the affiliate book flow ([[growth-fe-affiliate]]), not to this feature.

## Sources
- `pages/metasearch/r/[slug].page.tsx`, `r/config/{app,partner}.ts`, `r/types/partnerRedirection.ts`, `r/utils/{shopback-hotel,tiktok-hotel,tiktok-ttd}.ts`
- `pages/metasearch/c/[dcoCartId].page.tsx`, `c/useMetasearchCheckoutPage.ts`, `c/config/error.ts`, `c/__tests__/*`, `c/config/__tests__/*`
- `lib/services/metasearch.ts`, `lib/types/metasearch.ts`, `lib/hooks/useRetryScheduler.ts`, `lib/utils/backoff.ts`, `lib/utils/url.ts`, `lib/utils/env.ts`, `lib/utils/query.ts`, `lib/utils/device.ts`, `lib/gtm/harvesterEventWatcher.ts`, `lib/gtm/event.ts`, `lib/navigation/windowLocation.ts`, `lib/fetch/fetch.ts`
- `middleware.page.ts`, `.env.local.example`, `pages/_app.page.tsx`, `components/providers/AppProvider.tsx`
- `e2e/metasearch/{redirect,checkout}.spec.ts`, `e2e/playwright.env.ts`, `playwright.config.ts`, `jest.config.mjs`
- `docs/flow/metasearch-redirect.md`, `docs/flow/metasearch-checkout.md`
- TIX-REACT-COMMON `packages/react-common-core-attributes/src/utils/getTagParams.ts` (origin/master)
