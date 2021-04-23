trigger CourseRunTrigger on Course_Run__c (after insert) {
    if (Trigger.isAfter && Trigger.isInsert) {
        CourseRunTriggerHandler.generateCourseCode(Trigger.new);
    }
}