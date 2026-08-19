# Table Syntax (loaded only when building a table)
```al
table 50100 "<AFFIX> <Name>"
{
    Caption='<Caption>'; DataClassification=CustomerContent; LookupPageId="<AFFIX> <Name> List";
    fields
    {
        field(1;"<AFFIX> Code";Code[20]){Caption='Code';DataClassification=CustomerContent;NotBlank=true;}
        field(20;"<AFFIX> Amount";Decimal){Caption='Amount';DataClassification=CustomerContent;AutoFormatType=1;}
    }
    keys { key(PK;"<AFFIX> Code"){Clustered=true;} }
    fieldgroups { fieldgroup(DropDown;"<AFFIX> Code"){} fieldgroup(Brick;"<AFFIX> Code","<AFFIX> Amount"){} }
}
```
Types: Code[n] Text[n] Integer Decimal Boolean Date DateTime Option Enum Guid Blob Media.
DataClassification (required): CustomerContent · EndUserIdentifiableInformation · AccountData · OrganizationIdentifiableInformation · SystemMetadata.
Triggers: OnInsert/OnModify/OnDelete/OnRename; field OnValidate. FlowField: FieldClass=FlowField; CalcFormula=count(...).
Do NOT: omit DataClassification · add a field by creating a 2nd table (use a tableextension) · reuse a field ID · two objects per file.
