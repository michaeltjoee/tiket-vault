---
title: Image Preview
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-image-preview"
umbrella: true
sources:
  - packages/image-preview/src
  - packages/image-preview/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Image Preview
> Full-screen gallery viewer for images and videos, with a slider, thumbnails, captions and keyboard navigation. It has desktop, mobile and adaptive views.

Part of [[passport-packages]].

## What it does
It opens a controlled gallery at `initialIndex` and reports the index as it changes. Desktop renders inside `UnstableBaseModal` from [[passport-modal]], with arrow buttons, a thumbnail strip that scrolls the active item into view, and ←/→/Esc keys. Mobile renders full-screen through [[passport-portal]], with a close icon and a mobile thumbnail strip. Items with `type: 'video'` play as `<video>` with play/pause, mute and a seek bar (`InputBar`). The other items render `src.high` as an `<img>` and use `src.low` for thumbnails. Each slide has a caption block: `title`, `additionalTitle`, `subtitle`, `additionalSubtitle` and an "n / total" counter. Slides are driven by `keen-slider`.

## Public API
| Export | Props |
|---|---|
| `ImagePreviewAdaptive` | `images`, `initialIndex`, `isOpen`, `onIndexChanged(i)`, `onClosed()`, `modalTitle` (desktop only), `portalId` (default `modal-root`). Picks mobile or desktop from `usePassport().breakpoint` |
| `ImagePreviewDesktop` | the same, plus `imageAction` (an extra action in the caption) |
| `ImagePreviewMobile` | `images`, `initialIndex`, `isOpen`, `onClosed`, `onIndexChanged`, `portalId` |
Types: `ImagePreview` (`{ src: { high, low }, alt?, title?, additionalTitle?, subtitle?, additionalSubtitle?, type?, poster?, thumbnailGreyedOut? }`), `ImageDescriptionProps`, and each view's props type.

## Usage
```tsx
<ImagePreviewAdaptive
  images={photos.map((p) => ({ src: { high: p.large, low: p.thumb }, alt: p.caption }))}
  initialIndex={clicked}
  isOpen={open}
  onIndexChanged={setClicked}
  onClosed={() => setOpen(false)}
/>
```

## Depends on
[[passport-modal]], [[passport-portal]], [[passport-button]], [[passport-divider]], [[passport-icons]], [[passport-loading-indicator]], [[passport-typography]], [[passport-utils]]; `keen-slider`.

## Used by
- TIX-FINTECH-NEXT-FE, through the umbrella `@tiket/passport`: the insurance claim centre ([[fintech-fe-insurance-claim]]). `ClaimDocuments.tsx` renders `ImagePreviewAdaptive`. `FileUploadInput.tsx` and `FormSummary.tsx` use the `ImagePreview` type from `@tiket/passport/types/image-preview`.
- Internally, only the umbrella re-exports it.

## Gotchas
- `ImagePreviewAdaptive` falls back to desktop when the Passport context has no `breakpoint`, so wrap the app in the Passport provider ([[passport-utils]]) to get the mobile view.
- The default `portalId` is `modal-root`. That element has to exist in the DOM.
- `src/constants.ts` (`IMAGES`) is story fixture data and isn't exported.
- `thumbnailGreyedOut` is meant for the dashboard use case.

## Sources
- `packages/image-preview/src/index.ts`, `packages/image-preview/src/views/ImagePreview.types.ts`
- `packages/image-preview/src/views/adaptive/ImagePreview.tsx`, `packages/image-preview/src/views/desktop/ImagePreview.tsx`, `packages/image-preview/src/views/mobile/ImagePreview.tsx`
- `packages/image-preview/src/hooks/useKeyListener.ts`, `packages/image-preview/src/videoUtils.ts`
- `packages/image-preview/package.json`
