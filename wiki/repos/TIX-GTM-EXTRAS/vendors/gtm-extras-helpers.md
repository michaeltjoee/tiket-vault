---
title: GTM extras helpers
repo: TIX-GTM-EXTRAS
kind: vendor
sources:
  - scripts/helpers.js
  - scripts/temp-tag-gtm-hotel-data-completion.js
verified_at: 98478af
updated: 2026-10-16
status: current
tags: [repo/gtm-extras, kind/vendor]
---

# GTM extras helpers
> `helpers.js`: globals that replace GTM variables and trigger conditions for every vendor script, plus the `temp-*` hotel data patch.

## Scripts
| Script | Role |
|---|---|
| `helpers.js` | Bundled first. Holds constants, getters over `window.gtm`, trigger predicates, and pixel-retry wrappers. Everything is a bundle-scope global. |
| `temp-tag-gtm-hotel-data-completion.js` | On `gtm.screenName === 'vw_hotelSearchResult'`: scrapes the location from the DOM into `gtm.hotel.hotelCountry/Region/City/Area` (retries every 2.5 s), and on `m.tiket.com` scrapes the first 5 hotel IDs from the result links into `gtm.hotel.hotelIds`, then pushes to the dataLayer. |

## Constants
`INIT_SCRIPT_DELAY = 1000` ms (pixel init delay), `INIT_SCRIPT_MAX_WAIT_TIME = 1500`, cookie names `device_type` / `device_id` / `affiliate_partner_id`, `LOCAL_SUBDOMAINS`, the list of UTM sources that disabled the removed AF banner, and the shared-storage iframe id `tiket-com-localstorage-iframe`.

## GTM variables replaced
| Helper | Reads |
|---|---|
| `getOrigin` / `getDestination` | first 3 chars of `gtm.<flight|train|bus|railink>.origin/destination{Airport,Station,Terminal}` or `…City` |
| `getStartDate` / `getEndDate` | `gtm[vertical].startDate` or `.departureDate`, else `dataLayer` merged `products[0].departure_date`; `gtm[vertical].endDate` |
| `getAdult` / `getChild` / `getInfant` | `gtm[vertical].adult/child/infant` |
| `getLowestPrice` / `getSelectedPrice` / `getTotalPayment` | `departLowestPrice`/`lowestPrice`, `departSelectedPrice`/`selectedPrice`, `gtm.flight.totalPayment` |
| `getCity` / `getRegion` / `getCountry` / `getArea` | `gtm.hotel.cityName/regionName/countryName/area` (also `tixhotel`, `car`, `toDo`) |
| `getCityId`, `getItemIdHotel`, `getNewPriceHotel`, `getQuantity`, `getHotelIds`, `getCheckinDate`, `getCheckoutDate` | `gtm.hotel.cityId/itemId/newPrice/quantity/hotelIds/startDate/endDate` |
| `getItemName` | per vertical: hotelName, departAirline, carBrand, trainName, toDoName, tixPointName, designName |
| `getUserId`, `getCurrency` | `gtm.user.userId`, `gtm.user.currency` (default `IDR`) |
| `getDeviceId` | cookie `device_id` |
| `getScreenName`, `getScreenNameOrTitle` | `gtm.screenName`; GTM DL `screenNamePopup` → `gtm.screenName` → `document.title` |
| `getPageCategory` | GTM data model `page_category` via `google_tag_manager['GTM-PLRJPPQ'].dataLayer.get` |
| `getEventSearchVariable`, `getTypeURLVariable` | query `search`, `type` |
| `getHotelIdOfferDetailVariable` | last path segment |
| `environment` | `'testing'` if the hostname matches pegasus/testing/gatotkaca/staging/dev, else `'production'` |
| `webhookEnabled`, `isWebView` | `device_type` cookie is android/ios, or `window.webkit.messageHandlers.analyticsTracker` / `window.app.analyticsTracker` exists |
| `isBlibli`, `isPWA`, `isTaspenApp`, `isBrowserUserAgent`, `isSafari` | environment sniffing |

## Trigger predicates
`RMKTSearchAllTriggerCondition(path)` (path contains `search`/`cari` and `type` query is not `return`), `RMKTSearchFlightTriggeredTriggerCondition` (`/pesawat/search`), `RMKTSearchHotelTriggerCondition` (`/hotel/search`), `RMKTBookProductTriggerCondition(path)` (hotel `/hotel/checkout`, flight `/cart/flight`), `RMKTViewContentTriggerCondition(path)` (flight `/(flight|pesawat)/review`), `pageBookingFormTriggerCondition` / `isFlightCartPage` (`/cart/flight`).

## Pixel and wait utilities
- `trackFbEvent({eventName, eventParams})` and `trackTiktokEvent({eventName, eventParams, enableIdentify=true})` retry up to 5 times at 500 ms intervals until `window.fbq` / `window.ttq` exists. TikTok also calls `ttq.identify({external_id: device_id || userId})`.
- `waitForGTMData({maxWaitTime=5000})` resolves when `gtm.vertical` data exists (for hotel, it also waits for `regionName !== ''`), with exponential backoff from 50 ms ×1.4. It rejects on timeout.
- `waitUntilObjectExists(param)` polls a **value**, not a reference, so it effectively never sees a later change.

## dataLayer keys pushed
Only `temp-tag-gtm-hotel-data-completion.js`: `{event: 'rtgSearchResult', hotelIds}`.

## Gotchas
- **One IIFE for everything.** A `TypeError` in any script (e.g. `gtm.flight.roundTrip` when `gtm.flight` is undefined, or `startDate.slice` on undefined) aborts all later scripts in bundle order.
- `getSelectedPrice` and `getLowestPrice` test `gtm.vertical === 'flight' || 'train' || 'railink'`, which is always truthy. The non-flight branches never run.
- In `getEndDate`, the check `typeof gtm.vertical == 'tixPoint'` is never true.
- `getIframeLocalStorageData` adds its listener to `window` but removes it from `document`, so listeners leak. It is only used by the AF-banner leftover `disableScriptForAffiliatesAndBrands`, which nothing calls since #34.
- `pagePath` is captured once at load. SPA navigations don't update it.
- `temp-tag…` scrapes DOM class names (`tix-text-size-125 tix-font-medium`, `header-title`, `tix-content`) from the legacy hotel pages. It breaks silently if the markup changes. Its `do…while` loop can index past the end of `hotelList` if fewer than 5 links have an empty `className`.

## Sources
- scripts/helpers.js
- scripts/temp-tag-gtm-hotel-data-completion.js
