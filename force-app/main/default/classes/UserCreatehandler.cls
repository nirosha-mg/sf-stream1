/**
 * @description       : this class create the user record of B2B learner
 * @author            : Ravi Gupta(TMC)
 * @group             : 
 * @last modified on  : 30 march 2021
 * Modifications Log 
 * Ver      Date        	    Author                                     Modification
 * mvp1.1   30 march 2021  Ravi Gupta 
**/
public class UserCreatehandler {

    public static void createUser(set<Id> conList,map<string,List<string>> mapContactIdAndEmail){
        system.debug('conList'+conList);
        set<Id> contactIdToExclude = new set<Id>();
        set<Id> existingUserWithContactEmail= new set<Id>();
        List<Id> userIds = new List<Id>();
        map<string,string> mapContactIdAndUserName = new map<string,string>();
        set<string> contactEmail = new set<string>();
        List<User> userList =[select Id,ContactId from User where ContactId in:conList];
        for(User u:userList){
            contactIdToExclude.add(u.ContactId);
        }
        // remove all the contact Id that having user already
        if(contactIdToExclude.size()>0){
         	conList.removeAll(contactIdToExclude);   
        }
        List<Contact> contactList =[select Id,Email from Contact where Id in:conList];
        for(Contact c:contactList){
            if(c.Email != NULL){
                String usernameDomain = 'sso.sim.edu.sg';
                String username = c.Email;
                username = username.split('@')[0] + '.' + username.split('@')[1] + '@' + usernameDomain;
                //emailContact.add(username);
                contactEmail.add(username);   
            }
        }
        List<User> userListWithExistingEmailAsUserName = new List<User>();
        if(contactEmail.size()>0){
            /*set<string> emailContact = new set<string>();
            String usernameDomain = 'sso.sim.edu.sg';
            for(String str:contactEmail){
                String username = str;
                username = username.split('@')[0] + '.' + username.split('@')[1] + '@' + usernameDomain;
                emailContact.add(username);
            }*/
            // doing query in order to fetch the user when there is user with contatc email
            userListWithExistingEmailAsUserName =[select Id,ContactId,UserName,Email  from User where UserName in:contactEmail];
            
            for(User u:userListWithExistingEmailAsUserName){
                if(mapContactIdAndEmail.ContainsKey(u.Email)){
                    for(string str:mapContactIdAndEmail.get(u.Email)){
                        existingUserWithContactEmail.add(str);
                    }   
                }
            }   
        }
        if(existingUserWithContactEmail.size()>0){
            // removing the contact whose user with email already exist 
         	conList.removeAll(existingUserWithContactEmail);   
        }
        system.debug('conList'+conList);
        // query the record when there is no user with email and user with particular contact
        List<Contact> contactListForNewUser =[select Id,Email from Contact where Id in:conList];
        for(Contact c:contactListForNewUser){
            if(c.Email != null ){
                mapContactIdAndUserName.put(c.Id,c.Email);
            }
        }
        // creating the list of username when there is User with contact email
        /*List<Contact> contactListForExistingEmailUser = new List<Contact>();
        if(existingUserWithContactEmail.size()>0){
            contactListForExistingEmailUser =[select Id,Email,SIM_Contact_No__c,Account.SIM_Account_No__c from Contact where Id in:existingUserWithContactEmail];
            for(Contact c:contactListForExistingEmailUser){
                string usrName;
                if(c.Account.SIM_Account_No__c != null && c.SIM_Contact_No__c != NULL){
                    usrName=c.SIM_Contact_No__c+'@'+c.Account.SIM_Account_No__c+'.com'; 
                    mapContactIdAndUserName.put(c.Id,usrName);
                }
                
            }
        }*/
        List<User> userListCreated = new List<User>();
        if(mapContactIdAndUserName.keySet()!= NULL && mapContactIdAndUserName.keySet().Size()>0){
            /*List<User> userListOnContact = [select Id,ContactId from User where ContactId in :mapContactIdAndUserName.keySet()];
            for(User u:userListOnContact){
                if(mapContactIdAndUserName.ContainsKey(u.ContactId)){
                    mapContactIdAndUserName.remove(u.ContactId);
                }
            }*/
            system.debug('mapContactIdAndUserName'+mapContactIdAndUserName);
            userListCreated=prepareUser(mapContactIdAndUserName);
        }
        if(userListCreated.size()>0){
            insert userListCreated;
        }
        for(user u:userListCreated){
            userIds.add(u.Id);
        }
        if (userIds.size() > 0) {
            //System.enqueueJob(new SSOQueueable(userIds));
            Database.executeBatch(new SSOContactCalloutBatch(userIds),1);
        }
    }
    /**
    * @description 
    * @author Ravi | 31-03-2021 
    * @param user 
    * @return List<User> 
    **/
    public static List<User> prepareUser(map<string,string> contactIdAndUser ) {
        List<User> userList = new List<User>();
        List<Profile> b2bLearner = [SELECT Id FROM Profile WHERE Name = 'B2B Learner' LIMIT 1];
        Id b2bLearnerRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('B2B_Learner').getRecordTypeId();
        List<Contact> contactRecordList=[select Id,FirstName,LastName,Email,RecordTypeId from Contact where Id in:contactIdAndUser.keySet()];
            for (Contact conObj : contactRecordList) {
                if(conObj.RecordTypeId == b2bLearnerRT) {
                    if(contactIdAndUser.containsKey(conObj.Id)){
                        Id userProfileId = b2bLearner[0].Id;
                        User user = new User();
                        user.FirstName = conObj.FirstName;
                        user.LastName = conObj.LastName;
                        //user.CommunityNickname = contact.FirstName + ' ' + contact.LastName;
                        String usernameDomain = 'sso.sim.edu.sg';
                        String username = contactIdAndUser.get(conObj.Id);
                        username = username.split('@')[0] + '.' + username.split('@')[1] + '@' + usernameDomain;
                       	user.Username = username; 
                        user.Email = contactIdAndUser.get(conObj.Id);//conObj.Email;
                        user.FederationIdentifier = username;
                        user.ProfileId = userProfileId;
                        user.TimeZoneSidKey = 'Asia/Singapore';
                        user.LanguageLocaleKey='en_US';
                        user.LocaleSidKey='en_SG';
                        user.ContactId = conObj.Id;
                        user.Alias = conObj.LastName.left(8);
                        user.EmailEncodingKey = 'UTF-8';
                        userList.add(user);   
                    }
                }
            }
        return userList;
    }
    /*public static void checkUserExistWithContactEmail(list<Contact> newContact){
        set<string> EmailContacts = new set<string>();
        set<string> userEmail = new set<string>();
        for(Contact c:newContact){
            if(c.Email != NULL){
                String usernameDomain = 'sso.sim.edu.sg';
                String username = c.Email;
                username = username.split('@')[0] + '.' + username.split('@')[1] + '@' + usernameDomain;
                EmailContacts.add(username);
            }
        }
        List<User>  existingUserListWithContactEmail =[select Id,ContactId,Email from User where UserName in:EmailContacts];
        for(User u:existingUserListWithContactEmail){
                userEmail.add(u.Email);
        }
        for(Contact cr:newContact){
            if(userEmail.Contains(cr.Email)) {
                cr.Email.addError('Another user with same email exist');
            }
        }
    }*/
}