# Extension Syntax Reference (table/page/enum/profile extensions)
## Table extension — add fields to a base table
```al
tableextension 50100 "<AFFIX> Vendor Ext" extends Vendor { fields { field(50100; "<AFFIX> Spend Alert Threshold"; Decimal) { Caption='Spend Alert Threshold'; DataClassification=CustomerContent; AutoFormatType=1; } } }
```
Field ID from YOUR range. Affix. DataClassification. If an extension of this base already exists, add the field INSIDE it — never a second `tableextension <same id> "<same name>"` (AL0264/AL0139).
## Page extension — anchor to a stable group
```al
pageextension 50101 "<AFFIX> Vendor Card Ext" extends "Vendor Card" { layout { addlast(General) { field("<AFFIX> Spend Alert Threshold"; Rec."<AFFIX> Spend Alert Threshold") { ApplicationArea=All; ToolTip='Specifies the threshold.'; } } } }
```
Prefer addlast(<long-lived group>): General, Lines, Invoicing, Shipping, factboxes. Never remove a base control.
## Enum extension
```al
enumextension 50102 "<AFFIX> Pay Method Ext" extends "Payment Method" { value(50100; "<AFFIX> Crypto") { Caption='Crypto'; } }
```
Base enum must be Extensible=true. Value ID from your range. If the base enum implements an interface, supply Implementation.
## Profile extension (pairs with a pagecustomization)
```al
profileextension "<AFFIX> BM Ext" extends "BUSINESS MANAGER" { Caption='Business Manager (<Publisher>)'; }
```
