---
name: 'al-codeunits'
applyTo: '**/*.Codeunit.al'
---

# AL Codeunit Conventions
- Single responsibility. Access=Internal unless public. Publish [IntegrationEvent] at extension points; IsHandled pattern.
- SetLoadFields before FindSet; no DB call per loop; never HTTP in a loop/transaction; no Commit in a loop/TryFunction.
- Subscribers: SkipOnMissingLicense/Permission where needed; never throw on a shared base event; guard IsTemporary().
