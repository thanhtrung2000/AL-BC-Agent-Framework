---
name: al-extend-events
description: Create event subscriber codeunits that react to base events without modifying base objects.
---

# Event Subscribers
Start from [EventSubscriber.Codeunit.al.template](./templates/EventSubscriber.Codeunit.al.template). A THIN dispatcher — logic → object-builder codeunit. SkipOnMissingLicense/Permission; never throw on a shared event; guard IsTemporary(); never hand-write a signature. Name `<AFFIX> <Area> Subscribers`.

Full AL grammar (loads on demand): [eventsubscriber-syntax.md](./reference/eventsubscriber-syntax.md)
