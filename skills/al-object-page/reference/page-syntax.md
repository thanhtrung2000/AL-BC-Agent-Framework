# Page Syntax Reference (loaded only when building a page)
## Skeleton (List)
```al
page 50100 "<AFFIX> <Name> List"
{
    Caption='<Caption>'; PageType=List; UsageCategory=Lists; ApplicationArea=All; SourceTable="<AFFIX> <Name>"; CardPageId="<AFFIX> <Name> Card"; Editable=false;
    layout { area(Content) { repeater(Group) {
        field("<AFFIX> Code"; Rec."<AFFIX> Code") { ApplicationArea=All; ToolTip='Specifies the code.'; }
    } } area(FactBoxes) { part(Detail; "<AFFIX> Detail FactBox") { ApplicationArea=All; SubPageLink="Code"=field("<AFFIX> Code"); } } }
    actions { area(Processing) { action("<AFFIX> Process") { ApplicationArea=All; Caption='Process'; ToolTip='Runs it.'; Image=Process;
        trigger OnAction() var Mgt: Codeunit "<AFFIX> <Name> Mgt."; begin Mgt.Process(Rec); end; } } }
    trigger OnOpenPage() begin end;
}
```
## PageType
List (rows) · Card (one record) · Document (header+lines) · Worksheet (grid) · ListPart/CardPart (embedded) · RoleCenter (no UsageCategory) · API (integration-builder).
## Essentials
Every field: ApplicationArea + ToolTip. Every action: ApplicationArea+Caption+ToolTip+Image, delegate to a codeunit. Group fields in `group(Name){Caption='..';}`.
## Do NOT
Omit ApplicationArea (field won't render) · business logic in OnAction · UsageCategory on an API page/part.
