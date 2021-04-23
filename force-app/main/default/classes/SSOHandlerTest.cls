/*************************************************************************************************************
* @name			SSOHandlerTest
* @author			BLR\rohit.pal <rohit.pal@crmit.com>
* @created			13 / 10 / 2020
* @description		Description of your code
*
* Changes (version)
* -----------------------------------------------------------------------------------------------------------
* 				No.		Date			Author					Description
* 				----	------------	--------------------	----------------------------------------------
* @version		1.0		2020-10-13		BLR\rohit.pal			Changes desription
*               1.1     2020-10-30      Alvin Tayag             Replaced Test Methods
**************************************************************************************************************/
@isTest(seeAllData=false)
private class SSOHandlerTest {

    @TestSetup
    static void setupTestData() {
        String firstName = 'Test';
        String lastName = 'Test ' + UserInfo.getUserId();
        String email = UserInfo.getUserId() + '@' + UserInfo.getUserId() + '.com';
        Boolean corpAcct = false;
        String uenNo = '';
        String companyName = '';

        
        Account acct = RegistrationFormController.createB2CAccount(firstName, lastName, email);
        insert acct;
    }
    
    static void setupB2BTestData() {

        String firstName = 'Test';
        String lastName = 'Test ' + UserInfo.getUserId();
        String email = UserInfo.getUserId() + '@' + UserInfo.getUserId() + '.com';
        Boolean corpAcct = true;
        String uenNo = UserInfo.getUserRoleId();
        String companyName = UserInfo.getUserRoleId() + ' Pte. Ltd.';

        List<Profile> b2bLearner = [SELECT Id FROM Profile WHERE Name = 'B2B Learner' LIMIT 1];
        Account acct = RegistrationFormController.createB2BAccount(uenNo, companyName);
        insert acct;
        Contact contact = RegistrationFormController.createB2BContact(firstName, lastName, email, acct.Id);
        insert contact;
    }
    
    static testMethod void ssoHandlerCalloutforB2CNew() {
        //Prepare Data
        List<Contact> contact = [SELECT Id FROM Contact];
        List<Profile> b2cLearner = [SELECT Id FROM Profile WHERE Name = 'B2C Learner' LIMIT 1];
        User user = SSOHandler.prepareUser(contact[0].Id , b2cLearner[0].Id);
        insert user;

        String uuid = 'xxxxx-xxxxx-xxxxx';
        Test.setMock(HttpCalloutMock.class, new SSOHandlerMock(201, uuid)); 
        
        Test.startTest();
        Boolean createUser = SSOHandler.createUser(new List<Id> { user.Id });
        Test.stopTest();
        System.assert(createUser);

        List<User> userAssert = [SELECT Id, UUID__c FROM User WHERE Id =: user.Id];
        System.assertEquals(uuid, userAssert[0].UUID__c); //Value taken from Mock

        List<Application_Log__c> appLogs = [SELECT Id FROM Application_Log__c];
        System.assertEquals(2, appLogs.size());
        
    } 
    
    static testMethod void ssoHandlerCalloutforB2CExisting() {
        //Prepare Data
        List<Contact> contact = [SELECT Id FROM Contact];
        List<Profile> b2cLearner = [SELECT Id FROM Profile WHERE Name = 'B2C Learner' LIMIT 1];
        User user = SSOHandler.prepareUser(contact[0].Id , b2cLearner[0].Id);
        insert user;

        String uuid = 'xxxxx-xxxxx-xxxxx';
        Test.setMock(HttpCalloutMock.class, new SSOHandlerMock(409, uuid)); 
        
        Test.startTest();
        Boolean createUser = SSOHandler.createUser(new List<Id> { user.Id });
        Test.stopTest();
        System.assert(createUser);

        List<User> userAssert = [SELECT Id, UUID__c FROM User WHERE Id =: user.Id];
        System.assertEquals(uuid, userAssert[0].UUID__c); //Value taken from Mock

        List<Application_Log__c> appLogs = [SELECT Id FROM Application_Log__c];
        System.assertEquals(2, appLogs.size());
    } 
    
    static testMethod void ssoHandlerCalloutforB2CError() {
        //Prepare Data
        List<Contact> contact = [SELECT Id FROM Contact];
        List<Profile> b2cLearner = [SELECT Id FROM Profile WHERE Name = 'B2C Learner' LIMIT 1];
        User user = SSOHandler.prepareUser(contact[0].Id , b2cLearner[0].Id);
        insert user;

        String uuid = 'xxxxx-xxxxx-xxxxx';
        Test.setMock(HttpCalloutMock.class, new SSOHandlerMock(500, uuid)); 
        
        Test.startTest();
        Boolean createUser = SSOHandler.createUser(new List<Id> { user.Id });
        Test.stopTest();
        System.assert(!createUser);

        List<User> userAssert = [SELECT Id, UUID__c FROM User WHERE Id =: user.Id];
        System.assertEquals(null, userAssert[0].UUID__c); //Value taken from Mock

        List<Application_Log__c> appLogs = [SELECT Id FROM Application_Log__c];
        System.assertEquals(2, appLogs.size());
    } 
    
    static testMethod void ssoHandlerCalloutforB2CNewQueuable() {
        //Prepare Data
        List<Contact> contact = [SELECT Id FROM Contact];
        List<Profile> b2cLearner = [SELECT Id FROM Profile WHERE Name = 'B2C Learner' LIMIT 1];
        User user = SSOHandler.prepareUser(contact[0].Id , b2cLearner[0].Id);
        insert user;

        String uuid = 'xxxxx-xxxxx-xxxxx';
        Test.setMock(HttpCalloutMock.class, new SSOHandlerMock(201, uuid)); 

        Test.startTest();
        SSOQueueable queueJob = new SSOQueueable(new List<Id> { user.Id });
        queueJob.executeJob();
        Test.stopTest();

        List<User> userAssert = [SELECT Id, UUID__c FROM User WHERE Id =: user.Id];
        System.assertEquals(uuid, userAssert[0].UUID__c); //Value taken from Mock

        List<Application_Log__c> appLogs = [SELECT Id FROM Application_Log__c];
        System.assertEquals(2, appLogs.size());
    } 
}