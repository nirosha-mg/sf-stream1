public class AccountTriggerHandler {
    public static void createSSOUser(List<Account> accounts) {
        List<User> userList = new List<User>();
        Id b2cLearnerRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('B2C_Learner').getRecordTypeId();
        List<Profile> b2cLearner = [SELECT Id FROM Profile WHERE Name = 'B2C Learner' LIMIT 1];
        if (b2cLearner.size() > 0) {
            Id userProfileId = b2cLearner[0].Id;
            for (Account account : accounts) {
                if (account.IsPersonAccount && account.RecordTypeId == b2cLearnerRT) {
                    if(!account.Self_Registration__pc) {
                        User user = SSOHandler.prepareUser(account.PersonContactId, userProfileId);
                        userList.add(user);
                    }
                }
            }
        }

        if (userList.size() > 0) {
            List<Id> userIds = new List<Id>();
            for (Database.SaveResult res : Database.insert(userList)) {
                if (res.success) {
                    userIds.add(res.getId());
                }
            }
            if (userIds.size() > 0) {
                System.enqueueJob(new SSOQueueable(userIds));
            }
        }
    }
}