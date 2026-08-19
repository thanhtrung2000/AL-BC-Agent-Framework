# Extension Syntax (table/page/enum/profile)
```al
tableextension 50100 "<AFFIX> Vendor Ext" extends Vendor { fields { field(50100;"<AFFIX> Threshold";Decimal){Caption='Threshold';DataClassification=CustomerContent;} } }
pageextension 50101 "<AFFIX> Vendor Card Ext" extends "Vendor Card" { layout { addlast(General) { field("<AFFIX> Threshold"; Rec."<AFFIX> Threshold") { ApplicationArea=All; ToolTip='Specifies.'; } } } }
```
Field/value ID from YOUR range. If an extension of this base already exists, OVERWRITE that file with the field added — never a second `tableextension <same id> "<same name>"` (AL0264/AL0139). Never remove a base control.
