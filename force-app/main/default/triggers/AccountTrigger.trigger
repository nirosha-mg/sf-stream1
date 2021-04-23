trigger AccountTrigger on Account (after insert) {
    if (trigger.isAfter && trigger.isInsert) {
        //Disable until Azure B2C is ready
        AccountTriggerHandler.createSSOUser(trigger.new);
    }
}