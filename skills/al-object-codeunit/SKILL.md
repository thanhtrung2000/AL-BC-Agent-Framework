---
name: al-object-codeunit
description: Create new AL codeunits - business logic, PUBLISHING integration events, IsHandled. Subscribing is al-extend-events.
---

# Create a Codeunit
Start from [Codeunit.al.template](./templates/Codeunit.al.template).
- PUBLISHING [IntegrationEvent] is here. SUBSCRIBING to a base event → al-extend-events.
- Single responsibility; Access=Internal unless public. SetLoadFields before FindSet; never HTTP in a loop/transaction.
| Symptom | Cause |
|---|---|
| Others must fork you | No integration events |
