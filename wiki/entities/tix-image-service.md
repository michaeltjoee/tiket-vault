---
title: tix-image service (TIX-IMAGES-BE)
kind: entity
repos: [TIX-PASSPORT]
sources:
  - TIX-PASSPORT/packages/image-upload/src/ImageUpload.tsx
  - TIX-PASSPORT/packages/image-upload/src/types.ts
  - TIX-PASSPORT/packages/image-upload/src/lib/utils.ts
verified_at:
  TIX-PASSPORT: 7a33010aca
updated: 2026-10-16
status: current
tags: [kind/entity, repo/passport]
---

# tix-image service
> The image upload and transformation backend (repo `tiket/TIX-IMAGES-BE`, not in this workspace). [[passport-image-upload]] posts images to it and asks for resized variants.

## What the FE relies on
- **Endpoint:** `POST <host>/ms-gateway/tix-image/images` by default (`ImageUpload.tsx`). The `apiURL` prop overrides it. The story uses the dashboard gateway, `https://gatotkaca.tiket.com/tix-api-gateway-dashboard-event/tix-image/images`.
- **Host:** `defaultAPIHostName()` returns `https://gatotkaca.tiket.com` when the page runs on `local.tiket*` and `''` (same origin) otherwise. Local development therefore uploads to staging ([[tiket-environments]]).
- **Variants:** each `OutputVariant` has `name`, `width`, `height`, `isThumbnail` and a `crop` mode from the backend: `scale`, `fit`, `limit`, `mfit`, `fill`, `lfill`, `pad`, `lpad`, `mpad` or `crop`.
- Requests go through `usePassport().customFetch` when the host provides it ([[passport-custom-fetch]]).

## Consumers
No app in this workspace imports `@tiket/passport-image-upload` directly on its baseline. It is reachable only through the umbrella [[passport-umbrella]].

## Where it shows up
Pages that link here:
- TIX-PASSPORT: [[passport-image-upload]]

## Sources
- TIX-PASSPORT `packages/image-upload/src/{ImageUpload.tsx,ImageUpload.stories.tsx,types.ts,lib/utils.ts}`
