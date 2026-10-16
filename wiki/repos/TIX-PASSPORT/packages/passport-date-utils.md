---
title: Date Utils
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-date-utils"
sources:
  - packages/date-utils/src
  - packages/date-utils/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Date Utils
> date-fns helpers that generate calendar grids (weeks, months, years) and compare days, shared by Calendar and Picker.

## What it does
Generator-style functions build calendar matrices. `takeWeek(start)` returns a function that yields successive Sunday-to-Saturday weeks. `takeMonth(start)` yields successive months as `Week[]`, padded to full weeks. `takeYear(start, end)` yields all months between `start` and `end`, which defaults to one year ahead. There are also small predicates and formatters.

## Public API
| Export | Notes |
|---|---|
| `takeWeek(start?)` → `() => Week` | weeks start on Sunday (date-fns default) |
| `takeMonth(start?)` → `() => Month` | `Month = Week[]` |
| `takeYear(start?, end?)` → `() => Month[]` | |
| `isDayPast(day)` | past and not today |
| `isDayNotInSameMonth(day, firstDay)` | for greying out padding days |
| `isWithinRangeInclusive(date, start, end)` | |
| `formatDateAsString(date)` → `yyyy-MM-dd`, `formatDateAsYearMonthString(date)` → `yyyy-MM` | map keys used by the calendar metadata |
| types `Week`, `Month`, `TakeWeekReturn`, `TakeMonthReturn`, `TakeYearReturn`, `IsDayPast`, `DateToStringFn`, `IsDayNotInSameMonth` | |

## Usage
```ts
import { takeYear, formatDateAsString } from '@tiket/passport-date-utils';
const months = takeYear(minDate, maxDate)();   // Month[]
const key = formatDateAsString(day);           // '2026-10-16'
```

## Depends on
Peer dep `date-fns ^4`. [[passport-utils]] is listed as a dep but not imported.

## Used by
- No consumers in other repos.
- Internal: [[passport-calendar]], [[passport-picker]].

## Gotchas
- Week start is fixed to Sunday. There's no locale `weekStartsOn` option.
- All formatting uses local time (`format`), not UTC.
- Not in the umbrella `@tiket/passport`.

## Sources
- `packages/date-utils/src/date-utils.ts`
- `packages/date-utils/package.json`
