/**
 * @description       : 
 * @author            : Mark Alvin Tayag (mtayag@salesforce.com)
 * @group             : 
 * @last modified on  : 10-31-2020
 * @last modified by  : Mark Alvin Tayag (mtayag@salesforce.com)
 * Modifications Log 
 * Ver   Date         Author                                     Modification
 * 1.0   10-31-2020   Mark Alvin Tayag (mtayag@salesforce.com)   Initial Version
**/
public without sharing class SSOQueueable implements Queueable, Database.AllowsCallouts {
    public List<String> userIds = new List<String>();
    public SSOQueueable(List<String> userIds) {
        this.userIds = userIds;
    }

    public void execute(QueueableContext context) {
        executeJob();
    }

    public void executeJob() {

        List<Id> userIdsToProcess = new List<Id>();
        List<Id> userIdsToQueue = new List<Id>();

        for (Integer i = 0; i < userIds.size(); i++) {
            if (i < 50) {
                userIdsToProcess.add(userIds[i]);
            }
            else {
                userIdsToQueue.add(userIds[i]);
            }
        }
        if (userIdsToProcess.size() > 0) {
            SSOHandler.createUser(userIdsToProcess);
        } 

        if (userIdsToQueue.size() > 0) {
            if(!Test.isRunningTest()) { //Disable Queueing for Unit Test
                System.enqueueJob(new SSOQueueable(userIdsToQueue));
           }
        }
    }
}