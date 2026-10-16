---
title: Remote FooterDesktop
repo: TIX-REACT-REMOTE
kind: component
npm: "@tiket/passport-footer"
sources:
  - src/components/footer-desktop
verified_at: 281778b
updated: 2026-10-16
status: current
tags: [repo/react-remote, kind/component]
---

# Remote FooterDesktop
> Desktop-only footer (`FooterDesktop` from [[passport-footer]]) served over module federation.

## What it does
Exposed as `footer-desktop`. Same as [[react-remote-footer]] (same footer data selection, logo, and all three GTM trackers) but renders `FooterDesktop` and does not forward `abTestOnServerResponse`.

## Public API
`CommonComponentProps`: `lang` (default `'id'`), `country` (default `'id'`), `currency`, `isNewURLStructure`. `getServerSideProps` reads `tiket_currency` from cookies.

## Usage
```tsx
import { RemoteFooterDesktop } from '@tiket/react-common-remote';
<RemoteFooterDesktop />
```

## Depends on
[[passport-footer]], [[react-remote-wrapper]].

## Used by
- TIX-NEXT-PAYMENT-FE `pages/smart_pay/index.page.tsx`.
- TIX-FINTECH-NEXT-FE `app/error.page.tsx`, `projects/insurance/shared/components/Layout/Layout.tsx`, `projects/insurance/shared/components/ErrorFullPage/ErrorFullPage.tsx`, `projects/insurance/standalone/landing/index.tsx`.

## Sources
- src/components/footer-desktop/index.tsx
- src/utils/footer.ts
- src/utils/tracker/footer.ts
