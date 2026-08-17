---
name: al-object-enum-interface
description: Create new AL enums and interfaces - extensible value sets, interface contracts, enum-implements-interface dispatch.
---

# Create an Enum or Interface
Start from [EnumInterface.al.template](./templates/EnumInterface.al.template).
- Enums: Extensible=true unless told otherwise. Caption every value. Gaps between values. Never renumber.
- Interfaces: contract only; never one with a single implementation. Pair enum+interface so the value selects the implementation - no case statements.
| Symptom | Cause |
|---|---|
| Cannot extend | Extensible = false |
