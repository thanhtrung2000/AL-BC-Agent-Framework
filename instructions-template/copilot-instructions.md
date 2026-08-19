<!-- conventions-version: 1.0.0 (framework-owned; safe to overwrite on update) -->
# AL Development Conventions — Business Central
Always-on conventions applied to every Copilot request in this repository.

> Project settings (affix, ID range, publisher) live in `.github/al-setup.md`. This
> file is framework-owned and overwritten on each update — no project values here.

## Naming
Affix on every object, field, action, group, control. `<AFFIX> <Descriptive Name>`.
Role codeunits end in Mgt./Handler/Factory/Impl. Subscriber codeunits end in Subscribers.
## Object IDs
Only from the production range in al-setup.md. Never reuse an ID. Test objects use the test range.
## Data & schema
DataClassification on every table and field (release blocker). TableRelation on lookups.
Keys for the dominant filter pattern; SumIndexFields for aggregation. FlowField over stored where derivable.
## Pages
ApplicationArea on every field/action or it will not render. UsageCategory for searchable pages.
ToolTip starting "Specifies ". Actions delegate to a codeunit.
## Codeunits
Single responsibility. Publish [IntegrationEvent] at extension points. SetLoadFields before FindSet.
Never HTTP in a loop/transaction. Never Commit in a loop/TryFunction.
## Security
Secrets in Isolated Storage. Every object needs a permission set entry.
## What NOT to re-check (analyzers own these)
CodeCop, UICop, AppSourceCop, PerTenantExtensionCop. Enable all four in .vscode/settings.json.
## Style
Four spaces. begin/end own lines. Public procedures before local.
