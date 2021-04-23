trigger DeductionTrigger on Deduction__c (after insert, after update) {
    if (trigger.isAfter && trigger.isInsert) {
        DeductionTriggerHandler.calculateGST(Trigger.new, new Map<Id, Deduction__c>());
    }
    if (trigger.isAfter && trigger.isUpdate) {
        DeductionTriggerHandler.calculateGST(Trigger.new, trigger.oldMap);
    }
}