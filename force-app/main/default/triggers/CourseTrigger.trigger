trigger CourseTrigger on Course__c (before Insert, before Update, after Insert, after Update) {
  if(Trigger.isAfter && Trigger.isInsert) {
      CourseTriggerHandler.afterInsert(trigger.new);
  }
  
  if(Trigger.isAfter && Trigger.isUpdate) {
      CourseTriggerHandler.afterUpdate(trigger.newMap,trigger.oldMap, trigger.new);
  }

  if(Trigger.isBefore && Trigger.isInsert) {
    CourseTriggerHandler.beforeInsert(trigger.new);
  }

  if(Trigger.isBefore && Trigger.isUpdate) {  
    CourseTriggerHandler.beforeUpdate(trigger.new, trigger.oldMap);
  }
}