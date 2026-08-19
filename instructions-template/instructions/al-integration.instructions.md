---
name: 'al-integration'
applyTo: '**/Api/**/*.al,**/Integration/**/*.al'
---

# AL Integration Conventions
- Inbound API URL is a permanent contract. Expose only required fields; always lastModifiedDateTime; validate payloads; breaking change = new APIVersion; no UsageCategory.
- API queries: every non-aggregated column forms the implicit GROUP BY.
- Outbound: always a timeout; never HTTP in a transaction/loop; retry only 429/5xx with backoff.
- Secrets in Isolated Storage (SetEncrypted); refresh tokens before expiry; never log tokens.
