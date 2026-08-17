---
name: 'AL Integration Conventions'
description: 'Conventions for API pages, API queries, HttpClient calls, OAuth, and payloads in Business Central'
applyTo: '**/Api/**/*.al,**/Integration/**/*.al'
---
# AL Integration Conventions
- Inbound API URL is a permanent contract. Expose only required fields; always lastModifiedDateTime; DelayedInsert when mandatory fields exist; validate payloads; breaking change = new APIVersion; no UsageCategory.
- API queries: every non-aggregated column forms the implicit GROUP BY.
- Outbound: always a timeout; never HTTP in a transaction/loop; check IsSuccessStatusCode; retry only 429/5xx with backoff; never retry a non-idempotent POST without an idempotency key.
- Secrets in Isolated Storage (SetEncrypted); refresh tokens before expiry; never log tokens/headers.
- Payloads: guard every field; Evaluate(..,9) culture-invariant.
