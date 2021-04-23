trigger DiscountTrigger on Discount__c (after insert, after update) {
    if (trigger.isAfter && trigger.isInsert) {
        DiscountTriggerHandler.calculateGST(Trigger.new, new Map<Id, Discount__c>());
    }
    if (trigger.isAfter && trigger.isUpdate) {
        DiscountTriggerHandler.calculateGST(Trigger.new, trigger.oldMap);
    }
}