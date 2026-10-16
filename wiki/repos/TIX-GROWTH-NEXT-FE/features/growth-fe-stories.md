---
title: Stories blog (/stories/**)
repo: TIX-GROWTH-NEXT-FE
kind: feature
sources:
  - pages/stories
  - lib/services/stories
  - lib/config/apiUrl.ts
  - lib/helpers/errorHandling.ts
  - lib/mocks/data/mockStoriesLandingPage.ts
  - middleware.page.ts
  - pages/_app.page.tsx
verified_at: d4162e3
updated: 2026-10-16
status: current
tags: [repo/growth-fe, kind/feature]
---

# Stories blog (/stories/**)
> tiket.com's travel blog: a landing page, category and tag listings with pagination, and an article detail page with a table of contents, product cards, likes and share buttons. Every page is SSR from one CMS endpoint, `tix-seo-control` `seo-contents`, keyed by a `slug` query. Middleware skips the URL-structure step for `/stories`.

## What it does
- **Landing** `/stories`: renders `data.contents` by `type` and `imageType`. `DYNAMIC_HERO_BANNER` becomes `Header`, three headline cards picked from the children by `storyType` (`LATEST_STORY`, `HOT_STORY`, `PINNED_STORY`). `STATIC_IMAGE_BANNER` with `IMAGE_RATIO-2:1` becomes `PopularCategory` (it renders `children[0].children`). `STATIC_IMAGE_BANNER` with `ARTICLE_RATIO-1:1` becomes `PopularTags` (chip tabs, one per `STATIC_IMAGE_BANNER_TABBING` child, plus a "See all" button). Every other type is ignored. The page ends with a TikTok creator embed (`SocialMediaSection` and `tiktok.com/embed.js`, `lazyOnload`).
- **Category** `/stories/{type}`: a header ("Best {type} Collection", title-cased from the URL), an `ArticleList` of cards and a passport `Pagination` ([[passport-pagination]]).
- **Tag** `/stories/tags/{slug}`: the same pattern. The title is the slug, title-cased, and the cards also show a description.
- **Detail** `/stories/{type}/{slug}`: a hero image (`ImageBanner`), tag chips, the title, the author with read time and date, a like and share bar, then the article body. Body sections: `STATIC_PARAGRAPH` renders an `h2` with `id={name}`, an optional image and sanitized HTML (`isomorphic-dompurify`). `DYNAMIC_INVENTORY` renders `HotelCard` (`productType` `HOTEL`/`NHA`/`HOMES`) or `TtdCard` (`EVENT`/`TODO`; returns `null` when `soldOut`), using only the first card of each `data[]` entry. Desktop shows a table of contents on the side. Mobile shows `StickyTabListTop` while a TOC section is in view. It also emits `BlogPosting` JSON-LD.

## Routes & entry points
- `pages/stories/index.page.tsx`, `[type]/index.page.tsx`, `tags/[slug]/index.page.tsx`, `[type]/[slug]/index.page.tsx`. Each `getServerSideProps` runs `getReactRemoteProps([{ header: isLogin 1/0 }, 'footer'])` and `getStories` in parallel ([[react-common-remote]]).
- Every page wraps in `StoriesLayout` (`pages/stories/layout.tsx`). The layout chain is `I18nStoriesProvider`, then `MainLayout showHeaderInMobile` ([[growth-fe-app-shell]]), then `SEOPageHead` with `metadata.title/description` ([[growth-fe-components]]). Category, tag and detail pages pass `showBackIcon`.
- The detail page also has `getLayout`, which wraps it in `StoryDetailPageProvider` (`[slug]/providers/`). That context holds the like state, sticky-tab state, TOC, the share, tag and like handlers, and product-card tracking. All detail blocks read it through `useStoryDetailPageContext`.
- `pages/_app.page.tsx` special-cases the route `'/stories/[type]/[slug]'`: `TiketMetaTag` gets `xDefaultHrefLocaleCountry` and a single `hrefLangsAlternates` entry of `${locale}-${countryCode}`.
- **Middleware** (`middleware.page.ts`): `skippedPathForUrlRestructureRegex = [/\/stories(\/|$)/]` sets `chain(..., { skipUrlStructureMiddleware: true })`. In `@tiket/next` 3.3.1 this drops `urlStructureMiddleware`, so there is no redirect between legacy and `/{lang}-{country}/` URLs, and it forces `isNewURLStructure: false` ([[new-url-structure]], [[tiket-next-core]]). The local `rewriteMiddleware` still rewrites to `/{locale}{pathname}`. The regex is not anchored, so `/en-id/stories/...` or any path that contains a `/stories` segment matches too.
- Inbound links: the default data of [[passport-footer]] links to `/stories` and `/stories/newsroom`.

## Data & services
| Function | Endpoint | Used by |
|---|---|---|
| `getStories(initArg, params)` (`lib/services/stories/getStories.ts`, server `lib/fetch`) | `GET /tix-seo-control/v1/seo-contents?{params}` | all four `getServerSideProps`; header `lang: middlewareData.locale` |
| `useGetCategoryTagsStoriesData` (`fetchClient` from `@tiket/next/client`) | same endpoint, `slug`, `currentPage`, `tag` | category/tag client pagination |
| `useLikeStoryMutation` | `POST /tix-seo-control/v1/stories/{storyId}/like` → `{ liked, likeCount }` | detail like button |

`slug` values, built from `STORIES_URL_DOMAIN = 'stories'` (`lib/config/apiUrl.ts`):
- landing: `stories`
- category: `stories/{type}` plus `currentPage`
- tag: `stories/tags` plus `tag={slug}` and `currentPage`
- detail: `stories/{type}/{slug}`

Response type: `StoriesAPIResponse = APIResponse<TStoriesMain>` (`pages/stories/types.ts`). The `APIResponse` type comes from [[passport-page-module]]. Only the type is imported.
- Error mapping (`lib/helpers/errorHandling.ts`): `data.errorCode === 'DATA_NOT_EXIST'` returns `notFound`. Any other error code redirects (302) to `/stories`. The landing page is different: on `DATA_NOT_EXIST` it redirects to `/{lang-country}/` with query params forwarded.
- Client pagination: `useStoriesPagination` reads `?currentPage=`. `useCategoryTagsData` picks the first `DYNAMIC_SRP_INVENTORIES_STORIES` content, whose `data[]` is the cards and `attributes.totalPage` the page count. A page click does a shallow `router.push({ query: { currentPage } })` and calls the mutation, which writes into the `['categoryTagsStories', params]` query cache.
- Cache-Control `public, s-maxage=60, stale-while-revalidate=180` (`serverSideCtxCacheControlSetter`) is set on landing and detail only. Category and tag pages don't set it.
- Copy: `pages/stories/i18n/` has its own `en`/`id` dicts and `createI18nContext` provider (`useI18nStories`). It is separate from the app dict in `lib/i18n`.

## Key components
- Landing `_blocks/`: `Header`, `PopularCategory`, `PopularTags`, `GeneralInformation` (read time, title, author; reused by category cards), `SocialMediaSection` (TikTok).
- Category `[type]/blocks/`: `CategoryHeader`, `ArticleList`, `LoadingSkeleton`. Tag `tags/[slug]/blocks/`: `TagsHeader`, `ArticleList` + `ArticleCard`, `LoadingSkeleton`.
- Detail `[type]/[slug]/blocks/`: `ImageBanner`, `Header` (tag `Chip`s, author avatar, `SocialMediaSection`), `SocialMediaSection` (like with `Badge` count; Facebook, WhatsApp, Twitter, copy link through `lib/helpers/socialShare`), `ArticleContent`, `HotelCard`, `TtdCard` (passport `PriceModule`, `LabelCampaign`), `StickyTabListTop` (passport `Tabs`). `JsonLd.tsx` renders `StoryDetailJsonLd`.
- Hooks: `hooks/useStickyTabs` (an `IntersectionObserver` on the TOC section ids), `hooks/useStoriesPagination`, `hooks/useCategoryTagsData`, plus the per-page `useCategoryStoriesPage` and `useTagsStoriesPage`.
- Images: `components/Image` with Lightroom helpers. `getOptimizeLightroomImageUrl(!isMobile, url)` serves the detail page, and `getLightroomTinyImageUrl` serves mobile list cards. `isMobile` comes from the user agent (`getIsMobileFromMiddlewareData`) on category and detail, and from the passport `breakpoint` on the tag page.

## Tracking
Every event goes through `clickElement` or `pageVisit` (`lib/gtm/event.ts`) with vertical `growth` and `screenOwner`/`vertical: 'growth'`. Click events add `eventCategory: 'tiketBlog'`. See [[gtm-datalayer-tracking]].
| Screen (`screenName`) | Page visit | Clicks |
|---|---|---|
| `blogLandingPage` | `usePageVisitStories` in `StoriesLayout`. It runs on every stories page but fires only when the path, with any `/xx-xx` prefix stripped, matches `^/stories/?$` | `trackHeadlineClick` (`clickContent`, `eventLabel` `New Article`/`Hot Picks`/`Pinned`, section `This Week Picks`), `trackTopCategoryClick` (section `Categories`), `trackTopStoryTag` (`clickTab`), `trackStoryTagSectionClick` (section `Top Articles`, `tabName`), `trackSeeAllTagsPage` (`ctaTitle: 'SeeAll'`) |
| `blogCategoryPage` | `useCategoryStoriesPage`: `itemCategory` = type, `totalItem: 0` | `trackClickStoryOnCategory(slug)` |
| `blogTagPage` | `useTagsStoriesPage`: `tag`, `totalItem: 0` | `trackClickStoryOnTags(slug, tag)` |
| `blogDetailPage` | in the provider: `pageTitle`, `slug`, `tag` (titles joined with `;`) | `trackClickButton` with `eventDescription` `clickTabDetailPage` / `clickShareDetailPage` (+`channelId`) / `clickThumbsUpDetailPage`; product card: `eventAction: 'click'`, `eventCategory: 'chooseProduct'`, `itemId`, `itemName` |

## Tests
12 specs, about 151 cases. Landing: `LandingPage` (render plus `getServerSideProps`), `Header`, `PopularCategory`, `PopularTags`, `GeneralInformation`. Detail: `ArticleDetailPage` (render, TOC, `getServerSideProps`, `getLayout`), `StoryDetailPageProvider`, and the blocks `ArticleContent`, `Header`, `HotelCard`, `ImageBanner` and `TodoCard` (which tests `TtdCard`). Category and tag pages, the hooks, `lib/services/stories` and the trackers have no specs.
- Fixtures: `lib/mocks/data/mockStoriesLandingPage.ts` is a full landing response (`slug: 'stories'`) that only `LandingPage.spec` uses. `msw-handlers.ts` has no `seo-control` handler, so `NEXT_PUBLIC_API_MOCKING` does not mock stories. `pages/stories/_mocks` holds the remote-props and error-response factories. `[slug]/mocks` has `createStoryDetailMockData`, which still names `handleClickHotelCard` where the provider now uses `handleClickProductCard`.

## Gotchas
- **`getStories` never throws.** On a non-OK response or `code !== 'SUCCESS'` it returns `{ code: 'RUNTIME_ERROR', data: null }`. That has no `errorCode`, so the pages render as successes with empty data, and landing and detail send their public cache header with that page. The `catch` and rethrow in `getServerSideProps` only fire when the remote props fail.
- **When the API fails, the landing page crashes at render.** The fallback is `contents: {}`, an object (a spec asserts this), and `contents?.map(...)` throws on an object.
- On the landing page, an error code other than `DATA_NOT_EXIST` redirects to `/stories`, the same page, so it loops for as long as the API returns that code. On `DATA_NOT_EXIST`, `getLangCountry(ctx.req.url)` matches only a `/{lang}-{country}/` prefix. Without one it returns `undefined`, and the destination becomes `/undefined/`.
- **The tag page reads `?page=` on the server, but pagination writes `?currentPage=`.** After a reload of `/stories/tags/x?currentPage=3`, the server renders page 1 while the pagination highlights page 3. The client query is `enabled: false` and never refetches. The category page reads `currentPage` correctly.
- **The client list shows stale data instead of a skeleton.** `useQuery` has `initialData` set to the SSR response, so a new page key starts with the SSR (page-1) data and `isLoading` stays false. The list swaps only when the mutation resolves.
- `Pagination` gets `disabled={currentPage === totalPage}`, and passport's `disabled` disables the whole control. On the last page the user can't go back with it. The "{count} Articles" header counts the items on the current page, not the total.
- **Detail forwards only `{ locale }` as `middlewareData`.** `_app` builds the hreflang value from `middlewareData.countryCode`, which is missing on this route, so the value is `{locale}-undefined`. `getLayout` also reads `isLoggedIn` and `currency` props that `getServerSideProps` never returns.
- A detail page with no tags sends no page-visit event: the effect requires a non-empty `tagsTracker`.
- TOC entries come from server-side `contents` where `attributes.includeTOC === 'true'` (a string). Only `STATIC_PARAGRAPH` renders an element with `id={name}`. On main, `useStickyTabs` calls `observe(element!)`, so a flagged section with no rendered element throws. `handleScrollTo` scrolls to `offsetTop + 116`: it adds the sticky offset rather than subtracting it.
- The `PopularTags` story cards are `<a href>` and also call `navigate(slug)` (`window.location.assign`) in `onClick`, so two navigations race. "See all" builds the tag URL from the tab name (`formatTitleToKebabCase`), not from an API slug. Detail tag chips use the API `tag.slug`.
- `PopularCategory` and the landing `SocialMediaSection` use `next/dynamic` with `ssr: false`, so the category grid is not in the SSR HTML.
- Headline click tracking sends the hard-coded values `itemCategory: 'Tips'` and `pageTitle: 'Title'`. `extractCategory` (`helpers.ts`) assumes a slug with no leading slash (`stories/tips/x`).
- JSON-LD `@id` is `${NEXT_PUBLIC_HOME_PAGE}/${storyDetail.slug}` with no lang-country prefix. `author.url` is the author's image URL, and the image size is fixed at 1280×628.
- The like button has no login check on the client. It is throttled to 1 s, and failures are only `console.error`ed.
- The `en` dict has Indonesian `general.readTime` (`'Waktu dibaca {{time}} Menit'`). `FlightCard` is unused and fully hard-coded (TODO). Nothing imports `i18n/server.ts` or the stories `createI18n`.
- Not on main yet: `origin/prerelease` has `4abf3e6` (GRA-8337, #72). It adds `HOME_MODULE` sections and async SEO contents on the detail page (`useGetSeoContentModules`, `StoryPageModule`, `mergeSeoContents`) and the null guard in `useStickyTabs`. Refresh this page when it lands.

## Sources
- `pages/stories/index.page.tsx`, `layout.tsx`, `helpers.ts`, `types.ts`, `tracker.ts`, `usePageVisitStories.tsx`, `_blocks/**`, `_mocks/index.ts`, `hooks/*`, `i18n/*`, `__tests__/*`
- `pages/stories/[type]/index.page.tsx`, `useCategoryStoriesPage.tsx`, `blocks/**`
- `pages/stories/tags/[slug]/index.page.tsx`, `useTagsStoriesPage.tsx`, `blocks/**`
- `pages/stories/[type]/[slug]/index.page.tsx`, `JsonLd.tsx`, `tracker.ts`, `providers/**`, `blocks/**`, `mocks/index.ts`, `__tests__/*`
- `lib/services/stories/getStories.ts`, `useGetCategoryTagsStoriesData.ts`, `useLikeStoryMutation.ts`
- `lib/config/apiUrl.ts`, `lib/config/errorEnum.ts`, `lib/helpers/errorHandling.ts`, `lib/helpers/context.ts`, `lib/helpers/string.ts`, `lib/hooks/useCoreNavigation.ts`, `lib/gtm/event.ts`, `lib/gtm/gtm.types.ts`
- `lib/mocks/data/mockStoriesLandingPage.ts`, `lib/mocks/msw-handlers.ts`
- `middleware.page.ts`, `pages/_app.page.tsx`; `@tiket/next@3.3.1` `src/middlewares/chain.ts`, `constructor/constructor.ts`, `urlStructureMiddleware/*`
- TIX-PASSPORT `packages/footer/src/data/default/{en,id}.ts`
