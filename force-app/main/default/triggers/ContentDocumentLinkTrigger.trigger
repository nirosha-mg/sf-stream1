trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        ContentDocumentTriggerHandler.AllowSharingToCommunity(Trigger.new);
    }
}