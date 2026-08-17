---
name: al-extend-enum-profile
description: Create enum extensions and profile extensions - enum values with implementations, role centre customization.
---

# Extend an Enum or Profile
Start from [EnumProfileExt.al.template](./templates/EnumProfileExt.al.template).
- Base enum must be Extensible=true - no workaround. Value IDs from your range; caption values.
- If the base enum implements an interface, your value MUST supply Implementation (compiler-enforced). Never renumber/reuse.
- Profile: reference by ID string; usually pair with a pagecustomization or the change is invisible.
| Symptom | Cause |
|---|---|
| Cannot extend the enum | Extensible = false |
