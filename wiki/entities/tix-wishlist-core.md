---
title: tix-wishlist-core (wishlist backend)
kind: entity
repos: [TIX-PASSPORT, TIX-REACT-REMOTE, TIX-REACT-COMMON]
sources:
  - TIX-PASSPORT/packages/wishlist/src/services
  - TIX-PASSPORT/packages/utils/src/context.tsx
  - TIX-REACT-REMOTE/src/components/wishlist-module/index.tsx
  - TIX-REACT-REMOTE/src/components/wrapper/PassportWrapper/index.tsx
  - TIX-REACT-COMMON/packages/react-common-remote/src/RemoteWishlistModule
verified_at:
  TIX-PASSPORT: 7a33010aca
  TIX-REACT-REMOTE: 281778b
  TIX-REACT-COMMON: 14597c4e
updated: 2026-10-16
status: current
tags: [kind/entity, repo/passport, repo/react-remote, repo/react-common]
---

# tix-wishlist-core
> The wishlist backend (a Go service, `tix-wishlist-core-go`) that stores a user's saved products ("wishes") and their collections. Only [[passport-wishlist]] calls it, and the other repos reach it through that package. Its source is not in this workspace.

## Endpoints used by the FE
All under `/tix-wishlist-core-go/v1`, from `packages/wishlist/src/services`:
- `wishes`: create a wish, remove it, save it to a collection, and `wishes/{id}/redirect` to get the product page (`create-wish-by-id`, `remove-wish-by-id`, `save-wish-to-collection`, `get-product-page-by-wish-id`).
- `collections`: list (with query params), get by id, create, update (`get-all-collections`, `get-collection-by-id`, `create-new-collection`, `update-collection-by-id`).
- `collections/images`: cover images for collections (`get-collection-images`).

## How it reaches pages
- [[passport-wishlist]] `WishlistModule` makes the calls, through [[passport-custom-fetch]] when the host provides one.
- TIX-REACT-REMOTE serves it as the `wishlist-module` remote with `reuseRoot`, so repeated mounts update props instead of remounting ([[react-remote-wishlist-module]], [[module-federation]]). `PassportWrapper` passes `wishlistData` (wishes, `showManageWishlistPopup`) into `PassportProvider`, with a `@ts-ignore` for a type mismatch flagged for the wishlist team.
- TIX-REACT-COMMON has `RemoteWishlistModule` and its `Fallback` in [[react-common-remote]].
- TIX-REACT-COMMON's gatekeeper also has a Sonar config for a separate `tix-next-wishlist-fe` app, which is not in this workspace.

## Where it shows up
Pages that link here:
- TIX-PASSPORT: [[passport-wishlist]]

## Sources
- TIX-PASSPORT `packages/wishlist/src/services/*.ts`, `packages/utils/src/context.tsx` (`WishlistDataType`)
- TIX-REACT-REMOTE `src/components/wishlist-module/{index.tsx,bootstrap.ts}`, `src/components/wrapper/PassportWrapper/index.tsx`
- TIX-REACT-COMMON `packages/react-common-remote/src/RemoteWishlistModule/`, `packages/react-common-gatekeeper/src/sonar/projects/tix-next-wishlist-fe.ts`
