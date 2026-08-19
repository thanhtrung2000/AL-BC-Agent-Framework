# Event Subscriber Syntax Reference
## The subscriber codeunit (THIN dispatcher)
```al
codeunit 50100 "<AFFIX> Sales Subscribers"
{
    Access = Internal;
    var Mgt: Codeunit "<AFFIX> Sales Mgt.";
    // Last two bools: SkipOnMissingLicense, SkipOnMissingPermission.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', true, true)]
    local procedure OnAfterPost(var SalesHeader: Record "Sales Header"; SalesInvHeader: Record "Sales Invoice Header")
    begin
        Mgt.Handle(SalesInvHeader);   // do NOT throw unless posting MUST block
    end;
    // Table trigger event - fires per record; guard temp
    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterCustInsert(var Rec: Record Customer; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then exit;
        Mgt.DefaultSettings(Rec);
    end;
    // Field OnAfterValidate - element name (4th arg) is the FIELD
    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterValidateEvent', 'Credit Limit (LCY)', true, true)]
    local procedure OnAfterValidateLimit(var Rec: Record Customer; var xRec: Record Customer)
    begin
        Mgt.Recalc(Rec);
    end;
    // OnBefore + IsHandled - conditionally replace base logic
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"<Base>", 'OnBeforeDo', '', true, true)]
    local procedure OnBeforeDo(var Rec: Record "<T>"; var IsHandled: Boolean)
    begin
        if not Mgt.ShouldOverride(Rec) then exit;
        Mgt.DoInstead(Rec); IsHandled := true;
    end;
}
```
Never hand-write a signature from memory — use the event recorder; a mismatch binds to nothing.
Never call HTTP inside a transactional subscriber — enqueue and defer.
