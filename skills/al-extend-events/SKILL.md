---
name: al-extend-events
description: Create event subscriber codeunits in Business Central that react to base application or third-party events without modifying base objects - OnAfterPost, OnAfterValidate, OnAfterInsertEvent, OnBefore/IsHandled, and integration events. Use when extending base behaviour rather than base structure.
argument-hint: [base publisher] [what to react to]
---

# Extend Base Behaviour with Event Subscribers
Subscribing to a base event extends behaviour without touching the base object. Produces the subscriber codeunit - the hook. Belongs to al-extension-builder.

## Confirm a subscriber is right
Store data→table ext; show a field→page ext; **react to a base process→event subscriber**; conditionally change→OnBefore+IsHandled; publish from your own codeunit→al-object-codeunit.

## Find the event (prefer stability)
IntegrationEvent > BusinessEvent > trigger event. Prefer OnAfter unless you must prevent/alter → OnBefore+IsHandled. Use the event recorder for the exact signature - never hand-write it (a mismatch binds silently and never runs).

## Keep it THIN
A dispatcher. Business logic → al-object-builder codeunit. External calls → al-integration-builder. Start from [EventSubscriber.Codeunit.al.template](./templates/EventSubscriber.Codeunit.al.template).

## Rules that prevent incidents
1. SkipOnMissingLicense + SkipOnMissingPermission = true where the publisher may run for unlicensed users.
2. Never throw on a shared base event unless it MUST block.
3. Per-record events run thousands of times - no CalcFields/DB reads/HTTP.
4. Guard temp records: `if Rec.IsTemporary() then exit;`.
5. Never HTTP in a transactional subscriber - enqueue and defer.

## Naming
`<AFFIX> <Area> Subscribers` in src/EventSubscribers/. Access=Internal. List every base publisher + event name for re-check after an upgrade.

| Symptom | Cause |
|---|---|
| Never runs, no error | Signature mismatch |
| Base posting throws for some users | Missing Skip flags |
