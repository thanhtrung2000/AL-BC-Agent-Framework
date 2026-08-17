---
name: al-object-table
description: Create new AL tables owned by this extension - fields, keys, field groups, FlowFields, DataClassification, triggers.
---

# Create a Table
Start from [Table.al.template](./templates/Table.al.template). Allocate an ID with [next-object-id.ps1](./scripts/next-object-id.ps1).
- DataClassification on the table and **every** field - release blocker. TableRelation on lookups. Keys for the dominant filter; SumIndexFields for aggregation.
- FlowField over stored where derivable. DropDown + Brick field groups on lookup tables.
| Symptom | Cause |
|---|---|
| Release blocker | DataClassification missing |
