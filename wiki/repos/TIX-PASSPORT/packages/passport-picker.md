---
title: Picker (date/time/wheel)
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-picker"
umbrella: true
sources:
  - packages/picker/src
  - packages/picker/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Picker
> Single-date, time and date-time pickers. Desktop uses a month grid with holidays, mobile uses iOS-style scroll wheels. `WheelPicker` is the shared primitive.

Part of [[passport-packages]].

## What it does
- **Desktop** (`DatePickerDesktop`): a one-month calendar grid with navigation, month/year menus, holiday markers (`HolidaysSection`) and a `PickerAction` save button. Create its props with `useDatePickerDesktop(baseProps)`, which adds the date-fns locale (from `usePassport().locale`) and computed holiday maps (`Computed`). `TimePickerDesktop` and `DateTimePickerDesktop` add spin buttons.
- **Mobile** (`DatePickerMobile`, `TimePickerMobile`, `DateTimePickerMobile`): wheels built on `WheelPicker` (keen-slider). By default the year range is today −150 to today +20 years, and `onChange` is debounced by 400 ms.
- For a range or multi-month calendar, use [[passport-calendar]].

## Public API
Components: `DatePickerDesktop`, `DatePickerMobile`, `DateTimePickerDesktop`, `DateTimePickerMobile`, `TimePickerDesktop`, `TimePickerMobile`, `PickerAction`, `WheelPicker`; hook `useDatePickerDesktop`. All are also in [[passport-umbrella]].

| Type | Key fields |
|---|---|
| `DatePickerBaseProps` | `selectedSingleDate?`, `setSingleDate(date)`, `minDate`, `maxDate` (required), `isDayDisabled?`, `holidays?: { name, date }[]`, `onSave?`, `saveButtonText?` |
| `DatePickerMobileProps` | `initialDate?`, `minDate?`, `maxDate?` (Date or epoch ms), `onChange(date)`, `dragMode` (`free`/`snap`/`free-snap`, default `free-snap`), `loop` (default true), `truncatedMaxLines` |
| `WheelPickerProps` | `options: { value, label }[]`, `initialValue`, `loop` (only when there are more than 3 options), `dragMode`, `textAlign` |

## Usage
From TIX-FINTECH-NEXT-FE `components/DatePicker/DatePicker.tsx`:
```tsx
const datePickerProps = useDatePickerDesktop({ selectedSingleDate, setSingleDate, minDate, maxDate, onSave });
return isMobile ? <DatePickerMobile {...mobilePickerProps} /> : <DatePickerDesktop {...datePickerProps} />;
```

## Depends on
[[passport-date-utils]], [[passport-button]], [[passport-divider]], [[passport-typography]], [[passport-utils]], icons. External: `keen-slider`. Peer: `date-fns`.

## Used by
- TIX-FINTECH-NEXT-FE (`^12.4.3`, direct dependency): `components/DatePicker/DatePicker.tsx`, `components/TimePicker/TimePicker.tsx`, and insurance claim-form `projects/insurance/claim-center/claim-form/components/Form/DateInput/*`.

## Gotchas
- The `loop` setting is silently ignored for wheels with 3 or fewer options.
- The desktop picker needs `useDatePickerDesktop`, or a manually supplied `selectedLocale` and `metadata`. Its props type is `DatePickerBaseProps & Computed`.

## Sources
- packages/picker/src/index.ts
- packages/picker/src/types.ts
- packages/picker/src/useDatePickerDesktop.ts
- packages/picker/src/components/DatePickerMobile/DatePickerMobile.tsx
- packages/picker/src/components/WheelPicker/WheelPicker.tsx
- packages/picker/package.json
