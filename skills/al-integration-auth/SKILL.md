---
name: al-integration-auth
description: Handle credentials - Isolated Storage, OAuth, token caching, masked setup.
---

# Integration Auth
Start from [AuthCodeunit.al.template](./templates/AuthCodeunit.al.template). **Secrets in Isolated Storage - always** (else BLOCKER). Refresh tokens BEFORE expiry. Setup page ExtendedDatatype=Masked. Never log tokens.
