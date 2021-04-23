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
trigger InvoiceAdvanceTrigger on Invoice_Advance__c (before insert, before update, after insert, after update, after delete) {

    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        InvoiceAdvanceTriggerHandler.updateAmount(Trigger.isInsert, Trigger.new, Trigger.oldMap, Trigger.newMap);
    }
    if (Trigger.isAfter && Trigger.isInsert) {
        InvoiceAdvanceTriggerHandler.onInsert(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        InvoiceAdvanceTriggerHandler.updateAdvance(Trigger.oldMap, Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isDelete) {
        InvoiceAdvanceTriggerHandler.afterDelete(Trigger.old);
    }
}