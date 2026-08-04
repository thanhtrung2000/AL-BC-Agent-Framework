---
name: 'AL Page Conventions'
description: 'Conventions for AL page and page extension objects in Business Central'
applyTo: '**/*.Page.al,**/*.PageExt.al'
---

# AL Page Conventions

## Required on every page

- `Caption`
- `PageType` matched to purpose: `List`, `Card`, `Document`, `Worksheet`,
  `ListPart`, `CardPart`, `RoleCenter`, `API`.
- `UsageCategory` — without it the page cannot be found in Tell Me. Use
  `Lists`, `Tasks`, `ReportsAndAnalysis`, `Documents`, or `Administration`.
  Parts and role centres deliberately omit it.
- `ApplicationArea` — on the page **and** on every field and action. A control
  without it does not render at runtime. This is the single most common
  "my field disappeared" defect.

## Required on every field

- `ToolTip` starting with "Specifies ". Describe what the field means to the
  user, not what the code does with it.
- `Caption` where the source field name is not self-explanatory.

## Structure

- Group fields under captioned `group()` blocks. Ungrouped fields on a Card
  page render as a flat wall.
- Put a `FactBoxes` area on list and card pages where related data helps.
- Use `SubPageLink` on parts rather than filtering in code.

## Actions

- Every action needs `ApplicationArea`, `Caption`, `ToolTip`, and `Image`.
- Actions delegate to a codeunit. Logic in an action cannot be tested or reused.
- Promote sparingly. `Promoted = true` with `PromotedCategory`; reserve
  `PromotedIsBig` for the one primary action.

## Performance

- `SetLoadFields` in `OnOpenPage` on wide source tables.
- `Editable = false` on list pages that only navigate.
- Avoid `CalcFields` in `OnAfterGetRecord` — it fires per row. Use a FlowField
  column instead.

## Page extensions

- Anchor with `addlast(<stable group>)` in preference to
  `addafter(<specific control>)`. Anchoring to a control Microsoft later moves
  is the most common upgrade break in the ecosystem.
- Prefer long-lived base groups: `General`, `Lines`, `Invoicing`, `Shipping`,
  `factboxes`.
- Use `modify()` for property tweaks rather than redefining a control.
- Affix every added field, action, and group.
- Never remove a base control.

## API pages

API pages follow a different discipline — see the integration instructions. Do
not set `UsageCategory` on an API page.
