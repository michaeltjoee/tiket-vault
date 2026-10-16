---
title: MissionPageModule
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-mission-page-module"
sources:
  - packages/mission-page-module/src
  - packages/mission-page-module/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# MissionPageModule
> Compact mission card (title, stamp or GBV progress, nudge, CTA) for embedding a loyalty mission inside another page or WebView. Clicking it goes to `/mission/{slug}`.

Part of [[passport-packages]].

## What it does
It renders a single mission summary card with a gradient background from `mission.color.background.{top,bottom}`. It is presentational: the host fetches the mission and passes `isLoading`, `code` (the API result code) and the data. It shows a loader while `isLoading`, and an error state with `onRetry` when `code !== 'SUCCESS'` or `mission`/`cta` is missing. A click on the card body fires `clickMissionOutsidePageModule` and sets `window.location.href = /mission/{missionSlug}`. That URL is the full page rendered with [[passport-mission-landing-page]].

## Public API
`MissionPageModule` (memo, `'use client'`; also in [[passport-umbrella]]), plus the types and the `MissionCtaStatus` enum (`SEARCH`, `JOIN_MISSION`, `MISSION_JOINED`, `MISSION_DONE`, `MISSION_ENDED`, `MISSION_CLAIMED`, `LOGIN`, `PERSONAL_ACCOUNT`, `CHANGE_CURRENCY`, `SET_REMINDER`, `REMINDER_HAS_BEEN_SET`, `CLAIM_REWARD`).

| Prop | Notes |
|---|---|
| `mission`, `cta: { type, title, link? }`, `missionSlug`, `code`, `isLoading`, `onRetry` | data and state from the host |
| `milestoneEnable` | new milestone progress UI or legacy |
| `isTurnOffGBVProgressBar` | hides the GBV bar |
| `isPreviewMobile` | forces mobile layout (CMS preview) |
| `impressionMissionPageModule`, `clickMissionPageModule`, `clickMissionOutsidePageModule` | tracking callbacks |

## Usage
```tsx
<MissionPageModule mission={data} cta={data.cta} missionSlug={slug}
  code={res.code} isLoading={isLoading} onRetry={refetch}
  milestoneEnable isPreviewMobile={false} />
```

## Depends on
[[passport-countdown]], [[passport-loading-indicator]], [[passport-button]], [[passport-typography]], [[passport-utils]], assets, icons. Peer: `date-fns`.

## Used by
- No consumers found in the other workspace repos.

## Gotchas
- The navigation is a hard `window.location.href` change, not a router push.

## Sources
- packages/mission-page-module/src/MissionPageModule.tsx
- packages/mission-page-module/src/components/MissionWebview/index.tsx
- packages/mission-page-module/src/types/mission-props.ts
- packages/mission-page-module/package.json
