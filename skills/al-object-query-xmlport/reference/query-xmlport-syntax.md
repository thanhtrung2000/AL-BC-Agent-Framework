# Query & XMLport Syntax
```al
query 50100 "<AFFIX> Vendor Spend" { QueryType=Normal; DataAccessIntent=ReadOnly;
    elements { dataitem(H; "Purch. Inv. Header") { column(VendorNo; "Buy-from Vendor No.") { } column(TotalAmount; "Amount Including VAT") { Method=Sum; } dataitem(V; Vendor) { DataItemLink="No."=H."Buy-from Vendor No."; SqlJoinType=InnerJoin; column(vendorName; Name){ } } } } }
```
Every non-aggregated column joins the implicit GROUP BY. InnerJoin drops unmatched; LeftOuterJoin keeps. XMLport: Format=VariableText; FieldSeparator=';'; validate before insert; Evaluate(..,9).
