---
name: al-object-table
description: Create new AL tables - fields, keys, field groups, FlowFields, DataClassification, triggers.
---

# Create a Table
Start from [Table.al.template](./templates/Table.al.template). Allocate an ID with [next-object-id.ps1](./scripts/next-object-id.ps1).
- DataClassification on the table and **every** field. TableRelation on lookups. Keys for the dominant filter; SumIndexFields for aggregation. DropDown + Brick field groups on lookups.

Full AL grammar (loads on demand): [table-syntax.md](./reference/table-syntax.md)
