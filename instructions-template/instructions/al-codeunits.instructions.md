---
name: 'AL Codeunit Conventions'
description: 'Conventions for AL codeunits, business logic, events, and performance in Business Central'
applyTo: '**/*.Codeunit.al'
---
# AL Codeunit Conventions
- Single responsibility. Access=Internal unless public. Publish [IntegrationEvent] at extension points; IsHandled pattern.
- SetLoadFields before FindSet; no DB call per loop; no CalcFields in a loop; never HTTP in a loop/transaction; no Commit in a loop/TryFunction.
- Event subscribers: SkipOnMissingLicense/Permission where needed; never throw on a shared base event; keep per-record subscribers cheap; guard IsTemporary().
