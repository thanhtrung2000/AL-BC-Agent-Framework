---
name: al-object-table
description: Create new AL tables owned by this extension in Business Central — fields, keys, field groups, FlowFields, DataClassification, and table triggers. Use when the work is persistent storage, a setup table, a buffer table, or a temporary aggregation table.
argument-hint: [what the table stores]
---

# Create a Table

Start from [Table.al.template](./templates/Table.al.template).

Need a free object ID? Run
[next-object-id.ps1](./scripts/next-object-id.ps1):

```powershell
pwsh <plugin-root>/skills/al-object-table/scripts/next-object-id.ps1 -Type Table
```

Never invent an ID or a range. An out-of-range ID fails AppSourceCop and blocks
release.

## Step 1 — Decide the table's role

| Role | Shape |
|---|---|
| **Master data** | Code[20] PK, Description, `DropDown` + `Brick` field groups, LookupPageId |
| **Setup / singleton** | `Primary Key` Code[10] always blank, one record, `Insert` guarded |
| **Ledger / entry** | `Entry No.` Integer PK autoincrement, never editable after insert |
| **Buffer / temporary** | Used with `UseTemporary`; still needs real keys for sorting |
| **Line table** | Composite PK: document no. + line no. |

## Step 2 — Fields

Required on **every** field:

- `Caption`
- `DataClassification` — chosen deliberately, not copy-pasted
- `TableRelation` on every field pointing at another table

| DataClassification | Use for |
|---|---|
| `CustomerContent` | Business data the customer entered |
| `EndUserIdentifiableInformation` | Names, emails, phone numbers of people |
| `AccountData` | Tenant and account configuration |
| `OrganizationIdentifiableInformation` | Company names, addresses |
| `SystemMetadata` | Internal IDs, timestamps, flags with no business meaning |

Field design rules:

- Prefer a **FlowField** over a stored value when the value is derivable.
  Stored duplicates drift out of sync and cost upgrade effort.
- `Editable = false` on computed or system-maintained fields.
- `NotBlank = true` on mandatory codes.
- Match base application widths: `Code[20]` for identifiers, `Text[100]` for
  descriptions — so lookups and relations line up.
- `AutoFormatType = 1` on currency amounts.

## Step 3 — Keys

- Primary key first, `Clustered = true`.
- Add a secondary key **only** when a real filter pattern needs it. Every key
  costs write throughput.
- `SumIndexFields` on keys used for aggregation, so SIFT can seek not scan.
- Order key fields by selectivity — most selective first.

## Step 4 — Field groups

Define `DropDown` and `Brick` on any table used in lookups or tiles. Without
`DropDown`, lookups show only the primary key.

## Step 5 — Triggers

Keep them minimal:

- `OnInsert` — initialisation, number series
- `OnDelete` — cascade or guard against orphans
- `OnModify` — audit fields only

Cross-object business logic belongs in a codeunit, not a table trigger.

## Common failures

| Symptom | Cause |
|---|---|
| Release blocker | `DataClassification` missing on a field |
| Lookup shows only codes | No `DropDown` field group |
| Slow list page | No key matching the page's filter pattern |
| AppSourceCop error | ID outside `idRanges`, or affix missing |
| Data drifts out of sync | Stored field used where a FlowField belonged |
