---
title: Remote FooterMobile
repo: TIX-REACT-REMOTE
kind: component
npm: "@tiket/passport-footer"
sources:
  - src/components/footer-mobile
verified_at: 281778b
updated: 2026-10-16
status: current
tags: [repo/react-remote, kind/component]
---

# Remote FooterMobile
> Mobile-only footer (`FooterMobile` from [[passport-footer]]) served over module federation.

## What it does
Exposed as `footer-mobile`. Like [[react-remote-footer]] but renders `FooterMobile` and wires only the download-app and social-media trackers (no `footerContentGTMTracker`). Does not forward `abTestOnServerResponse`.

## Public API
`CommonComponentProps`: `lang` (default `'id'`), `country` (default `'id'`), `currency`, `isNewURLStructure`. `getServerSideProps` reads `tiket_currency` from cookies.

## Usage
```tsx
import { RemoteFooterMobile } from '@tiket/react-common-remote';
<RemoteFooterMobile />
```

## Depends on
[[passport-footer]], [[react-remote-wrapper]].

## Used by
No direct `RemoteFooterMobile` usage found in TIX-NEXT-PAYMENT-FE or TIX-FINTECH-NEXT-FE baselines.

## Sources
- src/components/footer-mobile/index.tsx
- src/utils/tracker/footer.ts
