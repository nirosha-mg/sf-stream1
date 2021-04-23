/**
 * @description       : 
 * @author            : Lim Poon Koon
 * @group             : 
 * @last modified on  : 09-03-2021
 * @last modified by  : Lim Poon Koon
 * Modifications Log 
 * Ver   Date         Author                                     Modification
 * 1.0   09-03-2021   Lim Poon Koon                              Initial Version
**/
public with sharing class ShortenURLInvocableForAnonSurvey {
    
    public static List<Application_Log__c> applogs = new List<Application_Log__c>();

    @InvocableMethod(label = 'shortenForAnonSurvey' description = 'Generate shortened URL for anonymous survey links')
    public static List<List<string>> shortenForAnonSurvey(List<List<string>> listCourseRunSurveyURL) {
        List<String> urlArray = new List<String>();
        for (List<String> surveyURLs : listCourseRunSurveyURL) {
            URLClass urlClass = new URLClass();
            urlClass.anonymousURL = surveyURLs[0];
            urlClass.courseRunId = surveyURLs[1];
            urlArray.add(JSON.serialize(urlClass));
        }
        shortenAsyncForAnonSurvey(urlArray);
    return listCourseRunSurveyURL;
    }

    @future (callout=true)
    public static void shortenAsyncForAnonSurvey(List<String> listCourseRunSurveyURL) {
        List<Course_Registration__c> courseRegs = new List<Course_Registration__c>();
        List<Course_Run__c> courseRuns = new List<Course_Run__c>();
        Map<Id, String> mapAnonymousToCRun = new Map<Id, String>();
        
        for (String surveyURLJSON : listCourseRunSurveyURL) {
            URLClass urlClass = (URLClass)JSON.deserialize(surveyURLJSON, URLClass.class);
            mapAnonymousToCRun.put(urlClass.courseRunId, urlClass.anonymousURL);
        }

        for (Id crunId : mapAnonymousToCRun.keySet()) {
            String invitationLinkAnonymous = mapAnonymousToCRun.get(crunId);
            Course_Run__c courseRun = new Course_Run__c();
            courseRun.Id = crunId;
            courseRun.Course_Survey_Anonymous__c = doCallOut(invitationLinkAnonymous, crunId);
            courseRuns.add(courseRun);
        }

        //DMLs
        if (courseRuns.size() > 0) {
            update courseRuns;
        }
        if (applogs.size() > 0) {
            insert applogs;
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
        public String courseRunId { get; set; }
    }
}