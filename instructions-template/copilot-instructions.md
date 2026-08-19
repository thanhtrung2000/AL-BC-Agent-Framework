<!-- conventions-version: 1.0.0 -->
# AL Development Conventions — Business Central
Always-on conventions for every Copilot request.
> Project settings live in `.github/al-setup.md` (framework never overwrites it).
## Naming
Affix on every object/field/action/control. Role codeunits end Mgt./Handler/Factory/Impl.
## Object IDs
Only from the production range. Never reuse an ID.
## Data & schema
DataClassification on every table and field (release blocker). TableRelation on lookups. FlowField over stored where derivable.
## Pages
ApplicationArea on every field/action or it won't render. UsageCategory for searchable pages. ToolTip "Specifies ". Actions delegate to a codeunit.
## Codeunits
Single responsibility. Publish [IntegrationEvent] at extension points. SetLoadFields before FindSet. Never HTTP in a loop/transaction. Never Commit in a loop/TryFunction.
## Reports
Report objects DEFINE their layout reference by a deterministic name; the layout FILE is generated separately by al-report-rdlc-layout only when a picture/description is provided.
## Security
Secrets in Isolated Storage. Every object needs a permission set entry.
## What NOT to re-check (analyzers own these)
CodeCop, UICop, AppSourceCop, PerTenantExtensionCop.
## Style
Four spaces. begin/end own lines. Public procedures before local.
