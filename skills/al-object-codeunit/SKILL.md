---
name: al-object-codeunit
description: Create new AL codeunits owned by this extension in Business Central — business logic, integration events, event subscribers, the IsHandled pattern, and performance-sensitive record processing. Use when the work is behaviour rather than storage or UI.
argument-hint: [what the codeunit does]
---

# Create a Codeunit

Start from [Codeunit.al.template](./templates/Codeunit.al.template).

## Step 1 — Decide the codeunit's role

| Role | Naming | Access |
|---|---|---|
| Business logic for an entity | `<AFFIX> <Entity> Mgt.` | `Public` |
| Event subscriber container | `<AFFIX> <Area> Subscribers` | `Internal` |
| Factory / builder | `<AFFIX> <Thing> Factory` | `Internal` |
| Interface implementation | `<AFFIX> <Interface> Impl.` | `Internal` |

Single responsibility. If the name needs more than five words, split it.

## Step 2 — Public surface is permanent

- `Access = Internal` unless the procedure is deliberately part of your public
  API. Anything `Public` you must support forever.
- Document every public procedure: what it does, what it requires, what it
  guarantees.
- Public procedures first, then local ones.

## Step 3 — Extensibility

Publish `[IntegrationEvent(false, false)]` at extension points. This is what
lets other extensions adapt without forking yours.

```al
OnBeforeProcess(Rec, IsHandled);
if IsHandled then
    exit;
```

- Publish `OnBefore` / `OnAfter` pairs around meaningful operations.
- Use the `IsHandled` pattern on anything a consumer may need to override.
- Never make a procedure `local` that an obvious consumer will need.

## Step 4 — Performance

- `SetLoadFields` before `FindSet` on wide tables — cloud SQL charges per column.
- Filter before reading, never after.
- Never issue a database call per loop iteration. Pre-load into a `Dictionary`
  or use a `Query`.
- Never call `CalcFields` inside a loop.
- Never call HTTP inside a loop or a transaction — an HTTP call holding a table
  lock is a tenant-wide outage.
- Take `LockTable` before the first read of that table, not after.
- Never place `Commit` inside a loop or a `TryFunction` context.

## Step 5 — Event subscribers

```al
[EventSubscriber(ObjectType::Codeunit, Codeunit::X, 'OnAfterPost', '', false, false)]
```

- Add `SkipOnMissingLicense` and `SkipOnMissingPermission` where the publisher
  runs in contexts your extension may not be licensed for.
- Keep subscribers fast — one on a posting event runs per record.
- Never throw from a subscriber on a base process unless the failure genuinely
  must block it. You will break unrelated flows.

## Step 6 — Errors

- Every message is a `Label` with a `Comment` when parameterised.
- State what went wrong **and** what to do next.
- Use `ErrorInfo` with actions where a fix can be offered inline.
- Wrap fallible external work in `[TryFunction]` and handle failure explicitly.

## Common failures

| Symptom | Cause |
|---|---|
| Other extensions must fork yours | No integration events published |
| Tenant-wide slowdown | Subscriber on a high-frequency event doing DB work |
| Deadlocks under load | `LockTable` after the first read |
| Report times out | Database call per loop iteration |
| Unhelpful runtime error | Hardcoded literal instead of a parameterised `Label` |
