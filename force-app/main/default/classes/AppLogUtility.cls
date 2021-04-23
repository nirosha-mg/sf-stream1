/**
 * @description       : 
 * @author            : Mark Alvin Tayag (mtayag@salesforce.com)
 * @group             : 
 * @last modified on  : 10-11-2020
 * @last modified by  : Mark Alvin Tayag (mtayag@salesforce.com)
 * Modifications Log 
 * Ver   Date         Author                                     Modification
 * 1.0   10-11-2020   Mark Alvin Tayag (mtayag@salesforce.com)   Initial Version
**/
public without sharing class AppLogUtility {
    public static Application_Log__c createApplicationLog(String stackTrace, String className, String recordId) {
        Application_Log__c appLog = new Application_Log__c();
        appLog.Stacktrace__c = stackTrace;
        appLog.Class__c = className;
        appLog.RecordId__c = recordId;
        appLog.RequestedBy__c = UserInfo.getUserId();
        appLog.Status__c = 'Failure';

        return appLog;
    }
}