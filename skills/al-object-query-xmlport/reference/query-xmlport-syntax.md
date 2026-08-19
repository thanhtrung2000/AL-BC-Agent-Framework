# Query & XMLport Syntax
```al
query 50100 "<AFFIX> Vendor Spend" { QueryType=Normal; DataAccessIntent=ReadOnly;
    elements { dataitem(H; "Purch. Inv. Header") { column(VendorNo; "Buy-from Vendor No.") { } column(TotalAmount; "Amount Including VAT") { Method=Sum; } } } }
```
Every non-aggregated column joins the implicit GROUP BY. XMLport: FieldSeparator explicit; Evaluate(..,9).
