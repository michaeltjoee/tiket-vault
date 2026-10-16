---
title: Group Field V2
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-group-field-v2"
umbrella: true
sources:
  - packages/group-field-v2/src
  - packages/group-field-v2/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Group Field V2
> Redesigned group-field card (Figma "Aufar - New Groupfield"). It has an optional clickable top nudge slot, rows that keep the main click surface separate from trailing selection controls, a tertiary action strip, and accessible helper/error text.

## What it does
`GroupFieldV2` is the card shell, with no built-in rows. You compose:
- top slot: `dynamicContent` (usually `GroupFieldV2Nudge`). With `onDynamicContentClick` the whole slot becomes one control (`role="button"`, Enter/Space).
- rows: `GroupFieldV2Row` with `GroupFieldV2RowLeading`, `GroupFieldV2RowContent` > `GroupFieldV2RowText` + `GroupFieldV2RowSubtext`, and `GroupFieldV2RowTrailing` (checkbox, radio or `GroupFieldV2IconButton`). `GroupFieldV2RowClickableBody` is the main action surface. `GroupFieldV2RowAction`, `GroupFieldV2RowList` and `GroupFieldV2Stack` handle layout.
- `GroupFieldV2Divider` (`default` N100, `dashed`, `bold` full-width) and `GroupFieldV2Actions` (tertiary strip, one clickable control with `aria-label`).

Below the card, helper or error text renders with `role="alert"` for errors, optional `helperTextMaxLines` clamping, and `helperAndErrorId` for `aria-describedby`.

## Public API
| Export | Key props |
|---|---|
| `GroupFieldV2` | `dynamicContent`, `onDynamicContentClick`, `dynamicContentAriaLabel`, `helperText`, `errorText`, `helperTextMaxLines`, `horizontalPadding: 12 \| 16` (default 16), `helperAndErrorId`, plus `div` props |
| `GroupFieldV2Nudge` | `icon`, `children` |
| `GroupFieldV2Row*` (Row, RowLeading, RowContent, RowText, RowSubtext, RowTrailing, RowClickableBody, RowAction, RowList), `GroupFieldV2Stack` | composition parts. `RowTrailing interactive={false}` keeps selection controls separate |
| `GroupFieldV2IconButton` | `icon`. A native button (not [[passport-button]], to stay light) |
| `GroupFieldV2Divider` | `variant` |
| `GroupFieldV2Actions` | `onClick`, `disabled`, `aria-label` (default "Tertiary action") |

## Usage
```tsx
<GroupFieldV2 dynamicContent={<GroupFieldV2Nudge icon={<IconInfo />}>Use your saved details</GroupFieldV2Nudge>} errorText={err}>
  <GroupFieldV2Row>
    <GroupFieldV2RowClickableBody onClick={edit}>
      <GroupFieldV2RowContent><GroupFieldV2RowText>Contact</GroupFieldV2RowText></GroupFieldV2RowContent>
    </GroupFieldV2RowClickableBody>
    <GroupFieldV2RowTrailing interactive={false}><Check checked={sel} onChange={toggle} /></GroupFieldV2RowTrailing>
  </GroupFieldV2Row>
  <GroupFieldV2Divider />
  <GroupFieldV2Actions onClick={addTraveler} aria-label="Add traveler">+ Add traveler</GroupFieldV2Actions>
</GroupFieldV2>
```

## Depends on
[[passport-divider]], [[passport-icons]], [[passport-typography]], [[passport-utils]]. [[passport-check]] and [[passport-radio]] are devDeps used only in stories.

## Used by
- No consumers found in other repos on their baselines. It's available through the umbrella.
- Internal: none.

## Gotchas
- Default aria-labels ("Dynamic content", "Tertiary action") are English placeholders. Always pass real labels.
- Children of `GroupFieldV2Actions` must not be interactive. The whole strip is the control.

## Sources
- `packages/group-field-v2/src/GroupFieldV2.tsx`, `src/components/*.tsx`, `src/interactiveSurfaceProps.ts`, `src/lineClamp.ts`
- `packages/group-field-v2/package.json`
