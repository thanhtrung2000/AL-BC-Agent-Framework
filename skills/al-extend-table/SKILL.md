---
name: al-extend-table
description: Create table extensions adding fields to base tables, with storage-cost and upgrade assessment.
---

# Extend a Table
Start from [TableExt.al.template](./templates/TableExt.al.template).
- On a high-volume base table a field is permanent storage/upgrade cost - consider a FlowField or linked own table. Field IDs from your range; affix; DataClassification. Never modify base field properties. Report upgrade impact.
| Symptom | Cause |
|---|---|
| Tenant-wide slowdown | Logic in a TableExt trigger |
