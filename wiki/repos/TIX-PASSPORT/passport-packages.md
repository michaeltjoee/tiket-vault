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
| [[passport-accordion]] | `@tiket/passport-accordion` | U | Compound components for expandable sections. Each item owns its own open state. |
| [[passport-action-banner]] | `@tiket/passport-action-banner` | U | Card-style banner with image, title, description and either one or two buttons or a slide-to-confirm slider. |
| [[passport-assets]] | `@tiket/passport-assets` |  | Registry of tiket's cloud-hosted design images as named URL constants, plus Lightroom image-loader helpers. |
| [[passport-badge]] | `@tiket/passport-badge` | U | Notification dot or count pill, either overlaid on a child element or inline. |
| [[passport-banner-carousel]] | `@tiket/passport-banner-carousel` |  | Auto-scrolling promo banner carousel used by page-module. It picks a card size from visible-items count and image ratio. |
| [[passport-banner-grid]] | `@tiket/passport-banner-grid` |  | CSS-grid layout of promo banner cards with separate mobile and desktop rows and columns, used by page-module and global-popup. |
| [[passport-bottom-app-bar]] | `@tiket/passport-bottom-app-bar` | U | Mobile bottom action bar container with an optional upper strip (labels, info) and a main CTA row. |
| [[passport-bottom-sheet]] | `@tiket/passport-bottom-sheet` | U | The mobile overlay primitive: portal-mounted, focus-trapped, scroll-locked, swipe-to-close, with a collapsing sticky header and an optional sticky footer. |
| [[passport-bottom-sheet-multi-account]] | `@tiket/passport-bottom-sheet-multi-account` | U | Login-nudge bottom sheet that fetches and lists blibli tiket member benefits, with "Log in now" and "Continue as guest" CTAs. |
| [[passport-bottom-tab-navigation]] | `@tiket/passport-bottom-tab-navigation` | U | Fixed mobile bottom nav bar (Home, My Orders, Rewards, Account…) rendered from a BE-provided `navigations` array. |
| [[passport-breadcrumb]] | `@tiket/passport-breadcrumb` | U | Horizontally scrollable breadcrumb trail with overflow arrows and a pluggable link renderer, for example for `next/link`. |
| [[passport-bubble-chat]] | `@tiket/passport-bubble-chat` |  | Presentational chat message bubble with left or right alignment and an optional attachment. |
| [[passport-button]] | `@tiket/passport-button` | U | The design-system button, rendered as `<button>` or `<a>`. It has variants, sizes, modes, a loading state, icons and a ripple on mouse-down. |
| [[passport-button-slider]] | `@tiket/passport-button-slider` | U | "Swipe to confirm" control. The user drags a knob to the end of the track to trigger an action, such as claiming a voucher. |
| [[passport-calendar]] | `@tiket/passport-calendar` | U | Single-date and range calendar plus a month picker, with holidays, daily price tiers (cheap/best), sold-out days, and mobile, desktop and responsive renderings. |
| [[passport-card]] | `@tiket/passport-card` | U | Surface container (`Card` + header/body/footer) and `CardWithNudge`, a card with a coloured top or bottom "nudge" strip that can rotate between messages. |
| [[passport-card-compound]] | `@tiket/passport-card-compound` | U | Add-on / upsell selection card, such as an extra flight product or insurance. It has a title, ribbon, benefit list, price and an Add/Cancel button. |
| [[passport-chat-box]] | `@tiket/passport-chat-box` |  | Pill-shaped auto-growing text input with a send/search button, for chat or AI-prompt style entry. |
| [[passport-check]] | `@tiket/passport-check` | U | Checkbox: a native `<input type="checkbox">` inside a `<label>`, with custom tick and indeterminate visuals. |
| [[passport-chips]] | `@tiket/passport-chips` | U | `Chip` button for filters and selections, with active, error, inverted and disabled states, prefix and suffix icons, and a badge slot. Also exports `ChipsIconPulse`. |
| [[passport-chips-carousel]] | `@tiket/passport-chips-carousel` | U | Horizontal scroller for a row of chips, with prev/next arrow buttons that appear only when content overflows. |
| [[passport-coachmark]] | `@tiket/passport-coachmark` | U | Multi-step onboarding tour. It dims the page, spotlights a target element found by CSS selector, and shows a step pane with Skip/Next/Done. |
| [[passport-collapse]] | `@tiket/passport-collapse` | U | Animated show and hide by height (`max-height` transition), safe for nested collapses. |
| [[passport-container]] | `@tiket/passport-container` | U | Centered page-width wrapper that applies the design system's responsive edge padding and max width. |
| [[passport-content-loader]] | `@tiket/passport-content-loader` | U | Skeleton placeholders (rect, text, title, circle, thumb, circle with label) with pulse or wave shimmer. |
| [[passport-corporate-interim-module]] | `@tiket/passport-corporate-interim-module` |  | tiket Corporate "interim" step between product selection and checkout. Corporate users pick a travel plan and fill notes, cost centers and custom fields, including file uploads, before the booking proceeds. |
| [[passport-countdown]] | `@tiket/passport-countdown` | U | `HH:MM:SS` boxed countdown timer, with optional tenths of a second, plus a `useCountdown` hook. |
| [[passport-country-and-currency-modal]] | `@tiket/passport-country-and-currency-modal` | U | A self-triggering popup that asks the user to confirm their country and currency when the URL doesn't match their stored preferences. It also exports the country picker pieces the header reuses. |
| [[passport-country-list-selection]] | `@tiket/passport-country-list-selection` | U | Searchable country list for phone-code or nationality pickers, meant to sit inside a BottomSheet, a dropdown or a Modal. |
| [[passport-currency-bottom-sheet]] | `@tiket/passport-currency-bottom-sheet` | U | Multi-currency picker. It fetches the user's allowed currencies, lets them pick one (radio list with search), and persists the choice to cookie, account and core attributes. |
| [[passport-dashboard]] | `@tiket/passport-dashboard` |  | Data `Table` for back-office and B2B dashboards: sortable columns, sticky left and right columns, row-span, loading skeleton, empty state and built-in pagination. |
| [[passport-date-utils]] | `@tiket/passport-date-utils` |  | date-fns helpers that generate calendar grids (weeks, months, years) and compare days, shared by Calendar and Picker. |
| [[passport-design-tokens]] | `@tiket/passport-design-tokens` | U | The foundation of Passport styling: global CSS (normalize, reset, CSS variables), the TiketOdyssey font, SCSS breakpoint and mixin helpers, and TS colour-token maps and mappers. |
| [[passport-dialog]] | `@tiket/passport-dialog` | U | Centered confirmation or alert pop-up, either illustration + title + description + buttons (through [[passport-figure]]) or fully custom children. |
| [[passport-divider]] | `@tiket/passport-divider` | U | A horizontal or vertical separator line in default, bold or dashed style. |
| [[passport-download-app-banner]] | `@tiket/passport-download-app-banner` |  | "Get the tiket.com app" promo banners that link to the OneLink smart download URL. |
| [[passport-dropdown]] | `@tiket/passport-dropdown` | U | Headless-ish dropdown kit: `useDropdown` positions a `BaseDropdown` panel against a target, and `DropdownFormDisplay` is a read-only form field that acts as the target. |
| [[passport-error-view]] | `@tiket/passport-error-view` | U | Standard error state with an illustration, localized title, description and buttons, in full-screen or inline layout. |
| [[passport-extended-tabs]] | `@tiket/passport-extended-tabs` | U | Horizontally scrollable tab bar whose tabs carry a title, subtext and content line, e.g. date tabs with prices. It has desktop arrow navigation and auto-scroll to the selected tab. |
| [[passport-figure]] | `@tiket/passport-figure` | U | Illustration + title + description + up to two buttons, for empty states, confirmations and the body of [[passport-dialog]]. |
| [[passport-file-upload]] | `@tiket/passport-file-upload` | U | Multi-file uploader (browse or drag-and-drop, file list with retry, remove and download) and a single-file form field with a progress bar. Uploading is delegated to your `uploadFn`. |
| [[passport-floating-button]] | `@tiket/passport-floating-button` | U | Fixed floating action button (FAB). It can be a single icon/illustration button or an "extended" pill of several labelled buttons, with optional show-after-scroll and hide-while-scrolling behaviour. |
| [[passport-focus-trap]] | `@tiket/passport-focus-trap` |  | Thin wrapper over `react-focus-lock` that keeps keyboard focus inside overlays and returns it to the trigger on close. |
| [[passport-footer]] | `@tiket/passport-footer` | U | tiket.com site footer: link columns, call center and contact, partner and award logos, social media and app download. It's fully responsive and driven by a `footerList` data object, with default EN/ID data included. |
| [[passport-form]] | `@tiket/passport-form` | U | Text form fields with a floating label: `TextInput`, `TextArea`, `PhoneNumberInput`, and the shared `InputWrapper` frame that other packages build on. |
| [[passport-generic-facilities]] | `@tiket/passport-generic-facilities` |  | "Passengers & facilities" section for order-detail pages (flight, hotel, train, car, bus, ferry, airport transfer). It's server-driven through the order composer's section API, with drill-down detail popups. |
| [[passport-gift-voucher]] | `@tiket/passport-gift-voucher` | U | Composable "ticket stub" voucher card (header / content / perforated divider / footer) with helpers for title, link, voucher code, CTA button and expiry countdown. |
| [[passport-gift-voucher-claim-widget]] | `@tiket/passport-gift-voucher-claim-widget` | U | Cross-sell section ("claim these vouchers") for booking forms. It shows a carousel of claimable vouchers with T&C and a Claim button, and tracks impressions and claims. |
| [[passport-global-popup]] | `@tiket/passport-global-popup` | U | Site-wide campaign popup engine. It fetches the popups the promotion service picked for the current screen and renders them by content type (gift voucher, promo code, full image, inventory, combination, floating), with ack, interact and claim calls plus GTM. |
| [[passport-global-search]] | `@tiket/passport-global-search` | U | The header's cross-vertical search box. On focus it opens a panel of server-driven "non-typing" modules (recent, popular, most-searched, inspirational, promos, info). While the user types it shows debounced keyword results (POI, verticals, SRP links). |
| [[passport-google-one-tap]] | `@tiket/passport-google-one-tap` |  | Google One Tap sign-in for logged-out web users. It loads Google Identity Services, prompts, and hands the credential to tiket's `/login` page. On desktop FedCM browsers it can show an optional AB-driven nudge banner next to the prompt. |
| [[passport-gradient-banner]] | `@tiket/passport-gradient-banner` | U | Slim, token-coloured promo or info strip (icon, text, optional timer, chevron or button). `GradientBannerContainer` turns several of them into an auto-rotating keen-slider carousel. |
| [[passport-group-field]] | `@tiket/passport-group-field` | U | v1 "group field" card: a bordered box of tappable rows (number, text, subtext, chevron), used for booking-form sections like contact or passenger details. It also has helper/error text, an info footer and a list-with-toggle row. For new work, see [[passport-group-field-v2]]. |
| [[passport-group-field-v2]] | `@tiket/passport-group-field-v2` | U | Redesigned group-field card (Figma "Aufar - New Groupfield"). It has an optional clickable top nudge slot, rows that keep the main click surface separate from trailing selection controls, a tertiary action strip, and accessible helper/error text. |
| [[passport-header]] | `@tiket/passport-header` | U | The tiket.com site header: desktop top bar plus verticals row, mobile app-style bar, and slim, booking-page and auto-hiding variants. |
| [[passport-highlight-discover]] | `@tiket/passport-highlight-discover` |  | Building blocks for the "Highlight Discover" page-module sections: a layout, a mobile carousel with a cross-fading hero image, a two-up desktop article carousel, and article/product cards. |
| [[passport-icons]] | `@tiket/passport-icons` |  | About 460 inline-SVG React icon components (`IconArrowLeft`, `IconPlus`, …), generated from the SVG files in `assets/`. |
| [[passport-image]] | `@tiket/passport-image` |  | One component, `DefaultImageWrapper`: a `div` whose background is the tiket placeholder image, so the placeholder shows until (or instead of) the real image. |
| [[passport-image-preview]] | `@tiket/passport-image-preview` | U | Full-screen gallery viewer for images and videos, with a slider, thumbnails, captions and keyboard navigation. It has desktop, mobile and adaptive views. |
| [[passport-image-upload]] | `@tiket/passport-image-upload` | U | A horizontal row of image slots. It validates the files a user picks and uploads each one, in one or more resized variants, to the tiket image service. |
| [[passport-info-banner]] | `@tiket/passport-info-banner` | U | An inline message box with an icon, an optional title, content, an action link and a close button. It comes in `general`, `warning` and `alert` variants and collapses when dismissed. |
| [[passport-insurance]] | `@tiket/passport-insurance` |  | Insurance product cards (`InsuranceProtectionCard`) and a self-contained cross-sell carousel widget (`InsuranceProtection`) that adds a protection to the standalone insurance cart and redirects to checkout. |
| [[passport-insurance-pop-up]] | `@tiket/passport-insurance-pop-up` | U | Renders the flight-insurance upsell pop-up from the "Get Product Popup Display" API payload. The template is picked by `templateName`, and the same component serves verticals, webviews and the CMS panel preview. |
| [[passport-kuber-price-dynamic-banner]] | `@tiket/passport-kuber-price-dynamic-banner` |  | Turns a Kuber "banner evaluate" API response into a rendered Passport banner (info, notification, action, gradient, voucher or price history), plus the placement info and GTM tracking that go with it. |
| [[passport-label]] | `@tiket/passport-label` | U | Small tag or pill (`Label`) in general and product (ribbon) styles, plus `LabelCampaign`, a pill that rotates through several gradient labels. |
| [[passport-language-and-currency-modal]] | `@tiket/passport-language-and-currency-modal` | U | Header settings modal where the user picks language, currency and (behind a flag) country, then the page reloads with the new settings. |
| [[passport-list]] | `@tiket/passport-list` | U | A single list row: optional left slot, title and description, optional link, a right slot (children), and an optional divider. |
| [[passport-loading]] | `@tiket/passport-loading` | U | Full-screen blocking loader with the looping "T-man" video and localized title/description, rendered in a portal. |
| [[passport-loading-indicator]] | `@tiket/passport-loading-indicator` | U | Propless animated three-dot SVG spinner that inherits `currentColor`. |
| [[passport-logo]] | `@tiket/passport-logo` |  | Inline SVG components for the "Blibli tiket group" corporate logo. |
| [[passport-manage-order]] | `@tiket/passport-manage-order` | U | The "Manage order" action grid on order-detail pages (e-ticket, receipt, calendar, refund, reschedule, edit booking), driven by the order-composer section API. |
| [[passport-mission-landing-page]] | `@tiket/passport-mission-landing-page` | U | Presentational page for a loyalty "mission" (stamp or GBV progress toward a reward): banner, progress and reward, more info (FAQ, how to join, T&C) and a CTA. |
| [[passport-mission-page-module]] | `@tiket/passport-mission-page-module` | U | Compact mission card (title, stamp or GBV progress, nudge, CTA) for embedding a loyalty mission inside another page or WebView. Clicking it goes to `/mission/{slug}`. |
| [[passport-modal]] | `@tiket/passport-modal` | U | Centered desktop dialog with header, scrollable body and footer buttons. It is portaled, focus-trapped and scroll-locked, and closes with ESC or an overlay click. |
| [[passport-notification-banner]] | `@tiket/passport-notification-banner` | U | Inline info, success, warning or alert banner with an icon, optional title, text or custom content, an action link, and a close or right icon. |
| [[passport-notification-login]] | `@tiket/passport-notification-login` |  | Shows a one-time "logged in" snackbar or a "welcome / verify your email" popup after login or registration, driven by a short-lived cookie. |
| [[passport-otp-form]] | `@tiket/passport-otp-form` | U | Self-contained OTP entry form. It generates an OTP for a recipient, shows the code input with a resend countdown, verifies the code, and handles the max-attempt, suspend and blocked-prefix popups. |
| [[passport-otp-unm]] | `@tiket/passport-otp-unm` |  | Multi-channel OTP verification UI (WhatsApp, SMS, email) for the UNM (user and member) auth backend `gks-unm-go-be`, with resend, "use another method", "OTP not received" and customer-care flows. |
| [[passport-page-control]] | `@tiket/passport-page-control` | U | Carousel pagination dots (1-based `current`), with an inverted color mode for dark backgrounds. |
| [[passport-page-module]] | `@tiket/passport-page-module` |  | Renders a CMS-driven list of "page modules" (banners, product carousels, promo codes, tabbing, floating button…) returned by `tix-home` page-modules-full. It is the main merchandising surface on homepage, vertical landing and order-complete pages. |
| [[passport-page-module-collapse]] | `@tiket/passport-page-module-collapse` | U | Wraps [[passport-page-module]] so that a leading `BANNER_GRID` with `interactionType: 'EXPAND_COLLAPSE'` renders as a collapsed strip. An "expand" button opens the rest of the modules in a portaled overlay panel. |
| [[passport-page-module-shared]] | `@tiket/passport-page-module-shared` |  | The shared layer under [[passport-page-module]]: React contexts, the section layout, carousels, the overlay and bottom-text cards, and helpers used by page-module and its module packages (banner-carousel, banner-grid, product-card, promo-carousel…). |
| [[passport-pagination]] | `@tiket/passport-pagination` | U | Numbered page navigator with previous/next chevrons and ellipses. It can render plain buttons or SEO-friendly links through `linkRenderer`. |
| [[passport-phone-verification]] | `@tiket/passport-phone-verification` |  | End-to-end "verify your phone number" flow: a phone input with a country picker, then a phone check, then an OTP ([[passport-otp-form]]), then confirm and update the account phone. |
| [[passport-picker]] | `@tiket/passport-picker` | U | Single-date, time and date-time pickers. Desktop uses a month grid with holidays, mobile uses iOS-style scroll wheels. `WheelPicker` is the shared primitive. |
| [[passport-portal]] | `@tiket/passport-portal` | U | SSR-safe `createPortal` wrapper that renders children into `#<id>` (default `modal-root`), creating that element on `document.body` if needed. |
| [[passport-price-history-bar]] | `@tiket/passport-price-history-bar` |  | A three-band "Good Deal / Average / Expensive" price gauge with an arrow marking where the current price falls, plus info text and a clickable current-price chip. |
| [[passport-price-module]] | `@tiket/passport-price-module` | U | Compound price block (label(s), slash price, final price with an optional loyalty-tier icon, description) used on product cards. It is the slot-based v1. See [[passport-price-module-v2]] for the prop-based TDS redesign. |
| [[passport-price-module-v2]] | `@tiket/passport-price-module-v2` | U | Prop-driven price block from the TDS "Arta – Price Module V2" spec: price context, slash price and discount %, main price, unit texts, contexts and a tier or chevron icon. |
| [[passport-price-summary]] | `@tiket/passport-price-summary` | U | Data-driven price breakdown: nested line items (up to three levels, expandable with an accordion), an optional slash price, the total, extra rows and a cashback banner. |
| [[passport-pricing-promo]] | `@tiket/passport-pricing-promo` | U | Shared pricing and promo building blocks for verticals: a server-templated `PricingDisplay`, a `PricingFilter` sheet, and the promo UI (`PromoSection`, `PromoList`, `PromoCard`) with helpers for promo API responses. |
| [[passport-product-card]] | `@tiket/passport-product-card` |  | Generic image product card plus vertical-specific cards (accommodation, flight, train, airport transfer, car rental) used by page-module product carousels and grids. |
| [[passport-progress-bar]] | `@tiket/passport-progress-bar` | U | Minimal horizontal progress bar: the fill width is `progress` percent. |
| [[passport-progress-step]] | `@tiket/passport-progress-step` | U | Step indicators in three shapes: a horizontal numbered stepper, a vertical timeline with check, cross or number indicators, and a vertical dotted timeline with solid, dash and end segments. |
| [[passport-progress-stepper]] | `@tiket/passport-progress-stepper` | U | Simple vertical status timeline where each entry has a title, subtitle and description, and a status of `initial`, `in_progress` or `achieved`. |
| [[passport-promo-carousel]] | `@tiket/passport-promo-carousel` | U | The building blocks of the `PROMO_CAROUSEL` page module: a section layout (icon, title, CTA, chips, background), a keen-slider carousel with slide bars, promo image cards, and a loading skeleton. |
| [[passport-promo-code-popup]] | `@tiket/passport-promo-code-popup` | U | Promo-code detail popup with a copy-to-clipboard code, a CTA, T&C HTML and quota rulesets. It is a BottomSheet on mobile and a medium Modal on desktop. |
| [[passport-qr-popup]] | `@tiket/passport-qr-popup` | U | "Scan to install the app" QR popup. Mount one provider, then open the popup from anywhere with `useQrCoordinator().openQr()`. |
| [[passport-quantity-editor]] | `@tiket/passport-quantity-editor` | U | A − / value / + stepper with `min`, `max` and `step`, optionally with a typeable value. |
| [[passport-radio]] | `@tiket/passport-radio` | U | Context-based radio buttons. `RadioGroup` owns `name`, `value`, `disabled` and `onChange`, and each `Radio` compares its `value` with the group's. |
| [[passport-refund-method]] | `@tiket/passport-refund-method` |  | Refund-method selector: choose how a refund is paid out (bank transfer, BliPay, tiket points, original card, Juspay…), add, verify or select a bank account, and track where the money went after the refund. |
| [[passport-reseller-finance-module]] | `@tiket/passport-reseller-finance-module` |  | Self-contained reseller-dashboard finance report: filters (order type, transaction type, date basis, date range), a paginated table with a grand total, and an asynchronous report download. |
| [[passport-review-widget]] | `@tiket/passport-review-widget` | U | Product review section: rating summary, a carousel of user review cards, a review-detail popup with images, and "helpful" likes. Guests get a login popup, and WebView users get an app-download popup. |
| [[passport-ripple]] | `@tiket/passport-ripple` |  | Imperative Material-style ripple: call `createRipple(variant, event)` from an `onMouseDown` handler. This is the ripple used inside [[passport-button]] and [[passport-tabs]]. |
| [[passport-ripple-effect]] | `@tiket/passport-ripple-effect` |  | Wrapper `div` that shows a 500 ms ripple on every mouse-down, with an optional red `danger` color. |
| [[passport-screen-force-update]] | `@tiket/passport-screen-force-update` | U | Full-screen "please update the app" page for WebViews. The CTA opens the App Store or Play Store, and an optional secondary button lets the user continue when the update isn't mandatory. |
| [[passport-scrollable-content]] | `@tiket/passport-scrollable-content` | U | Vertically scrollable box that adds top and bottom shadows while content overflows, with options for scrollbar side and hover-only visibility. |
| [[passport-search-box]] | `@tiket/passport-search-box` | U | Search input with a clear button, an optional leading nav icon, a trailing action button or link, and an optional rotating ("running") placeholder. |
| [[passport-search-form-display]] | `@tiket/passport-search-form-display` | U | The tappable "field" rows of a search form (origin, destination, dates, pax), with stacking, a swap button, and content helpers for split text, icon counts, toggles and placeholders. |
| [[passport-search-widget-flight]] | `@tiket/passport-search-widget-flight` | U | Self-contained flight search form (one-way or round-trip, origin/destination airports, dates with prices and holidays, passengers and cabin class) that redirects to `/flights/search`. |
| [[passport-search-widget-ttd]] | `@tiket/passport-search-widget-ttd` | U | "To Do" (things-to-do, attractions) search widget: a destination search box with a suggestion overlay, nearby/geolocation, popular, recently viewed and favorite destinations, then a redirect to `/to-do/search`. |
| [[passport-segmented-control]] | `@tiket/passport-segmented-control` | U | iOS-style segmented switch. A "floating" selected box slides between options, and options can have an icon and a badge. |
| [[passport-seo]] | `@tiket/passport-seo` | U | Server-renderable SEO content blocks for landing pages: a text-with-image slot, an FAQ accordion, cards, internal-link lists (optionally tabbed), and a content summary. |
| [[passport-sidebar]] | `@tiket/passport-sidebar` | U | Desktop "My Account" sidebar: profile header (name, verified badge, loyalty tier, points with an expiring-points countdown) and the account menu (account, payment methods, reviews, wishlist, orders, point history, passengers, help center, settings). |
| [[passport-slider]] | `@tiket/passport-slider` | U | Range slider with two thumbs (or one) for filters like price ranges. It supports mouse and touch, discrete steps and separator marks. |
| [[passport-snackbar]] | `@tiket/passport-snackbar` | U | Global toast system modeled on react-hot-toast. Mount `<SnackbarProvider />` once, then call `snackbar('text', opts)` from anywhere, including outside React. |
| [[passport-snackbar-multi-account]] | `@tiket/passport-snackbar-multi-account` | U | "Logged in with <email / phone> · Change account" snackbar for users with several accounts on one phone number. "Change account" logs out and sends the user back through login. |
| [[passport-snake-animation]] | `@tiket/passport-snake-animation` | U | Animated SVG border where one or two gradient "snake" strokes travel around a rounded container. It highlights promo or festive cards. |
| [[passport-social-share]] | `@tiket/passport-social-share` | U | Share sheet for Facebook, Twitter/X, WhatsApp and copy-link. It is a bottom sheet on mobile and a popover on desktop, and `SocialShareAdaptive` picks one by breakpoint. |
| [[passport-social-share-mobile]] | `@tiket/passport-social-share-mobile` |  | Compatibility package. Its whole source is `export { SocialShareMobile } from '@tiket/passport-social-share'`. |
| [[passport-supergraphic]] | `@tiket/passport-supergraphic` | U | Decorative brand "supergraphic" shape: two translucent gradient SVG blobs pinned to a corner or edge of a banner. |
| [[passport-tabs]] | `@tiket/passport-tabs` | U | Controlled compound tabs (`Tabs` › `TabList` › `Tab`, `TabPanels` › `TabPanel`) with a sliding indicator, overflow arrows and sliding panels, plus `useTabsScrollSpy` for tabs that scroll to page sections. |
| [[passport-toggle]] | `@tiket/passport-toggle` | U | An on/off switch built on a hidden checkbox. It is controlled and comes in `small` or `large`. |
| [[passport-tooltip]] | `@tiket/passport-tooltip` | U | A dark tooltip with an arrow that appears on hover or focus of its children. It has 12 placements, can render in place or through a portal, and narrows itself when it would overflow the viewport. |
| [[passport-top-nav-srp]] | `@tiket/passport-top-nav-srp` |  | The mobile search-results-page top bar: a back button, a two-part route title (e.g. "Jakarta → Bali") with a chevron that reopens the search form, a sub-line, and up to two action icons. |
| [[passport-typography]] | `@tiket/passport-typography` | U | `Text`, the polymorphic text component every Passport package uses. It maps design-system size, weight and colour tokens to CSS classes, and adds an optional diagonal strike-through for slashed prices. |
| [[passport-umbrella]] | `@tiket/passport` | — | A single-import barrel that re-exports the public components, hooks and context of most Passport packages: `import { Button, Text, Modal } from '@tiket/passport'`. |
| [[passport-utils]] | `@tiket/passport-utils` | U | The shared runtime under every Passport component: the `PassportProvider` context (locale, currency, breakpoint, accessibility, environment, customFetch, wishlist), plus small hooks, timing helpers, body-scroll lock, HTML sanitising and recent-search helpers. |
| [[passport-voucher-card]] | `@tiket/passport-voucher-card` | U | A coupon-shaped container: a rounded card with semicircular "ticket" cut-outs on the left and right edges, a solid or gradient token background, and a drop-shadow elevation. |
| [[passport-wishlist]] | `@tiket/passport-wishlist` | U | The wishlist heart (`WishIcon`), which saves or removes a product through the wishlist API, plus `WishlistModule`, the "Add to collection / Manage your wishlist" pop-up flow that ships as a React remote. |

## Sources
- `packages/*/package.json` (name, description), `packages/*/src/index.ts`
- `packages/passport/package.json` (umbrella dependency list → **U** column)
