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
@IsTest
public without sharing class AppLogUtilityTest {
    @IsTest
    static void createAppLog(){
        
        Test.startTest();
        insert AppLogUtility.createApplicationLog('stacktrace', 'AppLogUtility', 'xxxxxxx');
        Test.stopTest();

        List<Application_Log__c> appLogs = [SELECT Class__c, RecordId__c, RequestedBy__c, Status__c, Stacktrace__c FROM Application_Log__c];
        System.assertEquals(1, appLogs.size());
        System.assertEquals('stacktrace', appLogs[0].Stacktrace__c);
        System.assertEquals('AppLogUtility', appLogs[0].Class__c);
        System.assertEquals('xxxxxxx', appLogs[0].RecordId__c);
        System.assertEquals(UserInfo.getUserId(), appLogs[0].RequestedBy__c);
        System.assertEquals('Failure', appLogs[0].Status__c);
        
    }
}