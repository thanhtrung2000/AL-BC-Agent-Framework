---
name: al-object-enum-interface
description: Create new AL enums and interfaces - extensible value sets, contracts, dispatch.
---

# Create an Enum or Interface
Start from [EnumInterface.al.template](./templates/EnumInterface.al.template).
- Enums: Extensible=true unless told otherwise; caption every value; gaps; never renumber. Interfaces: contract only; never a single implementation. Pair enum+interface = dispatch without case statements.

Full AL grammar (loads on demand): [enum-interface-syntax.md](./reference/enum-interface-syntax.md)
