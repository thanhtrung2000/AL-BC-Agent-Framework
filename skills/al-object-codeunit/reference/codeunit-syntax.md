# Codeunit Syntax Reference (loaded only when building a codeunit)
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
## Procedure forms
`procedure P()` public · `local procedure P()` internal-to-codeunit · `internal procedure P()` same-app · params by value or `var` (by reference) · return type after `()`.
## var section — Name: Type; ONLY
`Rec: Record Customer;` · `Buf: Record "X" temporary;` · `Mgt: Codeunit "Y";` · `i: Integer;` · `Amount: Decimal;` · `D: Date;` · `Txt: Text[100];` · `Ok: Boolean;` · `Lbl: Label 'msg';` · `Dict: Dictionary of [Code[20], Decimal];`
## Integration event
```al
[IntegrationEvent(false, false)] local procedure OnBefore(var Rec: Record "X"; var IsHandled: Boolean) begin end;
// call: OnBefore(Rec, IsHandled); if IsHandled then exit;
```
## Statement patterns
Loop: `if Rec.FindSet() then repeat ... until Rec.Next()=0;` · if/else · `case Type of Type::A: DoA(); else DoDefault(); end;` · errors via Label: `Error(Err, x);` `Message(Msg, y);` `if not Confirm(Q,false,n) then exit;` · `[TryFunction]` returns Boolean.
## Do NOT
Statement in var · undeclared variable in begin · Commit in a loop/TryFunction · HTTP in a transaction/loop.
