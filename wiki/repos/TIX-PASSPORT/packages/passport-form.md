---
title: Form
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-form"
umbrella: true
sources:
  - packages/form/src
  - packages/form/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Form
> Text form fields with a floating label: `TextInput`, `TextArea`, `PhoneNumberInput`, and the shared `InputWrapper` frame that other packages build on.

## What it does
`InputWrapper` draws the field box: label, focus and error states, a prefix, a right slot, a bottom slot, and helper or error text. `TextInput` and `TextArea` put a native element inside it and use `useFormInput` to track focus and value for the label animation. They work **controlled** (pass `value`) or **uncontrolled**, and they forward the ref to the input, so `react-hook-form` `register()` works. `TextInput` can show a clear button (`allowClearText`) or a clickable `rightIcon`. `PhoneNumberInput` is a `TextInput type="tel"` with a country flag, `+code` and chevron button on the left. Its `onChangePhoneNumber` strips leading zeros. Opening the country list is up to the caller, usually with [[passport-country-list-selection]] in a sheet or dropdown.

## Public API
| Export | Key props |
|---|---|
| `TextInput` (forwardRef input) | `label` (required), `value`, `onChange`, `errorText`, `helperText`, `prefix`, `rightIcon` + `onRightIconClick`, `allowClearText` + `onClearText`, `truncationPlaceholderText`, `truncationHelperText`, plus input props |
| `TextArea` (forwardRef textarea) | `label`, `errorText`, `helperText`, `height`, `showCounter` (with `maxLength`), plus textarea props |
| `PhoneNumberInput` (forwardRef input) | `label`, `phoneNumber`, `onChangePhoneNumber`, `onClickCountryFlag`, `phoneCode` (default `+62`), `countryFlag`, `countryName` (default Indonesia), `isOpenCountryList`, `hideChevron`, `countryFlagButtonRef`, `textInputProps`, `onChange` (bypasses zero-stripping) |
| `InputWrapper` | `id`, `label`, `focused`, `disabled`, `errorText`, `helperText`, `prefix`, `rightSlot`, `bottomSlot`, `inputWrapperRef`, `onClickInputWrapper`, `inputWrapperClassName` |
| `labelToHTMLId(label)` | `"Full Name"` becomes `"full-name"`. It's the default `id` |
Types: `TextInputProps`, `TextInputOwnProps`, `TextAreaProps`, `PhoneNumberInputProps`, `InputWrapperProps`, `InputWrapperOwnProps`.

## Usage
```tsx
const { register, formState: { errors } } = useForm();
<TextInput label="Full name" {...register('name', { required: true })} errorText={errors.name && 'Required'} />
<PhoneNumberInput label="Phone" phoneNumber={phone} onChangePhoneNumber={setPhone} onClickCountryFlag={() => setOpen(true)} phoneCode={country.code} />
```

## Depends on
[[passport-icons]], [[passport-typography]], [[passport-utils]]. Country-list-selection, dropdown and modal are devDeps used only in stories.

## Used by
- Through the umbrella `@tiket/passport`: `TextInput` in TIX-NEXT-PAYMENT-FE (about 14 files, e.g. `app/payment-link/components/CreditCardForm/*`; [[payment-fe-payment-link]]) and TIX-FINTECH-NEXT-FE (about 14 files, e.g. [[fintech-fe-gift-card]] checkout forms). `TextArea` and `PhoneNumberInput` are used in FINTECH gift-card and claim forms. `InputWrapper` is used in PAYMENT-FE `app/downpay/.../DownPayInstallmentInput.tsx` ([[payment-fe-downpay]]).
- Internal: 16 packages. [[passport-dropdown]] (`DropdownFormDisplay`), [[passport-file-upload]] (`SingleFileUpload`) and [[passport-phone-verification]] build on `InputWrapper`.

## Gotchas
- With no explicit `id`, two fields with the same `label` get the same `id`. Pass `id` when labels repeat.
- `onChangePhoneNumber` applies `value.replace(/\b0+/g, '')`, which strips leading zeros of every digit group, not only the first. Pass `onChange` to handle raw input.
- `TextInput` imports `IconSize` from the deep path `@tiket/passport-icons/src/types`.

## Sources
- `packages/form/src/TextInput.tsx`, `src/TextArea.tsx`, `src/PhoneNumberInput.tsx`, `src/InputWrapper.tsx`, `src/useFormInput.ts`, `src/utils.ts`
- `packages/form/package.json`
