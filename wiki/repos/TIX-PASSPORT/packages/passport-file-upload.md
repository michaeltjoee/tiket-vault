---
title: File Upload
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-file-upload"
umbrella: true
sources:
  - packages/file-upload/src
  - packages/file-upload/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# File Upload
> Multi-file uploader (browse or drag-and-drop, file list with retry, remove and download) and a single-file form field with a progress bar. Uploading is delegated to your `uploadFn`.

## What it does
- **`FileUpload` + `useFileUpload`**: the hook owns `files: FileInfo[]`. The component validates the count (`maxCount`, default 5) and size (`maxSizeInMB`, default 3), calls `uploadFn(file)` for each new file, and marks each entry in-progress, done (`url`) or `error`. The list supports retry, delete (`deleteFn`) and download (`downloadFn`, or an object-URL fallback). File names are middle-truncated, macOS style. Pre-filled entries that have only a `url` are fetched back into a `File` (through `customFetch` when present) so they can be downloaded.
- **`SingleFileUpload` + `useSingleFileUpload`**: a form-field look built on [[passport-form]] `InputWrapper`, with a [[passport-progress-bar]] and cancel. You call `onUploadFile(file)` and drive `progress` with `setProgress`. `initialData` holding a `url` is fetched into a `File` once.

## Public API
| Export | Notes |
|---|---|
| `FileUpload` | `files`, `setFiles` (from the hook), `uploadFn: (file) => Promise<{ url, file } \| null>`, `extensions` (e.g. `'.jpg, .png'`), `maxSizeInMB`, `maxCount`, `title`, `subtext`, `browseBtnLabel`, `errorText`, `isMobile`, `deleteFn`, `downloadFn`, `onFileUploadSuccess`, `onFileUploadError`, `displayedFileNameLength`, `inputProps`, `truncatedMaxLines` |
| `useFileUpload(initialFiles?)` | `{ files, setFiles, deleteFile }` |
| `SingleFileUpload` | `file`, `setFile`, `progress`, `onUploadFile`, `onCancelUpload`, `label`, `helperText`, `errorText`, `extensions`, `disabled`, `rightSlot`, `inputProps` |
| `useSingleFileUpload({ initialData })` | `{ file, setFile, removeFile, progress, setProgress }` |
| `libs` helpers | `handleFiles`, `uploadFile`, `fetchFile`, `urlToFile`, `getFileSizeWithUnit`, `truncateTextInTheMiddle`, `Errors`, message getters |
| types | `FileInfo`, `SingleFileInfo`, `FileUploaderProps`, `FileListItemProps`, `UploaderFunction`, `UploaderReturnType`, `SingleFileUploadProps` |

## Usage
```tsx
const { files, setFiles, deleteFile } = useFileUpload();
<FileUpload files={files} setFiles={setFiles} extensions=".pdf, .jpg, .png" maxSizeInMB={5}
  uploadFn={async (file) => ({ url: (await api.upload(file)).url, file })} deleteFn={deleteFile} />
```

## Depends on
[[passport-button]], [[passport-form]], [[passport-progress-bar]], [[passport-icons]], [[passport-typography]], [[passport-utils]] (`customFetch`, `locale`), `uuid`. `firebase` is a devDep used only in stories, as an example uploader.

## Used by
- Through the umbrella `@tiket/passport`: TIX-FINTECH-NEXT-FE `projects/insurance/claim-center/claim-form/components/Form/FileUploadInput/FileUploadInput.tsx` (`FileUpload`, `useFileUpload`). `claim-detail/.../ClaimDocuments.tsx` and `claim-form/pages/FormSummary.tsx` use `useFileUpload` too.
- Internal: [[passport-corporate-interim-module]] (custom-field uploads).

## Gotchas
- The list status labels "Loading..." and "Uploading..." are hard-coded English. Error messages are localized.
- Pre-uploaded URLs are downloaded in the browser to rebuild `File` objects, which needs CORS on the storage host. Use `downloadFn` to avoid it.

## Sources
- `packages/file-upload/src/FileUpload.tsx`, `src/FileListItem.tsx`, `src/components/SingleFileUpload/SingleFileUpload.tsx`, `src/libs/useFileUpload.ts`, `src/libs/useSingleFileUpload.ts`, `src/types.ts`
- `packages/file-upload/package.json`
