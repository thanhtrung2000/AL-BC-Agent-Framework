---
name: al-extend-events
description: Create event subscriber codeunits in Business Central that react to base application or third-party events without modifying base objects - OnAfterPost, OnAfterValidate, OnAfterInsertEvent, OnBefore/IsHandled, and integration events. Use when extending base behaviour rather than base structure.
argument-hint: [base publisher] [what to react to]
---

# Extend Base Behaviour with Event Subscribers
Subscribing to a base event extends behaviour without touching the base object. This skill
produces the subscriber codeunit - the hook. It belongs to al-extension-builder.

## Step 1 - Confirm a subscriber is the right tool
| Need | Use |
|---|---|
| Store data on a base table | Table extension |
| Show a field/action on a base page | Page extension |
| React to a base process (post/validate/insert) | Event subscriber - this skill |
| Conditionally change base behaviour | OnBefore + IsHandled |
| Publish an event from your OWN codeunit | al-object-codeunit (not this skill) |

## Step 2 - Find the right event (prefer stability)
IntegrationEvent > BusinessEvent > trigger event (OnAfterInsertEvent). Prefer OnAfter unless you
must prevent/alter -> OnBefore + IsHandled. Use the event recorder for the exact signature -
never hand-write it (a mismatch binds silently and never runs).

## Step 3 - Keep it THIN
A dispatcher. Business logic -> al-object-builder codeunit. External calls -> al-integration-builder.
Start from [EventSubscriber.Codeunit.al.template](./templates/EventSubscriber.Codeunit.al.template).

## Step 4 - Rules that prevent incidents
1. SkipOnMissingLicense + SkipOnMissingPermission = true where the publisher may run for unlicensed users.
2. Never throw on a shared base event unless it MUST block - your error breaks posting for every extension.
3. Per-record events run thousands of times - no CalcFields, no per-call DB reads, no HTTP.
4. Guard temp records: `if Rec.IsTemporary() then exit;`.
5. Never HTTP in a transactional subscriber - locks are held; enqueue and defer.

## Step 5 - Binding
Static (default); Manual (EventSubscriberInstance = Manual) for scoped windows; SingleInstance only for tiny state.

## Step 6 - Structure and naming
One codeunit per area/publisher. Name `<AFFIX> <Area> Subscribers`, place in src/EventSubscribers/.
That naming + location keeps the *.Codeunit.al boundary with object-builder mechanical. Access=Internal.

## Step 7 - Report the boundary
List every base publisher + exact event name so a reviewer can re-check after a BC upgrade.

## Common failures
| Symptom | Cause |
|---|---|
| Never runs, no error | Signature mismatch - silent binding failure |
| Base posting throws for some users | Missing SkipOnMissingLicense/Permission |
| Posting slow tenant-wide | Heavy work in a per-record subscriber |
| Tenant-wide lock waits | HTTP inside a transactional subscriber |
| Unrelated extensions break | Subscriber throws on a shared event |
