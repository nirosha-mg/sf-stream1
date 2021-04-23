trigger ModuleTrigger on Module__c (after insert, after update) {
    if (trigger.isAfter && trigger.isInsert) {
        ModuleTriggerHandler.calculateGST(Trigger.new, new Map<Id, Module__c>());
        ModuleTriggerHandler.updateCourseModules(Trigger.newMap);
    }
    if (trigger.isAfter && trigger.isUpdate) {
        ModuleTriggerHandler.calculateGST(Trigger.new, trigger.oldMap);
        ModuleTriggerHandler.updateCourseModules(Trigger.newMap);
    }
}