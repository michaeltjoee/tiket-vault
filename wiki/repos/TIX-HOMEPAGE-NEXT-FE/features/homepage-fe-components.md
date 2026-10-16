---
title: Shared components (components/)
repo: TIX-HOMEPAGE-NEXT-FE
kind: feature
sources:
  - components
verified_at: 408983f6
updated: 2026-10-16
status: current
tags: [repo/homepage-fe, kind/feature]
---

# Shared components (components/)
> The 22 cross-feature folders under `components/`: the provider tree, remote-widget wrappers, page-module image renderers, the DLP content, headers, loaders and error views. Feature-only UI lives under each `pages/<feature>/components` instead.

## What it does
`components/` holds UI and providers that more than one route uses, or that the app shell needs. Several "shared" components are really owned by one feature: `Layout` is promo-only, `MobileHeader` is home-only, and `DynamicLandingPageContent` serves explore and its preview.

## Routes & entry points
None. They are imported via `@components/*`.

## Data & services
Only `components/providers/AppProvider` (React Query client, `coreFetcher` as Passport `customFetch`) and `components/MobileHeader/helpers` (`setPreferredLang`: `POST {host}/ms-gateway/tix-member-core/v3/account/lang/{lang}`, raced against a 2 s timeout) touch services.

## Key components
| Group | Folder | Purpose | Used by | Notable deps |
|---|---|---|---|---|
| **App frame** | `providers` | `AppProvider` (provider tree, see [[homepage-fe-architecture]]), `AppContext`, page-visit analytics config | `_app` ([[homepage-fe-app-shell]]) | [[passport-umbrella\|passport]] `PassportProvider`/`SnackbarProvider`/`ForwardParamsProvider`, [[react-common-remote]] `ReactRemoteProvider` + `RemoteCountryAndCurrencyModal`, [[react-common-ab-test]] types, `@tiket/next/client` |
| | `ErrorBoundary` | Class error boundary: logs with `createLogger` and shows `ErrorView` | `AppProvider` | passport, `@tiket/next/logger` |
| | `RemoteConfigScript` | Inline script that sets `window.__TIX_REMOTE_CONFIG__` (`basePrefixForApp`, `postLogPath`) before any remote loads | `_document` | none (feeds [[react-common-fetch-client]] inside remotes) |
| | `SEOPageHead` | `<title>`, description, Open Graph (including geo tags), links, optional `robots` (`useSEOPageHead`). `customCanonicalLink.ts` holds the DLP canonical overrides | home, destination, explore, cross-sell-trip, promo `Layout`, `_app` | `next/head` |
| **Remote wrappers** | `RemoteGlobalPopup` | Maps `isMobile` to `platform` for [[react-remote-global-popup]] | home | [[react-common-remote]], [[passport-utils]] types |
| | `RemoteGoogleOneTap` | Adds `isNewURLStructure` and `lang` from middleware data to [[react-remote-google-one-tap]] | home | react-common-remote, `@tiket/next/client` |
| | `Header` | Page header: hides itself when the legacy webview shows the native toolbar (`hideToolbar`, sets the native title), uses Passport `HeaderMobile` when `skipRemote` (webviews), else [[react-remote-header]] (`layoutVariantCode="001"`, sticky) | destination, explore, voucher-box, promo, DLP content | [[passport-header]], react-common-remote (both via `next/dynamic`) |
| | `Layout` | Promo page frame: `PromoHeader`, `SEOPageHead` or a `noindex` head for previews, critical [[react-remote-footer]] | promo ([[homepage-fe-promo]]) | react-common-remote. Imports `@context/Promo` and `pages/promo/...` |
| | `ErrorViewWithRetry` | Full-page error with remote header/footer and reload | home (desktop error) | passport `ErrorView`, react-common-remote |
| **Page-module support** | `PageModuleImageRenderer` | `next/image` renderers passed into `PageModule` (`DefaultPageModuleImageRenderer`, `CarouselImageRenderer`, `PageModuleLogoImageRenderer`) with Lightroom presets and critical-image `priority`/`fetchPriority` | home, destination, DLP content, voucher-box, cross-sell-trip | `@tiket/next/client`, `components/Image` (see [[passport-page-module]]) |
| | `Image` | `next/image` wrapper with Lightroom loader (`loaders.ts`, `initLocalLightroomLoader`), presets, blur placeholder | most features, `_app` | [[passport-assets]] placeholder, `@tiket/next/client` |
| **DLP** | `DynamicLandingPageContent` | Whole DLP body: hero, anchors, share, lazy `PageModule`, floating button, auto-hiding header, footer. Hooks `useAnchor`, `useAutoScrollToModule`, `useHideRemoteHeaderTitle`. Own `i18n/` | explore, explore-preview ([[homepage-fe-explore]]) | [[passport-page-module]], [[passport-floating-button]], [[passport-header]], [[passport-error-view]], [[passport-icons]], [[passport-utils]], react-common-remote `RemoteFooter` |
| | `DynamicLandingPageLoading` | DLP skeleton | explore | passport, [[passport-page-module-shared]] `Carousel` |
| | `HeroBanner` | DLP hero banner with menu/anchor navigation, colour helpers (`hexToRgb`, box-shadow) | DLP content | passport, [[passport-image]], [[passport-assets]], [[passport-utils]] |
| **Home** | `MobileHeader` | Mobile home header: animated search box (Lottie logo, marquee of `impressionSentences`), [[passport-global-search]] drawer, hamburger menu bottom sheet (login/register, language, currency, inbox, partnership, blibli tiket rewards), chatbot and promo buttons. Own `i18n/` and trackers | home (`HomeBackgroundBanner`) | [[passport-global-search]], passport, [[passport-icons]], [[passport-utils]], [[react-common-utilities]]. Imports `@pages/home/components/GlobalSearchTooltip` |
| **Destination** | `DestinationPageLoading` | Travel-guide skeleton | destination | passport, page-module-shared `Carousel` |
| **Share** | `ResponsiveSocialShare` | Picks `SocialShareMobile`/`SocialShareDesktop` by an explicit `isDesktop` prop, because Passport's adaptive version breaks on iOS webview (wrong `innerWidth`) | destination, DLP content | passport, [[passport-social-share]] types |
| **Feedback** | `ErrorPageContent` | Image + text + button error body (`notFound`/`general`) | `404` | passport |
| | `Loading` | Centered `LoadingIndicator` | voucher-box | passport |
| | `State` | `LoaderState` / `LoaderStateFull` (portal overlay that disables scroll) | `MobileHeader` menu bottom sheets | passport |
| | `LottiePlayer` | Thin `lottie-web` (light build) player: `src` URL or inline `animationData`, `loop`, `onComplete` | cross-sell-trip (offers hero, prize) | `lottie-web` |
| **Webview** | `WebViewWrapper` | Adds tap-highlight reset and an iOS status-bar spacer | destination, explore, promo, voucher-box, cross-sell-trip | none |

## Tracking
`MobileHeader` has its own `trackers.ts` per menu item (hamburger, chatbot, promo, language, currency, login/register, partnership, rewards). `DynamicLandingPageContent` uses `lib/tracker/dynamic-landing-page.ts`. The other components don't track.

## Tests
Most folders have colocated specs (`*.spec.tsx` or `__tests__/`). `components/HeroBanner/mock.tsx` is excluded from coverage and Sonar. `RemoteConfigScript`, `WebViewWrapper`, `RemoteGlobalPopup`, `RemoteGoogleOneTap`, `ErrorPageContent`, `ResponsiveSocialShare` have no spec of their own.

## Gotchas
- **Upward imports:** `components/Layout` imports `pages/promo` (header, i18n) and `@context/Promo`, and `components/MobileHeader` imports `@pages/home/components/GlobalSearchTooltip`. Moving those features means moving these too.
- `Header` and `DynamicLandingPageContent` load `@tiket/react-common-remote`/`@tiket/passport-header`/`@tiket/passport-page-module` through `next/dynamic`, while `ErrorViewWithRetry`, `Layout` and the page files import the remote components statically.
- `RemoteGoogleOneTap` (wrapper) derives `isNewURLStructure` from middleware data. Destination, explore, promo and voucher-box bypass it and hard-code `false`.
- `PageModuleImageRenderer` props are passed into `PageModule` with `as any` casts in every host, so type mismatches with Passport's renderer props don't show up at compile time.

## Sources
- `components/providers/*`, `components/ErrorBoundary/*`, `components/RemoteConfigScript/*`, `components/SEOPageHead/*`
- `components/RemoteGlobalPopup/*`, `components/RemoteGoogleOneTap/*`, `components/Header/*`, `components/Layout/*`, `components/ErrorViewWithRetry/*`
- `components/PageModuleImageRenderer/*`, `components/Image/*`
- `components/DynamicLandingPageContent/**`, `components/DynamicLandingPageLoading/*`, `components/HeroBanner/*`
- `components/MobileHeader/**`, `components/DestinationPageLoading/*`, `components/ResponsiveSocialShare/*`
- `components/ErrorPageContent/*`, `components/Loading/*`, `components/State/**`, `components/LottiePlayer/*`, `components/WebViewWrapper/*`
- `vitest.config.mts`, `sonar-project.properties` (coverage excludes)
