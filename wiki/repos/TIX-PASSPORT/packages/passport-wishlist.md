---
title: Wishlist
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-wishlist"
sources:
  - packages/wishlist/src
  - packages/wishlist/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Wishlist
> The wishlist heart (`WishIcon`), which saves or removes a product through the wishlist API, plus `WishlistModule`, the "Add to collection / Manage your wishlist" pop-up flow that ships as a React remote.

Part of [[passport-packages]].

## What it does
Wishlist state lives in the Passport context (`wishlistData` on `PassportProvider`, see [[passport-utils]]). `useRemoteWishlistModule()` creates that state (`wishes` map, active wish IDs and vertical, pop-up visibility, `snackbar`) and returns `getWishlistDataProps()`. Pass its `wishlistData` both to `PassportProvider` and to `WishlistModule`.

- `WishIcon` reads `wishes[productId]` to decide whether the heart is filled (`IconWishlistAnimated` from [[passport-icons]]). It seeds the map from the `wishId` prop. On click: when logged out, it redirects to `/login` with `wishProductId`, `wishProductParams` (JSON) and `wishProductType` appended to the return URL, so the wish can be completed after login. When logged in, it calls create or remove-wish, ignoring clicks while a request is pending.
- `WishlistModule` responds to `showManageWishlistPopup`. After a wish is created, it lets the user add it to a collection, create or edit a collection (name plus a chosen image), or jump to the wishlist page. It's a [[passport-modal]] on desktop and a [[passport-bottom-sheet]] on mobile (`AdaptivePopup`), with hash-based history (`#manage-your-wishlist`, `#create-collection`) when `enablePopupHistory` is set.

## Public API
| Export | Notes |
|---|---|
| `WishIcon` (memo) | `productId`, `productType` (`HOTEL`, `HOMES`, `FLIGHT`, `TODO`, `ORDER`), `productParams`, `wishId`, `isLogin`, `withButton` (wraps it in a `<button>`), `onClick`, `onWishActionCallback({ wishId, productId, isWishlisted })`, plus icon `size` |
| `useRemoteWishlistModule({ enablePopupHistory })` | returns `getWishlistDataProps()` |
| `WishlistModule` | `WishlistModuleProps` (the `wishlistData` object) |
| `ManageYourWishlist`, `CreateEditCollectionPopup` | inner pieces, also exported |
Types: `WishIconProps`, `WishlistModuleProps`, `WishlistVerticals`, `Wishes`, `ProductParams`, `WishActionCallback`, `Collection`, API param and response types, `BottomSheetHashKey`.

## Usage
```tsx
const { getWishlistDataProps } = useRemoteWishlistModule({ enablePopupHistory: true });
const { wishlistData } = getWishlistDataProps();

<PassportProvider wishlistData={wishlistData} …>
  <WishIcon productId={hotel.id} productType="HOTEL" productParams={params} wishId={hotel.wishId} isLogin={isLoggedIn} withButton />
  <RemoteWishlistModule {...wishlistData} />   {/* from TIX-REACT-REMOTE */}
</PassportProvider>
```

## Depends on
[[passport-bottom-sheet]], [[passport-bottom-app-bar]], [[passport-modal]], [[passport-dialog]], [[passport-form]], [[passport-radio]], [[passport-toggle]], [[passport-snackbar]], [[passport-notification-banner]], [[passport-card]], [[passport-button]], [[passport-content-loader]], [[passport-loading-indicator]], [[passport-divider]], [[passport-icons]], [[passport-page-module-shared]], [[passport-typography]], [[passport-assets]], [[passport-utils]]; [[react-common-utilities]] (`getWebViewEnvClient`). Backend: [[tix-wishlist-core]] (`/tix-wishlist-core-go/v1/wishes`, `/v1/collections`, `/collections/images`, `/wishes/{id}/redirect`).

## Used by
- TIX-REACT-REMOTE: [[react-remote-wishlist-module]] wraps `WishlistModule` in `PassportWrapper` and serves it over [[module-federation]].
- Internal: only the umbrella `@tiket/passport`. Product cards in apps render `WishIcon`.

## Gotchas
- `WishIcon` **throws** if `wishlistData` isn't in the Passport context. Any page that shows a heart needs `useRemoteWishlistModule` wired into `PassportProvider`.
- The source comment says `WishlistModule` "is not intended to be imported directly". Consume the remote from TIX-REACT-REMOTE so all verticals share one version.
- `unsetWish` sets `wishes[productId] = null` rather than deleting the key, so `WishIcon` won't re-seed from a stale `wishId` prop afterwards.
- `types/wishlist.ts` imports from `@tiket/passport-snackbar/src/core/types` and `@tiket/passport-icons/src/types`, deep paths into those packages' source.

## Sources
- `packages/wishlist/src/index.ts`, `packages/wishlist/src/WishIcon.tsx`, `packages/wishlist/src/types/wishlist.ts`
- `packages/wishlist/src/hooks/useRedirectToLoginPage.ts`, `packages/wishlist/src/services/`
- `packages/wishlist/src/components/RemoteWishlistModule/WishlistModule.tsx`, `packages/wishlist/src/components/RemoteWishlistModule/hooks/useRemoteWishlistModule.ts`
- `packages/wishlist/package.json`
