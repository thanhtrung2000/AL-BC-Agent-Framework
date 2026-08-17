# AL Development Conventions — Business Central
Always-on. Installed by the al-bc-framework plugin.

## SETUP — FILL THIS IN BEFORE FIRST USE
```
AFFIX / PREFIX      : <e.g. VSA>
PRODUCTION ID RANGE : <e.g. 50000..50099>
TEST ID RANGE       : <e.g. 50100..50149>
TARGET BC VERSION   : <e.g. 26.0>
PUBLISHER           : <e.g. Contoso>
```
If any placeholder remains, agents return NEEDS_SETUP. A wrong ID range compiles fine and fails AppSourceCop at release.

## Naming
Affix on every object/field/action/control. Role codeunits end in Mgt./Handler/Factory/Impl. Subscriber codeunits end in Subscribers.
## Object IDs
Only from the production range. Never reuse. Test objects in the test range.
## Data & schema
DataClassification on every table and field (release blocker). TableRelation on lookups. Keys for the dominant filter pattern. FlowField over stored where derivable.
## Pages
ApplicationArea on every field/action. UsageCategory for searchable pages. ToolTip "Specifies ". Actions delegate to a codeunit.
## Codeunits
Single responsibility. Publish [IntegrationEvent] at extension points. SetLoadFields before FindSet. Never HTTP in a transaction/loop. Never Commit in a loop/TryFunction.
## Security
Secrets in Isolated Storage. Every object needs a permission entry.
## What NOT to re-check (analyzers own these)
CodeCop, UICop, AppSourceCop, PerTenantExtensionCop. Enable all four in .vscode/settings.json.
## Style
Four spaces. begin/end own lines. Public procedures before local.
