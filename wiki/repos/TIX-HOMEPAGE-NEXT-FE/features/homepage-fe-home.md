---
title: Home page (/)
repo: TIX-HOMEPAGE-NEXT-FE
kind: feature
sources:
  - pages/index.page.tsx
  - pages/index.module.scss
  - pages/home
  - pages/types.ts
  - lib/services/HomeServices.ts
  - lib/services/account.ts
  - hooks/useNotificationCount.ts
  - hooks/useBroadcastChannel.tsx
  - context/AuthContext
  - lib/helpers/pagemodule
  - pages/__tests__/index.spec.tsx
  - pages/__tests__/getSsrProps.spec.tsx
verified_at: 408983f6
updated: 2026-10-16
status: current
tags: [repo/homepage-fe, kind/feature]
---

# Home page (/)
> The tiket.com home page: hero banner, vertical icons, desktop search widgets and a `HOME_V2` page-module feed from `tix-home`, with the remote header/footer, global popup, Google One Tap and an SSO notice layered on top.

## What it does
`pages/index.page.tsx` is the route. `pages/home/` holds its components, contexts and helpers and has no route of its own. The page:
- Renders a header section. **Desktop:** remote header + hero image + a vertical-tab search widget (Flight via [[passport-search-widget-flight]], To-Do via [[passport-search-widget-ttd]]). **Mobile:** `HomeBackgroundBanner`, which holds the app's own `MobileHeader` (animated search box, hamburger menu, chatbot/promo buttons), the vertical icons (top/bottom rows + "see all" bottom sheet), and the top/bottom hero banners.
- Renders the page-module feed (`HomePageModule` → `PageModule` from [[passport-page-module]]), an `ErrorBanner` when there are no modules, and on mobile the Passport `BottomTabNavigation` built from `navbar` (with badge counts).
- After the first module scrolls into view (`onFirstModuleAppear`): mounts `RemoteGlobalPopup` ([[react-remote-global-popup]]), the `SSONotification` for logged-in users, and, after an idle callback (3 s timeout), `RemoteGoogleOneTap` ([[react-remote-google-one-tap]]) for guests.
- On desktop with an error or empty response, it renders `ErrorViewWithRetry` (remote header/footer + generic error) instead of the page.
- On mount: scrolls to top, strips `?lang=` from the URL with `history.replaceState`, and sends `AnalyticsEventHandler({ screenName: 'home' })`.

## Routes & entry points
- `/` → `pages/index.page.tsx` (`HomepageWrapper` → `AuthProvider` → `HomepageProvider` → `Homepage`). The middleware rewrites to `/{locale}/` ([[homepage-fe-architecture]]).
- `getServerSideProps` runs, in parallel: `getAbTestOnServer({ deviceId, userId })` and `getReactRemoteProps(getHomeRemoteModules(sessionData, device, isBot))`. It reads the experiments `GV_EXPERIMENT_KEY` (new gift-voucher UI → `gvVariant: 'newUI'`) and `NEO_POLARIS_EXPERIMENT` (→ `recommendationVersion`) via `consumeAbTestResponse`. Then it builds the page-module experiments query with `constructPageModuleQueryParamsExperiments`.
- `dataLayer`: `{ screenName: 'home', screenOwner: 'discovery', variantName: 'homeResponsive' }`.
- Adds `<link rel="alternate" type="text/plain" href="/llms.txt">` and an SEO `H1Seo` (mobile).

## Data & services
- `GET /tix-home/v2/home-pages` with `pageModuleCode=HOME_V2`, `vertical=HOME`, `platform`, `availablePlatforms`, optional `recommendationVersion`, `gvVariant`, `homePageVersion=v2` (mobile), `experiment`, and UTM params on the server. Headers: `X-Account-Id`, `X-Username`, `X-Loyalty-Level`, `X-Channel-Id` (`MOBILE_WEB`/`DESKTOP`; tablets count as mobile). Server: `getHomepageData` (absolute `SERVER_SIDE_SERVICE_ENDPOINT/gateway/...`). Client: `getHomepageDataClient` (relative, via `ms-gateway`).
- Response type `HomepageLandingData` (`pages/types.ts`): `pageModules`, `verticalIcons`, `verticalIconCategorized`, `heroBanner` (+ bottom `banners`), `navbar`, `impressionSentences`, `inboxUnreadCount`, `chatUnreadCount`, `chatbot`, `footer`, tiket points and several `any`-typed legacy fields.
- React Query key `['homepage-data', currency, platform]`. **The server prefetches only for bots** (`middlewareData.isBot`). Users get loaders, and the browser fetches the data.
- `HomepageProvider` (`pages/home/contexts/homeContext`) normalises vertical icons and categories, hero banner and background, impression sentences and `chatbot`. It also tracks the active smart-widget tab and the unread count (`useNotificationCount`, which listens on the `push-notif-chat` BroadcastChannel).
- `TooltipPageVisitProvider` counts page visits to decide when to show `GlobalSearchTooltip`.
- `SSONotification`: shown when the `unm-sso-notification` cookie is `enabled`. It then fetches `GET /tix-member-core/v2/account` (`lib/services/account.ts`) and shows a modal (desktop) or bottom sheet (mobile) with the account's name and phone. "More info" goes to the UNM `/info` page. Closing deletes the cookie.
- `AuthContext` supplies `userName`, `normalizedCurrency`, `sessionData` (`accountId`, `loyaltyLevel`) to `PageModule`.

## Key components
`pages/home/components/`: `HomeHeaderSection` (`HomeDesktopHeaderSection` + `SearchWidget` with `VerticalTab`, `VerticalWidgetRenderer` and `WIDGET_MAPPING` `{ flight, to-do }`; `HomeRemoteHeader`), `HomeBackgroundBanner`, `HeroImage`, `VerticalIcons` (`TopVerticalIcons`, `BottomVerticalIcons`, `SeeAllBottomSheet`, `SeeAllHandle`, `HandleIcon`), `GlobalSearchTooltip`, `GreetingText`, `H1Seo`, `HomePageModule`, `HomeBottomNavigation`, `HomeFooter` (lazy `RemoteFooter` when in view, see [[react-remote-footer]]), `ErrorBanner`, `Label`, `SSONotification`.
Shared: `MobileHeader`, `PageModuleImageRenderer`, `Image`, `SEOPageHead`, `ErrorViewWithRetry`, `RemoteGlobalPopup`, `RemoteGoogleOneTap` ([[homepage-fe-components]]).

## Tracking
GTM `trackers.ts` per component, see [[gtm-datalayer-tracking]]: `smartHeroBanner/clickBanner` (bottom banners), `enterVertical/clickIcon|clickNext|clickPrev` (vertical icons), search-widget tab clicks, global-search tooltip impression, `loginRegistration` `ssoScreen`/`ssoInfo`/`ssoSubmit` (SSO notice), bottom tab nav (`lib/tracker/BottomTabNav.ts`). PageModule tracks with `screenName: 'home'`, `screenOwner: 'discovery'`, `additionalGtmVariables: { variantName: 'homeResponsive' }`.

## Tests
27 specs under `pages/home/`, plus `pages/__tests__/index.spec.tsx` and `pages/__tests__/getSsrProps.spec.tsx`. Tests use the partial `PageModule` mock (`__mocks__/@tiket/passport-page-module`), which fires `onFirstModuleAppear` on mount, so popup, SSO and One Tap paths are reachable in tests.

## Gotchas
- `isError` treats `code !== 'SUCCESS'` as an error, but **only desktop** swaps to `ErrorViewWithRetry`. Mobile keeps the header and shows `ErrorBanner` (driven by `HomepageLandingData.status`, the HTTP status that `getHomepageData` merges into the body; the client fetch doesn't add it).
- On the catch path of `getServerSideProps`, `homeLandingQueryKey` is not returned, so the client falls back to the same default key. It is built the same way, so there's no mismatch.
- `userId = String(sessionData?.accountId) || undefined` is never `undefined`: guests send `"undefined"` or `"0"` to the A/B service.
- `pages/home/components/HomeHeaderSection/HomeMobileHeaderSection` and `pages/home/components/MulticurrencyVerticalIcons` are not imported anywhere on main (dead code).
- The `TodoWidget` key is `to-do`. The service worker deliberately never handles `/to-do` URLs ([[homepage-fe-architecture]]).

## Sources
- `pages/index.page.tsx`, `pages/index.module.scss`, `pages/types.ts`
- `pages/home/components/**`, `pages/home/contexts/homeContext/**`, `pages/home/contexts/tooltipPageVisitCounter/**`, `pages/home/constants/verticals.ts`, `pages/home/utils/getHomeRemoteModules.ts`
- `lib/services/HomeServices.ts`, `lib/services/account.ts`, `lib/helpers/pagemodule/*`, `lib/utils/consumeAbTestResponse/*`
- `hooks/useNotificationCount.ts`, `hooks/useBroadcastChannel.tsx`, `context/AuthContext/index.tsx`
- `pages/__tests__/index.spec.tsx`, `pages/__tests__/getSsrProps.spec.tsx`, `__mocks__/@tiket/passport-page-module/index.tsx`
