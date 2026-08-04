---
name: al-permission-entitlement
description: Author entitlements in Business Central that map permission sets to licence types and roles for AppSource apps. Use only when shipping to AppSource or targeting specific Dynamics 365 licence types.
argument-hint: [target licence types]
---

# Entitlements

**Only needed for AppSource.** For per-tenant extensions, state "entitlement not
required" and skip.

Start from [Entitlement.al.template](./templates/Entitlement.al.template).

## What an entitlement does

A permission set says *what* a user can access. An entitlement says *which
licence types* may be granted that permission set.

Without one, an AppSource app's permission sets cannot be assigned to users
holding the relevant Dynamics 365 licences — the app installs but nobody can
use it.

## Structure

```al
entitlement "<AFFIX> Essential"
{
    Type = PerUserServicePlan;
    Id = '<service plan GUID>';
    ObjectEntitlements = "<AFFIX> All";
}
```

| Field | Meaning |
|---|---|
| `Type` | `PerUserServicePlan`, `Role`, or `PerTenantServicePlan` |
| `Id` | The GUID of the service plan or role — from Microsoft's published list |
| `ObjectEntitlements` | The permission sets granted |

## Common service plan types

| Licence | Typical entitlement |
|---|---|
| D365 Business Central Essential | Full functional access |
| D365 Business Central Premium | Full, including manufacturing/service |
| D365 Business Central Team Member | **Read-mostly** — grant a read-only set |
| Device / External Accountant | Depends on the app's purpose |

**Team Member is the one to get right.** Granting a Team Member licence full
write access is a licensing violation and an AppSource validation failure. Point
Team Member entitlements at a read-only permission set.

## Verify against the current GUID list

Service plan GUIDs are published by Microsoft and occasionally change. Do not
copy them from memory or from an old sample — check the current list and cite
where you got them in NOTES.

If you cannot verify a GUID, return `NEEDS_INPUT` rather than guessing. A wrong
GUID silently grants nothing.

## Common failures

| Symptom | Cause |
|---|---|
| App installs, nobody can use it | No entitlement, or wrong service plan GUID |
| AppSource validation rejection | Team Member granted write access |
| Some licence types work, others do not | Entitlement covers only one plan |
| Entitlement appears to do nothing | GUID is stale or mistyped |
