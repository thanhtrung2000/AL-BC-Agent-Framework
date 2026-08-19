---
name: 'al-codeunits'
applyTo: '**/*.Codeunit.al'
---
# AL Codeunit Conventions
- Single responsibility. Publish [IntegrationEvent]; IsHandled pattern. SetLoadFields before FindSet; never HTTP in a loop/transaction; no Commit in a loop/TryFunction. Subscribers: SkipOnMissingLicense/Permission; never throw on a shared event; guard IsTemporary().
