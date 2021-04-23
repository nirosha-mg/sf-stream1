/**
 * @description       : 
 * @author            : Mark Alvin Tayag (mtayag@salesforce.com)
 * @group             : 
 * @last modified on  : 11-12-2020
 * Modifications Log 
 * Ver   Date         Author                                     Modification
 * 1.0   10-11-2020   Mark Alvin Tayag (mtayag@salesforce.com)   Initial Version
**/
public without sharing class SSOHandler {
    public static List<Application_Log__c> listApplicationLog = new List<Application_Log__c>();

    public static Boolean createUser(List<Id> userIds) {
        Boolean success = false;
        List<User> updateUsers = new List<User>();
        List<User> userList = [SELECT FirstName, 
                                      LastName, 
                                      FederationIdentifier, 
                                      Email, 
                                      ContactId,
                                      UUID__c,
                                      Id
                              FROM User 
                              WHERE Id =: userIds];

        system.debug(' SSOHandler :: createUser :: Found :: userList >>' + userList);
        for (User user : userList) {
            Application_Log__c objApplicationLog = new Application_Log__c();
            objApplicationLog = AppLogUtility.createApplicationLog('', 'SSOHandler', user.id);
            try {
                List<String> responseArr = callout(user);
                success = (responseArr[0] == 'Success');
                objApplicationLog.Status__c = responseArr[0];
                if (success) {
                    User updUser = new User();
                    updUser.Id = user.Id;
                    updUser.UUID__c = responseArr[1];
                    updateUsers.add(updUser);
                }
                else {
                    objApplicationLog.Stacktrace__c = success ? '' : responseArr[1];
                }
                
            }
            catch (Exception e) {
                objApplicationLog.Status__c = 'Failure';
                objApplicationLog.Stacktrace__c = e.getMessage() + '\n' + e.getStackTraceString();
            }
            listApplicationLog.add(objApplicationLog);
        }

        if (listApplicationLog.size() > 0 && !System.isFuture()) {
            
            insertLogs(JSON.serialize(listApplicationLog)); //Future method due to Mixed DML with User
        }
        if (updateUsers.size() > 0) {
            update updateUsers;
        }
        system.debug(' SSOHandler :: createUser :: Found :: listApplicationLog >>' + listApplicationLog);
        return success;
    }
    
    /**
    * @description 
    * @author Rohit Pal | 10-22-2020 
    * @param user 
    * @return Boolean 
    **/
    public static List<String> callout(User user) {
        List<String> responseArr = new List<String>();

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        SSOWrapper wrapper = new SSOWrapper(user.FirstName, 
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
        system.debug(' SSOHandler :: callout :: Found :: request >>' + request);
        system.debug(' SSOHandler :: callout :: Found :: wrapper >>' + wrapper);

        //Send out the Request
        HttpResponse response = http.send(request);
        // Parse the JSON response
        system.debug(' SSOHandler :: callout :: Found :: response >>' + response);
        responseArr = handleResponse(response);
        if (responseArr[0] == 'Success') {
            sendEmail(user.Id, user.Email);
        }

        return responseArr;
    }

    public static List<String> handleResponse (HttpResponse response) {
        List<String> responseArr = new List<String>();
        if (response.getStatusCode() == 201 || //Created
            response.getStatusCode() == 204 || //Updated
            response.getStatusCode() == 409) { //Existing
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                responseArr.add('Success');
                responseArr.add(String.valueOf(jsonResponse.get('id'))); //Return UUID
        } 
        else {
            responseArr.add('Failure');
            responseArr.add('The status code returned was not expected: ' +
                            response.getStatusCode() + ' ' + response.getStatus());
        }

        return responseArr;
    }

    @future
    private static void insertLogs (String logsJson) {
        List<Application_Log__c> logs = (List<Application_Log__c>)JSON.deserialize(logsJson, List<Application_Log__c>.class);
        insert logs;
    }

    private static void sendEmail (Id userId, string emailAddress) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(userId); 
        message.setSaveAsActivity(false); 
        
        EmailTemplate emailTemplate = [SELECT Id
                                        FROM EmailTemplate 
                                        WHERE DeveloperName = 'SIM_PD_User_Registration'];

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

    public class SSOWrapper {
        public String firstName { get; set; }
        public String lastName { get; set; }
        public String email { get; set; }
        public String password { get; set; }
        public String phone { get; set; }
        public String federationId { get; set; }
        public String sfContactId { get; set; }
        public String sfUserId { get; set; }

        public SSOWrapper (String firstName, String lastName, String email, String password, String phone, String federationId, String sfContactId, String sfUserId) {
            this.firstName = firstName;
            this.lastName = lastName;
            this.email = email;
            this.password = password;
            this.phone = phone;
            this.federationId = federationId;
            this.sfContactId = sfContactId;
            this.sfUserId = sfUserId;
        }
    }

    //Used to prepare User Record for Self-Registration and Account/Contact Trigger
    public static User prepareUser(Id contactId, Id userProfileId) {
        Contact contact = [SELECT FirstName, LastName, Email FROM Contact WHERE Id=:contactId];

        return prepareUser(contact.FirstName, contact.LastName, contact.Email, contact.Id, userProfileId);
    }

    //Used to prepare User Record for Self-Registration and Account/Contact Trigger
    public static User prepareUser(String firstName, String lastName, String email, Id contactId, Id userProfileId) {
        //username domain
        String usernameDomain = 'sso.sim.edu.sg';
        String username = email;
        username = username.split('@')[0] + '.' + username.split('@')[1] + '@' + usernameDomain;
        User user = new User();
        user.FirstName = firstName;
        user.LastName = lastName;
        //user.CommunityNickname = contact.FirstName + ' ' + contact.LastName;
        user.Username = username; 
        user.Email = email;
        user.FederationIdentifier = email;
        user.ProfileId = userProfileId;
        user.TimeZoneSidKey = 'Asia/Singapore';
        user.LanguageLocaleKey='en_US';
        user.LocaleSidKey='en_SG';
        user.ContactId = contactId;
        user.Alias = lastName.left(8);
        user.EmailEncodingKey = 'UTF-8';
        return user;
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
}