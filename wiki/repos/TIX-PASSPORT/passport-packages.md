---
title: TIX-PASSPORT package catalog
repo: TIX-PASSPORT
kind: overview
sources:
  - packages
  - packages/passport/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/overview]
---

# TIX-PASSPORT package catalog

> All 130 workspace packages on `origin/main`. Every one is versioned in lockstep (12.8.1 at `verified_at`, see [[changesets-fixed-versioning]]).

**U** marks packages re-exported by the umbrella [[passport-umbrella|@tiket/passport]]. Apps can import those as `import { X } from '@tiket/passport'` and their types from `@tiket/passport/types/<pkg>`. Packages without **U** must be installed and imported directly.

| Page | npm | U | Purpose |
|---|---|---|---|
| [[passport-accordion]] | `@tiket/passport-accordion` | U | Accordion / AccordionItem / Button / Panel / Icon compound for expandable sections |
| [[passport-action-banner]] | `@tiket/passport-action-banner` | U | Banner with icon, text and a CTA or slider action |
| [[passport-assets]] | `@tiket/passport-assets` | | Generated registry of cloud image URLs (illustrations, logos) as named string constants |
| [[passport-badge]] | `@tiket/passport-badge` | U | Small count or status badge |
| [[passport-banner-carousel]] | `@tiket/passport-banner-carousel` | | Promo banner carousel with optional chip filters (page-module section) |
| [[passport-banner-grid]] | `@tiket/passport-banner-grid` | | Grid of promo banners with chip filters (page-module section) |
| [[passport-bottom-app-bar]] | `@tiket/passport-bottom-app-bar` | U | Sticky mobile bottom bar (Main and Upper slots) for primary CTAs |
| [[passport-bottom-sheet-multi-account]] | `@tiket/passport-bottom-sheet-multi-account` | U | Bottom sheet for switching between linked tiket accounts |
| [[passport-bottom-sheet]] | `@tiket/passport-bottom-sheet` | U | Mobile bottom sheet primitive (focus-trapped, scroll-locked) |
| [[passport-bottom-tab-navigation]] | `@tiket/passport-bottom-tab-navigation` | U | Mobile bottom tab bar (Home, My Orders, Account…) |
| [[passport-breadcrumb]] | `@tiket/passport-breadcrumb` | U | Breadcrumb trail |
| [[passport-bubble-chat]] | `@tiket/passport-bubble-chat` | | Chat message bubble |
| [[passport-button-slider]] | `@tiket/passport-button-slider` | U | Horizontally scrollable row of buttons with arrow navigation |
| [[passport-button]] | `@tiket/passport-button` | U | Button primitive (variants, sizes, loading, icon slots, ripple) |
| [[passport-calendar]] | `@tiket/passport-calendar` | U | Date / date-range calendar with holidays and price labels, desktop and mobile |
| [[passport-card-compound]] | `@tiket/passport-card-compound` | U | Card variant with ribbon and compound slots |
| [[passport-card]] | `@tiket/passport-card` | U | Card / CardHeader / CardBody / CardFooter / CardWithNudge |
| [[passport-chat-box]] | `@tiket/passport-chat-box` | | Chat input box |
| [[passport-check]] | `@tiket/passport-check` | U | Checkbox |
| [[passport-chips-carousel]] | `@tiket/passport-chips-carousel` | U | Horizontally scrolling chip list |
| [[passport-chips]] | `@tiket/passport-chips` | U | Chip / filter chip |
| [[passport-coachmark]] | `@tiket/passport-coachmark` | U | Onboarding coachmark tooltip anchored to an element |
| [[passport-collapse]] | `@tiket/passport-collapse` | U | Animated height collapse |
| [[passport-container]] | `@tiket/passport-container` | U | Responsive max-width page container |
| [[passport-content-loader]] | `@tiket/passport-content-loader` | U | Skeleton shimmer placeholders |
| [[passport-corporate-interim-module]] | `@tiket/passport-corporate-interim-module` | | tiket Corporate interim page (travel plan and booking criteria before search) |
| [[passport-countdown]] | `@tiket/passport-countdown` | U | Countdown timer display and hook |
| [[passport-country-and-currency-modal]] | `@tiket/passport-country-and-currency-modal` | U | Country/language and currency picker modal (header setting) |
| [[passport-country-list-selection]] | `@tiket/passport-country-list-selection` | U | Searchable country list (phone code / nationality picker) |
| [[passport-currency-bottom-sheet]] | `@tiket/passport-currency-bottom-sheet` | U | Currency picker bottom sheet that fetches the currency list |
| [[passport-dashboard]] | `@tiket/passport-dashboard` | | Dashboard layout components (B2B / reseller) |
| [[passport-date-utils]] | `@tiket/passport-date-utils` | | Date helpers shared by calendar and picker |
| [[passport-design-tokens]] | `@tiket/passport-design-tokens` | U | SCSS/CSS design tokens, base styles, font loader |
| [[passport-dialog]] | `@tiket/passport-dialog` | U | Centered dialog with title, body and action buttons |
| [[passport-divider]] | `@tiket/passport-divider` | U | Horizontal/vertical divider |
| [[passport-download-app-banner]] | `@tiket/passport-download-app-banner` | | "Download the tiket app" banner |
| [[passport-dropdown]] | `@tiket/passport-dropdown` | U | BaseDropdown, DropdownFormDisplay, useDropdown |
| [[passport-error-view]] | `@tiket/passport-error-view` | U | Full-section error state with illustration and retry |
| [[passport-extended-tabs]] | `@tiket/passport-extended-tabs` | U | Tabs with extended content (icons, subtitles) |
| [[passport-figure]] | `@tiket/passport-figure` | U | Illustration + title + description block |
| [[passport-file-upload]] | `@tiket/passport-file-upload` | U | FileUpload / SingleFileUpload / useFileUpload |
| [[passport-floating-button]] | `@tiket/passport-floating-button` | U | Floating action button |
| [[passport-focus-trap]] | `@tiket/passport-focus-trap` | | Focus trap wrapper for overlays |
| [[passport-footer]] | `@tiket/passport-footer` | U | Site footer (desktop and mobile) with default link data |
| [[passport-form]] | `@tiket/passport-form` | U | TextInput, TextArea, PhoneNumberInput, InputWrapper and form field primitives |
| [[passport-generic-facilities]] | `@tiket/passport-generic-facilities` | | Facility list / dialog for accommodation-style products |
| [[passport-gift-voucher-claim-widget]] | `@tiket/passport-gift-voucher-claim-widget` | U | Widget for claiming gift vouchers |
| [[passport-gift-voucher]] | `@tiket/passport-gift-voucher` | U | Voucher card UI |
| [[passport-global-popup]] | `@tiket/passport-global-popup` | U | Site-wide campaign popup driven by the popup inventory API |
| [[passport-global-search]] | `@tiket/passport-global-search` | U | Header global search with suggestions and recent searches |
| [[passport-google-one-tap]] | `@tiket/passport-google-one-tap` | | Google One Tap sign-in prompt |
| [[passport-gradient-banner]] | `@tiket/passport-gradient-banner` | U | Gradient promo banner + container |
| [[passport-group-field-v2]] | `@tiket/passport-group-field-v2` | U | Grouped form field, v2 |
| [[passport-group-field]] | `@tiket/passport-group-field` | U | Grouped form field (stacked inputs in one box) |
| [[passport-header]] | `@tiket/passport-header` | U | Site header (desktop, mobile, slim) with login, search, settings |
| [[passport-highlight-discover]] | `@tiket/passport-highlight-discover` | | "Highlight / discover" content section (page-module) |
| [[passport-icons]] | `@tiket/passport-icons` | | Generated SVG icon components (`Icon*`) |
| [[passport-image-preview]] | `@tiket/passport-image-preview` | U | Fullscreen image preview / gallery (ImagePreviewAdaptive) |
| [[passport-image-upload]] | `@tiket/passport-image-upload` | U | Image uploader with preview |
| [[passport-image]] | `@tiket/passport-image` | | Image with lazy loading and fallback |
| [[passport-info-banner]] | `@tiket/passport-info-banner` | U | Inline informational banner |
| [[passport-insurance-pop-up]] | `@tiket/passport-insurance-pop-up` | U | Insurance cross-sell popup in the booking funnel |
| [[passport-insurance]] | `@tiket/passport-insurance` | | Standalone insurance product UI (search/list cards) |
| [[passport-kuber-price-dynamic-banner]] | `@tiket/passport-kuber-price-dynamic-banner` | | Dynamic price banner fed by the Kuber service |
| [[passport-label]] | `@tiket/passport-label` | U | Small coloured label / tag |
| [[passport-language-and-currency-modal]] | `@tiket/passport-language-and-currency-modal` | U | Language and currency selection modal |
| [[passport-list]] | `@tiket/passport-list` | U | List / list item rows |
| [[passport-loading-indicator]] | `@tiket/passport-loading-indicator` | U | Spinner |
| [[passport-loading]] | `@tiket/passport-loading` | U | LoadingWithIllustration full-state loader |
| [[passport-logo]] | `@tiket/passport-logo` | | blibli tiket logo |
| [[passport-manage-order]] | `@tiket/passport-manage-order` | U | Manage-order actions (edit booking, e-ticket language, multi-order) with services and GTM |
| [[passport-mission-landing-page]] | `@tiket/passport-mission-landing-page` | U | Mission/gamification landing page sections |
| [[passport-mission-page-module]] | `@tiket/passport-mission-page-module` | U | Mission webview page module |
| [[passport-modal]] | `@tiket/passport-modal` | U | Desktop modal (plus UnstableBaseModal) |
| [[passport-notification-banner]] | `@tiket/passport-notification-banner` | U | Notification banner (info/warning/error) |
| [[passport-notification-login]] | `@tiket/passport-notification-login` | | Post-login notification dialog/modal driven by a cookie |
| [[passport-otp-form]] | `@tiket/passport-otp-form` | U | OTP request/verify form |
| [[passport-otp-unm]] | `@tiket/passport-otp-unm` | | OTP flow (UNM) with context provider and customer-care component |
| [[passport-page-control]] | `@tiket/passport-page-control` | U | Carousel page-indicator dots |
| [[passport-page-module-collapse]] | `@tiket/passport-page-module-collapse` | U | Collapsible page-module section |
| [[passport-page-module-shared]] | `@tiket/passport-page-module-shared` | | Shared page-module pieces (carousel, layout, card variants, loyalty badge) |
| [[passport-page-module]] | `@tiket/passport-page-module` | | CMS-driven page module renderer (client and server components, initial data) |
| [[passport-pagination]] | `@tiket/passport-pagination` | U | Pagination control |
| [[passport-umbrella]] | `@tiket/passport` | — | Umbrella package re-exporting most components and types |
| [[passport-phone-verification]] | `@tiket/passport-phone-verification` | | Phone number verification flow |
| [[passport-picker]] | `@tiket/passport-picker` | U | Date, date-time, time and wheel pickers |
| [[passport-portal]] | `@tiket/passport-portal` | U | React portal helper |
| [[passport-price-history-bar]] | `@tiket/passport-price-history-bar` | | Price history bar chart |
| [[passport-price-module-v2]] | `@tiket/passport-price-module-v2` | U | Price display module, v2 |
| [[passport-price-module]] | `@tiket/passport-price-module` | U | Price display (slash price, final price, label, description) |
| [[passport-price-summary]] | `@tiket/passport-price-summary` | U | Price breakdown summary + cashback banner |
| [[passport-pricing-promo]] | `@tiket/passport-pricing-promo` | U | Promo list and promo API transforms |
| [[passport-product-card]] | `@tiket/passport-product-card` | | Product cards (flight, accommodation, generic, grid) |
| [[passport-progress-bar]] | `@tiket/passport-progress-bar` | U | Linear progress bar |
| [[passport-progress-step]] | `@tiket/passport-progress-step` | U | Horizontal / vertical / dotted step indicators |
| [[passport-progress-stepper]] | `@tiket/passport-progress-stepper` | U | Funnel progress stepper |
| [[passport-promo-carousel]] | `@tiket/passport-promo-carousel` | U | Promo card carousel with layout, loading and context |
| [[passport-promo-code-popup]] | `@tiket/passport-promo-code-popup` | U | Promo code popup |
| [[passport-qr-popup]] | `@tiket/passport-qr-popup` | U | QR app-install popup shared by global-popup and page-module |
| [[passport-quantity-editor]] | `@tiket/passport-quantity-editor` | U | +/- quantity stepper |
| [[passport-radio]] | `@tiket/passport-radio` | U | Radio / RadioGroup |
| [[passport-refund-method]] | `@tiket/passport-refund-method` | | Refund method selection, panel and tracker |
| [[passport-reseller-finance-module]] | `@tiket/passport-reseller-finance-module` | | Reseller finance report table with filters and download |
| [[passport-review-widget]] | `@tiket/passport-review-widget` | U | Product review widget (fetches reviews, login cases) |
| [[passport-ripple-effect]] | `@tiket/passport-ripple-effect` | | Decorative ripple animation |
| [[passport-ripple]] | `@tiket/passport-ripple` | | Click ripple utility/container used by button |
| [[passport-screen-force-update]] | `@tiket/passport-screen-force-update` | U | "Please update the app" blocking screen |
| [[passport-scrollable-content]] | `@tiket/passport-scrollable-content` | U | Scroll container with shadows/arrows |
| [[passport-search-box]] | `@tiket/passport-search-box` | U | Search input |
| [[passport-search-form-display]] | `@tiket/passport-search-form-display` | U | Read-only search-form fields that open pickers |
| [[passport-search-widget-flight]] | `@tiket/passport-search-widget-flight` | U | Flight search widget |
| [[passport-search-widget-ttd]] | `@tiket/passport-search-widget-ttd` | U | Things-to-do search widget + suggestions |
| [[passport-segmented-control]] | `@tiket/passport-segmented-control` | U | Segmented toggle control |
| [[passport-seo]] | `@tiket/passport-seo` | U | SEO blocks (slot, FAQ, card, internal links, content summary) |
| [[passport-sidebar]] | `@tiket/passport-sidebar` | U | Account sidebar menu (tier-aware) |
| [[passport-slider]] | `@tiket/passport-slider` | U | Range slider |
| [[passport-snackbar-multi-account]] | `@tiket/passport-snackbar-multi-account` | U | Snackbar for multi-account switching |
| [[passport-snackbar]] | `@tiket/passport-snackbar` | U | Imperative `snackbar()` API + SnackbarProvider store |
| [[passport-snake-animation]] | `@tiket/passport-snake-animation` | U | Animated gradient "snake" border |
| [[passport-social-share-mobile]] | `@tiket/passport-social-share-mobile` | | Deprecated alias re-exporting SocialShareMobile from social-share |
| [[passport-social-share]] | `@tiket/passport-social-share` | U | Social share (mobile, desktop, adaptive) |
| [[passport-supergraphic]] | `@tiket/passport-supergraphic` | U | Brand supergraphic decoration (client-only, uuid ids) |
| [[passport-tabs]] | `@tiket/passport-tabs` | U | Tabs / TabList / Tab / TabPanels + useTabsScrollSpy |
| [[passport-toggle]] | `@tiket/passport-toggle` | U | Toggle switch |
| [[passport-tooltip]] | `@tiket/passport-tooltip` | U | Tooltip |
| [[passport-top-nav-srp]] | `@tiket/passport-top-nav-srp` | | Search-results-page top navigation bar |
| [[passport-typography]] | `@tiket/passport-typography` | U | `Text` component following DS typography |
| [[passport-utils]] | `@tiket/passport-utils` | U | PassportProvider/usePassport context, forward params, body-scroll-lock, format, debounce |
| [[passport-voucher-card]] | `@tiket/passport-voucher-card` | U | Voucher card |
| [[passport-wishlist]] | `@tiket/passport-wishlist` | U | Wish icon + RemoteWishlistModule |

## Sources
- `packages/*/package.json` (name, description), `packages/*/src/index.ts`
- `packages/passport/package.json` (umbrella dependency list → **U** column)
