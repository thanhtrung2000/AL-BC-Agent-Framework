# Query & XMLport Syntax Reference
## Query (WARNING: every non-aggregated column joins the implicit GROUP BY)
```al
query 50100 "<AFFIX> Vendor Spend" { QueryType=Normal; DataAccessIntent=ReadOnly;
    elements { dataitem(H; "Purch. Inv. Header") {
        column(VendorNo; "Buy-from Vendor No.") { }
        column(TotalAmount; "Amount Including VAT") { Method=Sum; }
        dataitem(V; Vendor) { DataItemLink="No."=H."Buy-from Vendor No."; SqlJoinType=InnerJoin; column(vendorName; Name){ } }
    } } }
```
## XMLport (CSV import; culture-invariant parse)
```al
xmlport 50101 "<AFFIX> Vendor Import" { Format=VariableText; FieldSeparator=';'; Direction=Import; TextEncoding=UTF8;
    schema { textelement(Root) { tableelement(Buf; "<AFFIX> Buffer") {
        fieldelement(No; Buf."<AFFIX> No.") { }
        textelement(AmountText) { trigger OnAfterAssignVariable() begin if not Evaluate(Buf."<AFFIX> Amount", AmountText, 9) then Error('Bad amount'); end; }
    } } } }
```
InnerJoin drops unmatched rows; LeftOuterJoin keeps them. Validate before insert.
