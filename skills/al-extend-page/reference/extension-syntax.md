# Extension Syntax (table/page/enum/profile extensions)
```al
tableextension 50100 "<AFFIX> Vendor Ext" extends Vendor { fields { field(50100;"<AFFIX> Spend Alert Threshold";Decimal){Caption='Spend Alert Threshold';DataClassification=CustomerContent;AutoFormatType=1;} } }
pageextension 50101 "<AFFIX> Vendor Card Ext" extends "Vendor Card" { layout { addlast(General) { field("<AFFIX> Spend Alert Threshold"; Rec."<AFFIX> Spend Alert Threshold") { ApplicationArea=All; ToolTip='Specifies the threshold.'; } } } }
enumextension 50102 "<AFFIX> Pay Method Ext" extends "Payment Method" { value(50100;"<AFFIX> Crypto"){Caption='Crypto';} }
```
Field/value ID from YOUR range. Affix. If an extension of this base already exists, OVERWRITE that file with the field added — never a second `tableextension <same id> "<same name>"` (AL0264/AL0139). Long-lived anchors: General, Lines, Invoicing, Shipping, factboxes. Never remove a base control.
