---
title: Calendar
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-calendar"
umbrella: true
sources:
  - packages/calendar/src
  - packages/calendar/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Calendar
> Single-date and range calendar plus a month picker, with holidays, daily price tiers (cheap/best), sold-out days, and mobile, desktop and responsive renderings.

## What it does
`useCalendar(props)` computes months between `minDate` (default today) and `maxDate` (default +1 year). It also builds a per-day metadata map (holidays, price tier), the range-selection state and the click handler, and returns `mobileProps` and `desktopProps`. `CalendarMobile` is a vertically scrolling month list with sticky month and week headers. `CalendarDesktop` is paged. `CalendarResponsive` picks one by `usePassport().breakpoint`. `MonthPicker*` follows the same model for month selection with monthly price tiers.

## Public API
| Export | Notes |
|---|---|
| `Calendar` | backwards-compatible default. **Always mobile** |
| `CalendarMobile`, `CalendarDesktop`, `CalendarResponsive` | |
| `CalendarBottomSheetModal` | `BottomSheet` (variant `clean`) on mobile, `Modal` (large, no padding) on desktop |
| `useCalendar` | build your own wrapper |
| `MonthPicker`, `MonthPickerMobile`, `MonthPickerDesktop`, `MonthPickerResponsive`, `useMonthPicker` | |
| types | `CalendarProps`, `CalendarBaseProps`, `CalendarVariant`, `DailyPrice`, `Holiday`, `Legend`, `Accent`, `PriceTier`, `MonthPickerVariant`, `MonthlyPrice`, `DateRangeArgs`, `DateSetter`, `DateRangeSetter`, `UseDatePickerArgs`, Figma override unions… |

Key `CalendarBaseProps`:
| Prop | Notes |
|---|---|
| `selectedSingleDate` + `setSingleDate` | single mode |
| `isRangePicker` + `startDate`/`endDate` + `setDateRange` | range mode. `allowSameStartAndEndDates` is read only on click |
| `variant` | `basic` (default, ignores prices), `generalPrice` (dot), `specificPrice` (label, bold accent, best container) |
| `dailyPrices: { date, label?, isBestPrice?, isCheapPrice? }[]`, `legends`, `accent: GREEN \| TURQUOISE` | best wins over cheap |
| `holidays: { name, date }[]` | |
| `isDayDisabled(date)` | default disables past dates |
| `isDaySoldOut(date)` | strikethrough, not clickable, wins over disabled |
| `minDate`, `maxDate`, `hideTodayLabel` | always whole months |
| mobile only: `placement`, `scrollableContainerSelector`, `stickyTopOffset`, `confirmation` | |
| desktop only: `initialOpenPage(maxPage)` | |

## Usage
From `stories/RangePicker.stories.tsx`:
```tsx
const handleSetDateRange = useCallback(({ startDate, endDate }) => setDateRange({ startDate, endDate }), []);
<CalendarResponsive isRangePicker startDate={range.startDate} endDate={range.endDate} setDateRange={handleSetDateRange} />
```

## Depends on
[[passport-date-utils]], [[passport-bottom-sheet]], [[passport-modal]], [[passport-divider]], [[passport-icons]], [[passport-typography]], [[passport-utils]], [[passport-design-tokens]]. Peer dep `date-fns ^4`. It has a devDep on `@tiket/react-common-utilities` from TIX-REACT-COMMON (see [[react-common-utilities]]).

## Used by
- No direct imports in other repos. TIX-NEXT-PAYMENT-FE's `.cursor/skills/migrate-tiket-packages/SKILL.md` mentions it. It's available through the umbrella.
- Internal: [[passport-reseller-finance-module]], [[passport-search-widget-flight]].

## Gotchas
- `Calendar` is mobile-only for backwards compatibility. Use `CalendarResponsive` for adaptive UIs.
- `CalendarResponsive` and `MonthPickerResponsive` render `null` until `PassportProvider` reports a breakpoint. They need a [[passport-utils]] provider with breakpoint detection.
- Memoize `setSingleDate` and `setDateRange` (the stories say so). Unstable callbacks re-run the calendar effects.
- Inside a [[passport-bottom-sheet]], mobile scroll-to-selected relies on the sheet's `data-bottom-sheet-scrollable-element`. In a custom scroller, pass `scrollableContainerSelector`.
- Tests for `CalendarBottomSheetModal` change `window.innerWidth`. The global bun setup resets the viewport before each test for this reason (see [[passport-architecture]]).

## Sources
- `packages/calendar/src/index.ts`, `src/Calendar.tsx`, `src/types.ts`, `src/components/CalendarResponsive.tsx`, `src/components/CalendarBottomSheetModal.tsx`
- `packages/calendar/src/stories/RangePicker.stories.tsx`
- `packages/calendar/package.json`, `bun-test-config/setup.ts`
