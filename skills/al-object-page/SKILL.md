---
name: al-object-page
description: Create new AL pages owned by this extension in Business Central — list, card, document, worksheet, list part, card part, and role centre pages. Use when building UI, including actions, FactBoxes, and page-level filtering.
argument-hint: [page type] [what it shows]
---

# Create a Page

Start from [Page.al.template](./templates/Page.al.template).

## Step 1 — Choose the PageType

| Need | PageType | UsageCategory |
|---|---|---|
| Browse many records | `List` | `Lists` |
| Edit one record's details | `Card` | `Lists` (reached via the list) |
| Header + lines, e.g. an order | `Document` | `Documents` |
| Batch entry grid | `Worksheet` | `Tasks` |
| Embedded list inside another page | `ListPart` | none |
| Embedded detail inside another page | `CardPart` | none |
| Landing page for a role | `RoleCenter` | none |
| Setup or configuration | `Card` | `Administration` |

**`UsageCategory` is what makes the page findable in Tell Me.** Omit it and
users cannot search for the page. Parts and role centres deliberately omit it.

## Step 2 — Required on every control

- `ApplicationArea` — on the page **and** on every field and action. A control
  without it **does not render at runtime**. This is the single most common
  "my field disappeared" defect.
- `ToolTip` starting with "Specifies ". Describe what the field means to the
  user, not what the code does with it.
- `Caption` where the source field name is not self-explanatory.

## Step 3 — Structure

- Group fields under captioned `group()` blocks. Ungrouped fields on a Card page
  render as a flat wall.
- Add a `FactBoxes` area on list and card pages where related data helps.
- Use `SubPageLink` on parts rather than filtering in code.
- On Document pages, link the lines part with `SubPageLink` on the document no.

## Step 4 — Actions

Every action needs `ApplicationArea`, `Caption`, `ToolTip`, and `Image`.

- Actions **delegate to a codeunit**. Never put business logic in `OnAction` —
  logic there cannot be tested or reused.
- Promote sparingly: `Promoted = true` with `PromotedCategory` set. Reserve
  `PromotedIsBig` for the one primary action.

## Step 5 — Performance

- `SetLoadFields` in `OnOpenPage` on wide source tables.
- `Editable = false` on list pages that only navigate.
- Avoid `CalcFields` in `OnAfterGetRecord` — it fires per row. Use a FlowField
  column instead.
- Set `SourceTableView` to apply a default sort and filter.

## API pages

Not yours. A page with `PageType = API` belongs to `al-integration-builder` —
the permanent public contract matters more than the object type.

## Common failures

| Symptom | Cause |
|---|---|
| Field invisible at runtime | `ApplicationArea` missing |
| Page not searchable in Tell Me | `UsageCategory` missing |
| Card page is a flat wall of fields | No `group()` blocks |
| List page slow on real data | No `SetLoadFields`, or `CalcFields` per row |
| Action does nothing useful | Business logic inline instead of in a codeunit |
