# Page Syntax (loaded only when building a page)
```al
page 50100 "<AFFIX> <Name> List"
{
    Caption='<Caption>'; PageType=List; UsageCategory=Lists; ApplicationArea=All; SourceTable="<AFFIX> <Name>"; Editable=false;
    layout { area(Content) { repeater(Group) { field("<AFFIX> Code"; Rec."<AFFIX> Code") { ApplicationArea=All; ToolTip='Specifies the code.'; } } } }
    actions { area(Processing) { action("<AFFIX> Process") { ApplicationArea=All; Caption='Process'; ToolTip='Runs it.'; Image=Process; trigger OnAction() var Mgt: Codeunit "<AFFIX> <Name> Mgt."; begin Mgt.Process(Rec); end; } } }
}
```
PageType: List Card Document Worksheet ListPart CardPart RoleCenter API. Every field: ApplicationArea+ToolTip. Every action: ApplicationArea+Caption+ToolTip+Image, delegate to a codeunit.
Do NOT: omit ApplicationArea · logic in OnAction · UsageCategory on API/parts · two objects per file.
