---
name: al-api
description: Create an API page, an API query, or an outbound HTTP integration for Business Central.
argument-hint: [inbound|outbound] [entity or endpoint]
agent: al-implementer
---

Create an integration for Business Central.

**Direction:** ${input:direction:inbound (someone calls BC) | outbound (BC calls someone)}
**Entity or endpoint:** ${input:target:e.g. vendorSpendStatistics, or https://api.partner.com/v1/invoices}
**Consumer or provider:** ${input:consumer:Who calls this, or what we are calling}

Route to `al-integration-builder`. It will classify the sub-type — API page,
API query, outbound, or auth — and load the matching skill. Require it to:

**If inbound:**
- State the resulting URL:
  `/api/<publisher>/<group>/<version>/companies(<id>)/<entitySetName>`
- Expose only the fields the contract requires — every extra field is supported
  forever.
- Expose `lastModifiedDateTime` so consumers can do delta sync.
- Set `DelayedInsert = true` if the backing table has mandatory fields.
- Validate the payload in `OnInsertRecord` / `OnModifyRecord`.

**If outbound:**
- Set a timeout on every `HttpClient`.
- Never call HTTP inside a transaction or a record loop.
- Check `IsSuccessStatusCode` explicitly and surface a meaningful error.
- Retry only 429 and 5xx with exponential backoff.
- Store every secret in Isolated Storage — never a table field.
- Parse decimals culture-invariantly with `Evaluate(..., 9)`.

If an API spec URL exists, fetch and follow it. If the contract is ambiguous,
stop and ask me rather than inventing field names.
