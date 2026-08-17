---
name: al-integration-outbound
description: Build outbound HTTP integrations with timeouts, retry, status handling, JSON parsing.
---

# Outbound HTTP
Start from [HttpClientCodeunit.al.template](./templates/HttpClientCodeunit.al.template).
Four rules: (1) always a timeout; (2) never HTTP in a transaction/loop; (3) check IsSuccessStatusCode; (4) retry only 429/5xx with backoff, never a non-idempotent POST without an idempotency key. Guard every JSON field. Evaluate(..,9). Credentials → al-integration-auth.
| Symptom | Cause |
|---|---|
| Tenant-wide lock waits | HTTP inside a transaction |
