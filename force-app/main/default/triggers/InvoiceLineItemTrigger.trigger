trigger InvoiceLineItemTrigger on Invoice_Line_Item__c (after insert, after update) {
    if (trigger.isAfter && trigger.isInsert) {
        InvoiceLineItemTriggerHandler.calculateGST(Trigger.new, new Map<Id, Invoice_Line_Item__c>());
    }
    if (trigger.isAfter && trigger.isUpdate) {
        InvoiceLineItemTriggerHandler.calculateGST(Trigger.new, trigger.oldMap);
    }
}