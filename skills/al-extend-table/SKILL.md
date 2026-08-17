---
name: al-extend-table
description: Create table extensions that add fields to base tables. Includes storage-cost assessment and upgrade impact.
---

# Extend a Table
Start from [TableExt.al.template](./templates/TableExt.al.template).
- Confirm a field is needed - on a high-volume base table it is permanent storage + upgrade cost. Consider a FlowField or linked own table.
- Field IDs from your range; affix; DataClassification. Never modify base field properties. Behaviour belongs in a subscriber, not a trigger.
- Report upgrade impact: field, where the value lives, text→decimal risk.
| Symptom | Cause |
|---|---|
| Tenant-wide slowdown | Logic in a TableExt trigger |
