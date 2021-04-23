/**
 * @description       : 
 * @author            : Mark Alvin Tayag (mtayag@salesforce.com)
 * @group             : 
 * @last modified on  : 11-13-2020
 * @last modified by  : Mark Alvin Tayag (mtayag@salesforce.com)
 * Modifications Log 
 * Ver   Date         Author                                     Modification
 * 1.0   11-12-2020   Mark Alvin Tayag (mtayag@salesforce.com)   Initial Version
**/
public without sharing class InvoiceAdvanceTriggerHandler {

    public static void updateAmount(Boolean isInsert, List<Invoice_Advance__c> advList, Map<Id, Invoice_Advance__c> mapOldAdvList, Map<Id, Invoice_Advance__c> mapNewAdvList) {
        List<Invoice_Advance__c> invAdvList = new List<Invoice_Advance__c>();
        Map<Id, Invoice_Advance__c> invAdvMap = new Map<Id, Invoice_Advance__c>();

        for (Invoice_Advance__c invAdv : [SELECT Id, Invoice_Line_Item__r.Invoice__c, Advance__c, Advance__r.Amount__c, Advance__r.GST_Amount__c, Advance__r.GST_Code__c FROM Invoice_Advance__c WHERE Id =: mapNewAdvList.keySet()]) {

            if (!isInsert) {
                Invoice_Advance__c oldInvAdv = mapOldAdvList.get(invAdv.Id);
    
                if (oldInvAdv.Advance__c == invAdv.Advance__c) {
                    break;
                }
            }
            invAdv.Invoice__c = invAdv.Invoice_Line_Item__r.Invoice__c;
            invAdv.Amount__c = invAdv.Advance__r.Amount__c;
            invAdv.GST_Amount__c = invAdv.Advance__r.GST_Amount__c;
            invAdv.GST_Code__c = invAdv.Advance__r.GST_Code__c;
            invAdv.Previous_Advance__c = invAdv.Advance__c;
            invAdvList.add(invAdv);
        }

        if (invAdvList.size() > 0) {
            update invAdvList;
        }
    }

    public static void onInsert(List<Invoice_Advance__c> advList) {
        List<Id> advances = new List<Id>();
        for (Invoice_Advance__c invAdv : advList) {
            advances.add(invAdv.Advance__c);
        }

        if (advances.size() > 0) {
            updateAdvanceOnInsert(advances);
        }
    }

    @future
    public static void updateAdvanceOnInsert(List<Id> advanceIds) {
        List<Advance__c> advances = new List<Advance__c>();
        for (Id advanceId : advanceIds) {
            Advance__c advanceNew = new Advance__c();
            advanceNew.Id = advanceId;
            advanceNew.Status__c = 'In Use';

            advances.add(advanceNew);
        }

        if (advances.size() > 0) {
            update advances;
        }
    }

    public static void updateAdvance(Map<Id, Invoice_Advance__c> oldMap, List<Invoice_Advance__c> advList) {
        
        List<Advance__c> advances = new List<Advance__c>();
        for (Invoice_Advance__c invAdv : advList) {
            Invoice_Advance__c oldAdv = oldMap.get(invAdv.Id);
            if (invAdv.Advance__c != oldAdv.Advance__c) {
                Advance__c advance = new Advance__c();
                advance.Id = oldAdv.Advance__c;
                advance.Status__c = 'New';

                advances.add(advance);

                Advance__c advanceNew = new Advance__c();
                advanceNew.Id = invAdv.Advance__c;
                advanceNew.Status__c = 'In Use';

                advances.add(advanceNew);
            }
        }

        if (advances.size() > 0) {
            update advances;
        }
    }

    //Release Advance
    public static void afterDelete(List<Invoice_Advance__c> advList) {
        List<Advance__c> advances = new List<Advance__c>();
        for (Invoice_Advance__c invAdv : advList) {
            Advance__c adv = new Advance__c();
            adv.Id = invAdv.Advance__c;
            adv.Status__c = 'New';
            advances.add(adv);
        }
        update advances;
    }
}