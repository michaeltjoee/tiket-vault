---
title: Image Upload
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-image-upload"
umbrella: true
sources:
  - packages/image-upload/src
  - packages/image-upload/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Image Upload
> A horizontal row of image slots. It validates the files a user picks and uploads each one, in one or more resized variants, to the tiket image service.

Part of [[passport-packages]].

## What it does
`ImageUpload` renders `maxCount` cells (default 5), padding `imageList` with empty cells. Picking files (`.jpeg/.jpg/.png`, multiple by default) fills the empty cells in order. If one file is picked while a cell is focused, it replaces that cell. Each file is read as base64 and checked against `inputSettings` (size, min/max dimension). Each output variant is then POSTed to the image API as JSON. When every variant succeeds, each variant URL is stored on the image object under the variant's name (e.g. `data.thumbnail`, `data.large`). A batch counter (`uploaded/failed/total/remaining`) drives `onProgress` and `onFinish`. Scroll arrows appear when the row overflows.

## Public API
`ImageUpload`, `DEFAULT_INPUT_SETTINGS` (`maxSizeInMB: 3`), `DEFAULT_OUTPUT_SETTINGS` (folder `images`, variants `thumbnail` 64×64 and `large`), `DEFAULT_MAX_IMAGE_SIZE_IN_MB`, and `Errors` (`MAX_DIMENSION_ERROR`, `MIN_DIMENSION_ERROR`, `MAX_SIZE_ERROR`, `NETWORK_ERROR`, `FILE_READ_ERROR`). Types: `ImageUploadProps`, `ImageParams`, `InputSettings`, `OutputSettings`, `OutputVariant` (`name`, `width`, `height`, `isThumbnail`, `crop`), `UploadFn`, `UploadResult`, `UploadBatch`, `FileInfo`, `ImageCellProps`.

| Prop | Notes |
|---|---|
| `imageList` | images uploaded earlier (`{ id, thumbnail?, … }`) |
| `maxCount` | number of cells, default 5 |
| `inputSettings`, `outputSettings` | validation rules, and the folder plus variants to produce |
| `apiURL` | default `/ms-gateway/tix-image/images` (or `https://gatotkaca.tiket.com/...` on `local.tiket*` hosts) |
| `uploadFn` | replaces the built-in POST (gets `fileInfo`, `variant`, `folder`, `apiURL`) |
| `onImageUploaded`, `onImageError`, `onImageDeleted`, `onImageClick` | per image |
| `onFileSelectionChange(files, skipped)`, `onProgress(list, batch)`, `onFinish(list, batch)` | per batch |
| `multipleFiles`, `placeholderLabel` | |

## Usage
```tsx
<ImageUpload
  maxCount={3}
  inputSettings={{ maxSizeInMB: 5, minDimension: [300, 300] }}
  outputSettings={{ folder: 'review', variants: [{ name: 'thumbnail', width: 64, height: 64, isThumbnail: true }, { name: 'large' }] }}
  onFinish={(list) => setPhotos(list.filter((i) => i.large))}
/>
```

## Depends on
[[passport-button]], [[passport-icons]], [[passport-loading-indicator]], [[passport-typography]], [[passport-utils]] (`usePassport().customFetch`); `js-cookie`, `uuid`. The backend is the [[tix-image-service]] (`TIX-IMAGES-BE`, which also defines the `crop` modes).

## Used by
- No direct importers in the other repos. Internally only the umbrella `@tiket/passport` re-exports it.

## Gotchas
- A variant without `width`/`height` is uploaded at full HD: 1920×1080 for landscape, 1080×1920 for portrait. `crop` defaults to `limit`.
- Auth header: the `accessToken` cookie is sent when present (needed in webviews). Otherwise it sends `X-Cookie-Session-V2: true`. It uses `customFetch` from the Passport context when one is provided.
- The `thumbnail` key decides whether a cell counts as filled. Mark another variant with `isThumbnail` if you rename it.
- `useImageAPI` is a default export, so `export *` doesn't re-export it. Only `Errors` comes out of that module.
- If any variant upload fails, the whole image is marked as an error. Variants that already succeeded aren't kept.

## Sources
- `packages/image-upload/src/ImageUpload.tsx`, `packages/image-upload/src/types.ts`
- `packages/image-upload/src/lib/useImageAPI.ts`, `packages/image-upload/src/lib/utils.ts`
- `packages/image-upload/package.json`
