/**
 * @description       : 
 * @author            : Mark Alvin Tayag (mtayag@salesforce.com)
 * @group             : 
 * @last modified on  : 11-11-2020
 * @last modified by  : Mark Alvin Tayag (mtayag@salesforce.com)
 * Modifications Log 
 * Ver   Date         Author                                     Modification
 * 1.0   11-11-2020   Mark Alvin Tayag (mtayag@salesforce.com)   Initial Version
 * 1.1   2021-03-17   Poon Koon                                  Modify logics to generate certificate running number to use Setting object
**/
public with sharing class CertificateGeneratorController {

    @AuraEnabled
    public static List<Course_Registration__c> getCourseRegistrations (Id courseRunId){
        List<Course_Registration__c> courseRegistrations = new List<Course_Registration__c>();

        if (!String.isBlank(courseRunId)) {
            courseRegistrations = [SELECT Name, 
                                    Contact__c, 
                                    Preferred_Certificate_Name__c, 
                                    First_Name__c, 
                                    Last_Name__c, 
                                    Registration_Status__c 
                                FROM Course_Registration__c
                                WHERE Course_Run_Id__c =: courseRunId];
        }
        

        return courseRegistrations;
    }

    @AuraEnabled
    public static List<String> getCertificateTemplates() {
        List<String> templateNames = new List<String>();
        Certificate_Template_Folder__c templateFolder = Certificate_Template_Folder__c.getOrgDefaults();
        
        for (EmailTemplate e : [SELECT Name FROM EmailTemplate WHERE Folder.Name=: templateFolder.Folder_Name__c]) {
            templateNames.add(e.Name);
        }

        return templateNames;
    }

    //Upload PDF to each Registration Selected
    @AuraEnabled
    public static Boolean generateCertificate(String registrations, String templateName) {
        List<String> registrationIds = (List<String>)JSON.deserialize(registrations, List<String>.class);
        Boolean success = false;
        try {
            //Get current course running number
            //2021-03-17 Poon Koon: Get running number from Setting object
            Setting__c setting = [SELECT Id, Certificate_Running_Number__c FROM Setting__c WHERE Name = 'Certificate Running Number' LIMIT 1];
            Integer latestRegNo = Integer.valueOf(setting.Certificate_Running_Number__c);
            /*Course_Registration__c firstReg = [SELECT Course_Run_Id__r.Course__r.Id, Course_Run_Id__r.Course__r.Certificate_Running_No__c FROM Course_Registration__c WHERE Id =: registrationIds[0]];
            Integer latestRegNo = firstReg.Course_Run_Id__r.Course__r.Certificate_Running_No__c != null ? Integer.valueOf(firstReg.Course_Run_Id__r.Course__r.Certificate_Running_No__c) : 0;*/

            List<Course_Registration__c> regs = new List<Course_Registration__c>();

            for (String regId : registrationIds) {
                latestRegNo = latestRegNo + 1;
                String certificateName = 'CER-' + String.valueOf(latestRegNo).leftPad(5, '000');
                Course_Registration__c courseReg = new Course_Registration__c();
                courseReg.Id = regId;
                courseReg.Certificate_No__c = certificateName;
                regs.add(courseReg);
            }

            if (regs.size() > 0) {
                update regs;

                //2021-03-17 Poon Koon: Update running number back to Setting object
                Setting__c updSetting = new Setting__c();
                updSetting.Id = setting.Id;
                updSetting.Certificate_Running_Number__c = latestRegNo;

                update updSetting;
            }

            uploadCertificates(registrationIds, templateName); //Fire Future Method

            success = true;
        }
        catch (Exception e) {
            success = false;
        }
        return success;
    }

    @future (callout=true)
    public static void uploadCertificates (List<String> registrationIds, String templateName) {

        try {
            List<ContentVersion> cvList = new List<ContentVersion>();
            Map<Id, String> regCerts = new Map<Id, String>();
            for (Course_Registration__c regs : [SELECT Id, Certificate_No__c FROM Course_Registration__c WHERE Id=:registrationIds]) {
                regCerts.put(regs.Id, regs.Certificate_No__c);
            }

            for (String regId : regCerts.keySet()) {
                String certificateName = regCerts.get(regId);
                Blob pdfData = null;
                if (!Test.isRunningTest()) {
                    pdfData = new PageReference('/apex/eCertPage?id=' + regId + '&templateName=' + EncodingUtil.urlEncode(templateName, 'UTF-8')).getContent();
                }
                else {
                    pdfData = EncodingUtil.base64Decode('Test Data');
                }
                ContentVersion cv = new ContentVersion();
                cv.Description = regId;
                cv.VersionData = pdfData;
                cv.ContentLocation = 'S';
                cv.PathOnClient = certificateName + '.pdf';
                cv.Title = certificateName + '.pdf';
                cvList.add(cv);
            }
            
            Database.insert(cvList);

            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
            for (ContentVersion cv : [SELECT Id, Description, ContentDocumentId FROM ContentVersion WHERE Description =: registrationIds]) {
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.LinkedEntityId = cv.Description;
                cdl.ContentDocumentId = cv.ContentDocumentId;
                cdl.ShareType = 'I';
                cdlList.add(cdl);
            }

            Database.insert(cdlList, false);
        }
        catch (Exception e) {
            insert AppLogUtility.createApplicationLog(e.getMessage() + '\n' + e.getStackTraceString(), 'CertificateGeneratorController', '');
        }
    }
}