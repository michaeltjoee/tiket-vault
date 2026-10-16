---
title: Affiliate book, co-brand landing and redirect (/affiliate/**)
repo: TIX-GROWTH-NEXT-FE
kind: feature
sources:
  - pages/affiliate
  - lib/services/b2b.ts
  - lib/services/cobrand.ts
  - lib/services/partner.ts
  - lib/gtm/pages/CoBrand.ts
  - lib/types/b2b.ts
  - lib/types/cobrand.ts
  - lib/types/partner.ts
  - lib/mocks/msw-handlers.ts
  - lib/mocks/data/b2b
  - lib/utils/url.ts
  - docs/flow/affiliate-book-product.md
  - docs/flow/affiliate-cobrand-landing.md
  - docs/flow/affiliate-redirect.md
  - e2e/affiliate
  - middleware.page.ts
  - next.config.js
verified_at: d4162e3
updated: 2026-10-16
status: current
tags: [repo/growth-fe, kind/feature]
---

# Affiliate book, co-brand landing and redirect (/affiliate/**)
> Three affiliate entry points. `/affiliate/book/flight` turns a Google Flights deep link into a B2B flight cart and redirects to it. `/affiliate/c/{slug}` is a partner co-brand landing page. `/affiliate/r/{publicId}` validates a partner and redirects to a tiket.com URL with affiliate tags.

## What it does
- **Book** `/affiliate/book/{product}`: a loading screen only. In the browser it runs init search → poll stream → create cart, then sets `location.href` to `/cart/flight/{cartId}?{attribution tags}`. Any failure sends the user to the flight SRP (`/pesawat/search?...`) built from the same query. Only `product=flight` is supported. It replaces the legacy TIX-B2B-LANDING-FE (the attribution logic says it mirrors that repo).
- **Co-brand** `/affiliate/c/{slug}`: SSR fetches the partner campaign config. The page renders a hero (banner title, product icons, highlight carousel), "how to get the benefit" cards, a page-module section (`AFF_C_{SLUG}`) and T&C. Partners distribute the link through their own channels.
- **Redirect** `/affiliate/r/{publicId}?ref=<url>`: SSR checks that `ref` is a tiket domain and that the partner exists. The client then calls `location.replace(ref + tag_aff_id + tag_aff_type=redirection [+ utm_term=ttoclid] + any extra query params)`. Used by platforms such as TikTok and Google, where tiket.com is listed as a provider.

## Routes & entry points
- `pages/affiliate/book/[product]/index.page.tsx`: `getServerSideProps` returns `notFound` unless `product.toLowerCase() === 'flight'`. Otherwise it returns remote props (`header` variant `default`, `footer-desktop`) and `middlewareData`. The flow runs in a `useEffect` (`executeFlightFlow`), and the footer renders only on desktop.
- `pages/affiliate/c/[slug].page.tsx`: `getServerSideProps` gets middleware data, remote props (`header` with `variant: 'transparent'`, `footer`), `getDeviceInfo`, and `getCobrandConfig(slug, locale || userlang cookie || 'id')`. When `code !== 'SUCCESS'` it sets status 404 and returns `notFound`. It adds `utm_medium: 'aff-cobrand'` to the `queries` prop.
- `pages/affiliate/r/[slug].page.tsx`: `getServerSideProps` only. It does not fetch middleware data or remote props. Every failure returns a 302 to `NEXT_PUBLIC_HOME_PAGE`.
- **`middleware.page.ts` skips `/affiliate/book`** (`isApplicationRoute`, together with `/b2b-gateway` and `/metasearch/r`). There is no locale rewrite or middleware chain for the book page. `/affiliate/c` and `/affiliate/r` go through the normal chain.

## Data & services
| Function | Endpoint | Used by |
|---|---|---|
| `postFlightSearch` (`lib/services/b2b.ts`) | `POST /b2b-gateway/tix-affiliate-platform/flight/search` body `{ parameters: [{parameterName, value}] (every non-empty query param), partnerID: 'google' }` → `{ requestItem }` | book, init |
| `postFlightSearchStream` | `POST /b2b-gateway/tix-affiliate-platform/flight/search/stream` `{ requestItem }` → `{ complete, cartRequest: { currency, departurePrice, cartDetails[] } }` | book, stream |
| `postFlightCart` | `POST /b2b-gateway/tix-flight-cart/v5/b2b/metasearch/cart` `{ cartDetails, currency, channelId }` → `{ data: { cartId } }` | book, create cart |
| `getCobrandConfig` (`lib/services/cobrand.ts`) | `GET ${NEXT_PUBLIC_AFFILIATE_NONA_INGRESS}/tix-affiliate-nona-internal/cobrand/landing-page?slugUrl=&countryId=` (SSR, internal cluster service) | co-brand |
| `getInitialData` from [[passport-page-module]] | `/ms-gateway` page module, `pageModuleCode: AFF_C_{SLUG uppercased}` (CSR, React Query `retry: 1`, `staleTime` 5 min) | co-brand (`hooks/usePageModule.tsx`) |
| `getPartnerByPublicId` (`lib/services/partner.ts`) | `GET ${NEXT_PUBLIC_AFFILIATE_BE_INTERNAL_SERVICE}/tix-affiliate-partner-internal/partner/data?publicId=` (SSR, `skipAuth`) | redirect |

- The B2B calls use `apiGateway: 'b2b-gateway'` through the local `lib/fetch` wrapper (`apiFetch` from [[tiket-next-core]]). `next.config.js` adds **dev-only** rewrites (`PHASE_DEVELOPMENT_SERVER`) from `/b2b-gateway/*` and `/partner-gateway/*` to `https://gatotkaca.tiket.com/...`. In deployed environments the host serves these paths.
- `createFlightCart` sends extra headers: `X-Channel-Id`/`ChannelId`, `X-Currency`, `X-Reseller-Type: B2B_METASEARCH`, `X-Store-Id`/`StoreId: TIKETCOMB2B`, and `resellerId: NEXT_PUBLIC_B2B_GOOGLE_RESELLER_ID`.
- Book constants (`constants.ts`): `REQUEST_INTERVAL` 1000 (the wait between stream polls is `REQUEST_INTERVAL * 2` = 2 s, fixed), `REQUEST_LIMIT` 20, `CREATE_CART_RETRY_TIME` 3 (500 ms apart).
- Cart currency (`utils/currency.ts`): with `NEXT_PUBLIC_CUSTOM_CURRENCY_CONFIG=true`, the order is the `PointOfSaleCountry` currency from `COUNTRY_CURRENCY_MAP` ([[react-common-utilities]]), then `DisplayedPriceCurrency` if supported, then the middleware currency if supported, then `USD`. With the flag off, it is the middleware currency, falling back to `USD`.
- URLs (`utils/url.ts`): `generateFlightSRPUrl` maps `Origin1` → `d`, `Destination{last index of Slice1}` → `a`, `DepartureDate{first index of Slice1}` → `date`, `DepartureDate{last index of Slice2}` → `ret_date`, `Cabin1` → `class`, plus `gclid`/`gclsrc`. `generateFlightCartQuery` walks `ATTRIBUTION_TAGS` in order. It forwards `utm_source`, `utm_content`, `utm_campaign`, `ChannelId`, `utm_term`, `tag_aff_id`, `tag_aff_type`, `tag_meta_id`, forces `utm_medium=aff-meta` and `tag_meta_type=google-flight`, forces `tag_meta_id` to the reseller id env, then appends `gclid`/`gclsrc`. Both redirects then go through `withForwardParams` (`useForwardParams` from `@tiket/passport`).
- Co-brand session storage: `aff-co-logo` (partner header logo URL) and `tag_aff_id` (publicId). The redirect page writes `tag_aff_id` (`SS_TAG_AFF_ID`).
- Types: `lib/types/b2b.ts`, `cobrand.ts` (`CobrandConfigResponse`; note the misspelled field `higlightCards`), `partner.ts`.

## Key components
- Book: `LoadingWithIllustration` ([[passport-loading]]), `RemoteHeader` (`showBackIcon`, empty `rightIcons`) and `RemoteFooter isCritical` from [[react-common-remote]].
- Co-brand (`pages/affiliate/c/components/`): `Hero` (`next/dynamic`, `ssr: false`) with `MenuIcon` (also `ssr: false`; it reads `window`) and an `OfferCard` carousel built with `Carousel`/`Layout` from [[passport-page-module-shared]] (`visibleItems` base 1.15, large 3). Also `Benefit`/`BenefitCard`, `Terms` (`RichText` inline on desktop, a full-height [[passport-bottom-sheet]] on mobile), `PageModule` from [[passport-page-module]] (`ssr: false`, `screenName="cobrand"`, `screenOwner="affiliate"`) and `components/Loading`. Copy lives in its own i18n context `pages/affiliate/c/i18n` (`AffiliateCoBrandI18nProvider`, id/en). See [[growth-fe-components]].
- Redirect: `RemoteHeader` and `LoadingWithIllustration` ("Relax and take a breath").

## Tracking
- `lib/gtm/pages/CoBrand.ts` (exported as `CoBrandGTM`). `initialLoadPage(isLogin, slug, platform, isFirstPage)` runs on mount: `pushGTM('affiliate', { screenName: 'coBrandLandingPage', data: { status, coBrandSlug, isFirstPage } })`, then `pageView` / `pageVisit` / `coBrandVisit` with `utmSection`/`utmLogic`/`utmPage` from the URL. `isFirstPage` is 0 when the referrer (or `sessionStorage.referrer`) contains `tiket.com` and `window.isSessionExpired` is falsy. `onClickProduct` sends `click` / `enterVertical` / `clickIcon` with the product name and URL. See [[gtm-datalayer-tracking]].
- Book and redirect send no GTM events. Book logs every step through `createLogger({ name: 'affiliate/book' })` plus `standardizedLogData`, and on failure logs `flow failed at {step}` (`init`/`stream`/`createCart`/`redirect`). The co-brand and redirect pages log SSR outcomes (`affiliate/c`, `affiliate/r`).

## Tests
- Unit (Jest): `book/[product]/__tests__/index.page.spec.tsx` (logging and SSR 404), `utils/__tests__/flight-flow/{initializeFlightSearch,streamFlightSearch,createFlightCart}.spec.ts`, `getCurrency.spec.ts`, `url.spec.ts`, `c/__tests__/[slug].page.spec.tsx`, `lib/services/__tests__/b2b.spec.ts`. The redirect page has no unit test.
- E2E (Playwright, `e2e/affiliate/`): `book-flight.spec.ts`, `c-cobrand.spec.ts`, `r-redirect.spec.ts`. They need `E2E_COBRAND_SLUG`, `E2E_PARTNER_PUBLIC_ID` and optionally `E2E_VALID_REF_URL`. `PLAYWRIGHT_APP_ENV` (local/staging/preprod/prod) picks the base URL and the `NEXT_PUBLIC_HOME_PAGE` passed to `next dev`. See [[growth-fe-workflows]].
- MSW: `lib/mocks/msw-handlers.ts` mocks the three B2B calls with `lib/mocks/data/b2b/flight.{search,stream,cart}.json` (`requestItem: mock-requestitem-flight`, `cartId: mock-cartid-flight`). Add `MockCase=Error` to the page URL to get the error response from flight search. This works because every query param is forwarded as a search `parameter`. Mocking is on when `NEXT_PUBLIC_API_MOCKING=enabled` (`.env.test`). The browser worker starts from `_app`, and SSR uses `registerFetchMock` in `instrumentation.page.ts`.

## Gotchas
- **`docs/flow/affiliate-book-product.md` is partly stale.** It says a non-flight product fires `reportInvalidProductType` and redirects to SRP on the client. That function doesn't exist, and SSR returns 404. It also says the stream waits for `complete: true`. Since GRA-8412 (#64), `streamFlightSearch` ignores `complete` and returns as soon as any `cartDetails` entry has both `flightId` and `supplierRequest.supplierId`.
- The comment calls the stream wait "exponential backoff", but it is a fixed 2 s. The worst case is about 20 × (request + 2 s) ≈ 40 s+ of loader before the SRP fallback.
- The services fail in different ways. `postFlightSearch` swallows errors and returns `requestItem: ''`, so the flow throws "No request item received". `postFlightSearchStream` **throws** on a fetch error, which aborts the flow at once without using the remaining poll attempts. `postFlightCart` returns a `RUNTIME_ERROR` object, so there is no `cartId` and it retries.
- `ChannelId` must equal `google` case-insensitively (`Google` works), or the flow fails at `init` and goes to SRP.
- Because middleware skips `/affiliate/book`, `useMiddlewareData()` may not have the user currency. The cart currency then comes from `PointOfSaleCountry`/`DisplayedPriceCurrency` (flag on) or falls back to `USD`.
- `gclid`/`gclsrc` are added by hand because `ForwardParamsProvider` only forwards `tag_*` and `currency`. Keep `ATTRIBUTION_TAGS` in the legacy order. `tag_meta_id` appears twice on purpose, and the second entry overrides any URL value with `NEXT_PUBLIC_B2B_GOOGLE_RESELLER_ID`.
- E2E `book-flight` expects `/flights/search` on failure (the app builds `/pesawat/search`. Something outside this repo then lands on `/flights/search`, but where that happens hasn't been checked) and a numeric `cartId`. It therefore runs against the real staging B2B gateway through the dev rewrite, not the MSW mock, whose `mock-cartid-flight` would not match `\d+`.
- No app code on the baseline calls `/partner-gateway` directly. The metasearch checkout uses `/ms-gateway/partner-gateway/...` (see [[growth-fe-metasearch]]), so that dev rewrite looks unused.
- Co-brand: `Hero`, `MenuIcon` and `PageModule` are client-only, so the SSR HTML has no banner title, product links or modules. Only `Benefit` and `Terms` are server-rendered.
- Co-brand: `useI18n()` in `CoBrand` runs above the `AffiliateCoBrandI18nProvider` that it renders. The `<meta name="description">` therefore reads the context default, not the page dictionary.
- Co-brand: the SSR header props ask for `variant: 'transparent'`, but the component renders `RemoteHeader variant="default"`.
- Co-brand: `getCobrandConfig` has no try/catch. A network error or a non-JSON body throws inside `getServerSideProps` (500, not 404). Its `x-request-id` is a single `uuidv4()` created at module load, so every request from one server process sends the same id. `pages/api/partner-config.page.ts` does the same.
- Co-brand: on mount, `addParamsToQuery` does a **shallow client `router.push`**, not an SSR redirect. It fills in any missing `tag_aff_id` (publicId), `tag_aff_type=cobrand`, `utm_source`/`utm_campaign` (from config) and keeps the `/{lang}-{country}` prefix. `MenuIcon` rebuilds every product link on `NEXT_PUBLIC_HOME_PAGE`. It keeps only the configured URL's path and query, adds the locale-country prefix when the path isn't new-structure ([[new-url-structure]]), and appends `tag_aff_id`, `tag_aff_type=cobrand`, `utm_medium=aff-cobrand` and the config UTMs.
- Co-brand: each partner needs a page-module configuration with code `AFF_C_{SLUG}`, or that section stays empty. There is no error UI.
- The `aff-co-logo` session key is read by [[passport-header]] (`packages/header/src/utils/cobrand/getCoBrandLogoUrl.ts`) to show the partner logo on later tiket pages. When `tag_aff_id` is in the URL, the header first fetches `/ms-gateway/tix-affiliate-nona-app/cobrand/logo?publicId=` and overwrites the key.
- Redirect: `isRedirectWhitelistDomain` tests a regex against the raw string, not the parsed host. `tiket.com` followed by anything passes (`https://tiket.com.example.org`), and `tiket.onelink` anywhere in the string passes. The partner lookup must still succeed.
- Redirect: the `partnerId` prop and the `tag_aff_id` session value are `data.publicId`, which equals the slug, not `data.partnerId`. Extra query params are merged on the client with `searchParams.set`, so they override params with the same name inside `ref`. They don't appear in the SSR log's `redirectUrl`.
- Redirect: the partner LRU cache (1 h, 10 entries) is per server process and also caches non-`SUCCESS` responses. A partner that was looked up before it existed stays "not found" for up to an hour on that pod. Thrown errors are not cached.
- E2E `r-redirect` "session storage" reads the key `'SS_TAG_AFF_ID'` (the constant's name, not its value `tag_aff_id`) and only asserts when the value is non-null, so it never checks anything. Many co-brand and redirect e2e assertions are wrapped in `if (count)` guards.

## Sources
- `pages/affiliate/book/[product]/index.page.tsx`, `constants.ts`, `utils/currency.ts`, `utils/url.ts`, `utils/flight-flow/*`, `__tests__/*`, `utils/__tests__/**`
- `pages/affiliate/c/[slug].page.tsx`, `components/**`, `hooks/usePageModule.tsx`, `i18n/*`, `types.ts`, `__tests__/[slug].page.spec.tsx`
- `pages/affiliate/r/[slug].page.tsx`
- `lib/services/b2b.ts`, `lib/services/cobrand.ts`, `lib/services/partner.ts`, `lib/services/__tests__/b2b.spec.ts`
- `lib/types/b2b.ts`, `lib/types/cobrand.ts`, `lib/types/partner.ts`
- `lib/gtm/pages/CoBrand.ts`, `lib/gtm/helper.ts`, `lib/utils/url.ts`, `lib/utils/addUrlParams.ts`, `lib/hooks/useSessionStorage.ts`, `lib/config/app.ts`, `lib/fetch/*`
- `lib/mocks/msw-handlers.ts`, `lib/mocks/msw-init.ts`, `lib/mocks/data/b2b/*.json`, `instrumentation.page.ts`, `.env.test`, `.env.local.example`
- `docs/flow/affiliate-book-product.md`, `docs/flow/affiliate-cobrand-landing.md`, `docs/flow/affiliate-redirect.md`
- `e2e/affiliate/*.spec.ts`, `e2e/playwright.env.ts`, `playwright.config.ts`
- `middleware.page.ts`, `next.config.js`
- Commit 86c118c (GRA-8412, #64): stream completion change
