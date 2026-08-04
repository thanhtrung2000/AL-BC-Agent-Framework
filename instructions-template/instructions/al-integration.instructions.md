---
name: 'AL Integration Conventions'
description: 'Conventions for API pages, API queries, HttpClient calls, OAuth, and payload handling in Business Central'
applyTo: '**/Api/**/*.al,**/Integration/**/*.al'
---

# AL Integration Conventions

## Inbound — API pages and queries

The contract is **permanent**. `APIPublisher`, `APIGroup`, `APIVersion`,
`EntityName`, and `EntitySetName` compose the public URL:

```
/api/<publisher>/<group>/<version>/companies(<id>)/<entitySetName>
```

Once a consumer integrates, these cannot change without breaking them.

- Expose only the fields the contract requires. Every extra field is one you
  support forever and a potential data-exposure finding.
- `DelayedInsert = true` when the backing table has mandatory fields.
- `ODataKeyFields = SystemId` unless there is a stated reason otherwise.
- `Extensible = false` unless third parties are meant to extend it.
- Always expose `SystemModifiedAt` as `lastModifiedDateTime` — consumers use it
  for delta sync.
- Breaking change means a new `APIVersion`. Never remove or retype a field in
  place.
- Do not set `UsageCategory` on an API page.
- Validate every inbound payload in `OnInsertRecord` / `OnModifyRecord`. Never
  trust the caller.

⚠️ On API **queries**, every non-aggregated column forms the implicit GROUP BY.
Adding one silently changes the numbers.

## Outbound — HttpClient

Four rules, each preventing a specific production incident:

1. **Always set a timeout.** An unbounded call hangs the session.
2. **Never call HTTP inside a transaction or a record loop.** Collect, then
   call, then write. An HTTP call holding a table lock is a tenant-wide outage.
3. **Check `IsSuccessStatusCode` explicitly.** Read the body on failure and
   surface a meaningful error, not "something went wrong".
4. **Retry only 429 and 5xx**, with exponential backoff. Never retry a
   non-idempotent POST without an idempotency key.

## Credentials

- Secrets go in **Isolated Storage**. Never a table field, never `app.json`,
  never a hardcoded string, never a `Label`.
- Use `IsolatedStorage.SetEncrypted` where the platform supports it.
- Cache OAuth tokens with expiry; refresh **before** expiry, not on failure.
  Refreshing on 401 means every expiry causes one user-visible error.
- Never log a token, key, or full request header.
- Setup pages use `ExtendedDatatype = Masked` and never display the stored
  secret back to the user.

## Payloads

- `JsonObject` / `JsonToken` with an existence check on **every** field. Never
  assume a key is present.
- Convert types explicitly. A text-to-decimal failure inside a posting routine
  is a production incident, not a validation message.
- Use culture-invariant conversion — pass `9` to `Evaluate`. Decimal separators
  and date formats in payloads must not depend on the user's regional settings.

## Telemetry

- Emit `Session.LogMessage` for call start, outcome, and duration with a stable
  event ID.
- Never include payload contents or credentials in telemetry dimensions.
