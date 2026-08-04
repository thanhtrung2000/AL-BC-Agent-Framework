---
name: al-quick-object
description: Create a single new AL object owned by this extension. Skips planning — use for small, self-contained work.
argument-hint: [object type] [what it is for]
agent: al-implementer
---

Create a new AL object. This is a single-packet task, so skip planning and
route it directly.

**Object type:** ${input:type:Table | Page | Codeunit | Enum | Interface | Query | XMLport}
**Purpose:** ${input:purpose:What this object is for, in business terms}

Before routing:

1. Read the SETUP block in `.github/copilot-instructions.md` for the affix and
   ID range. If the file is missing or placeholders remain, stop and tell me to
   run `/al-bc-framework:al-framework-setup`.
2. Allocate the next free object ID using the script bundled with the
   `al-object-table` skill.
3. Route to `al-object-builder` with a complete brief — intent, ID range and
   IDs already taken, affix, target file path, upstream context, and boundaries.

The expert will classify the object sub-type itself and load one focused skill.

If the request actually needs an extension object, a report, an API page, or a
permission set, route it to the correct expert instead and tell me why.
