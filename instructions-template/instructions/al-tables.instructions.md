---
name: 'AL Table Conventions'
description: 'Conventions for AL table and table extension objects in Business Central'
applyTo: '**/*.Table.al,**/*.TableExt.al'
---

# AL Table Conventions

## Required on every field

- `Caption`
- `DataClassification` — chosen deliberately, not copy-pasted. Release blocker
  if missing.
- `TableRelation` on every field referencing another table.

## DataClassification guide

| Value | Use for |
|---|---|
| `CustomerContent` | Business data the customer entered |
| `EndUserIdentifiableInformation` | Names, emails, phone numbers of people |
| `AccountData` | Tenant and account configuration |
| `OrganizationIdentifiableInformation` | Company names, addresses |
| `SystemMetadata` | Internal IDs, timestamps, flags with no business meaning |

## Keys

- Primary key first, `Clustered = true`.
- Add a secondary key only when a real filter pattern needs it. Every key costs
  write throughput on high-volume tables.
- `SumIndexFields` on keys used for aggregation so SIFT can seek, not scan.
- Order key fields by selectivity — most selective first.

## Field design

- Prefer a FlowField over a stored value when the value is derivable.
- `Editable = false` on computed or system-maintained fields.
- `NotBlank = true` on mandatory codes.
- Match base application widths: `Code[20]` identifiers, `Text[100]`
  descriptions — so lookups and relations line up.
- `AutoFormatType = 1` on currency amounts.

## Field groups

Define `DropDown` and `Brick` on any table used in lookups or tiles. Without
`DropDown`, lookups show only the primary key.

## Table extensions

- Field IDs come from **this extension's** range, never the base table's.
- Affix every added field.
- Never modify properties of base fields.
- Weigh the cost before adding a field to a high-volume base table
  (`Sales Line`, `Item Ledger Entry`, `G/L Entry`). Consider a linked record in
  your own table. If you add it anyway, say why in a comment.
- Keep triggers minimal. Logic reacting to base processes belongs in an event
  subscriber codeunit — extension triggers run for every consumer of that
  object in every company.
