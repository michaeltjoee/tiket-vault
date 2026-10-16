---
title: SocialShare
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-social-share"
umbrella: true
sources:
  - packages/social-share/src
  - packages/social-share/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# SocialShare
> Share sheet for Facebook, Twitter/X, WhatsApp and copy-link. It is a bottom sheet on mobile and a popover on desktop, and `SocialShareAdaptive` picks one by breakpoint.

Part of [[passport-packages]].

## What it does
Each channel builds a share URL from `url` and `title`, with optional per-channel query params (`queryParamsByShareChannel.{facebook,twitter,whatsapp,copyLink}`, e.g. UTM tags). It opens the URL in a new window, or calls `onClickSocmed(url, socmedName)` instead if you provide it. Copy-link uses `copyTextToClipboard` and shows a localized success snackbar (needs a [[passport-snackbar]] provider), then calls `onSuccessCopyText` or `onFailedCopyText`. The desktop variant has `onOpen` and closes on scroll (`hooks/useScroll.ts`).

## Public API
`SocialShareMobile`, `SocialShareDesktop`, `SocialShareAdaptive` (all in [[passport-umbrella]]) and their props types.

| Prop | Notes |
|---|---|
| `isOpen`, `onClose` | required |
| `onOpen` | desktop and adaptive only (required there) |
| `title`, `url` | share payload |
| `queryParamsByShareChannel` | per-channel extra params |
| `onClickSocmed`, `onSuccessCopyText`, `onFailedCopyText` | hooks |
| `bottomSheetTitle`; `portalId` (mobile) | |

## Usage
```tsx
<SocialShareAdaptive isOpen={open} onOpen={() => setOpen(true)} onClose={() => setOpen(false)}
  title="Gift card tiket.com" url={shareUrl}
  queryParamsByShareChannel={{ whatsapp: { utm_source: 'wa' }, facebook: {}, twitter: {}, copyLink: {} }} />
```

## Depends on
[[passport-bottom-sheet]], [[passport-snackbar]], [[passport-divider]], [[passport-typography]], [[passport-utils]], icons.

## Used by
- Inside TIX-PASSPORT: [[passport-social-share-mobile]], a re-export shim.
- TIX-FINTECH-NEXT-FE: `vitest.setup.tsx` mocks `@tiket/passport-social-share` globally, so any share UI under test is stubbed. No baseline source file imports the components by name through `@tiket/passport`.

## Gotchas
- `SocialShareAdaptive` relies on `usePassport().breakpoint`. Before it resolves it renders the desktop variant.

## Sources
- packages/social-share/src/views/adaptive/SocialShare.tsx
- packages/social-share/src/views/mobile/SocialShare.tsx
- packages/social-share/src/views/desktop/SocialShare.tsx
- packages/social-share/src/utils.ts
- packages/social-share/package.json
