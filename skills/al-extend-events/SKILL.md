---
name: al-extend-events
description: Create event subscriber codeunits that react to base events without modifying base objects.
---

# Extend Base Behaviour with Event Subscribers
Start from [EventSubscriber.Codeunit.al.template](./templates/EventSubscriber.Codeunit.al.template). A THIN dispatcher — business logic → object-builder codeunit.
- SkipOnMissingLicense/Permission where the publisher may run for unlicensed users. Never throw on a shared base event. Per-record events run thousands of times — no CalcFields/DB/HTTP. Guard IsTemporary(). Never hand-write an event signature (use the recorder). Name `<AFFIX> <Area> Subscribers` in src/EventSubscribers/.

Full AL grammar (loads on demand): [eventsubscriber-syntax.md](./reference/eventsubscriber-syntax.md)
