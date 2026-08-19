---
name: al-integration-outbound
description: Build outbound HTTP integrations with timeouts, retry, JSON parsing.
---

# Outbound HTTP
Start from [HttpClientCodeunit.al.template](./templates/HttpClientCodeunit.al.template). Always a timeout; never HTTP in a transaction/loop; check IsSuccessStatusCode; retry only 429/5xx with backoff. Guard every JSON field. Evaluate(..,9).
