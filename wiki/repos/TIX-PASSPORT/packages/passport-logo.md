---
title: Logo (Blibli tiket group)
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-logo"
sources:
  - packages/logo/src
  - packages/logo/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Logo
> Inline SVG components for the "Blibli tiket group" corporate logo.

Part of [[passport-packages]].

## What it does
Exports the group logo as inline SVG React components (viewBox `0 0 104 19`) that accept any `<svg>` props. The blue version is for light backgrounds, and the white version has a yellow dot for dark backgrounds. It is not the tiket.com wordmark: the header uses its own `DEFAULT_TIKET_LOGO` (see [[passport-header]]).

## Public API
- `BlibliTiketLogoBlue(props: JSX.IntrinsicElements['svg'])`
- `BlibliTiketLogoWhite(props)`. It uses a fixed `clipPath` id `blibli-tiket-logo-white-clip`.
- `BlibliTiketLogo`: **deprecated** because it has unintended padding. Use Blue or White.

Not re-exported by [[passport-umbrella]]. Import it from `@tiket/passport-logo`.

## Usage
```tsx
<BlibliTiketLogoBlue height={18} />
```

## Depends on
[[passport-utils]] (declared only).

## Used by
- Inside TIX-PASSPORT: [[passport-footer]], [[passport-otp-unm]], [[passport-sidebar]].
- No direct consumers in the other repos on baseline.

## Gotchas
- Several `BlibliTiketLogoWhite` instances on one page share the same `clipPath` id. That works, but the ids are duplicated in the DOM.

## Sources
- packages/logo/src/BlibliTiketLogo.tsx
- packages/logo/package.json
