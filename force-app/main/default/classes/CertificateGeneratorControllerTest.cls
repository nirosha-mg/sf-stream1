/**
 * @description       : 
 * @author            : Mark Alvin Tayag (mtayag@salesforce.com)
 * @group             : 
 * @last modified on  : 10-31-2020
 * @last modified by  : Mark Alvin Tayag (mtayag@salesforce.com)
 * Modifications Log 
 * Ver   Date         Author                                     Modification
 * 1.0   10-31-2020   Mark Alvin Tayag (mtayag@salesforce.com)   Initial Version
 * 1.1   2021-03-17   Poon Koon                                  Update TestSetup to insert Setting data
**/
@IsTest
public class CertificateGeneratorControllerTest {
    @TestSetup
    static void makeData(){

        //Hardcoded Folder due to access issues when testing
        String folderName = 'Certificate Templates';
        Id folderId = [SELECT ID FROM Folder WHERE Name =: folderName].Id;

        Certificate_Template_Folder__c folder = TestDataFactory.createCertFolderSetting(folderName);
        insert folder;
        
        //Create Course Run from TestDataFactory
        Id personAccountRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Account acct = TestDataFactory.createAccount(personAccountRT);
        acct.FirstName = 'Test';
        acct.LastName = 'Account';
        acct.PersonEmail = 'testApexUser@sim.edu.sg';
        insert acct;

        Course__c course = TestDataFactory.createCourse(null);
        insert course;

        Course_Run__c courseRun = TestDataFactory.createCourseRun();
        courseRun.Course__c = course.Id;
        insert courseRun;

        //Create Course Registration from TestDataFactory
        Course_Registration__c reg = TestDataFactory.createCourseRegistration(courseRun.Id, acct.PersonContactId);
        insert reg;

        //2021-03-17 Poon Koon: Create Certificate Running Number record in Setting object
        Setting__c setting = new Setting__c();
        setting.Name = 'Certificate Running Number';
        setting.Certificate_Running_Number__c = 1;
        insert setting;
    }

    @IsTest
    static void getCourseRegistrations(){
        
        Id courseRunId = [SELECT Id FROM Course_Run__c].Id;
        
        Test.startTest();
        List<Course_Registration__c> courseReg = CertificateGeneratorController.getCourseRegistrations(courseRunId);
        Test.stopTest();

        List<Course_Registration__c> courseRegExp = [SELECT Id FROM Course_Registration__c WHERE Course_Run_Id__c =: courseRunId AND Parent_Registration__c = null];

        System.assertEquals(courseRegExp.size(), courseReg.size());
        System.assertEquals(courseRegExp[0].Id, courseReg[0].Id);
    }

    @IsTest
    static void getCertificateTemplates(){
        Certificate_Template_Folder__c templateFolder = Certificate_Template_Folder__c.getOrgDefaults();
        List<EmailTemplate> emails = [SELECT Name FROM EmailTemplate WHERE Folder.Name =: templateFolder.Folder_Name__c];
        
        Test.startTest();
        
        List<String> emailTemplateNames = CertificateGeneratorController.getCertificateTemplates();

        Test.stopTest();
        System.assertEquals(emails.size(), emailTemplateNames.size());
    }

    @IsTest
    static void generateCertificate(){
        List<String> registrationIds = new List<String>();
        for (Course_Registration__c reg : [SELECT Id FROM Course_Registration__c]) {
            registrationIds.add(reg.Id);
        }
        String registrations = JSON.serialize(registrationIds);
        Certificate_Template_Folder__c templateFolder = Certificate_Template_Folder__c.getOrgDefaults();
        List<EmailTemplate> emails = [SELECT Name FROM EmailTemplate WHERE Folder.Name =: templateFolder.Folder_Name__c];
        
        Test.startTest();
        CertificateGeneratorController.generateCertificate(registrations, emails[0].Name);
        Test.stopTest();

        Id registrationId = registrationIds[0];
        List<ContentDocumentLink> cdlList = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:registrationId];
        System.assertEquals(1, cdlList.size());
    }
}