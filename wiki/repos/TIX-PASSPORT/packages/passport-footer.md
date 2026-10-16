---
title: Footer
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-footer"
umbrella: true
sources:
  - packages/footer/src
  - packages/footer/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Footer
> tiket.com site footer: link columns, call center and contact, partner and award logos, social media and app download. It's fully responsive and driven by a `footerList` data object, with default EN/ID data included.

## What it does
`Footer` renders `FooterDesktop`, which despite the name is responsive on every breakpoint. Column content comes from `footerList: FooterElements[]` (title, contents `{ text, image, url, isNewUrlStructure }`, key `company | product | support | download | contact`). Static parts come from `utils/constants.ts`: call-center numbers, email, halo tiket chat link, social links and Lightroom logo URLs. Links go through `useForwardParams().withForwardParams(url, isNewUrlStructure)`. GTM is left to the caller through tracker callbacks. Default datasets: `DEFAULT_FOOTER_DATA_EN/ID`, plus IDR multi-currency variants `FOOTER_DATA_EN_IDR/ID_IDR`.

## Public API
| Export | Notes |
|---|---|
| `Footer` | `footerList`, `tiketLogo` (URL), `footerContentGTMTracker`, `socialMediaGTMTracker`, `downloadAppGTMTracker`. `device` and `variant` are deprecated no-ops |
| `FooterDesktop` | same, without the deprecated props |
| `FooterMobile` | **deprecated** old mobile footer (`tiketLogo`, `variant`, trackers) |
| `DEFAULT_FOOTER_DATA_EN`, `DEFAULT_FOOTER_DATA_ID`, `FOOTER_DATA_EN_IDR`, `FOOTER_DATA_ID_IDR` | ready `FooterProps` (minus logo) |
| types `FooterProps`, `FooterMobileProps`, `FooterElements`, `FooterContent`, `GTMTracker`, `GTMTrackerArg` (`itemTitle`, `itemOrder`, `sectionItemTotal`, `url`, `sectionTitle`), `Device` | |

## Usage
From TIX-REACT-COMMON `RemoteFooter/Fallback.tsx`:
```tsx
const { locale } = usePassport();
return <Footer {...{ en: DEFAULT_FOOTER_DATA_EN, id: DEFAULT_FOOTER_DATA_ID }[locale]} />;
```

## Depends on
[[passport-container]], [[passport-divider]], [[passport-logo]] (`BlibliTiketLogoBlue`), [[passport-assets]], [[passport-icons]], [[passport-typography]], [[passport-utils]].

## Used by
- TIX-REACT-REMOTE `src/components/footer/index.tsx` (plus `footer-desktop`, `footer-mobile` and `src/utils/__test__/footer.spec.ts`). It picks the data with `getFooterData(lang, tiket_currency cookie)`, wires the trackers, and is exposed as a remote ([[react-remote-footer]]). Pinned `12.4.2`.
- TIX-REACT-COMMON `packages/react-common-remote/src/RemoteFooter*/Fallback.tsx` render it from the umbrella with the default data when the remote can't load ([[react-common-remote]]).
- Internal: none.

## Gotchas
- `Footer` and `FooterDesktop` are the same component. The real mobile/desktop split is CSS. Don't use `FooterMobile` in new code.
- Contact numbers, email and social links are hard-coded constants, not props. Changing them needs a Passport release, then a react-remote bump.
- The multi-currency data variants exist because some footer content (payment partners) depends on currency. The remote picks a variant from the `tiket_currency` cookie on the client.

## Sources
- `packages/footer/src/Footer.tsx`, `src/components/desktop/Footer.tsx`, `src/components/mobile/Footer.tsx`, `src/types.ts`, `src/index.ts`, `src/data/*`
- `packages/footer/package.json`
- TIX-REACT-REMOTE `src/components/footer/index.tsx` (281778b); TIX-REACT-COMMON `packages/react-common-remote/src/RemoteFooter/Fallback.tsx` (14597c4e)
