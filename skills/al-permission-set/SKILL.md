---
name: al-permission-set
description: Author permission sets so non-SUPER users can run the feature.
---

# Permission Sets
Start from [PermissionSet.al.template](./templates/PermissionSet.al.template). Enumerate every object; grant the minimum; indirect (lowercase) permissions where a base table is written via a base codeunit. Granular sets Assignable=false rolled into an Assignable=true composite.
