# Codeunit Syntax (loaded only when building a codeunit)
```al
codeunit 50100 "<AFFIX> <Name> Mgt."
{
    Access = Internal;
    var
        GlobalRec: Record "<AFFIX> <Table>";
    procedure DoWork(VendorNo: Code[20]): Decimal
    var
        PurchInvLine: Record "Purch. Inv. Line";
        Total: Decimal;
    begin
        PurchInvLine.SetRange("Buy-from Vendor No.", VendorNo);
        if PurchInvLine.FindSet() then repeat Total += PurchInvLine.Amount; until PurchInvLine.Next() = 0;
        exit(Total);
    end;
}
```
var — Name: Type; ONLY. Integration event: `[IntegrationEvent(false, false)] local procedure OnX(...) begin end;`. Do NOT: statement in var; undeclared variable in begin; Commit in a loop/TryFunction; two objects per file.
