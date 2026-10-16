---
title: SearchWidgetTtd
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-search-widget-ttd"
umbrella: true
sources:
  - packages/search-widget-ttd/src
  - packages/search-widget-ttd/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# SearchWidgetTtd
> "To Do" (things-to-do, attractions) search widget: a destination search box with a suggestion overlay, nearby/geolocation, popular, recently viewed and favorite destinations, then a redirect to `/to-do/search`.

Part of [[passport-packages]].

## What it does
- `SearchWidgetTtd({ isLoggedIn, platform? })` renders the destination card list and a search box. Focusing the box opens `SearchSuggestionTtd` in an overlay (a modal or bottom sheet).
- "Nearby" asks for the `geolocation` permission and redirects to `/to-do/search?<lat/long params>` via `withForwardParams`. "See all" adds internal UTM (`utmSection: 'seeAll'`, `screenName: 'toDoSearch'`).
- Data comes from `tix-events-v2-inventory` (`/v1/keywords`, `/v1/user-destinations`, `/v1/discovery-destinations`, `/v1/popular-destinations`, `/v1/favorite-destinations`, `/v1/recently-viewed-pdp`, `/v2/product-categories`) and `tix-events-v2-search/v2/suggestions`, through React Query.
- GTM vertical name is `toDo` (`tracker/GTM.ts`).

## Public API
`SearchWidgetTtd`, `SWLoader` (skeleton), `SearchSuggestionTtd({ query, updateQuery, isLoggedIn, type?: 'default'|'overlay' })`. `overlay` creates a portal id for error dialogs. [[passport-umbrella]] re-exports `SearchWidgetTtd` and `SearchSuggestionTtd`.

## Usage
```tsx
<QueryClientProvider client={queryClient}>
  <SearchWidgetTtd isLoggedIn={!!accountId} />
</QueryClientProvider>
```

## Depends on
[[passport-umbrella]] (imports `@tiket/passport`), [[passport-bottom-sheet]], [[passport-modal]], [[passport-dialog]], [[passport-typography]], [[passport-utils]], assets, icons, `@tiket/react-common-utilities`. External dependencies: `@tanstack/react-query ^5.90` (a regular dependency), `lodash`.

## Used by
- No internal dependents and no consumers in the other workspace repos.

## Gotchas
- **Circular package dependency** with `@tiket/passport`, as in [[passport-search-widget-flight]].
- `@tanstack/react-query` is a regular dependency, so the host must dedupe it or the widget won't see the host's `QueryClientProvider`.
- Tests: `DestinationSearchContent.spec.tsx`, `DestinationSearchInitialContent.spec.tsx`, `PopularDestinationSection.spec.tsx` wrap the components in their own `QueryClientProvider`.

## Sources
- packages/search-widget-ttd/src/SearchWidgetTtd.tsx
- packages/search-widget-ttd/src/components/SearchSuggestionTtd/SearchSuggestionTtd.tsx
- packages/search-widget-ttd/src/services/
- packages/search-widget-ttd/src/helpers/config.ts
- packages/search-widget-ttd/package.json
