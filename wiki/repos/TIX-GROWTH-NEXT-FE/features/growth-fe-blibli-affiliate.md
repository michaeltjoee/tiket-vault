---
title: Blibli affiliate landing (/blibli-affiliate)
repo: TIX-GROWTH-NEXT-FE
kind: feature
sources:
  - pages/blibli-affiliate
  - components/Layout/MainLayout
  - components/SEOPageHead
  - lib/i18n/en.ts
  - lib/i18n/id.ts
  - lib/gtm/event.ts
  - lib/config/apiUrl.ts
  - .env.local.example
verified_at: d4162e3
updated: 2026-10-16
status: current
tags: [repo/growth-fe, kind/feature]
---

# Blibli affiliate landing (/blibli-affiliate)
> A static landing page that asks guests to log in and join the Blibli × tiket affiliate program. Logged-in users are redirected server-side to the external Blibli affiliate platform (`NEXT_PUBLIC_BLIBLI_AFFILIATE_PAGE`).

## What it does
- **Guest:** the page shows the title ("Let's join"), the Blibli-tiket affiliate logo, three selling points, an eligibility note (Indonesian ID card and bank account) and a sticky "Log in to join" button. The button sends the user to `/login?ref=<current URL>`.
- **Logged in:** `getServerSideProps` returns a 302 to `NEXT_PUBLIC_BLIBLI_AFFILIATE_PAGE`, or to `/` when that env is unset. The example value is `https://affiliate.test.bliblitiket.dev/?tenantId=TIKET`. After login, the user returns through `ref` to `/blibli-affiliate`, and this redirect then takes them to the platform. That is the whole join flow.
- There are no API calls. All content is static copy in the app-wide i18n dictionary.

## Routes & entry points
- `pages/blibli-affiliate/index.page.tsx` (`AffPage`). `getServerSideProps` does the following:
  - reads `getServerSidePropsMiddlewareData`
  - redirects when `sessionData.isLogin` is set
  - otherwise returns `middlewareData` plus remote props: `header` with `isLogin` taken from `accountId`, and `footer`
- Layout depends on `usePassport().breakpoint` ([[passport-utils]]). On desktop the content sits inside `MainLayout` with `withFooter={false}`, which renders [[react-common-remote]] `RemoteHeader`. On mobile there is no layout, only `MobileBackButton variant="transparent"` ([[passport-header]]) above the content.
- `SEOPageHead` (see [[growth-fe-components]]) is rendered without `title`/`description`, so it uses the app defaults `meta.title`/`meta.description`.
- A global `<style jsx>` sets the `body` background to `--color-B100`.
- The route goes through the normal middleware chain (locale rewrite). See [[growth-fe-app-shell]].

## Data & services
None. Copy comes from `lib/i18n/{en,id}.ts` under `pages.blibliAffiliate` (`title`, `description`, `informationItems[3]` with inline `<b>` HTML, `additionalInformation`, `ctaLabel`) through `useI18n` from `@/lib/i18n`. Icons are `tds_bc_logo_blibli_tiket_affiliate`, `tds_mi_share_affiliate`, `tds_mi_affordable_price` and `tds_mi_profile_add` from [[passport-assets]].

| Env | Use |
|---|---|
| `NEXT_PUBLIC_BLIBLI_AFFILIATE_PAGE` | redirect target for logged-in users (falls back to `/`) |

## Key components
`pages/blibli-affiliate/_blocks/`: `HeaderPage` (title, logo, description), `InformationSection` (three items; HTML sanitised with `isomorphic-dompurify` and rendered with `dangerouslySetInnerHTML`), `AdditionalInformationSection`, `FooterPage` (full-width `Button` CTA). The logic lives in `useBlibliAffiliateLandingPage.ts`. `_blocks` contains no `*.page.tsx` files, so Next does not route it (`pageExtensions: ['page.tsx', 'page.ts']`).

## Tracking
`useBlibliAffiliateLandingPage` (common fields `screenName: 'blibliAffiliatePage'`, `vertical`/`screenOwner: 'growth'`):
- On mount, and again whenever `middlewareData` changes: `pageVisit('growth', …)` → `customTracker` with `pageView` / `pageVisit`, `eventLabel: 'tiketPageVisit'`, `eventDescription: 'pageLoadedBlibliAffiliate'`, `url`.
- On CTA click: `GTM.pushObject` `click` / `ctaButton` / `clickButton`, `eventLabel: 'blibliAffiliate'`, `ctaButton: 'Log in to join'`, `eventDescription: 'joinBlibliAffiliate'`, then `replaceLocation(withForwardParams('/login?ref=' + href))`.

See [[gtm-datalayer-tracking]].

## Tests
Five Jest specs live in `pages/blibli-affiliate/_blocks/__tests__/`: `HeaderPage`, `InformationSection`, `AdditionalInformation`, `indexPage` (mobile vs desktop layout, CTA click) and `useBlibliAffiliateLandingPage` (page-visit tracking, CTA event and redirect). No test covers `getServerSideProps`, and there is no e2e spec.

## Gotchas
- The `ref` value in the login URL is **not URL-encoded**. If `/blibli-affiliate` itself has query params, they become top-level params of `/login` instead of staying inside `ref`. `withForwardParams` (here from `@tiket/react-common-utilities`, see [[react-common-utilities]]) then adds the forwarded `tag_*`/`currency` params.
- The CTA uses `replaceLocation`, so the landing page is replaced in history: pressing back from login skips it.
- The two login checks read different fields. The redirect uses `sessionData.isLogin`, while the header `isLogin` prop uses `accountId`.
- SSR fetches the `footer` remote props, but the page never renders a footer (desktop sets `withFooter={false}` and mobile has no layout). On mobile it also fetches `header` props that are never rendered.
- The page-visit effect depends on `middlewareData`. A new object reference on re-render fires `pageVisit` again.

## Sources
- `pages/blibli-affiliate/index.page.tsx`, `useBlibliAffiliateLandingPage.ts`, `index.module.scss`
- `pages/blibli-affiliate/_blocks/*/index.tsx`, `_blocks/__tests__/*.spec.ts(x)`
- `components/Layout/MainLayout/index.tsx`, `components/SEOPageHead/*`
- `lib/i18n/en.ts`, `lib/i18n/id.ts`, `lib/gtm/event.ts`, `lib/config/apiUrl.ts`, `lib/config/appDefaults.ts`
- `.env.local.example` (`NEXT_PUBLIC_BLIBLI_AFFILIATE_PAGE`), `next.config.js` (`pageExtensions`)
