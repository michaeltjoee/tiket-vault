---
title: Global Search
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-global-search"
umbrella: true
sources:
  - packages/global-search/src
  - packages/global-search/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Global Search
> The header's cross-vertical search box. On focus it opens a panel of server-driven "non-typing" modules (recent, popular, most-searched, inspirational, promos, info). While the user types it shows debounced keyword results (POI, verticals, SRP links).

## What it does
`GlobalSearch` renders a [[passport-search-box]], and `GlobalSearchModal` is lazy-loaded when the box opens. That's a dropdown on desktop and a full-page overlay on mobile.
- **Non-typing state**: `GET /tix-home/v2/page-modules-full?pageModuleCode=GLOBAL_SEARCH_LANDING&pageModuleType=GLOBAL_SEARCH`. This reuses the page-module pipeline, so modules can be page-module types (`PromoCarouselModule`, `BannerGridModule`, …) or GS-specific ones (`GSRecentSearch`, `GSPopular`, `GSMostSearch`, `GSInspirationalSearch`, `GSInfo`, `GSStaticVertical`, `GSTabbing`…).
- **Typing state**: `GET /tix-global-search/v3/search?…`, 500 ms debounce. The response includes `variant` and `variant_design` for POI experiments. `POST /tix-global-search/popular-search-tracker` logs searches.
- **Recent searches** live in `localStorage` (`searchKeyWord`). Currency comes from the prop, then the `tiket_currency` cookie, then the default. The `search` query param is kept in sync.
- **Experiments and rollouts** use `@tiket/react-common-ab-test` (`useRollout` with `abTestOnServerResponse`). Keys include `disc-global-search-poi-experiment` and a typing experiment, with fallback model version `circinus_V6.3`.
- GTM and analytics through `utils/Tracker` and `@tiket/react-common-analytic`.

## Public API
| Export | Notes |
|---|---|
| `GlobalSearch` | `isOpen`, `setIsOpen` (controlled), `searchBoxVariant: sm \| md`, `currency`, `userData: User`, `dataLayer`, `clientSideServiceEndpoint`, `onClickDesktopSearchBox`, `onBlurDesktopSearchBox`, `noOverlay`, `lightBackground`, `toRemoveAccessibility`, class and style props |
| types | `GlobalSearchProps`, `User`, `NonTypingModule`, `NonTypingData`, `TypingData`, plus `types/Types` (`TypingTypeEnum`, `LocalSearchKeyword`, `GlobalSearchResultType`, `GSInfoModuleType`, …) |

## Usage
```tsx
const [open, setOpen] = useState(false);
<GlobalSearch isOpen={open} setIsOpen={setOpen} searchBoxVariant="sm" userData={user} currency={currency} />
```

## Depends on
[[passport-search-box]], [[passport-page-module]] (types and module renderers), [[passport-tabs]], [[passport-chips]], [[passport-chips-carousel]], [[passport-page-control]], [[passport-image]], [[passport-info-banner]], [[passport-label]], [[passport-dialog]], [[passport-error-view]], [[passport-content-loader]], [[passport-button]], [[passport-icons]], [[passport-assets]], [[passport-typography]], [[passport-utils]], `keen-slider`. From TIX-REACT-COMMON: `react-common-ab-test`, `react-common-analytic`, `react-common-utilities`. Peers: `@tanstack/react-query ^5`, `uuid`.

## Used by
- TIX-REACT-REMOTE `webpack.config.js` lists it in `consumeFromSource`, so the remote bundles its `src/` directly. It also has a dedicated CSS split-chunk group (`globalSearchStyles`). It reaches the remote through [[passport-header]].
- Internal: [[passport-header]].

## Gotchas
- `src/index.ts` deliberately **doesn't** export `./components`. Exporting them broke code splitting of the lazy modal, per the comment there.
- `@tanstack/react-query` v5 is a peer dep. The host needs a `QueryClientProvider`.
- The typing API's `variant` and `variant_design` drive which result layout renders (design A or B). Mock both (`mocks/typing-state-variant-*.json`) when testing.

## Sources
- `packages/global-search/src/GlobalSearch.tsx`, `src/index.ts`, `src/services/{global-search-by-keyword-v3,initial-data,popular-search-tracker}.ts`, `src/hooks/{useRollout,useRecentSearch}.ts`, `src/utils/constants.ts`, `src/types/Types.ts`
- `packages/global-search/package.json`
- TIX-REACT-REMOTE `webpack.config.js` (281778b)
