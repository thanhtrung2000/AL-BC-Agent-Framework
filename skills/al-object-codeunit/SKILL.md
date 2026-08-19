---
name: al-object-codeunit
description: Create new AL codeunits - business logic, PUBLISHING integration events, IsHandled. Subscribing is al-extend-events.
---

# Create a Codeunit
Start from [Codeunit.al.template](./templates/Codeunit.al.template). PUBLISHING events here; SUBSCRIBING → al-extend-events. SetLoadFields before FindSet; never HTTP in a loop/transaction.

Full AL grammar (loads on demand): [codeunit-syntax.md](./reference/codeunit-syntax.md)
