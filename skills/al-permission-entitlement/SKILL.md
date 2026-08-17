---
name: al-permission-entitlement
description: Author entitlements that map permission sets to licence types for AppSource.
---

# Entitlements
Start from [Entitlement.al.template](./templates/Entitlement.al.template).
AppSource only - else "not required". Maps a service plan GUID to permission sets. **Team Member must point at a read-only set** or AppSource rejects it. Verify GUIDs; unverifiable → NEEDS_INPUT.
| Symptom | Cause |
|---|---|
| App installs, nobody can use it | Wrong/stale service-plan GUID |
