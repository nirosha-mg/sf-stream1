trigger CourseRegistrationTrigger on Course_Registration__c (before insert,before update,after insert) {

    if(trigger.isInsert||trigger.isUpdate && trigger.isbefore) {
      CourseRegistrationTriggerHandler.CourseRegistrationMethod(trigger.new);  
    }
    
    if(trigger.isInsert && trigger.isAfter ) {
      CourseRegistrationTriggerHandler.createB2BUser(trigger.new);  
    } 

}