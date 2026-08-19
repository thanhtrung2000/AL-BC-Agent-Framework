---
name: al-extend-table
description: Create table extensions adding fields to base tables, with storage-cost and upgrade assessment.
---

# Extend a Table
Start from [TableExt.al.template](./templates/TableExt.al.template).
- On a high-volume base table a field is permanent storage/upgrade cost. Field IDs from your range; affix; DataClassification. Never modify base field properties. If a tableextension of this base already exists, add the field INSIDE it — never a duplicate.

Full AL grammar (loads on demand): [extension-syntax.md](./reference/extension-syntax.md)
