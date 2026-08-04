---
name: al-integration-auth
description: Handle credentials and authentication for Business Central integrations — Isolated Storage for secrets, OAuth 2.0 client credentials and authorization code flows, token caching with expiry, and setup pages for credential entry. Use whenever an integration needs a secret.
argument-hint: [auth scheme] [service]
---

# Integration Authentication

For anything involving a secret: API keys, OAuth tokens, client secrets,
certificates.

Start from [AuthCodeunit.al.template](./templates/AuthCodeunit.al.template).

## The absolute rule ⭐

**Secrets go in Isolated Storage. Always.**

Never a table field. Never `app.json`. Never a hardcoded string. Never a
`Label`. If the plan asks for anything else, refuse and flag it as a **BLOCKER**
in your output.

```al
IsolatedStorage.SetEncrypted(TokenKeyTok, Secret, DataScope::Company);
```

| Scope | Use for |
|---|---|
| `DataScope::Company` | Per-company credentials — the usual choice |
| `DataScope::CompanyAndUser` | Per-user OAuth tokens |
| `DataScope::Module` | Shared across all companies in the extension |

Use `SetEncrypted` where the platform supports it. Plain `Set` only for
non-sensitive configuration.

## OAuth 2.0 client credentials

For service-to-service calls with no user present.

1. POST to the token endpoint with `client_id`, `client_secret`, `scope`,
   `grant_type=client_credentials`
2. Read `access_token` and `expires_in`
3. **Cache the token with its expiry**
4. Refresh **before** expiry, not on 401

```al
if (CachedToken <> '') and (CurrentDateTime() < TokenExpiry - 60000) then
    exit(CachedToken);   // 60s safety margin
```

Refreshing on failure means every token expiry causes one user-visible error.

## OAuth 2.0 authorization code

For calls made on behalf of a signed-in user. Use the platform's
`OAuth2` codeunit rather than hand-rolling the redirect flow — it handles the
browser round trip and PKCE correctly.

Store the **refresh token** in Isolated Storage with
`DataScope::CompanyAndUser`.

## Setup page

Credentials need somewhere to be entered:

- A setup page with `ExtendedDatatype = Masked` on the secret field
- The field is **not** bound to a table column — it writes to Isolated Storage
  in `OnValidate` and shows a placeholder when a value exists
- Never display the stored secret back to the user

```al
field(ClientSecret; ClientSecretMask)
{
    ExtendedDatatype = Masked;
    trigger OnValidate()
    begin
        AuthMgt.SetClientSecret(ClientSecretMask);
        ClientSecretMask := '***';
    end;
}
```

## Never log

Tokens, keys, client secrets, full request headers, or `Authorization` values.
Not in telemetry, not in error messages, not in a log table.

## Common failures

| Symptom | Cause |
|---|---|
| Security review blocker | Secret stored in a table field |
| One error per hour, then works | Token refreshed on failure instead of before expiry |
| Secret visible to users | Setup page displays the stored value |
| Credentials leak into telemetry | Full headers logged |
| Works for one company only | Wrong `DataScope` |
