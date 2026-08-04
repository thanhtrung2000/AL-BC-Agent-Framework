---
name: al-extend-page
description: Create page extensions in Business Central that add fields, actions, groups, and parts to base application or third-party pages. Use when surfacing new data on a page this extension does not own, including stable anchor selection to survive Microsoft updates.
argument-hint: [base page name] [what to add]
---

# Extend a Page

Start from [PageExt.al.template](./templates/PageExt.al.template).

## Step 1 — Choose a stable anchor ⭐

Anchoring to a control Microsoft later moves or renames is **the most common
upgrade break in the BC ecosystem**. Your extension compiles today and fails
after the next platform update.

Anchor preference, best to worst:

| Anchor | Stability | Example |
|---|---|---|
| `addlast(<long-lived group>)` | ✅ Best | `addlast(General)` |
| `addfirst(<long-lived group>)` | ✅ Good | `addfirst(Invoicing)` |
| `addafter(<well-known field>)` | ⚠️ Risky | `addafter("No.")` |
| `addafter(<recently added field>)` | ❌ Fragile | avoid |

Long-lived base groups that rarely move: `General`, `Lines`, `Invoicing`,
`Shipping`, `Foreign Trade`, `Application`, `factboxes`.

**Always name the anchor you chose in your output** so a reviewer can judge it
and re-check after each BC upgrade.

## Step 2 — Required on every added control

- `ApplicationArea` — without it the control **does not render at runtime**.
- `Caption` and `ToolTip` starting with "Specifies ".
- Affix on every added field, action, group, and part.

## Step 3 — Modify vs redefine

Use `modify()` for property tweaks on an existing control:

```al
modify("Posting Date")
{
    ToolTip = 'Specifies the posting date. Custom validation applies.';
}
```

Never redefine a base control to change one property. And never remove a base
control — another extension or a user's personalisation may depend on it.

## Step 4 — Actions

- `ApplicationArea`, `Caption`, `ToolTip`, `Image` on every action.
- Delegate to a codeunit. No business logic in `OnAction`.
- Promote sparingly — the base page's ribbon is already crowded.

## Step 5 — Parts and FactBoxes

`addlast(factboxes)` is a stable anchor on most base pages. Use `SubPageLink`
to filter the part rather than filtering in code.

## Step 6 — Page-level triggers

`OnOpenPage` and `OnAfterGetRecord` in a page extension run for every user of
that base page. Keep them trivial. Anything expensive belongs in a FactBox that
loads on demand, or in a subscriber.

## Common failures

| Symptom | Cause |
|---|---|
| Compile break after a BC update | Anchored to a moved or renamed control |
| Field invisible at runtime | `ApplicationArea` missing |
| Base page feels sluggish for all users | Expensive logic in `OnAfterGetRecord` |
| AppSourceCop affix error | Added action missing the prefix |
| Another extension breaks | A base control was removed |
