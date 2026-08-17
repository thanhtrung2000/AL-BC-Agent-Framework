---
name: al-integration-api-page
description: Build inbound API pages that let external systems read/write records over OData.
---

# Inbound API Page
Start from [ApiPage.al.template](./templates/ApiPage.al.template).
The URL is a **permanent contract**. Expose only required fields; always lastModifiedDateTime for delta sync; DelayedInsert when mandatory fields exist; validate payloads. Breaking change = new APIVersion. No UsageCategory.
| Symptom | Cause |
|---|---|
| Consumer breaks | Field removed without APIVersion bump |
