---
title: Portal
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-portal"
umbrella: true
sources:
  - packages/portal/src
  - packages/portal/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Portal
> SSR-safe `createPortal` wrapper that renders children into `#<id>` (default `modal-root`), creating that element on `document.body` if needed.

Part of [[passport-packages]].

## What it does
On mount it looks up `document.getElementById(id)`, creates and appends a `<div id={id}>` if there is none, then portals `children` into it. It renders `null` until mounted, so nothing is in the SSR output and there is no hydration mismatch. Every Passport overlay goes through it: [[passport-modal]], [[passport-bottom-sheet]], [[passport-dialog]], [[passport-snackbar]], [[passport-tooltip]], [[passport-loading]] and others.

## Public API
`Portal({ id = 'modal-root', children })` (also in [[passport-umbrella]]); type `PortalProps`.

## Usage
```tsx
<Portal id="page-module-collapse">
  <div className={styles.overlay} />
</Portal>
```

## Depends on
[[passport-utils]] (declared). Peers: `react`, `react-dom`.

## Used by
- Inside TIX-PASSPORT: 14 packages, including bottom-sheet, coachmark, dialog, dropdown, header, loading, modal, page-module-collapse, snackbar and tooltip.
- TIX-FINTECH-NEXT-FE: `projects/insurance/shared/components/Modal/Modal.tsx` (via `@tiket/passport`).

## Gotchas
- The created container is never removed on unmount.
- Overlays that share an `id` (e.g. all modals use `modal-root`) stack in DOM order inside one container.
- Content appears one effect tick after mount. Tests need to wait for it (e.g. `findBy*`).

## Sources
- packages/portal/src/Portal.tsx
- packages/portal/package.json
