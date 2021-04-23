/*************************************************************************************************************
 * @name            createLearnerUserClass
 * @author          Ravi Gupta (TMC)
 * @created         26 / 03 / 2021
 * @description     Apex class in order to create the Learner user : quick action on Course Registration
 * @last modified on  : 
 * @last modified by  : Ravi Gupta (TMC)
**************************************************************************************************************/
public class createLearnerUserClass {

    @AuraEnabled
    public static UserInformationWrapper checkUserWithContact(string courseRegId){
        List<User> usrRecord = new List<User>();
        UserInformationWrapper wrp = new UserInformationWrapper();
        wrp.courseRegistrationId=courseRegId;
        // getting user exist with particular contact 
        Course_Registration__c courseRegObj=  [select Id,Contact__c,Contact__r.Email,Contact__r.SIM_Contact_No__c,Contact__r.Account.SIM_Account_No__c,Account__r.SIM_Account_No__c,Email_Address__c from Course_Registration__c where Id=:courseRegId limit 1];
        if(courseRegObj.Contact__c != NULL){
            usrRecord =[select Id,ContactId from User where ContactId=:courseRegObj.Contact__c ];   
        }
        if(usrRecord.size()>0){
            wrp.Result='userExistWithContactId';
            wrp.contactId=courseRegObj.Contact__c;
            //return wrp;
        }else{
            if(courseRegObj.Email_Address__c != NULL){
                String usernameDomain = 'sso.sim.edu.sg';
                String username = courseRegObj.Email_Address__c;
                username = username.split('@')[0] + '.' + username.split('@')[1] + '@' + usernameDomain;
                List<User> usrRecordWithExistingEmail =[select Id,ContactId,UserName,Email  from User where UserName=:username];   
                if(usrRecordWithExistingEmail.size()>0){
                    wrp.Result='userExistWithEmailAsUserName';
                    /*wrp.Email=usrRecordWithExistingEmail[0].Email != null ? usrRecordWithExistingEmail[0].Email:NULL;
                    string usrName;
                    if(courseRegObj.Contact__r.Account.SIM_Account_No__c != null && courseRegObj.Contact__r.SIM_Contact_No__c != NULL){
                        usrName=courseRegObj.Contact__r.SIM_Contact_No__c+'@'+courseRegObj.Contact__r.Account.SIM_Account_No__c+'.com';
                    }
                    wrp.userName=usrName;
                    wrp.contactId=courseRegObj.Contact__c;*/
                }else{
                    wrp.Result='userDoesNotExistWithEmailAsUserName';
                    wrp.Email=courseRegObj.Email_Address__c;
                    wrp.userName=courseRegObj.Email_Address__c;
                    wrp.contactId=courseRegObj.Contact__c;
                }
            }
        }
        return wrp;
    }
    
    @AuraEnabled
    public static string createUser(string wrp){ 
        try{
            List<Id> userIds = new List<Id>();
            UserInformationWrapper wrapperinstance = new UserInformationWrapper();
            wrapperinstance = (UserInformationWrapper)JSON.deserialize(wrp, UserInformationWrapper.class);
            List<User> userList = UserCreatehandler.prepareUser(new map<string,string>{wrapperinstance.contactId => wrapperinstance.userName});
            
            if(userList.size()>0){
                insert userList;
            }
            for(user u:userList){
                userIds.add(u.Id);
            }
            if (userIds.size() > 0) {
                System.enqueueJob(new SSOQueueable(userIds));
            }
            if(wrapperinstance.courseRegistrationId != NULL && wrapperinstance.contactId != NULL){
                updateNeedUserAccount(wrapperinstance.courseRegistrationId,wrapperinstance.contactId,wrapperinstance.Email);   
            }
        }catch(Exception e){
            system.debug('--->>>>>msg'+e.getMessage() +'=====>>>>>LIne NO.'+e.getLineNumber());
            return 'FAIL:'+e.getMessage();
        }
       return 'SUCCESS';
        
        
    }
    @future
    public static void updateNeedUserAccount(string courseRegId,string contactId,string email){
        Contact cObj = new Contact();
        cObj.Id=contactId;
        cObj.Email=email;
        cObj.Need_User_Account__c='Yes';
        update cObj;
        Course_Registration__c cRegObj = new Course_Registration__c();
        cRegObj.Id=courseRegId;
        cRegObj.Need_User_Account__c='Yes';
        update cRegObj;
        
    }
    Public class UserInformationWrapper{
        @AuraEnabled
        public  string Result{get;set;}
        @AuraEnabled
        public  string Email{get;set;}
        @AuraEnabled
        public  string userName{get;set;}
        @AuraEnabled
        public  string contactId{get;set;}
        @AuraEnabled
        public string courseRegistrationId{get;set;}
    }
}