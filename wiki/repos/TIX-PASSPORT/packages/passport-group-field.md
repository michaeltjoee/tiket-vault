---
title: Group Field
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-group-field"
umbrella: true
sources:
  - packages/group-field/src
  - packages/group-field/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Group Field
> v1 "group field" card: a bordered box of tappable rows (number, text, subtext, chevron), used for booking-form sections like contact or passenger details. It also has helper/error text, an info footer and a list-with-toggle row. For new work, see [[passport-group-field-v2]].

## What it does
`GroupField` is the card shell, with helper or error text below it. An error turns the border red. Each `GroupFieldBody` is a full-width `<button>` row (`onClick` required), composed from `GroupFieldBodyNumber`, `GroupFieldBodyContent` > `GroupFieldBodyText` + `GroupFieldBodySubtext`, and `GroupFieldBodyChevron`. The chevron icon is replaceable or can be turned off with `false`, and the `alert` colour delays its transition. `GroupFieldDivider` separates rows. `GroupFieldInfo` is an info strip. `GroupFieldListWithToggle` is a row with a toggle (stories use [[passport-toggle]]).

## Public API
| Export | Props |
|---|---|
| `GroupField` | `children`, `helperText`, `errorText` |
| `GroupFieldBody` | `onClick` (required), `children` |
| `GroupFieldBodyNumber`, `GroupFieldBodyContent`, `GroupFieldBodyText`, `GroupFieldBodySubtext` | layout and text pieces |
| `GroupFieldBodyChevron` | `icon?: IconComponent \| false` (default `IconChevronRight`), `color: alert \| activity \| high-emphasis` |
| `GroupFieldDivider`, `GroupFieldInfo`, `GroupFieldListWithToggle` | |

## Usage
```tsx
<GroupField errorText={!contact && 'Please fill in contact details'}>
  <GroupFieldBody onClick={openContactForm}>
    <GroupFieldBodyContent>
      <GroupFieldBodyText>Contact details</GroupFieldBodyText>
      <GroupFieldBodySubtext>{contact?.email ?? 'Required'}</GroupFieldBodySubtext>
    </GroupFieldBodyContent>
    <GroupFieldBodyChevron color={contact ? 'high-emphasis' : 'alert'} />
  </GroupFieldBody>
</GroupField>
```

## Depends on
[[passport-divider]], [[passport-icons]] (deep import of `src/types` for `IconProps`), [[passport-typography]], [[passport-utils]].

## Used by
- No consumers found in other repos on their baselines. It's available through the umbrella.
- Internal: none.

## Gotchas
- Every `GroupFieldBody` is a `<button>`. Don't nest other buttons or links inside it. v2 separates the clickable body from trailing controls for that reason.

## Sources
- `packages/group-field/src/GroupField.tsx`, `src/components/*.tsx`
- `packages/group-field/package.json`
