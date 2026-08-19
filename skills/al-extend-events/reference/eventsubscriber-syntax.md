# Event Subscriber Syntax
```al
codeunit 50100 "<AFFIX> Sales Subscribers"
{
    Access = Internal;
    var Mgt: Codeunit "<AFFIX> Sales Mgt.";
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', true, true)]
    local procedure OnAfterPost(var SalesHeader: Record "Sales Header"; SalesInvHeader: Record "Sales Invoice Header")
    begin Mgt.Handle(SalesInvHeader); end;
}
```
Last two bools: SkipOnMissingLicense, SkipOnMissingPermission. Never hand-write a signature; use the event recorder. Never HTTP in a transactional subscriber.
