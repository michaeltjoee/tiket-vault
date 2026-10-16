---
title: Tabs
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-tabs"
sources:
  - packages/tabs/src
  - packages/tabs/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Tabs
> Controlled compound tabs (`Tabs` › `TabList` › `Tab`, `TabPanels` › `TabPanel`) with a sliding indicator, overflow arrows and sliding panels, plus `useTabsScrollSpy` for tabs that scroll to page sections.

Part of [[passport-packages]].

## What it does
`Tabs` is a context provider with no DOM of its own. It is **controlled**: you own `index` and update it in `onTabChange`. `TabList` and `TabPanels` clone their children and inject `index` by position, so you don't number `Tab`/`TabPanel` yourself. The indicator's width and x position are measured from the selected tab's box minus its padding. They are recomputed by a `ResizeObserver` and by a 500 ms font-size poll, so accessibility font scaling is picked up. Changing tabs scrolls the selected tab to the centre of the list. When the list overflows, left/right arrow buttons scroll it by 300 px. Panels slide left or right according to the direction of the change (300 ms). While a slide runs, further tab clicks are ignored. Each `Tab` gets a ripple from [[passport-ripple]] on mouse-down.

## Public API
| Export | Props |
|---|---|
| `Tabs` | `index`, `onTabChange(index)` (required), `invert` (for dark backgrounds), `equallyDistributed` |
| `TabList` | `withDivider` (default `true`), `className`, `containerClassName`, `style` |
| `Tab` | `icon` (recoloured by state unless it has its own `color`), `iconPosition` (`left`/`right`), `badge` (e.g. a [[passport-badge]]), `className` |
| `TabPanels` | `tabPanelPaddingVariant` (`default`, `noVerticalPadding`, `noPadding`), `innerContainerClassName`, `tabPanelClassName` |
| `TabPanel` | `children`. Inactive panels stay mounted with `hidden` |
| `useTabsScrollSpy({ tabSectionCodes, offset?, scrollableContainerRef? })` | returns `{ tabsProps, sectionRef(code) }` |
Also exported: `TabsContext`, `getTextVariant`, `getIconColor`, and types `TabsProps`, `TabProps`, `TabListProps`, `TabPanelsProps`, `TabPanelProps`, `TabsScrollSpyProps`, `SectionListRecord`.

## Usage
```tsx
const [index, setIndex] = useState(0);
<Tabs index={index} onTabChange={setIndex}>
  <TabList>
    <Tab>Departure</Tab>
    <Tab>Return</Tab>
  </TabList>
  <TabPanels>
    <TabPanel>…</TabPanel>
    <TabPanel>…</TabPanel>
  </TabPanels>
</Tabs>

// scroll spy
const { tabsProps, sectionRef } = useTabsScrollSpy({ tabSectionCodes: ['overview', 'benefit', 'tnc'] });
<Tabs {...tabsProps}>…</Tabs>
<div ref={sectionRef('overview')}>…</div>
```

## Depends on
[[passport-button]], [[passport-divider]], [[passport-icons]], [[passport-ripple]], [[passport-typography]], [[passport-utils]] (`useOverflow`, `usePrevious`, `useMounted`, `debounce`, `throttle`). It also imports types from [[passport-design-tokens]].

## Used by
- TIX-NEXT-PAYMENT-FE, through the umbrella `@tiket/passport`: `components/OrderSummary/components/Bus` ([[payment-fe-components]]).
- TIX-FINTECH-NEXT-FE, through the umbrella: the insurance claim centre ([[fintech-fe-insurance-claim]]: claim detail, landing order section, shared `OrderList`) and the standalone PDP ([[fintech-fe-insurance-standalone]]), which uses `useTabsScrollSpy`.
- Internal: [[passport-global-search]], [[passport-header]], [[passport-insurance]], [[passport-language-and-currency-modal]], [[passport-mission-landing-page]], [[passport-page-module]], [[passport-seo]], and the umbrella. [[passport-extended-tabs]] is a separate implementation.

## Gotchas
- If you don't update `index` in `onTabChange`, nothing changes. There's no uncontrolled mode.
- `index` is injected by child position. Conditionally rendered `null` children keep their slot (they're skipped, not re-indexed), so tabs and panels stay aligned only if you null the same position in both.
- `useTabsScrollSpy` calls `useRef` inside a loop over `tabSectionCodes`. Keep that array the same length for the component's lifetime (Rules of Hooks). Its scroll offset assumes a 52 px tab bar plus `offset`, and it disables scroll tracking for 1 s after a click.
- `Tabs.tsx` imports `IconColor` from `@tiket/passport-icons/src/types`, a deep path into the icons source.

## Sources
- `packages/tabs/src/Tabs.tsx`, `packages/tabs/src/useTabs.ts`
- `packages/tabs/src/components/Tab.tsx`, `packages/tabs/src/components/TabList.tsx`, `packages/tabs/src/components/TabPanels.tsx`, `packages/tabs/src/components/TabPanel.tsx`
- `packages/tabs/src/useTabsScrollSpy.ts`, `packages/tabs/package.json`
