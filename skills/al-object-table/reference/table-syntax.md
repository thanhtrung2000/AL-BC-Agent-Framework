# Table Syntax
```al
table 50100 "<AFFIX> <Name>"
{
    Caption='<Caption>'; DataClassification=CustomerContent; LookupPageId="<AFFIX> <Name> List";
    fields { field(1;"<AFFIX> Code";Code[20]){Caption='Code';DataClassification=CustomerContent;NotBlank=true;} }
    keys { key(PK;"<AFFIX> Code"){Clustered=true;} }
}
```
Types: Code[n] Text[n] Integer Decimal Boolean Date DateTime Option Enum Guid Blob Media. DataClassification required. Do NOT: omit DataClassification; add a field via a 2nd table; two objects per file.
