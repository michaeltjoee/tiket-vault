---
title: SearchWidgetFlight
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-search-widget-flight"
sources:
  - packages/search-widget-flight/src
  - packages/search-widget-flight/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# SearchWidgetFlight
> Self-contained flight search form (one-way or round-trip, origin/destination airports, dates with prices and holidays, passengers and cabin class) that redirects to `/flights/search`.

Part of [[passport-packages]].

## What it does
It is a whole vertical widget with its own data layer. Airport autocomplete, popular cities, holidays, price summary and general content come from the gateway `/ms-gateway/...` (or the paths go to `customFetch` as-is):
- `/tix-flight-master-discovery/v3/airport/autocomplete`
- `/tix-flight-master-discovery/popularDestination/findPopularCity`
- `/tix-calendar/holiday`
- `/tix-price-summary/v3/priceSummary`
- `/tix-flight-master-discovery/general-content-search/v3/find`

Recent searches are kept in localStorage (`__flight_recentlySearched`, `__flight_recentlySearchedDeparture`, …). On desktop the forms open as dropdowns, and on mobile as adaptive popups or dialogs. Submitting sets `window.location.href = withForwardParams('/flights/search?...')`. GTM events are in `src/tracker`.

## Public API
`SearchWidgetFlight({ eventTrackerProperties? })`. The default is `{ tabName: 'Flights', tabPosition: 1 }`, which is merged into tracking events. Also in [[passport-umbrella]].

## Usage
```tsx
<QueryClientProvider client={queryClient}>
  <SearchWidgetFlight eventTrackerProperties={{ tabName: 'Flights', tabPosition: 1 }} />
</QueryClientProvider>
```

## Depends on
[[passport-umbrella]] (`Button`, `Radio`, `RadioGroup`, `SearchFormDisplay`, `Text`, `usePassport` imported from `@tiket/passport`), [[passport-calendar]], [[passport-focus-trap]], [[passport-utils]], icons, `@tiket/react-common-utilities`. External **dependencies** (not peers): `@tanstack/react-query ^5.90`, `dayjs`, `buffer`, `querystring`.

## Used by
- No internal dependents and no consumers in the other workspace repos. The homepage and flight landing apps live elsewhere.

## Gotchas
- **Circular package dependency.** It imports `@tiket/passport`, which depends on it. Same pattern as [[passport-manage-order]] and [[passport-search-widget-ttd]].
- `@tanstack/react-query` is a regular dependency, not a peer. If the host resolves a different copy, `useQuery` won't find the host's `QueryClientProvider`, and you get the "No QueryClient set" error.
- It navigates with a hard redirect, not the host router.

## Sources
- packages/search-widget-flight/src/SearchWidgetFlight.tsx
- packages/search-widget-flight/src/hooks/useSearchFormFlight.ts
- packages/search-widget-flight/src/config/api-endpoints.ts
- packages/search-widget-flight/src/config/page-routes.ts
- packages/search-widget-flight/src/config/local-storage-keys.ts
- packages/search-widget-flight/src/helpers/apiUrl.ts
- packages/search-widget-flight/package.json
