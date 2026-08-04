---
name: al-integration-api-page
description: Build inbound API pages in Business Central that let external systems read and write records over OData v4 — Power BI, partner integrations, mobile apps. Use when an external caller needs CRUD access mapped to a table.
argument-hint: [entity name]
---

# Inbound API Page

For an external system that reads **or writes** BC records.

Start from [ApiPage.al.template](./templates/ApiPage.al.template).

## The contract is permanent ⭐

These five properties compose the public URL:

```
/api/<publisher>/<group>/<version>/companies(<id>)/<entitySetName>
```

Once a consumer integrates, **you cannot change them without breaking them.**

| Property | Convention |
|---|---|
| `APIPublisher` | lowercase, your org — `contoso` |
| `APIGroup` | lowercase, functional area — `spend` |
| `APIVersion` | `v1.0` — bump for breaking changes only |
| `EntityName` | singular, camelCase — `vendorSpendStatistic` |
| `EntitySetName` | plural, camelCase — `vendorSpendStatistics` |

**State the resulting URL in your output.** The consuming team needs it.

## Required properties

```al
PageType = API;
SourceTable = "<AFFIX> <Entity>";
ODataKeyFields = SystemId;
DelayedInsert = true;      // when the table has mandatory fields
Extensible = false;        // unless third parties should extend it
```

Do **not** set `UsageCategory` on an API page — it is not a UI page.

## Field discipline

Expose **only** what the contract requires. Every extra field is:

- one you must support forever
- a potential data-exposure finding in security review

Always include `SystemId` as `id` and `SystemModifiedAt` as
`lastModifiedDateTime` — consumers use the latter for delta sync.

## Validation

Never trust the caller. Validate in the triggers:

```al
trigger OnInsertRecord(BelowxRec: Boolean): Boolean
begin
    // Reject incomplete or inconsistent payloads here.
    exit(true);
end;
```

## Versioning

A breaking change means a **new `APIVersion`**, never an in-place field removal
or retype. Keep the old version live until consumers migrate.

Breaking: removing a field, renaming a field, changing a field's type,
tightening validation.
Non-breaking: adding an optional field.

## Performance

- `SetLoadFields` where the source table is wide.
- Consider `DataAccessIntent = ReadOnly` if the page is read-only.

## Common failures

| Symptom | Cause |
|---|---|
| Consumer integration breaks | Field removed without an `APIVersion` bump |
| Insert fails with mandatory field error | `DelayedInsert` not set |
| Security review finding | Fields exposed beyond the contract |
| Consumers cannot do delta sync | `lastModifiedDateTime` not exposed |
