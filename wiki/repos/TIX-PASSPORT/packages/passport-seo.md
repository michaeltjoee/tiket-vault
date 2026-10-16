---
title: SEO components
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-seo"
umbrella: true
sources:
  - packages/seo/src
  - packages/seo/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# SEO components
> Server-renderable SEO content blocks for landing pages: a text-with-image slot, an FAQ accordion, cards, internal-link lists (optionally tabbed), and a content summary.

Part of [[passport-packages]].

## What it does
These are content sections whose text has to be in the HTML for crawlers. Each takes `titleAs` (or `headingAs`) so the page controls its heading hierarchy (default `h2`).
- `SeoSlot`: a title, an `image` slot (`imagePosition` left or right, `imageRatio` `1:1` or `3:2`) and body `children` in a [[passport-scrollable-content]] with a read-more box (`TextBoxWithReadMoreButton`), plus `theme` and `moduleId`. It is the `TEXT_WITH_IMAGE` page module.
- `SeoFaq`: `{ title, items: { question, answer }[] }` rendered with [[passport-accordion]].
- `SeoCard`: `{ title, subtitle?, cards: { imageUrl?, title, subtitle?, linkText?, linkHref? }[], cardTitleAs? }`.
- `SeoInternalLink`: either flat `links` or `tabbedLinks: { id, title, links }[]` (via [[passport-tabs]]), with `heading`, `onTabClick`, `onLinkClick(link, linkIndex, tab?, tabIndex?)` and `theme`. It is the `INTERNAL_LINK` page module.
- `SeoContentSummary`: `{ title, subTitle, contents: { slug, image, label, ctaText }[], onClickItem, onClickItemActionLink }`.

## Public API
`SeoSlot`, `SeoFaq`, `SeoCard`, `SeoInternalLink`, `SeoContentSummary` (all in [[passport-umbrella]]), plus their props types (`SeoSlotProps`, `FAQ`, `SeoFaqProps`, `Card`, `SeoCardProps`, `Link`, `Tab`, `WithTabs`, `LinkClickEvent`, …).

## Usage
From TIX-FINTECH-NEXT-FE insurance claim-center `MoreInfoSection`:
```tsx
<SeoFaq title="Pertanyaan umum" titleAs="h3"
  items={faqs.map((f) => ({ question: f.q, answer: <div dangerouslySetInnerHTML={{ __html: f.a }} /> }))} />
```

## Depends on
[[passport-accordion]], [[passport-tabs]], [[passport-scrollable-content]], [[passport-container]], [[passport-button]], [[passport-image]], [[passport-typography]], [[passport-utils]], icons.

## Used by
- Inside TIX-PASSPORT: [[passport-page-module]] (`TEXT_WITH_IMAGE`, `INTERNAL_LINK`).
- TIX-FINTECH-NEXT-FE: `SeoFaq` in `projects/insurance/claim-center/landing/components/MoreInfoSection/components/{Desktop,Mobile}.tsx`.

## Gotchas
- FAQ answers are collapsed accordion panels. Check that [[passport-accordion]] keeps panel content in the DOM if the answers need to be crawlable.

## Sources
- packages/seo/src/SeoSlot.tsx
- packages/seo/src/SeoFaq.tsx
- packages/seo/src/SeoCard.tsx
- packages/seo/src/SeoInternalLink.tsx
- packages/seo/src/SeoContentSummary.tsx
- packages/seo/package.json
