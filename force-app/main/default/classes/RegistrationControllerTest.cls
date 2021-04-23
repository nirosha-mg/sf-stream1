/**
 * @description       : 
 * @author            : Mark Alvin Tayag (mtayag@salesforce.com)
 * @group             : 
 * @last modified on  : 10-31-2020
 * @last modified by  : Mark Alvin Tayag (mtayag@salesforce.com)
 * Modifications Log 
 * Ver   Date         Author                                     Modification
 * 1.0   10-30-2020   Mark Alvin Tayag (mtayag@salesforce.com)   Initial Version
**/
@isTest
public class RegistrationControllerTest {
    //B2C Learner Account Scenarios
    @IsTest
    static void b2cNewUser(){
        String firstName = 'Test';
        String lastName = 'Test ' + UserInfo.getUserId();
        String email = UserInfo.getUserId() + '@' + UserInfo.getUserId() + '.com';
        Boolean corpAcct = false;
        String uenNo = '';
        String companyName = '';

        Test.startTest();
        String result = RegistrationFormController.createUser(firstName, lastName, email, corpAcct, uenNo, companyName);
        Test.stopTest();
        
        List<Account> acct = [SELECT Id, PersonContactId FROM Account WHERE PersonEmail =: email];
        System.assertEquals(1, acct.size());
        List<User> user = [SELECT Id FROM User WHERE ContactId =: acct[0].PersonContactId AND IsCommunityUser__c = TRUE];
        System.assertEquals(1, user.size());
        System.assertEquals(user[0].Id, result);

    }

    @IsTest
    static void b2cExistingUser(){

        String firstName = 'Test';
        String lastName = 'Test ' + UserInfo.getUserId();
        String email = UserInfo.getUserId() + '@' + UserInfo.getUserId() + '.com';
        Boolean corpAcct = false;
        String uenNo = '';
        String companyName = '';

        List<Profile> b2cLearner = [SELECT Id FROM Profile WHERE Name = 'B2C Learner' LIMIT 1];
        Account acct = RegistrationFormController.createB2CAccount(firstName, lastName, email);
        insert acct;
        Id personContactId = [SELECT PersonContactId FROM Account WHERE Id=:acct.Id].PersonContactId;
        User user = SSOHandler.prepareUser(personContactId, b2cLearner[0].Id);
        insert user;

        Test.startTest();
        String result = RegistrationFormController.createUser(firstName, lastName, email, corpAcct, uenNo, companyName);
        Test.stopTest();
        
        System.assertEquals('Existing User', result);
        List<User> userAssert = [SELECT Id FROM User WHERE ContactId =: personContactId AND IsCommunityUser__c = TRUE];
        System.assertEquals(1, userAssert.size());
    }

    @IsTest
    static void b2cExistingAcctOnly(){

        String firstName = 'Test';
        String lastName = 'Test ' + UserInfo.getUserId();
        String email = UserInfo.getUserId() + '@' + UserInfo.getUserId() + '.com';
        Boolean corpAcct = false;
        String uenNo = '';
        String companyName = '';

        List<Profile> b2cLearner = [SELECT Id FROM Profile WHERE Name = 'B2C Learner' LIMIT 1];
        Account acct = RegistrationFormController.createB2CAccount(firstName, lastName, email);
        insert acct;
        Test.startTest();
        String result = RegistrationFormController.createUser(firstName, lastName, email, corpAcct, uenNo, companyName);
        Test.stopTest();
        
        
        List<Account> acctAssert = [SELECT Id, PersonContactId FROM Account WHERE PersonEmail =: email];
        System.assertEquals(1, acctAssert.size());
        List<User> userAssert = [SELECT Id FROM User WHERE ContactId =: acctAssert[0].PersonContactId AND IsCommunityUser__c = TRUE];
        System.assertEquals(1, userAssert.size());
        System.assertEquals(userAssert[0].Id, result); //It should still return success and create User for the existing Acct instead of adding a new one
    }

    //B2B Account Scenarios
    @IsTest
    static void b2bNewUser(){
        String firstName = 'Test';
        String lastName = 'Test ' + UserInfo.getUserId();
        String email = UserInfo.getUserId() + '@' + UserInfo.getUserId() + '.com';
        Boolean corpAcct = true;
        String uenNo = UserInfo.getUserRoleId();
        String companyName = UserInfo.getUserRoleId() + ' Pte. Ltd.';

        Test.startTest();
        String result = RegistrationFormController.createUser(firstName, lastName, email, corpAcct, uenNo, companyName);
        Test.stopTest();
        List<Account> acct = [SELECT Id FROM Account WHERE UEN_No__c =: uenNo];
        System.assertEquals(1, acct.size());
        List<Contact> contact = [SELECT Id FROM Contact WHERE Email =: email AND AccountId =: acct[0].Id];
        System.assertEquals(1, contact.size());
        List<User> user = [SELECT Id FROM User WHERE ContactId =: contact[0].Id AND IsCommunityUser__c = TRUE];
        System.assertEquals(1, user.size());
        
        System.assertEquals(user[0].Id, result);

    }

    @IsTest
    static void b2bExistingUser(){

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
        User user = SSOHandler.prepareUser(contact.Id, b2bLearner[0].Id);
        insert user;

        Test.startTest();
        String result = RegistrationFormController.createUser(firstName, lastName, email, corpAcct, uenNo, companyName);
        Test.stopTest();
        
        System.assertEquals('Existing User', result);
        List<Account> acctAssert = [SELECT Id FROM Account WHERE UEN_No__c =: uenNo];
        System.assertEquals(1, acctAssert.size());
        List<Contact> contactAssert = [SELECT Id FROM Contact WHERE Email =: email];
        System.assertEquals(1, contactAssert.size());
        List<User> userAssert = [SELECT Id FROM User WHERE ContactId =: contact.Id AND IsCommunityUser__c = TRUE];
        System.assertEquals(1, userAssert.size());
    }

    @IsTest
    static void b2bExistingAcctOnly(){

        String firstName = 'Test';
        String lastName = 'Test ' + UserInfo.getUserId();
        String email = UserInfo.getUserId() + '@' + UserInfo.getUserId() + '.com';
        Boolean corpAcct = true;
        String uenNo = UserInfo.getUserRoleId();
        String companyName = UserInfo.getUserRoleId() + ' Pte. Ltd.';

        List<Profile> b2bLearner = [SELECT Id FROM Profile WHERE Name = 'B2B Learner' LIMIT 1];
        Account acct = RegistrationFormController.createB2BAccount(uenNo, companyName);
        insert acct;

        Test.startTest();
        String result = RegistrationFormController.createUser(firstName, lastName, email, corpAcct, uenNo, companyName);
        Test.stopTest();
        
        
        List<Account> acctAssert = [SELECT Id FROM Account WHERE UEN_No__c =: uenNo];
        System.assertEquals(1, acctAssert.size());
        List<Contact> contactAssert = [SELECT Id FROM Contact WHERE Email =: email];
        System.assertEquals(1, contactAssert.size());
        List<User> userAssert = [SELECT Id FROM User WHERE ContactId =: contactAssert[0].Id AND IsCommunityUser__c = TRUE];
        System.assertEquals(1, userAssert.size());
        
        System.assertEquals(userAssert[0].Id, result); //It should still return success and create the User and Contact for the existing Acct instead of adding a new one
    }
    
    @IsTest
    static void b2bExistingAcctAndContact(){

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

        Test.startTest();
        String result = RegistrationFormController.createUser(firstName, lastName, email, corpAcct, uenNo, companyName);
        Test.stopTest();
        
        
        List<Account> acctAssert = [SELECT Id FROM Account WHERE UEN_No__c =: uenNo];
        System.assertEquals(1, acctAssert.size());
        List<Contact> contactAssert = [SELECT Id FROM Contact WHERE Email =: email];
        System.assertEquals(1, contactAssert.size());
        List<User> userAssert = [SELECT Id FROM User WHERE ContactId =: contactAssert[0].Id AND IsCommunityUser__c = TRUE];
        System.assertEquals(1, userAssert.size());
        System.assertEquals(userAssert[0].Id, result); //It should still return success and create the User and Contact for the existing Acct instead of adding a new one
    }
}