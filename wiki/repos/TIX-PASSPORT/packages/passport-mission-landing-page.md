---
title: MissionLandingPage
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-mission-landing-page"
sources:
  - packages/mission-landing-page/src
  - packages/mission-landing-page/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# MissionLandingPage
> Presentational page for a loyalty "mission" (stamp or GBV progress toward a reward): banner, progress and reward, more info (FAQ, how to join, T&C) and a CTA.

Part of [[passport-packages]].

## What it does
It is purely presentational and does no fetching. The host supplies props for four sections, and `Layout` renders them in order: `SectionBanner`, `SectionProgressReward`, `SectionMoreInfo` (hidden when `reward.status === 'EXPIRED'`) and `SectionCta`. `milestoneEnable` switches between the current milestone-based sections and the legacy `MissionOld/*` ones. `isPreviewSizeMobile` forces the mobile layout, for CMS preview frames.

## Public API
- `MissionLandingPage` (memo, `'use client'`). Also in [[passport-umbrella]].
- Section components: `SectionBanner`, `SectionMoreInfo`, `SectionCta`, `SectionCtaOld`.
- `MissionLandingPageProps`: `{ isPreviewSizeMobile, milestoneEnable, sectionBanner, sectionProgressReward, sectionMoreInfo, sectionCta }`.
  - `sectionProgressReward`: `userProgress[]`, `milestones[]`, `reward`, `gbvProgress?`, `nudge`, `color`, `missionCtaStatus`, loading flags. `popup` and `multiEnroll` are marked "remove after migration".
  - `sectionCta`: `onConfirm`, `status`, `ctaButtonState` (a [[passport-button-slider]] status), `ctaText`, `ctaLink`, `totalProgress` / `totalActiveProgress`, `startAt`, `isLoadingClaimReward`, `rewardStatus` (`CLAIMED|COMPLETED|NOT_COMPLETED|EXPIRED`), plus impression callbacks for B2B-corporate and non-IDR-currency users.

## Usage
See `src/stories/MissionLandingPage.stories.tsx` (milestone variant) and `src/stories/MissionOldPage.tsx` (legacy).
```tsx
<MissionLandingPage milestoneEnable isPreviewSizeMobile={false}
  sectionBanner={banner} sectionProgressReward={progress}
  sectionMoreInfo={info} sectionCta={cta} />
```

## Depends on
[[passport-button-slider]], [[passport-countdown]], [[passport-gift-voucher]], [[passport-gradient-banner]], [[passport-tabs]], [[passport-tooltip]], [[passport-collapse]], [[passport-card]], [[passport-header]], [[passport-content-loader]], [[passport-typography]], [[passport-utils]], assets, icons. External: `@floating-ui/react`.

## Used by
- No consumers found in the other workspace repos. Its sibling for in-app or page-module surfaces is [[passport-mission-page-module]].

## Gotchas
- The legacy (`MissionOld`) and new section types differ. `Layout` casts `sectionProgressReward` to the old type when `milestoneEnable` is false, so a type mismatch won't surface at compile time.

## Sources
- packages/mission-landing-page/src/MissionLandingPage.tsx
- packages/mission-landing-page/src/components/Layout/index.tsx
- packages/mission-landing-page/src/types/mission-landing-props.ts
- packages/mission-landing-page/src/components/SectionCta/types.ts
- packages/mission-landing-page/package.json
