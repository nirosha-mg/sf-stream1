/**
 * @description       : 
 * @author            : Mark Alvin Tayag (mtayag@salesforce.com)
 * @group             : 
 * @last modified on  : 11-11-2020
 * @last modified by  : Mark Alvin Tayag (mtayag@salesforce.com)
 * Modifications Log 
 * Ver   Date         Author                                     Modification
 * 1.0   11-10-2020   Mark Alvin Tayag (mtayag@salesforce.com)   Initial Version
 * 1.1   09-03-2021   Poon Koon                                  Update method to only update anonymous link to course run if previously not exists
**/
public with sharing class ShortenURLInvocable {
    /*
    @InvocableMethod(label = 'shorten' description = 'Given survey IDs then generates a bitly short url for them')
    public static List < List < string >> shorten(List < List < string >> listCourseRegistrationSurveyURL) {
        shortenAsync(listCourseRegistrationSurveyURL);
        return listCourseRegistrationSurveyURL;      
    }
    */
    
    /*
    public static void shortenAsync(List < List < string >> listCourseRegistrationSurveyURL) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        List < Messaging.SingleEmailMessage > messages = new List < Messaging.SingleEmailMessage > ();
        List < Course_Registration__c > listUpdateCourseRegistration = new List < Course_Registration__c > ();
        Set<Id> setCourseId = new Set<Id>();
        string strInvitationLinkAnonymous;
        string strInvitationLink;
        string strCourseRegistrationId;
        System.debug('ShortenURLInvocable :: shortenAsync :: Found :: listCourseRegistrationSurveyURL >>>' + listCourseRegistrationSurveyURL);
        System.debug('ShortenURLInvocable :: shortenAsync :: Found :: size >>>' + listCourseRegistrationSurveyURL.size());
        //
        for (List < string > iterator: listCourseRegistrationSurveyURL) {
                strInvitationLinkAnonymous = iterator[0];
                strInvitationLink = iterator[1];
                strCourseRegistrationId = iterator[2];
                System.debug('strInvitationLinkAnonymous' + strInvitationLinkAnonymous);
                System.debug('strInvitationLink' + strInvitationLink);
                System.debug('strCourseRegistrationId' + strCourseRegistrationId);
                setCourseId.add(strCourseRegistrationId);
                updateInfo(strCourseRegistrationId,strInvitationLinkAnonymous,strInvitationLink,false);
        }
        //
        EmailTemplate emailTemplate = [SELECT Id, 
                                            Subject, 
                                            Description, 
                                            HtmlValue, 
                                            DeveloperName, 
                                            Body
                                        FROM EmailTemplate
                                        WHERE name = 'SIM PD Course Evaluation Survey'];
        for (Course_Registration__c iterator: [SELECT Id, Email_Address__c, Contact__c FROM Course_Registration__c WHERE Id IN: setCourseId]) {
        if(string.isNotBlank(iterator.Email_Address__c)){
            system.debug('inside class==>' + iterator.Email_Address__c);
            //send email to end usr about the survey
            message.setTargetObjectId(iterator.Contact__c);
            message.setSaveAsActivity(false);
            message.setTemplateID(emailTemplate.Id);
            message.setWhatId(iterator.Id); //This is important for the merge fields in template to work
            message.toAddresses = new String[] {
            iterator.Email_Address__c
            };
            messages.add(message);
            System.debug('ShortenURLInvocable :: shortenAsync :: Found :: messages >>>' + messages);
        }
        }
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

        if (results[0].success) {
        System.debug('The email was sent successfully.');
        } else {
        System.debug('The email failed to send:' + results[0].errors[0].message);
        } 
    }
    */

    /**
        * @description 
        * @author ROhit Pal | 10-19-2020 
        * @param strURL 
        **/
        /*
    public static string doCallOut(string strURL) {
        strURL = EncodingUtil.urlEncode(strURL, 'UTF-8');
        Map < string,
        string > mpp = new Map < string,
        string > ();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('Content-Length', '0');
        request.setEndpoint('https://tinyurl.com/api-create.php?url=' + strURL);
        //request.setEndpoint('https://tinyurl.com/api-create.php?');
        request.setMethod('POST');
        // request.setBody('{"url":"https://simstream1-simdigital.cs113.force.com/SIMDigitalSurveyPortal/survey/runtimeApp.app?invitationId=0Ki1s0000008SlY&surveyName=course_survey&UUID=5462140f-746f-4b9a-9220-10414a5ac742"}');
        system.debug(' ShortenURLInvocable :: doCallOut :: Found :: request >>' + request);
        HttpResponse response = http.send(request);
        system.debug(' ShortenURLInvocable :: doCallOut :: Found :: response >>' + response);
        system.debug(' ShortenURLInvocable :: doCallOut :: Found :: response getBody  >>' + response.getBody());
        return string.valueOf(response.getBody());
    }
    */
    /*
    @future (callout=true)
    public static void updateInfo(string strCourseRegistrationId,
                                string strInvitationLinkAnonymous,
                                string strInvitationLink,
                                boolean isFalse ){
        //
        Course_Registration__c objCourseRegistration = new Course_Registration__c(Id = strCourseRegistrationId);
        if (!Test.isRunningTest()) {
            objCourseRegistration.Course_Survey_Anonymous__c = doCallOut(strInvitationLinkAnonymous);
            objCourseRegistration.Course_Survey_Participant__c = doCallOut(strInvitationLink);
        }
        objCourseRegistration.Send_Survey__c = isFalse;
        update objCourseRegistration;
    }
    */

    public static List<Application_Log__c> applogs = new List<Application_Log__c>();

    @InvocableMethod(label = 'shorten' description = 'Given survey IDs then generates a bitly short url for them')
    public static List<List<string>> shorten(List<List<string>> listCourseRegistrationSurveyURL) {
        List<String> urlArray = new List<String>();
        for (List<String> surveyURLs : listCourseRegistrationSurveyURL) {
            URLClass urlClass = new URLClass();
            urlClass.anonymousURL = surveyURLs[0];
            urlClass.participantURL = surveyURLs[1];
            urlClass.regId = surveyURLs[2];
            urlClass.courseRunId = surveyURLs[3];
            urlArray.add(JSON.serialize(urlClass));
        }
        shortenAsync(urlArray);
    return listCourseRegistrationSurveyURL;
    }

    @future (callout=true)
    public static void shortenAsync(List<String> listCourseRegistrationSurveyURL) {
        List<Course_Registration__c> courseRegs = new List<Course_Registration__c>();
        List<Course_Run__c> courseRuns = new List<Course_Run__c>();
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        List<Id> courseRegIds = new List<Id>();
        Map<Id, String> mapAnonymousToCRun = new Map<Id, String>();
        EmailTemplate emailTemplate = [SELECT Id, 
                                            Subject, 
                                            Description, 
                                            HtmlValue, 
                                            DeveloperName, 
                                            Body
                                        FROM EmailTemplate
                                        WHERE name = 'SIM PD Course Evaluation Survey'];
        for (String surveyURLJSON : listCourseRegistrationSurveyURL) {
            URLClass urlClass = (URLClass)JSON.deserialize(surveyURLJSON, URLClass.class);
            mapAnonymousToCRun.put(urlClass.courseRunId, urlClass.anonymousURL);
        }

        for (Id crunId : mapAnonymousToCRun.keySet()) {
            String invitationLinkAnonymous = mapAnonymousToCRun.get(crunId);
            String invitationLinkAnonymousShortened = doCallOut(invitationLinkAnonymous, crunId);
            //Course_Run__c courseRun = new Course_Run__c();
            //courseRun.Id = crunId;
            Course_Run__c courseRun = [SELECT Id, Course_Survey_Anonymous__c FROM Course_Run__c WHERE Id =: crunId];
            if(String.isBlank(courseRun.Course_Survey_Anonymous__c)) {
                courseRun.Course_Survey_Anonymous__c = invitationLinkAnonymousShortened;
                courseRuns.add(courseRun);
            }
            mapAnonymousToCRun.put(crunId, invitationLinkAnonymousShortened);
        }

        for (String surveyURLJSON : listCourseRegistrationSurveyURL) {
            URLClass urlClass = (URLClass)JSON.deserialize(surveyURLJSON, URLClass.class);
            String invitationLinkAnonymous = urlClass.anonymousURL;
            String invitationLink = urlClass.participantURL;
            String courseRegistrationId = urlClass.regId;

            Course_Registration__c courseReg = new Course_Registration__c();
            courseReg.Id = courseRegistrationId;
            courseReg.Course_Survey_Anonymous__c = mapAnonymousToCRun.get(urlClass.courseRunId);
            courseReg.Course_Survey_Participant__c = doCallOut(invitationLink, courseRegistrationId);
            courseReg.Send_Survey__c = false;
            courseRegs.add(courseReg);
            courseRegIds.add(courseRegistrationId);
        }

        Map<Id, String> anonymousURLForCR = new Map<Id, String>();
        for (Course_Registration__c courseReg : [SELECT Id, Contact__c, Email_Address__c, Course_Run_Id__c FROM Course_Registration__c WHERE Id =: courseRegIds]) {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            if(string.isNotBlank(courseReg.Email_Address__c)){
                message.setTargetObjectId(courseReg.Contact__c);
                message.setSaveAsActivity(false);
                message.setTemplateID(emailTemplate.Id);
                message.setWhatId(courseReg.Id); 
                message.toAddresses = new String[] {
                    courseReg.Email_Address__c
                };
                messages.add(message);
            }
        }

        //DMLs
        if (courseRegs.size() > 0) {
            update courseRegs;
        }
        if (courseRuns.size() > 0) {
            update courseRuns;
        }
        if (applogs.size() > 0) {
            insert applogs;
        }
        if (messages.size() > 0) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        }
    }

    public static string doCallOut(String strURL, String recordId) {
        String encodedURL = EncodingUtil.urlEncode(strURL, 'UTF-8');

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('Content-Length', '0');
        request.setEndpoint('https://tinyurl.com/api-create.php?url=' + encodedURL);
        request.setMethod('POST');
        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                return string.valueOf(response.getBody());
            }
            else {
                Application_Log__c appLog = AppLogUtility.createApplicationLog(response.getStatusCode() + '\n' + response.getBody(), 
                                                    'ShortenURLInvocable', 
                                                    recordId);
                applogs.add(appLog);
                return strURL; // Return original URL for errors
            }
        }
        catch (Exception e) {
            Application_Log__c appLog = AppLogUtility.createApplicationLog(e.getMessage() + '\n' + e.getStackTraceString(), 
                                                'ShortenURLInvocable', 
                                                recordId);
            applogs.add(appLog);
            return strURL; // Return original URL for errors
        }
    }

    private class URLClass {
        public String anonymousURL { get; set; }
        public String participantURL { get; set; }
        public String regId { get; set; }
        public String courseRunId { get; set; }
    }
}