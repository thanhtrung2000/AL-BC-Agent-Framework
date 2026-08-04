---
name: 'AL Codeunit Conventions'
description: 'Conventions for AL codeunits, business logic, events, and performance in Business Central'
applyTo: '**/*.Codeunit.al'
---

# AL Codeunit Conventions

## Structure

- Single responsibility. If the name needs more than five words, split it.
- Public procedures first, then local ones.
- `Access = Internal` unless the procedure is deliberately part of your public
  API. Public surface is permanent — you must support it forever.
- Document every public procedure: what it does, what it requires, what it
  guarantees.

## Extensibility

- Publish `[IntegrationEvent(false, false)]` at extension points. This is what
  lets other extensions adapt without forking yours.
- Use the `IsHandled` pattern on any procedure a consumer may need to override:

```al
OnBeforeProcess(Rec, IsHandled);
if IsHandled then
    exit;
```

- Publish `OnBefore` and `OnAfter` pairs around meaningful operations.
- Never make a procedure `local` that an obvious consumer will need.

## Performance

- `SetLoadFields` before `FindSet` on wide tables. Cloud SQL charges for every
  column returned.
- Filter before reading, never after.
- Never issue a database call per loop iteration. Pre-load into a `Dictionary`
  or use a `Query` object.
- Never call `CalcFields` inside a loop.
- Never call HTTP inside a loop or inside a transaction — an HTTP call holding
  a table lock is a tenant-wide outage.
- Take `LockTable` before the first read of that table, not after, or you
  invite deadlocks under concurrency.
- Never place `Commit` inside a loop or inside a `TryFunction` context.

## Event subscribers

- Subscribe with
  `[EventSubscriber(ObjectType::Codeunit, Codeunit::X, 'EventName', '', false, false)]`.
- Add `SkipOnMissingLicense` and `SkipOnMissingPermission` where the publisher
  runs in contexts your extension may not be licensed for.
- Keep subscribers fast. One on a posting event runs per record.
- Never throw from a subscriber on a base process unless the failure genuinely
  must block it — you will break unrelated flows.

## Errors

- Every message is a `Label` with a `Comment` when parameterised.
- State what went wrong and what to do next.
- Use `ErrorInfo` with actions where a fix can be offered inline.
- Wrap fallible external work in `[TryFunction]` and handle the failure
  explicitly — never swallow it.

## Security

- Secrets go in Isolated Storage, never a table field or a hardcoded string.
- Set `Permissions` narrowly. Prefer indirect permissions where the extension
  writes to a base table only through a base codeunit.
