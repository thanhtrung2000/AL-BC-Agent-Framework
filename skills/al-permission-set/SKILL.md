---
name: al-permission-set
description: Author permission sets and permission set extensions in Business Central so non-SUPER users can run the feature. Use after all objects exist to ensure every object is covered, grants match actual usage, and sets are rolled into an assignable composite.
argument-hint: [feature name]
---

# Permission Sets

Run **last**. You cannot cover objects that do not exist yet.

Start from [PermissionSet.al.template](./templates/PermissionSet.al.template).

## The defect this prevents

Developers test as SUPER. Permission gaps never surface in development — they
surface for the customer's AP clerk on day one, as a runtime error with no
compile-time warning.

Assume nothing was verified.

## Step 1 — Enumerate every object

List everything this extension owns. Your prompt should carry the inventory
from earlier packets; if not, scan the workspace.

| Object type | Required grant |
|---|---|
| Table | `R` `I` `M` `D` as actually used |
| Codeunit | `X` |
| Page (including API pages) | `X` |
| Report | `X` |
| Query | `X` |
| XMLport | `X` |

**Every object needs an entry.** A missing one is a runtime error.

## Step 2 — Grant the minimum that works

Trace the real calls. Do not pattern-match.

- Table only read → `R`. Not `RIMD`.
- Nothing deletes → no `D`.
- Something inserts → `I` is required, and its absence is a runtime error the
  compiler will not catch.

Over-granting is a security finding. Under-granting is a production failure.
Both are avoidable by reading the code.

## Step 3 — Indirect permissions for base tables

Where the extension writes to a base table **only through a base codeunit**, use
indirect permissions rather than direct `IMD`:

```al
tabledata "Sales Header" = Rimd;   // lowercase = indirect
```

Direct write grants on base tables are a security review finding.

## Step 4 — Structure and rollup

| Set | `Assignable` | Purpose |
|---|---|---|
| Granular, one per functional area | `false` | Building blocks |
| Composite / rollup | `true` | What administrators assign |
| Read-only variant | `true` | Reporting and viewer roles |

**Include every granular set in the composite.** A set nobody can be assigned is
a set nobody receives — the second most common miss after uncovered objects.

```al
IncludedPermissionSets = "<AFFIX> Spend Analysis", "<AFFIX> Setup";
```

## Step 5 — Permission set extensions

To add your objects to a **base** permission set, use
`permissionsetextension`. Prefer this over asking administrators to assign an
extra set — users who already have the base role get your feature automatically.

## Step 6 — Audit data classification

You do not set `DataClassification`, but you do **report** every field missing
it, naming the builder that created the file so the developer can route the fix.

## Common failures

| Symptom | Cause |
|---|---|
| "You do not have permission to read table X" | Object omitted from the set |
| Works for developer, fails for user | Tested only as SUPER |
| User has the extension but sees nothing | Set not rolled into the composite |
| Security finding | Direct `IMD` on a base table |
| API caller gets 403 | API page missing its `X` grant |
