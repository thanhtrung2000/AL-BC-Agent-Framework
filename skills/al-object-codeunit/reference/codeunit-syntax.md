# Codeunit Syntax (loaded only when building a codeunit)
## Skeleton
```al
codeunit 50100 "<AFFIX> <Name> Mgt."
{
    Access = Internal;
    var
        GlobalRec: Record "<AFFIX> <Table>";
        MsgTxt: Label 'Done %1', Comment = '%1 = value';
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
## var — Name: Type; ONLY
`Rec: Record Customer;` `Buf: Record "X" temporary;` `Mgt: Codeunit "Y";` `i: Integer;` `Amount: Decimal;` `D: Date;` `Txt: Text[100];` `Ok: Boolean;` `Lbl: Label 'm';`
## Integration event
`[IntegrationEvent(false, false)] local procedure OnBefore(var Rec: Record "X"; var IsHandled: Boolean) begin end;` — call: `OnBefore(Rec, IsHandled); if IsHandled then exit;`
## Patterns
loop `if Rec.FindSet() then repeat ... until Rec.Next()=0;` · `case T of T::A: DoA(); else DoDefault(); end;` · `Error(Err,x); Message(Msg,y);` · `[TryFunction]` returns Boolean.
## Do NOT
Statement in var · undeclared variable in begin · Commit in a loop/TryFunction · HTTP in a transaction/loop · two objects in one file.
