public without sharing class ContentDocumentTriggerHandler {
    public static void AllowSharingToCommunity(List<ContentDocumentLink> cdlList) {
        //Allow Sharing for Invoice, Receipt, and Registration
        for (ContentDocumentLink cdl : cdlList) {
            Id linkedEntityId = cdl.LinkedEntityId;
            if (linkedEntityId.getSobjectType() == Invoice__c.getSObjectType() ||
                linkedEntityId.getSobjectType() == Course_Registration__c.getSObjectType() ||
                linkedEntityId.getSobjectType() == Receipt__c.getSObjectType()) {
                cdl.Visibility = 'AllUsers';
                cdl.ShareType = 'V';
            }
        }
    }
}