/**
 * @description       : 
 * @author            : Mark Alvin Tayag (mtayag@salesforce.com)
 * @group             : 
 * @last modified on  : 10-29-2020
 * @last modified by  : Mark Alvin Tayag (mtayag@salesforce.com)
 * Modifications Log 
 * Ver   Date         Author                                     Modification
 * 1.0   10-28-2020   Mark Alvin Tayag (mtayag@salesforce.com)   Initial Version
**/
public without sharing class RegistrationFormController {
    
    @AuraEnabled
    public static String createUser (String firstName, String lastName, String email, Boolean corpAcct, String uenNo, String companyName) {
        String result = 'Error';

        if (userExists(email)) {
            result = 'Existing User';
            return result;
        }

        if (corpAcct) {
            //B2B Learner
            List<String> acctIds = AccountUtility.findCompany(new List<String> { uenNo });
            Account acct = new Account();
            if (acctIds.size() == 0) {
                acct = createB2BAccount(uenNo, companyName);
            }
            else {
                acct.Id = acctIds[0];
            }
            if (acct.Id == null) {
                Database.SaveResult res = Database.insert(acct);
                if (res.success) {
                    acct.Id = res.getId();
                }
                else {
                    result = 'Account Insert Error';
                    return result;
                }
            }

            if (acct.Id != null) {
                Contact contact = null;
                contact = findB2BContact(email, acct.Id);
                if (contact == null) {
                    contact = createB2BContact(firstName, lastName, email, acct.Id);
                    Database.SaveResult res = Database.insert(contact);
                    if (res.success) {
                        contact.Id = res.getId();
                    }
                }
                
                if (contact.Id != null) {
                    List<Profile> b2bLearner = [SELECT Id FROM Profile WHERE Name = 'B2B Learner' LIMIT 1];
                    User user = SSOHandler.prepareUser(contact.Id, b2bLearner[0].Id);
                    Database.SaveResult resUser = Database.insert(user);
                    if (resUser.success) {
                        result = resUser.getId();
                    }
                }
                else {
                    result = 'Contact Insert Error';
                    return result;
                }
            }
        }
        else {
            //B2C Learner
            Account acct = new Account();
            acct = findB2CAccount(email);
            if (acct == null) {
                acct = createB2CAccount(firstName, lastName, email);
                Database.SaveResult res = Database.insert(acct);
                if (res.success) {
                    acct.Id = res.getId();
                }
            }
            
            if (acct.Id != null) {
                
                Id personContactId = [SELECT PersonContactId FROM Account WHERE Id =: acct.Id].PersonContactId;
                List<Profile> b2cLearner = [SELECT Id FROM Profile WHERE Name = 'B2C Learner' LIMIT 1];
                User user = SSOHandler.prepareUser(personContactId, b2cLearner[0].Id);
                Database.SaveResult resUser = Database.insert(user);
                if (resUser.success) {
                    result = resUser.getId();
                }
                else {
                    result = 'User Callout Error';
                    return result;
                }
            }
            else {
                result = 'Person Account Insert Error';
                return result;
            }
        }

        return result;
    }
    
    @AuraEnabled
    public static string userCallout(String userId){
        String result = '';
            if (SSOHandler.createUser(new List<Id> { userId })) {
                result = 'Success';
            }
            else {
                result = 'User Callout Error';
            }

        return result;
    }

    @TestVisible
    private static Boolean userExists(String email) {
        //Look in Community Users
        List<User> usersFound = [SELECT Id FROM User WHERE email =: email AND IsCommunityUser__c = TRUE LIMIT 1];

        return usersFound.size() > 0;
    }
    
    @TestVisible
    private static Account findB2CAccount(String email) {
        //Look in Community Users
        List<Account> accountsFound = [SELECT Id FROM Account WHERE PersonEmail =: email LIMIT 1];

        return accountsFound.size() > 0 ? accountsFound[0] : null;
    }
    
    @TestVisible
    private static Contact findB2BContact(String email, String acctId) {
        //Look in Community Users
        List<Contact> contactsFound = [SELECT Id FROM Contact WHERE Email =: email AND AccountId =: acctId LIMIT 1];

        return contactsFound.size() > 0 ? contactsFound[0] : null;
    }

    @TestVisible
    private static Account createB2CAccount(String firstName, String lastName, String email) {
        Id b2cLearnerRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('B2C_Learner').getRecordTypeId();
        Account acct = new Account();
        acct.RecordTypeId = b2cLearnerRT;
        acct.FirstName = firstName;
        acct.LastName = lastName;
        acct.PersonEmail = email;
        acct.Primary_Email_Address__pc = email;
        acct.Self_Registration__pc = true;
        return acct;
    }

    @TestVisible
    private static Account createB2BAccount(String uenNo, String companyName) {
        Id b2bAccountRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('B2B_Account').getRecordTypeId();
        Account acct = new Account();
        acct.RecordTypeId = b2bAccountRT;
        acct.Name = companyName;
        acct.UEN_No__c = uenNo;
        return acct;
    }

    @TestVisible
    private static Contact createB2BContact(String firstName, String lastName, String email, Id acctId) {
        Id b2bLearnerRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('B2B_Learner').getRecordTypeId();
        Contact contact = new Contact();
        contact.RecordTypeId = b2bLearnerRT;
        contact.FirstName = firstName;
        contact.LastName = lastName;
        contact.Email = email;
        contact.Primary_Email_Address__c = email;
        contact.AccountId = acctId;
        contact.Self_Registration__c = true;
        return contact;
    }
}