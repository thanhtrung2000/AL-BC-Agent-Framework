---
name: al-quick-object
description: Create a single new AL object owned by this extension. Skips planning.
agent: al-implementer
---
Create a new AL object (single-packet).
**Object type:** ${input:type:Table | Page | Codeunit | Enum | Interface | Query | XMLport}
**Purpose:** ${input:purpose:What this object is for}
Check the code first (does it exist?); allocate an ID; route to al-object-builder; build to zero errors.
