---
title: Corporate Interim Module
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-corporate-interim-module"
sources:
  - packages/corporate-interim-module/src
  - packages/corporate-interim-module/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Corporate Interim Module
> tiket Corporate "interim" step between product selection and checkout. Corporate users pick a travel plan and fill notes, cost centers and custom fields, including file uploads, before the booking proceeds.

## What it does
On mount it fetches interim details for the given product and booking criteria (`POST /tix-corporate/interim/details`, plus `GET …/details/content`). It renders a mobile or desktop form: travel-plan selection with search, notes, cost center, and custom fields (dropdown, multi-dropdown, text, file upload through `/tix-corporate/uploader/upload`). Submitting posts `/tix-corporate/interim/transactions` and calls `onSuccess(resp)`. It handles business errors with dialogs: travel plan required, travel plan not available (BE-driven `modalConfig`), general error, and a full [[passport-error-view]] on 500. Travel-agent (TA) accounts never get the "travel plan required" rule. The `VirtualInterlining` component covers multi-carrier flights.

## Public API
| Export | Notes |
|---|---|
| `CorporateInterimModule` | main component |
| `CorporateInterimModuleProps` | discriminated on `productType`: `hotel`, `car`, `flight`, `train`, `whoosh`, `airport_transfer`, `bus`, each with a typed `payload` (`HotelBookingCriteria`…) |
| `CorporateLoggingProvider` + `CorporateLoggingHandlers` (`logRequest`, `logResponse`), `CorporateLoggingOperation` | opt-in request/response logging per endpoint |
| types from `types/corporate-interim` and `types/api-response` | `TravelPlan`, `BookingCriteria`, `CallBackResponseData`, `InterimDetailsResponse`… |

Common props: `clientSideServiceEndpoint`, `isMobile`, `enforcedLocale`, `onSuccess`, `onError`, `onClickBack`, `onCallBackRequestForLog`, `onCallBackResponseForLog`, `useMockData`.

## Usage
```tsx
<CorporateInterimModule
  productType="hotel"
  payload={{ cartId, publicId, startDate, endDate, … }}
  clientSideServiceEndpoint={process.env.NEXT_PUBLIC_CLIENT_SIDE_SERVICE_ENDPOINT}
  isMobile={isMobile}
  onSuccess={(resp) => router.push(resp.redirectUrl)}
  onClickBack={() => router.back()}
/>
```

## Data & services
`usePassport().customFetch` is used when provided, with relative URLs. Otherwise it uses `fetch` against `${clientSideServiceEndpoint}/ms-gateway/tix-corporate/...` ([[passport-custom-fetch]]). Headers come from `getCommonHeaders` in **`@tiket/react-common-utilities`**, which is a runtime dependency on TIX-REACT-COMMON ([[react-common-utilities]]).

## Depends on
About 20 Passport packages: [[passport-card]], [[passport-container]], [[passport-bottom-sheet]], [[passport-button]], [[passport-dropdown]], [[passport-error-view]], [[passport-dialog]], [[passport-modal]], [[passport-form]], [[passport-file-upload]], [[passport-check]], [[passport-radio]], [[passport-search-box]], [[passport-info-banner]], [[passport-notification-banner]], [[passport-label]], [[passport-content-loader]], [[passport-loading-indicator]], [[passport-icons]], [[passport-typography]], [[passport-utils]].

## Used by
- TIX-REACT-REMOTE `src/components/corporate-interim-module/index.tsx`. It wraps the module in `PassportWrapper` and exposes it as a federated remote ([[react-remote-corporate-interim-module]]), pinned `12.4.2`.
- Internal: none.

## Gotchas
- The 2026-10-14 revert `869aae151a` (#3621) removed CRP-6951 (travel-plan selection improvements) and CRP-7228 (flight multi-city criteria) from this package. Those features aren't on `main`.
- Locale: `enforcedLocale` overrides the Passport locale. The type comment says it's meant to be removed eventually.
- Not in the umbrella `@tiket/passport`.

## Sources
- `packages/corporate-interim-module/src/CorporateInterimModule.tsx`, `src/types/corporate-interim.ts`, `src/corporate-logging.tsx`, `src/services/*.ts`, `src/utils/common.ts`
- `packages/corporate-interim-module/package.json`
- `git show 869aae151a` (revert commit)
- TIX-REACT-REMOTE `src/components/corporate-interim-module/index.tsx` (281778b)
