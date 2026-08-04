---
name: al-integration-outbound
description: Build outbound HTTP integrations in Business Central — HttpClient calls to external services with timeouts, retry and backoff, status handling, JSON payload parsing, and telemetry. Use when BC calls an external API.
argument-hint: [endpoint or service]
---

# Outbound HTTP Integration

For BC calling an external service.

Start from [HttpClientCodeunit.al.template](./templates/HttpClientCodeunit.al.template).

## The four rules ⭐

Each prevents a specific production incident.

### 1. Always set a timeout

```al
Client.Timeout := 30000;
```

An unbounded call hangs the user's session indefinitely.

### 2. Never call HTTP inside a transaction or a record loop

Collect → call → write. An HTTP call holding a table lock is a **tenant-wide
outage**, not a slow page.

```al
// Wrong: lock held for the duration of N network calls
if Rec.FindSet(true) then
    repeat
        CallApi(Rec);        // <-- holding a lock
        Rec.Modify();
    until Rec.Next() = 0;

// Right: gather, call, then write
CollectPayload(Rec, Payload);
Client.Send(Request, Response);
ApplyResults(Response);
```

### 3. Check `IsSuccessStatusCode` explicitly

Read the body on failure and surface a meaningful error. "Something went wrong"
is not an error message.

### 4. Retry only 429 and 5xx, with exponential backoff

```al
if StatusCode in [429, 500, 502, 503, 504] then
    Sleep(Power(2, Attempt) * 500);   // 1s, 2s, 4s
```

**Never retry a non-idempotent POST without an idempotency key** — you will
create duplicate records at the far end.

## Payload handling

Guard **every** field read:

```al
if not Source.Get('amount', Token) then exit(false);
if not Token.IsValue() then exit(false);
if Token.AsValue().IsNull() then exit(false);
```

Convert culture-invariantly:

```al
Evaluate(Result, ValueText, 9);   // 9 = invariant
```

A naive `Evaluate` returns 0 for `"1.234,50"` in a European session. Silent
wrong amounts, no error.

## Telemetry

```al
Session.LogMessage('<AFFIX>-INT-0001', 'Outbound call', Verbosity::Normal,
    DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, Dimensions);
```

Log endpoint, status code, duration, success. **Never** log payload contents or
credentials.

## Credentials

Not this skill. Secrets and OAuth belong to `al-integration-auth`. Call
`GetAccessToken()` and let that skill own the storage.

## Common failures

| Symptom | Cause |
|---|---|
| Session hangs | No timeout on `HttpClient` |
| Tenant-wide lock waits | HTTP call inside a transaction |
| Duplicate records at the far end | POST retried without an idempotency key |
| Wrong amounts from a partner | Culture-dependent decimal parsing |
| Cannot diagnose a failure | No telemetry, or error swallowed |
