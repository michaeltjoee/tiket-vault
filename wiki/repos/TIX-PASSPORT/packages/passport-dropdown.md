---
title: Dropdown
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-dropdown"
umbrella: true
sources:
  - packages/dropdown/src
  - packages/dropdown/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Dropdown
> Headless-ish dropdown kit: `useDropdown` positions a `BaseDropdown` panel against a target, and `DropdownFormDisplay` is a read-only form field that acts as the target.

## What it does
`useDropdown` measures `targetRef`, computes `top`/`bottom`/`left` and width, and returns `getDropdownProps()` for you to spread on `BaseDropdown`. It recomputes on resize (100 ms debounce) and on scroll of every overflow ancestor (from `@floating-ui/utils`). It closes on outside `mousedown`, except on the target itself or inside `ignorePortalId`. With `autoAdjustMaxHeight` it limits the panel height to the space left. Inside a scroll-locked modal it uses the nearest scrollable ancestor for that calculation. `BaseDropdown` portals by default, animates open and close (250 ms) and focus-traps its content. You render the options yourself, e.g. [[passport-radio]], a list or [[passport-country-list-selection]].

## Public API
| Export | Key props |
|---|---|
| `useDropdown(args)` → `{ getDropdownProps }` | `isOpen`, `onOpenChange`, `targetRef`, `dropdownRef`, `width` (CSS value or `(targetWidth) => value`), `align` (`left \| center \| right`, default center), `direction` (`bottom \| top`), `offset` (8), `domPlacement` (`portal \| inline`), `initialFocusRef`, `autoAdjustMaxHeight`, `ignorePortalId` |
| `BaseDropdown` (forwardRef) | `isOpen`, `align`, `direction`, `paddingVariant: default \| none`, `domPlacement`, `initialFocusRef`, `autoAdjustMaxHeight`, plus `div` props |
| `DropdownFormDisplay` (forwardRef to the wrapper) | `label`, `isOpen`, `errorText`, `helperText`, `disabled`, `inputRef`, `icon`, `onClick`, plus `input` props. A read-only input inside [[passport-form]] `InputWrapper` with a rotating chevron |
| types `BaseDropdownProps`, `DropdownFormDisplayProps`, `GetDropdownProps`, `UseDropdownArgs` | |

## Usage
```tsx
const targetRef = useRef<HTMLDivElement>(null);
const dropdownRef = useRef<HTMLDivElement>(null);
const { getDropdownProps } = useDropdown({ isOpen, onOpenChange: setOpen, targetRef, dropdownRef, width: (w) => w, align: 'left' });

<DropdownFormDisplay ref={targetRef} label="Bank" value={bank?.name ?? ''} isOpen={isOpen} onClick={() => setOpen(!isOpen)} />
<BaseDropdown ref={dropdownRef} {...getDropdownProps()}>{options}</BaseDropdown>
```

## Depends on
[[passport-focus-trap]], [[passport-portal]], [[passport-form]], [[passport-icons]], [[passport-utils]] (`useMountTransition`, `debounce`, `getPreventScrollCount`), `@floating-ui/utils`.

## Used by
- Through the umbrella `@tiket/passport`: TIX-NEXT-PAYMENT-FE `components/CountryField/CountryField.tsx`, `components/CardComponentV2/.../CardInstallmentV2.tsx`, `pages/smart_pay/components/RemoveBindingDropdown` ([[payment-fe-components]]). TIX-FINTECH-NEXT-FE `components/DatePicker/DatePicker.tsx`, `components/TimePicker/TimePicker.tsx` and the claim-form inputs ([[fintech-fe-components]]).
- Internal: 12 packages (corporate-interim-module, country-and-currency-modal, dashboard, form, header, insurance(-pop-up), language-and-currency-modal, page-module, picker, refund-method, reseller-finance-module).

## Gotchas
- With `align: 'center'`, `left` is the target's centre and CSS translates the panel. Pass `width` or the panel may overflow the viewport on narrow screens.
- `autoAdjustMaxHeight` only works with `direction: 'bottom'` and `domPlacement: 'portal'`. You still have to make your content scroll.
- When the dropdown is nested inside a modal that portals elsewhere, pass `ignorePortalId`. Otherwise clicks in the modal count as outside clicks.

## Sources
- `packages/dropdown/src/hooks/useDropdown.ts`, `src/components/BaseDropdown.tsx`, `src/components/DropdownFormDisplay.tsx`
- `packages/dropdown/package.json`
