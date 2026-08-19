---
name: al-integration-outbound
description: Build outbound HTTP integrations.
---

# Outbound HTTP
Start from [HttpClientCodeunit.al.template](./templates/HttpClientCodeunit.al.template). Always a timeout; never HTTP in a transaction/loop; retry only 429/5xx. Evaluate(..,9).
