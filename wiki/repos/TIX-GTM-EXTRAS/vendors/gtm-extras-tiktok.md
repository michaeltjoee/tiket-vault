---
title: GTM extras TikTok Pixel
repo: TIX-GTM-EXTRAS
kind: vendor
sources:
  - scripts/tiktok-init.js
  - scripts/tiktok-search.js
  - scripts/tiktok-initiatecheckout.js
  - scripts/tiktok-viewcontent-flight.js
  - scripts/tiktok-viewcontent-hotel.js
  - scripts/tiktok-viewcontent.js
verified_at: 98478af
updated: 2026-10-16
status: current
tags: [repo/gtm-extras, kind/vendor]
---

# GTM extras TikTok Pixel
> TikTok Pixel bootstrap plus Search, ViewContent and InitiateCheckout events for flight and hotel dynamic travel ads, with SPA navigation hooks.

Part of [[gtm-extras-overview]].

## Scripts
| Script | Event | Condition / timing |
|---|---|---|
| `tiktok-init.js` | `ttq.load('C6F1LR0B3BVPD5SJMP6G')`, `ttq.page()` | after 1 s (`INIT_SCRIPT_DELAY`); logs `tiktok-init 2` |
| `tiktok-search.js` | `Search` | `RMKTSearchAllTriggerCondition(url)`, then `await waitForGTMData()`; 300 ms after load, and 3.5 s after each `pushState` |
| `tiktok-initiatecheckout.js` | `InitiateCheckout` | `RMKTBookProductTriggerCondition(path)`: hotel `/hotel/checkout`, flight `/cart/flight`; 300 ms after load and on each `pushState`/`replaceState` |
| `tiktok-viewcontent-flight.js` | `ViewContent` | `RMKTViewContentTriggerCondition(path)`: flight `/(flight|pesawat)/review`; 300 ms after load and on `pushState` |
| `tiktok-viewcontent-hotel.js` | `ViewContent` | `window.eventProperties.screenName === 'productDetailPage'` and `.vertical === 'hotel'`, 300 ms after load |
| `tiktok-viewcontent.js` | — | **entirely commented out** (old `/cart/flight` ViewContent) |

Flight/hotel events go through `trackTiktokEvent` ([[gtm-extras-helpers]]), which retries until `window.ttq` exists and first calls `ttq.identify({external_id: device_id cookie || gtm.user.userId})`.

## Event params
- **Flight** (Search / ViewContent / InitiateCheckout): `content_type: 'product'`, `content_category: 'FLIGHT'`, `content_name: 'outbound flight page'`, `content_id: ORIGIN-DEST`, `departing_date`, `returning_date` (round trip / non-null only), `departing_airport`, `returning_airport` (= destination), `num_adults/children/infants`. InitiateCheckout adds `value: gtm.flight.totalPayment` and `currency`. Search sends `returning_date` only when `gtm.flight.roundTrip === 1`.
- **Hotel**: `content_category: 'HOTEL'`. Search uses `content_name: 'Hotel Search Page'` and `content_id: gtm.hotel.cityId`. PDP uses `'hotel PDP'` and the hotel id from the last path segment. Checkout uses `'hotel Book Page'`, `content_id: gtm.hotel.itemId`, and `value = newPrice × duration × quantity`. All include checkin/checkout, city/region/country and pax (`gtm.hotel.hotelChildren` on checkout).
- **Car / event / toDo / train Search** call `ttq.track` directly (no retry, no identify) with the same shapes as [[gtm-extras-facebook]].

## GTM data read
`window.gtm.vertical`, `screenName`, `flight.{originAirport,destinationAirport,roundTrip,totalPayment,…}`, `hotel.{cityId,itemId,newPrice,duration,quantity,hotelChildren,startDate,endDate,cityName,regionName,countryName}`, `user.{userId,currency}`, `car.*`, `toDo.toDoCategory`. `window.eventProperties.{screenName,vertical}` (hotel PDP). GTM data model `page_category`. Cookie `device_id`.

## dataLayer keys
None pushed.

## Gotchas
- Three scripts each monkey-patch `history.pushState` (and checkout patches `replaceState` too). The wrappers chain, so every navigation runs all three handlers. Search re-checks only after a 3.5 s delay.
- Flight Search and Checkout dereference `gtm.flight.*` / `window.gtm.hotel.*` without guards. If the vertical object is missing, the throw aborts later scripts in the bundle (TikTok scripts run last, so the damage is limited to the TikTok scripts that follow).
- `waitForGTMData` rejects after 5 s with an unhandled promise rejection, and Search silently doesn't fire.
- Commit 365c66c (#23) fixed the flight and hotel pixels, and f640050 (#20) added the dynamic-travel-ads params. Check those before changing param names.

## Sources
- scripts/tiktok-init.js
- scripts/tiktok-search.js
- scripts/tiktok-initiatecheckout.js
- scripts/tiktok-viewcontent-flight.js
- scripts/tiktok-viewcontent-hotel.js
- scripts/tiktok-viewcontent.js
- scripts/helpers.js
