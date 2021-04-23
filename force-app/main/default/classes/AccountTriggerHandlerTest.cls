@IsTest
public without sharing class AccountTriggerHandlerTest {
    @IsTest
    static void createSSOUserForB2C(){
        Id b2cLearnerRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('B2C_Learner').getRecordTypeId();
        Account acct = TestDataFactory.createB2CAccount('Test', 'Last', 'testApexUser@sim.edu.sg');
        acct.Self_Registration__pc = false;
        Test.startTest();
        insert acct;
        Test.stopTest();
        Id personContactId = [SELECT PersonContactId FROM Account WHERE Id =: acct.Id].PersonContactId;
        List<User> user = [SELECT Id FROM User WHERE ContactId =: personContactId];
        System.assertEquals(1, user.size());
    }
}