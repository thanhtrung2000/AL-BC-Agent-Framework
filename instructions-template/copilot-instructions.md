# AL Development Conventions — Business Central

Always-on instructions for this repository. Applied to every Copilot request.

Installed by the `al-bc-framework` plugin. Re-run
`/al-bc-framework:al-framework-setup` to reinstall or verify.

---

## SETUP — FILL THIS IN BEFORE FIRST USE

The framework cannot work until these five values are filled in. Replace every
`<...>` placeholder.

```
AFFIX / PREFIX      : <e.g. VSA>
PRODUCTION ID RANGE : <e.g. 50000..50099>   (must match idRanges in app.json)
TEST ID RANGE       : <e.g. 50100..50149>   (must sit OUTSIDE production range)
TARGET BC VERSION   : <e.g. 26.0>           (must match application in app.json)
PUBLISHER           : <e.g. Contoso>
```

| Value | Where to find it |
|---|---|
| ID ranges | `app.json` → `idRanges` |
| Target version | `app.json` → `application` |
| Publisher | `app.json` → `publisher` |
| Affix | Your team standard. For AppSource, registered with Microsoft |

The setup script prints the detected values — run it and copy them across.

If any placeholder remains, agents return `NEEDS_SETUP` rather than guessing.
This is intentional: a wrong object ID range compiles fine, passes review, and
fails AppSourceCop at release.

---

## Naming

- Every object, field, action, group, and control this extension adds carries
  the affix. On extension objects AppSourceCop enforces it, and it prevents
  real collisions with other ISVs.
- Object names use `<AFFIX> <Descriptive Name>`, e.g. `VSA Spend Setup`.
- Codeunits describing a role end with a role word: `Mgt.`, `Handler`,
  `Factory`, `Impl.`
- Variables use PascalCase and name the thing, not the type:
  `VendorLedgerEntry`, not `Rec2`.
- Never abbreviate beyond the base application's own conventions.

## Object IDs

- Allocate only from the production range declared above.
- Never reuse an ID. Never invent a range.
- Test objects use the test range and live in a separate test app.

## Data and schema

- `DataClassification` is required on every table and every field. Missing
  values block release. Choose deliberately — do not copy-paste
  `CustomerContent` onto system metadata.
- `TableRelation` on every field pointing at another table.
- Define keys for the dominant filter pattern, not just the primary key. Every
  additional key costs write throughput — justify each one.
- Prefer a FlowField over a stored field when the value is derivable. Stored
  duplicates drift out of sync and cost upgrade effort.

## Pages

- `ApplicationArea` on every field and action, or the control does not render
  at runtime.
- `UsageCategory` on every page a user should be able to search for.
- `ToolTip` on every field, starting with "Specifies ".
- Actions delegate to a codeunit. Business logic never lives in `OnAction`.

## Codeunits and logic

- Single responsibility. If the name needs more than five words, split it.
- Publish `[IntegrationEvent]` at extension points instead of hardcoding
  branches — that is what lets other extensions adapt without forking.
- Use the `IsHandled` pattern on any procedure a consumer may need to override.
- `SetLoadFields` before `FindSet` on wide tables — cloud SQL charges for every
  column returned.
- Never call HTTP inside a database transaction or inside a record loop.
- Never place `Commit` inside a loop or inside a `TryFunction` context.

## Errors and text

- Every user-facing string is a `Label` with a `Comment` when parameterised.
  Never inline a literal in `Error`, `Message`, or `Confirm`.
- Error messages state what went wrong **and** what the user should do next.
- Use `ErrorInfo` with actions where a fix can be offered inline.

## Security

- Secrets go in Isolated Storage. Never a table field, never `app.json`, never
  a hardcoded string.
- Never log tokens, keys, or full request headers.
- Every new object needs a permission set entry, or non-SUPER users hit a
  runtime error that never appears in developer testing.

## What NOT to state in generated output or review

The AL Code Analyzers already enforce the following. Do not spend context
re-checking them, and do not report them as findings:

- **CodeCop** — naming casing, unused variables, missing `Caption`
- **UICop** — `ApplicationArea`, `ToolTip`, page control rules
- **AppSourceCop** — affix compliance, ID range, breaking schema changes
- **PerTenantExtensionCop** — per-tenant restrictions

Enable all four in `.vscode/settings.json` under `al.codeAnalyzers`.

## Style

- Four spaces, no tabs.
- `begin`/`end` on their own lines.
- One statement per line.
- Group related procedures; public procedures before local ones.
