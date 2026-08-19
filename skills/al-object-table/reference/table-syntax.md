# Table Syntax Reference (loaded only when building a table)
## Skeleton
```al
table 50100 "<AFFIX> <Name>"
{
    Caption = '<Caption>'; DataClassification = CustomerContent; LookupPageId = "<AFFIX> <Name> List";
    fields
    {
        field(1; "<AFFIX> Code"; Code[20]) { Caption='Code'; DataClassification=CustomerContent; NotBlank=true; }
        field(10; "<AFFIX> Vendor No."; Code[20]) { Caption='Vendor No.'; DataClassification=CustomerContent; TableRelation=Vendor."No."; }
        field(20; "<AFFIX> Amount"; Decimal) { Caption='Amount'; DataClassification=CustomerContent; AutoFormatType=1; }
        field(30; "<AFFIX> Count"; Integer) { FieldClass=FlowField; CalcFormula=count("<AFFIX> Detail" where("Code"=field("<AFFIX> Code"))); Editable=false; }
    }
    keys { key(PK; "<AFFIX> Code") { Clustered=true; } key(ByVendor; "<AFFIX> Vendor No.") { SumIndexFields="<AFFIX> Amount"; } }
    fieldgroups { fieldgroup(DropDown; "<AFFIX> Code") { } fieldgroup(Brick; "<AFFIX> Code","<AFFIX> Amount") { } }
    trigger OnInsert() var Setup: Record "<AFFIX> Setup"; begin end;
}
```
## Data types
Code[n] Text[n] Integer Decimal Boolean Date Time DateTime Option Enum Guid BigInteger Blob Media.
## Field properties
Caption (required) · DataClassification (required) · TableRelation · NotBlank · Editable · AutoFormatType=1 (currency).
## DataClassification
CustomerContent · EndUserIdentifiableInformation · AccountData · OrganizationIdentifiableInformation · SystemMetadata.
## Triggers
OnInsert/OnModify/OnDelete/OnRename; field-level OnValidate.
## Do NOT
Omit DataClassification · add a field by creating a 2nd table (use a tableextension) · reuse a field ID.
