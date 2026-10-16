---
title: react-common-navigator-permission
repo: TIX-REACT-COMMON
kind: package
npm: "@tiket/react-common-navigator-permission"
sources:
  - packages/react-common-navigator-permission/src
  - packages/react-common-navigator-permission/package.json
  - packages/react-common-navigator-permission/README.md
verified_at: 14597c4e
updated: 2026-10-16
status: current
tags: [repo/react-common, kind/package]
---

# react-common-navigator-permission
> One API for device features (contacts, share, calendar, location, maps) that uses browser `navigator` APIs on mweb/dweb and Cross App Routing (C.A.R) or JSI inside the tiket app webview.

## What it does
Each feature checks for a webview (`device_type` cookie is `android`/`ios`). In a webview it uses C.A.R: it redirects to a generated "car request" URL that the app intercepts. The app runs the native flow, appends the result as a query param to the original URL, and calls `window.handleResponse`, which resolves the promise. Field names in the request are generic names, mapped per platform by the GTM tag "Cross App Routing Properties Map". Outside a webview it uses the Contact Picker API, `navigator.share`, a Google Calendar deeplink, `navigator.geolocation` or a Google Maps URL. See [[cross-app-routing]] and [[webview-jsi-bridge]].

## Public API
| Export | Webview path | Browser path |
|---|---|---|
| `ContactPicker.get(fields)` | C.A.R `CONTACT_PICKER` | Contact Picker API |
| `ShareDownloadableFiles(files)` | Android: JSI `handleActionSendContent` | `navigator.share` with fetched files |
| `shareFilesWithContent({ files, mimeType, message })` | Android: JSI with content | `navigator.share` |
| `addToCalendar(eventProps)` | C.A.R `ADD_TO_CALENDAR` | Google Calendar deeplink |
| `getCurrentLocation(options?)` | n/a | `navigator.geolocation.getCurrentPosition` |
| `useGetCurrentLocation()` | iOS: JSI `getLocation` (falls back to browser on code `-603`) | geolocation |
| `openMaps({ latitude, longitude, ... })` | C.A.R `OPEN_MAPS`, fire-and-forget | `window.open` Google Maps search |

Errors are thrown or rejected as `standardErrorResponse.*` objects (`internal_error`, `cannot_resolve`…), not `Error`s.

## Usage
```ts
// TIX-FINTECH-NEXT-FE app/gift-card/checkout/components/SenderDynamicForm/SenderDynamicForm.tsx
import { ContactPicker } from '@tiket/react-common-navigator-permission';
const maybeContact = await ContactPicker.get(['phoneNumbers']);

// TIX-PASSPORT packages/manage-order/src/hooks/useActionButton.ts
addToCalendar({
  title: calendarTitle ?? '',
  startTime: getDateInMilliseconds(time?.start ?? ''),
  endTime: getDateInMilliseconds(time?.end ?? ''),
  /* ... */
});
```

## Depends on
- [[react-common-jsi]] (`useGetLocation`, `handleActionSendContent`), [[react-common-fetch-client]] (downloads files to share). Both are **bundled** into `dist` (esbuild, only react external).
- `uuid`; peer React 19

## Used by
- TIX-PASSPORT: [[passport-manage-order]] (`addToCalendar`).
- TIX-FINTECH-NEXT-FE: gift-card `ShareLink` (`shareFilesWithContent`), `SenderDynamicForm` / `RecipientDynamicForm` (`ContactPicker`). See [[fintech-fe-gift-card]].

## Gotchas
- C.A.R **navigates the webview away** and back. Component state that isn't persisted may be lost, and the promise resolves only through `window.handleResponse` called by the app. `CARWebview` temporarily replaces any existing `window.handleResponse` (defined by other services) and restores it after the response.
- iOS webview share goes through `navigator.share`, not JSI. Only Android uses JSI.
- Shared files are downloaded with `fetchClient(url)`, so the URLs must be reachable from the browser (CORS) and follow fetch-client's URL rules (relative paths go through `ms-gateway`).
- `getCurrentLocation` throws synchronously when `geolocation` is missing, but otherwise returns a promise. Wrap calls in both try/catch and `.catch`.
- All functions return `undefined` on the server.

## Sources
- packages/react-common-navigator-permission/src/{index,helper,constant}.ts
- packages/react-common-navigator-permission/src/{contact-picker,share,add-to-calendar,location,open-maps,car-webview}/*
- packages/react-common-navigator-permission/README.md, package.json, build.js
