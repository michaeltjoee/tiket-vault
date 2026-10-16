---
title: Shared components (components/)
repo: TIX-NEXT-PAYMENT-FE
kind: feature
sources:
  - components
verified_at: 9e92b20bb
updated: 2026-10-16
status: current
tags: [repo/payment-fe, kind/feature]
---

# Shared components (components/)
> The 59 top-level folders in `components/`: mostly the original Pages Router payment UI, shared with the newer `app/` features.

## What it does
`components/` holds UI for every route. Most of it was built for the Pages Router landing, confirm and complete pages (`pages/payment/`) and for saved methods (`pages/smart_pay/`). The App Router features ([[payment-fe-payment-link]], [[payment-fe-downpay]], `app/payment/` modules of [[payment-fe-payment]]) reuse parts of it. Layout follows `docs/CODING_CONVENTION.md` where it has been refactored: presentational `X.tsx`, `X.container.tsx`, `useXLogic` and `useXData` hooks.

Consumer codes in the tables below come from `git grep` of `@/components/<Name>` across `app/` and `pages/` (specs excluded):
**LAND** `pages/payment/index.page.tsx` · **CC** `pages/payment/[type]/{confirm,complete,callback}` · **PAY** `app/payment/*` · **DP** `app/downpay`, `app/contexts` · **PL** `app/payment-link`, `app/l` · **SP** `pages/smart_pay` · **root** `pages/_app`, `app/layout`. "via X" means the folder is only imported by another component.

## Layout, chrome and infrastructure
| Folder | Purpose | Used by | Notable deps |
|---|---|---|---|
| `PaymentsLayout` | Page shell for Pages Router payment pages (header, error, back confirmation) | LAND, CC | |
| `Header` | Payment page header (title, back) | LAND, CC | [[passport-icons]] |
| `Stepper` | Checkout progress stepper | LAND, CC | [[passport-icons]] |
| `PaymentSteps` | Single and grouped "how to pay" step lists | CC, PL | [[passport-icons]] |
| `Countdown` | Payment-expiry countdown; triggers the expired state | LAND, CC, PL | |
| `LoadingSkeleton` | Landing, order summary and price detail skeletons | LAND, PL | |
| `BackButtonInterceptor` | Dialog shown on browser back during confirm | CC | |
| `BackConfirmation` | Leave-page confirmation | via PaymentsLayout, PaymentStatus | |
| `TnC` | Terms footer | LAND, SP | |
| `ImportantInfo` | Payment-method message box | LAND | |
| `NotificationBanner` | Inline banner | CC, PL | [[passport-icons]] |
| `Image` | `next/image` wrapper for lightroom assets | LAND, CC, PAY, PL, SP (+15 components) | [[passport-assets]] |
| `Icons` | Local icons (`IconDownPayWallet`, `RoundedIconContainer`…) | DP, PAY | [[passport-icons]] |
| `Error`, `Restructure/Error` | Full-page error states (`errorGtmUtils` for tracking) | via PaymentsLayout; LAND, CC | [[passport-assets]] |
| `ErrorBoundary` | React error boundary | via `providers/AppProvider` | |
| `GTMHandler` | Fires page-level GTM events | LAND, CC | |
| `AnalyticsProvider` | `router.beforePopState` analytics hook | only `vitest.setup.tsx` | |
| `MSWInit` | Starts the MSW browser worker when `NEXT_PUBLIC_API_MOCKING=enabled` | root, PAY | |
| `providers` | `AppProvider` (Pages Router root), `PaymentPageProvider` (payment contexts stack), `NudgeProvider`, `HashStackProvider` | root, LAND, CC, SP | [[react-common-remote]], [[passport-utils]] |

## Payment-method selection
| Folder | Purpose | Used by | Notable deps |
|---|---|---|---|
| `Groups` | Payment group list and sheets (VA, e-wallet, cards…), promoted groups | LAND, PAY | [[passport-phone-verification]], [[passport-assets]], [[passport-icons]], [[passport-utils]] |
| `PaymentMethod` | Landing method section: recommended + selected + saved cards | LAND | [[react-common-storage]] |
| `Recommended`, `SelectedPayment` | Recommended list and current selection, rendered as `PaymentTile`s | via PaymentMethod | |
| `PaymentTile` | One payment option tile (installment, card form, co-brand banner) | via Recommended, SelectedPayment | [[passport-icons]] |
| `PaymentTileLoader` | Tile skeleton | via PaymentTile | |
| `CommonItemTileContent` | Shared tile body, saved-card name and type tag | SP; via PaymentTile, SavedCards | |
| `SavedCards` | Saved card list | via PaymentMethod | [[passport-icons]] |
| `LoginBox` | Login nudge (`isHideLoginNudge`) | LAND | |
| `TiketPointLabel` | Points earned label | LAND, CC | |
| `Infinity/PopupAppliedPromoError` | Popup when an applied promo becomes invalid | LAND | |
| `NotEligible` | "Can't combine" dialog (points / discount / BliPay with promo) | PAY | [[passport-assets]] |

## Cards and installments
| Folder | Purpose | Used by | Notable deps |
|---|---|---|---|
| `CardComponent` | Credit-card form v1 (number, expiry, CVV, BIN check) | PAY, PL, SP (+8 components) | [[passport-assets]], [[passport-icons]], [[passport-utils]] |
| `CardComponentV2` | Card form v2 with installment (`CardInstallmentV2`) and form-validation context; DownPay-aware | via PaymentTile | [[react-common-utilities]] |
| `Installment` | Card and pay-later installment options and bottom sheet; DownPay-aware | DP; via PaymentTile | [[passport-icons]] |
| `CoBrandingCardBanner`, `CoBrandingNote`, `CoBrandingNotif` | Co-brand card promos and extra-points notes (feature-flagged, own mutation) | via CardComponent, PaymentTile | [[react-common-utilities]] |
| `OneKlik` | BCA OneKlik flow | via Groups, SubmitPayment | [[passport-icons]] |

## E-wallets, linkage and OTP
| Folder | Purpose | Used by | Notable deps |
|---|---|---|---|
| `Ovo` | OVO add-account UI | via OneKlik | |
| `BlipayFrame` | BliPay iframe with origin-checked redirect | via SubmitPayment | [[passport-icons]] |
| `OTP` | OTP form and error popup (member OTP) | SP; via SubmitPayment | |

## Order and price
| Folder | Purpose | Used by | Notable deps |
|---|---|---|---|
| `OrderSummary` | Per-vertical order summary (Flight, FlightAddOn, Hotel, TrainV4, Bus, Ferry, CarV4, AirportTransferV4, TTD, StandaloneInsurance, MultiOrderDetail…); 131 files. See `docs/order-detail-flow.md` | LAND, CC, PL | [[passport-info-banner]], [[passport-assets]], [[passport-icons]], [[passport-utils]] |
| `ProgressStepperVertical` | Vertical stepper | via OrderSummary (AirportTransferV4) | |
| `PriceSummary` | Sticky price summary and price-details fetch | LAND, CC | [[react-common-utilities]] |
| `PriceDetailV4` | Price breakdown incl. `DownPayDetails` and `FlexiblePaymentSection` | DP, PL; via PriceSummary, Installment | [[react-common-utilities]] |
| `CollapsibleCard` | Collapsible card | DP | [[passport-icons]] |

## Submit and post-submit
| Folder | Purpose | Used by | Notable deps |
|---|---|---|---|
| `SubmitPayment` | Pay button and submit orchestration (redirects, 3DS, BliPay, OTP, OneKlik, DownPay flags, myBCA auto-redirect: `docs/mybca-auto-redirect-flow.md`) | DP, LAND, PAY | [[react-common-analytic]], [[react-common-queue]], [[react-common-utilities]], [[passport-assets]] |
| `CorporateErrorDialog` | Corporate billing errors | via SubmitPayment | [[passport-utils]] |
| `FormRedirect` | Auto-submitting POST form to a provider `redirect_url` | CC | |
| `PaymentConfirm` | Confirm-page pieces (AccountInfo loader) | CC | |
| `BCAVirtualAccount` | BCA VA display | CC | [[passport-icons]] |
| `PaymentStatus` | `PaymentProcessingPage` (processing state) | CC | [[passport-assets]], [[passport-icons]] |

## Overlays
| Folder | Purpose | Used by |
|---|---|---|
| `BottomSheetOrModal` | Bottom sheet on mobile, modal on desktop | PL, SP; via Groups, OrderSummary |
| `BottomSheetModal` | Bottom-sheet modal | PL |

## Unused on main
No importer outside its own folder and specs: `CountryField`, `DataProtection`, `Dialog` (`NextAvailablePromoDialog`), `Timer`. `AnalyticsProvider` is only referenced by `vitest.setup.tsx`.

## Tracking
Several components push GTM directly via `lib/hooks/useGTM` (e.g. `Ovo/AddAccount` uses `pushGTMClick`; `Error/errorGtmUtils.tsx`). `SubmitPayment` waits on the [[react-common-analytic]] queue (`waitFor(QUEUE_KEY_REACT_COMMON_ANALYTIC)` from [[react-common-queue]]) before navigating, so analytics flush first.

## Tests
154 Vitest specs under `components/`. Tests run against the local mock `__mocks__/@tiket/passport.tsx`, not the real [[passport-passport|passport]] (see [[payment-fe-workflows]]).

## Gotchas
- `docs/CODING_CONVENTION.md` describes the container/logic/data split, but older folders (`OrderSummary`, `Groups`, `CardComponent`) still use `index.tsx` monoliths.
- There are two card forms (`CardComponent`, `CardComponentV2`). V2 is reached only through `PaymentTile`, while payment-link and smart_pay use v1.
- Shared components read Pages Router contexts (`useLandingContext`, `usePaymentContext`). When you reuse one in the App Router, check that the provider is mounted: `AppRouterProvider` only supplies Global, WindowSize and Forter.

## Sources
- `components/*` (folder listing and imports on `origin/main`)
- `vitest.setup.tsx`, `vitest.config.mts`
- `docs/CODING_CONVENTION.md`, `docs/order-detail-flow.md`, `docs/mybca-auto-redirect-flow.md`
