/**
 * @description       : Batch class to send the User to Mulesoft and trigger the email in bulk
 * @author            : Sanjay(TMC)
 * @group             : 
 * @last modified on  : 9 April 2021
 * Modifications Log 
 * Ver      Date        	    Author                                     Modification
**/
global class SSOContactCalloutBatch implements Database.Batchable<sObject>, Database.AllowsCallouts,Database.stateful{
	public List<String> userIds = new List<String>();
    Global List<Application_Log__c> listApplicationLog;
    global SSOContactCalloutBatch(List<String> usrIds){
    	userIds = usrIds;
        listApplicationLog = new List<Application_Log__c>();
        
    }
    
	global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([select id,FirstName,LastName,FederationIdentifier,Email,ContactId,UUID__c from User where Id in: userIds]);
    }
    
    global void execute(Database.BatchableContext BC, List<user> users) {
        If(users!=null && users.size()==1){
            Application_Log__c objApplicationLog = new Application_Log__c();
            objApplicationLog = AppLogUtility.createApplicationLog('', 'SSOContactCalloutBatch', users[0].id);
            try {
                List<String> responseArr = callout(users[0]);
                Boolean success = (responseArr[0] == 'Success');
                objApplicationLog.Status__c = responseArr[0];
                if (success) {
                    users[0].UUID__c = responseArr[1];
                    update users[0];
                }
                else {
                    objApplicationLog.Stacktrace__c = responseArr[1];
                }
                
            }
            catch (Exception e) {
                objApplicationLog.Status__c = 'Failure';
                objApplicationLog.Stacktrace__c = e.getMessage() + '\n' + e.getStackTraceString();
            }
            listApplicationLog.add(objApplicationLog);
        }
    }
    
    public List<String> callout(User user) {
        List<String> responseArr = new List<String>();

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        SSOHandler.SSOWrapper wrapper = new SSOHandler.SSOWrapper(user.FirstName, 
                                            user.LastName, 
                                            user.Email, 
                                            '', 
                                            '', 
                                            user.FederationIdentifier, 
                                            user.ContactId,
                                            user.Id);

        if(string.isNotBlank(user.UUID__c)){
            request.setEndpoint('callout:Mulesoft_API' + '/x-sfdc-v1/api/users/' + user.UUID__c);
            request.setMethod('PATCH');
        } else {
            request.setEndpoint('callout:Mulesoft_API' + '/x-sfdc-v1/api/users');
            request.setMethod('POST');
            //Only set the password for new users
            wrapper.password = generatePassword(10);
        }
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(JSON.serialize(wrapper));
        // Set the body as a JSON object
        system.debug(' SSOContactCalloutBatch :: callout :: Found :: request >>' + request);
        system.debug(' SSOContactCalloutBatch :: callout :: Found :: wrapper >>' + wrapper);

        //Send out the Request
        HttpResponse response = http.send(request);
        // Parse the JSON response
        system.debug(' SSOHanSSOContactCalloutBatchdler :: callout :: Found :: response >>' + response);
        system.debug(' SSOContactCalloutBatch :: callout :: Found :: response >>' + response.getBody());
        responseArr = SSOHandler.handleResponse(response);
        if (responseArr[0] == 'Success') {
            sendEmail(user.Id, user.Email);
        }

        return responseArr;
    }
    
    private static String generatePassword(Integer length) {
        String password = '';

        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz!@#$%^&*()-_=+';
        while (password.length() < length) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            password += chars.substring(idx, idx+1);
        }

        return password;
    }
    
    private static void sendEmail (Id userId, string emailAddress) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(userId); 
        message.setSaveAsActivity(false); 
        
        List<OrgWideEmailAddress> orgEmailAddrList = [select id, Address from OrgWideEmailAddress where DisplayName='simdigital_noreply'];
        If(orgEmailAddrList.size()>0){
            message.setOrgWideEmailAddressId(orgEmailAddrList[0].Id);
        }
        
        EmailTemplate emailTemplate = [SELECT Id
                                        FROM EmailTemplate 
                                        WHERE DeveloperName = 'SIM_PD_User_Registration_B2B'];

        message.setTemplateID(emailTemplate.Id); 

        message.toAddresses = new String[] { emailAddress };
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage> { message };
        List<Messaging.SendEmailResult> results = Messaging.sendEmail(messages);
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } 
        else {
            System.debug('The email failed to send:'  +  results[0].errors[0].message);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        If(listApplicationLog.size()>0){
            insert listApplicationLog;
        }
	}
}