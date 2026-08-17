<!-- conventions-version: 2.2.0  (framework-owned; safe to overwrite on update) -->
# AL Development Conventions — Business Central
Always-on conventions applied to every Copilot request in this repository.

> Project settings (affix, ID range, publisher) live in `.github/al-setup.md`.
> This file is framework-owned and is overwritten on each framework update — do
> not put project values here.

## Naming
Affix on every object, field, action, group, control. `<AFFIX> <Descriptive Name>`.
Role codeunits end in Mgt./Handler/Factory/Impl. Subscriber codeunits end in Subscribers.

## Object IDs
Only from the production range in al-setup.md. Never reuse an ID. Test objects use the test range.

## Data & schema
DataClassification on every table and field (release blocker if missing).
TableRelation on every lookup field. Keys for the dominant filter pattern; SumIndexFields for aggregation.
Prefer a FlowField over a stored field where the value is derivable.

## Pages
ApplicationArea on every field and action, or it does not render at runtime.
UsageCategory on every searchable page. ToolTip starting "Specifies ". Actions delegate to a codeunit.

## Codeunits
Single responsibility. Publish [IntegrationEvent] at extension points. IsHandled pattern.
SetLoadFields before FindSet on wide tables. Never HTTP in a loop/transaction. Never Commit in a loop/TryFunction.

## Errors & text
Every user-facing string is a Label with a Comment when parameterised. Errors state what went wrong AND what to do next.

## Security
Secrets go in Isolated Storage — never a table field, app.json, or a literal. Never log tokens.
Every new object needs a permission set entry, or non-SUPER users hit a runtime error never seen in dev.

## What NOT to re-check (the AL analyzers own these)
CodeCop, UICop, AppSourceCop, PerTenantExtensionCop. Enable all four in .vscode/settings.json.

## Style
Four spaces, no tabs. begin/end on their own lines. One statement per line. Public procedures before local.
