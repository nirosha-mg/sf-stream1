trigger InvoiceDiscountTrigger on Invoice_Discount__c (after insert, after update) {
    if (trigger.isAfter && trigger.isInsert) {
        InvoiceDiscountTriggerHandler.calculateGST(Trigger.new, new Map<Id, Invoice_Discount__c>());
    }
    if (trigger.isAfter && trigger.isUpdate) {
        InvoiceDiscountTriggerHandler.calculateGST(Trigger.new, trigger.oldMap);
    }
}