---
name: al-object-codeunit
description: Create new AL codeunits - business logic, PUBLISHING integration events, IsHandled, performance. Publishing is here; SUBSCRIBING to base events is al-extend-events.
---

# Create a Codeunit
Start from [Codeunit.al.template](./templates/Codeunit.al.template).
- PUBLISHING [IntegrationEvent] is here. SUBSCRIBING to a base event → al-extend-events (extension-builder).
- Single responsibility; Access=Internal unless public. IsHandled pattern.
- SetLoadFields before FindSet; no DB call per loop; never HTTP in a loop/transaction; no Commit in a loop/TryFunction.
| Symptom | Cause |
|---|---|
| Others must fork you | No integration events published |
