trigger ContentVersionTrigger on ContentVersion (After Insert, After Update) {
    if(trigger.isInsert && trigger.isAfter) {
        ContentVersionTriggerHandler.afterInsert(trigger.new);
    }
    if(trigger.isUpdate && trigger.isAfter) {
        ContentVersionTriggerHandler.afterUpdate(trigger.new);
    }
}