---
title: GTM extras Facebook Pixel
repo: TIX-GTM-EXTRAS
kind: vendor
sources:
  - scripts/fb-pixel-tag.js
  - scripts/fb-search-tag.js
  - scripts/fb-search-hotel.js
  - scripts/fb-viewcontent.js
  - scripts/fb-viewcontent-flight-search.js
  - scripts/fb-viewcontent-hotel.js
verified_at: 98478af
updated: 2026-10-16
status: current
tags: [repo/gtm-extras, kind/vendor]
---

# GTM extras Facebook Pixel
> Meta Pixel bootstrap plus Search and ViewContent events for travel ads, driven by `window.gtm`.

Part of [[gtm-extras-overview]].

## Scripts
| Script | Fires | Condition |
|---|---|---|
| `fb-pixel-tag.js` | `fbq('init', '295057137344359')`, `PageView` | always, after `INIT_SCRIPT_DELAY` (1 s); also appends a `<noscript>` tracking img |
| `fb-search-tag.js` | `Search` | `RMKTSearchAllTriggerCondition(location.pathname)`; branch by page (below) |
| `fb-search-hotel.js` | — | **entirely commented out** |
| `fb-viewcontent.js` | `ViewContent` | `/cart/flight` (`pageBookingFormTriggerCondition`) |
| `fb-viewcontent-flight-search.js` | `ViewContent` | `/pesawat/search` and `getEndDate() === null` (one-way) |
| `fb-viewcontent-hotel.js` | `ViewContent` | `getScreenNameOrTitle() === 'hotelDetail'` |

All events go through `trackFbEvent` ([[gtm-extras-helpers]]): 5 attempts, 500 ms apart, waiting for `window.fbq`.

## Search branches (`fb-search-tag.js`)
| Match | content_type | Params |
|---|---|---|
| `pagePath === '/pesawat/search'` | `['flight','product']` | `content_ids: ORIGIN-DEST`, departing/returning dates (returning only if `gtm.flight.roundTrip == true`), origin/destination airport, `num_adults/children/infants`, `price` (lowest), `currency` |
| GTM `page_category == 'kereta-api/cari'` | `train` | dates, origin/destination station, pax, price, `currency: 'IDR'` |
| `pagePath == '/hotel/search'` | `hotel` | checkin/checkout, `city`, `region` (from `getArea`), `country`, adults, children |
| `page_category == 'sewa-mobil/cari'` | `car` | start/end date, `gtm.car.area`, `gtm.car.carIds`, `gtm.car.numberOfCar` |
| `page_category == 'event-list'` | `event` | `search` query param |
| `gtm.screenName == 'toDoSearchResult'` | `toDo` | `search: getTodoCategory()` |

## GTM data read
`window.gtm`: `vertical`, `screenName`, `flight.{originAirport,destinationAirport,originCity,destinationCity,roundTrip,departLowestPrice,lowestPrice}`, `[vertical].{startDate,departureDate,endDate,adult,child,infant}`, `hotel.{startDate,endDate,cityName,regionName,countryName,area}`, `car.{area,carIds,numberOfCar}`, `user.currency`. GTM data-model keys: `page_category`, `screenNamePopup`. URL: `search`, `type`, last path segment (hotel id).

## dataLayer keys
None pushed. These scripts call `fbq` directly.

## Gotchas
- The `toDoSearchResult` branch calls `getTodoCategory()`, but the helper is named `getToDoCategory`. On a ToDo search page this throws `ReferenceError`, which aborts every later script in the bundle (all TikTok events, Polaris, Ahrefs…).
- `fb-viewcontent-flight-search.js` sends hard-coded `content_ids` for 5 airlines (lion-air, citilink-indonesia, garuda-indonesia, batik-air, sriwijaya-air) as `ORIG-DEST-DD/MM/YYYY-<airline>`, regardless of actual results, and always `travel_class: 'economy'`. It throws if `startDate` is undefined.
- Hotel Search sends `region: getArea()`, not `getRegion()`.
- The FB scripts evaluate only once at bundle load. They do not hook `history.pushState` the way the [[gtm-extras-tiktok]] scripts do, so client-side navigations in Next.js apps don't fire Search/ViewContent.

## Sources
- scripts/fb-pixel-tag.js
- scripts/fb-search-tag.js
- scripts/fb-search-hotel.js
- scripts/fb-viewcontent.js
- scripts/fb-viewcontent-flight-search.js
- scripts/fb-viewcontent-hotel.js
- scripts/helpers.js
