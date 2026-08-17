---
name: al-quick-object
description: Create a single new AL object owned by this extension. Skips planning.
argument-hint: [object type] [what it is for]
agent: al-implementer
---
Create a new AL object (single-packet, skip planning).
**Object type:** ${input:type:Table | Page | Codeunit | Enum | Interface | Query | XMLport}
**Purpose:** ${input:purpose:What this object is for}
Read the SETUP block; allocate an ID; route to al-object-builder with a full brief. The expert classifies the sub-type.
