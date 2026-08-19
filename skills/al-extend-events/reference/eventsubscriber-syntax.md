# Event Subscriber Syntax
```al
codeunit 50100 "<AFFIX> Sales Subscribers"
{
    Access = Internal;
    var Mgt: Codeunit "<AFFIX> Sales Mgt.";
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', true, true)]
    local procedure OnAfterPost(var SalesHeader: Record "Sales Header"; SalesInvHeader: Record "Sales Invoice Header")
    begin Mgt.Handle(SalesInvHeader); end;
    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterCustInsert(var Rec: Record Customer; RunTrigger: Boolean)
    begin if Rec.IsTemporary() then exit; Mgt.DefaultSettings(Rec); end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"<Base>", 'OnBeforeDo', '', true, true)]
    local procedure OnBeforeDo(var Rec: Record "<T>"; var IsHandled: Boolean)
    begin if not Mgt.ShouldOverride(Rec) then exit; Mgt.DoInstead(Rec); IsHandled := true; end;
}
```
Last two bools: SkipOnMissingLicense, SkipOnMissingPermission. Field OnAfterValidate: element name (4th arg) is the FIELD. Never hand-write a signature; use the event recorder. Never HTTP in a transactional subscriber — enqueue and defer.
