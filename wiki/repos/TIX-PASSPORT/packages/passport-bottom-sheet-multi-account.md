---
title: Bottom Sheet Multi Account
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-bottom-sheet-multi-account"
umbrella: true
sources:
  - packages/bottom-sheet-multi-account/src
  - packages/bottom-sheet-multi-account/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Bottom Sheet Multi Account
> Login-nudge bottom sheet that fetches and lists blibli tiket member benefits, with "Log in now" and "Continue as guest" CTAs.

## What it does
When `isOpen` becomes true, it calls `GET /tix-member-core/v3/multi-account/benefit` and fires an impression event. It then renders a [[passport-bottom-sheet]] with the API's title, a benefit list (icon and description) and button labels, all from the response. "Log in" navigates to `/login?ref=<referenceUrl>&selector=1&isfrom=<partnerType>`, with forward params added. "Continue as guest" calls `onContinueGuest`. On API error it shows a generic [[passport-error-view]] with retry. Despite the name, it doesn't switch accounts.

## Public API
`BottomSheetMultiAccount` (memoized).
| Prop | Notes |
|---|---|
| `isOpen`, `onClose` | controlled |
| `referenceUrl` | becomes the `ref` query on the login URL |
| `verticalType`, `partnerType` | lower-cased into GTM `eventValue`. `partnerType` is also the `isfrom` param |
| `onContinueGuest` | called after `onClose` |

## Usage
```tsx
<BottomSheetMultiAccount
  isOpen={open} onClose={() => setOpen(false)}
  referenceUrl={location.href} verticalType="FLIGHT" partnerType="BLIBLI"
  onContinueGuest={proceedAsGuest}
/>
```

## Data & tracking
- Fetch: `usePassport().customFetch` when provided (relative URL). Otherwise `fetch` against `/ms-gateway/tix-member-core/...`. Headers are `deviceId` (from the `device_id` cookie), `platform: MOBILE`, `X-Channel-Id: MOBILE`, `X-Request-Id: uuid`, with `credentials: include`. See [[passport-custom-fetch]].
- GTM: `screenName: loginNudge`, `eventCategory: loginRegistration`, `eventDescription: loginNudge`. Labels are `closeLogin`, `continueLogin` and `declineLogin`, plus an impression. Events are pushed to `window.dataLayer` directly.

## Depends on
[[passport-bottom-sheet]], [[passport-button]], [[passport-error-view]], [[passport-typography]], [[passport-utils]] (`usePassport`, `useForwardParams`), `uuid`.

## Used by
- No direct imports in other repos. It's available through the umbrella `@tiket/passport`.
- Internal: none.

## Gotchas
- The sheet isn't rendered at all until the first fetch resolves (`!isLoading && data`, or `isError`), so there's a delay after `isOpen` turns true.
- Benefits text and button labels come only from the API. `src/mocks/` holds EN and ID samples used only for stories.
- Benefit images fall back to a hardcoded 1:1 placeholder on error.

## Sources
- `packages/bottom-sheet-multi-account/src/components/Layout/index.tsx`, `trackers.ts`
- `packages/bottom-sheet-multi-account/src/hooks/useGetMultiAccountBenefit.ts`, `src/services/get-multi-account-benefit.ts`, `src/utils/common.ts`, `src/types/*`
- `packages/bottom-sheet-multi-account/package.json`
