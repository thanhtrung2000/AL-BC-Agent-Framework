---
name: al-extend-table
description: Create table extensions in Business Central that add fields and keys to base application or third-party tables. Use when storing new data on a table this extension does not own, including storage cost assessment and upgrade impact reporting.
argument-hint: [base table name] [what to add]
---

# Extend a Table

Start from [TableExt.al.template](./templates/TableExt.al.template).

## Step 1 — Confirm a field is actually needed

A field added to a high-volume base table (`Sales Line`, `Item Ledger Entry`,
`G/L Entry`, `Value Entry`) carries permanent storage and upgrade cost across
**every tenant**, forever.

Before adding one, ask:

| Alternative | When it works |
|---|---|
| FlowField over a table you own | The value is derivable from your own data |
| A linked record in your own table | The data is sparse — few base records have it |
| An existing base field | Sometimes one already carries the meaning |

If you add the field anyway, say **why** in NOTES. That justification is what a
reviewer needs.

## Step 2 — Field IDs and affix

- **IDs come from your own `idRanges`**, never the base table's numbering.
- **Affix every added field.** AppSourceCop enforces this, and it prevents real
  collisions with other ISVs extending the same table.
- `DataClassification` on every added field — release blocker if missing.
- `TableRelation` on every lookup field.

## Step 3 — Keys

Only add a key if a real filter pattern needs it. Every key costs write
throughput on a table that may already handle thousands of inserts per posting
run.

Never add a key "just in case" to a base table.

## Step 4 — Triggers: usually don't

Extension table triggers run for **every** consumer of that table, in every
company, on every operation — including base posting routines you never
anticipated.

| Need | Correct place |
|---|---|
| Default a value on insert | `OnInsert` in the extension is acceptable |
| Validate a field you added | `OnValidate` on **your** field is acceptable |
| React to a base posting process | **Event subscriber codeunit** — not here |
| Cross-table logic | **Event subscriber codeunit** — not here |

If the packet asks for behaviour, return the boundary rather than absorbing it.

## Step 5 — Report upgrade impact

Whenever you add a field existing tenants need populated, state in UPGRADE
IMPACT:

- Which field, and where the value lives today
- The row volume on a large tenant
- **Type conversion risk** — especially text to decimal, where a naive
  `Evaluate` uses the session locale and returns 0 for `"1.234,50"` in European
  companies

## Never do

- Modify properties of base fields
- Remove or obsolete a base field
- Change a base key

## Common failures

| Symptom | Cause |
|---|---|
| AppSourceCop affix error | Added field missing the prefix |
| Release blocker | `DataClassification` missing |
| Tenant-wide slowdown | Logic in a `TableExt` trigger instead of a subscriber |
| Posting throughput drops | Unnecessary key added to a high-volume base table |
| Silent data loss on upgrade | Text-to-decimal migration parsed with session locale |
