# Page Syntax
```al
page 50100 "<AFFIX> <Name> List"
{
    Caption='<Caption>'; PageType=List; UsageCategory=Lists; ApplicationArea=All; SourceTable="<AFFIX> <Name>";
    layout { area(Content) { repeater(Group) { field("<AFFIX> Code"; Rec."<AFFIX> Code") { ApplicationArea=All; ToolTip='Specifies the code.'; } } } }
}
```
PageType: List Card Document Worksheet ListPart CardPart RoleCenter API. Every field: ApplicationArea+ToolTip. Actions delegate to a codeunit. Do NOT: omit ApplicationArea; logic in OnAction; two objects per file.
