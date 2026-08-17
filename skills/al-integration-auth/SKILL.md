---
name: al-integration-auth
description: Handle credentials - Isolated Storage, OAuth 2.0, token caching, masked setup.
---

# Integration Auth
Start from [AuthCodeunit.al.template](./templates/AuthCodeunit.al.template).
**Secrets in Isolated Storage - always** (refuse otherwise as a BLOCKER). SetEncrypted. Cache tokens with expiry, **refresh BEFORE expiry not on 401**. Setup page ExtendedDatatype=Masked. Never log tokens/keys/headers.
| Symptom | Cause |
|---|---|
| Security blocker | Secret in a table field |
