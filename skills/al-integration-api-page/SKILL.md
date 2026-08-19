---
name: al-integration-api-page
description: Build inbound API pages over OData.
---

# Inbound API Page
Start from [ApiPage.al.template](./templates/ApiPage.al.template). URL is a permanent contract. Expose only required fields; always lastModifiedDateTime; DelayedInsert when mandatory fields exist; validate payloads. Breaking change = new APIVersion. No UsageCategory.
