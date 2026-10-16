---
title: Insurance popup (webview)
repo: TIX-FINTECH-NEXT-FE
kind: feature
sources:
  - pages/insurance-popup
  - projects/insurance/popup
  - projects/insurance/shared/lib/services/insurance-popup.ts
  - projects/insurance/shared/lib/configs/url.ts
  - lib/jsi/index.ts
verified_at: 5833b842
updated: 2026-10-16
status: current
tags: [repo/fintech-fe, kind/feature]
---

# Insurance popup (webview)
> Pages Router page `/insurance-popup/[uniqueSignature]` that the mobile apps open in a webview to show an insurance upsell popup during booking, then hand the user's choice back to the app via a redirect URL.

## What it does
Fetches the popup content for a signed `uniqueSignature`, renders it with `InsurancePopUp` from [[passport-insurance-pop-up]] in `viewMode="webview"`, and on a button press redirects to the target URL with the result in query params:
- Primary (buy): `?isInsuranceCallback=true&insuranceData=<JSON>`; for `vertical === 'flight'` the JSON is a list of `{ code, fare, insuranceName }` built by `libs/utils.ts#getParamsInsuranceData` (other verticals send `[]`).
- Secondary (decline): `?isInsuranceCallback=true`.
- Close: `backOrClose()` from `@/lib/jsi` (native bridge back/close).

The redirect target is `insuranceData.redirectionTarget` from the API (used by the newer client webview, "CW") or, if absent, the popup's own URL `/{BASE_POPUP_URL}/{uniqueSignature}` (legacy webview, "LW", where the app intercepts the URL).

## Routes & entry points
- `pages/insurance-popup/[uniqueSignature].page.tsx` re-exports `default` and `getServerSideProps` from `@insurance/popup` (`projects/insurance/popup/index.tsx`).
- `getServerSideProps` only returns `middlewareData` and `vertical: 'insurance'`; all data is fetched client-side.
- Base path configurable with `NEXT_PUBLIC_INSURANCE_POPUP_BASE_PATH` (default `insurance-popup`, `shared/lib/configs/url.ts`).

## Data & services
- `getInsurancePopUp(uniqueSignature)` → `POST /tix-insurance-core/products/popup/display/{uniqueSignature}` (`shared/lib/services/insurance-popup.ts`), with `shouldRemoveApiResponseFromLogs` and `shouldRemoveApiRequestBodyFromLogs` so popup payloads (sensitive, large) stay out of logs.
- React Query key `['insurancePopUp', uniqueSignature]`, `gcTime: 0`; uses the first element of `data`.
- `hooks/useInsurancePopUp.ts` holds all logic; types in `index.types.ts` and `shared/lib/types/popup`.

## Key components
`components/Loader` (`Loader` while fetching, `LoaderWithIndicator` after a button press), passport `InsurancePopUp`. Content variants (delay, baggage, full refund, flight disruption…) are templates inside the passport package, so new popup designs usually ship as a passport bump (e.g. PR #422 "fix insurance popup opt-out flow via passport package update").

## Tracking
No GTM calls in this repo; tracking (Amplitude) happens inside the passport component, which is why both button handlers wait 2 s (`setTimeout(..., 2000)`) before `assignUrl`, to let the event send.

## Tests
`projects/insurance/popup/__tests__/index.spec.tsx`, `hooks/__tests__`, `libs/utils.spec.ts`, plus `pages/insurance-popup/__tests__`.

## Gotchas
- If the API code is not `200` and `isInsuranceCallback` is absent, the page immediately redirects to the target with `isInsuranceCallback=true`, so the app treats it as "no insurance" instead of showing an empty popup. The flag also prevents a redirect loop. (Insurance-core returns numeric `code: 200` here, unlike the usual `'SUCCESS'`.)
- `redirectionTarget` from the query string is `decodeURIComponent`-ed because apps may send it encoded.
- `getInsuranceDataFlight` mutates the API product objects (deletes `id`/`price`) for forward compatibility, and maps old `{id, price}` shapes to `{code, fare}` for backward compatibility.

## Sources
- `pages/insurance-popup/[uniqueSignature].page.tsx`
- `projects/insurance/popup/index.tsx`, `projects/insurance/popup/hooks/useInsurancePopUp.ts`, `projects/insurance/popup/libs/utils.ts`
- `projects/insurance/shared/lib/services/insurance-popup.ts`, `projects/insurance/shared/lib/configs/url.ts`, `lib/jsi/index.ts`
- TIX-PASSPORT `packages/insurance-pop-up/src/InsurancePopUp.tsx` (viewMode docs)
