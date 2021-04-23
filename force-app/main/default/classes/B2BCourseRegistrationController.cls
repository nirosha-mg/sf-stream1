/*************************************************************************************************************
* @name            B2BCourseRegistrationController
* @author          TMC\Devender Singh (tmc)
* @created         08 / 03 / 2021
* @description     Description of your code
*
* Changes (version)
* -----------------------------------------------------------------------------------------------------------
*              No.     Date            Author                       Description
*              ----    ------------    --------------------    ----------------------------------------------
* @version     1.1     2021-04-13      Devender Singh      Added the getPromoCode method for Promo code functinality
**************************************************************************************************************/
public without sharing class B2BCourseRegistrationController {
    
    @AuraEnabled
    public static ContactInformation getContactRecord(){
        ContactInformation objContactInformation;
        Contact contactRecord = new Contact();
        Id userId = UserInfo.getUserId();
        system.debug(' 19 userId ----> '+userId);
        User userInfo = [SELECT ContactId FROM User WHERE Id=:userId];
        for(contact iterator :  [SELECT Id,Name,FirstName,LastName,Salutation,Persons_with_Disabilities__c,Education_Level__c,NRIC__c,
                                 Employment_Status__c,Gender__c,Monthly_Basic_Salary__c,Date_of_Birth__c,Designation_Level__c,
                                 Nationality__c,Designation__c,Residency_Status__c,title,Race__c,MobilePhone,email,
                                 Secondary_Salutation__c,homephone,Secondary_Email_Address__c,Secondary_Mobile_Number__c,Remarks__c,
                                 Secondary_Contact_Name__c,Attention__c,OtherPhone,phone,Billing_Address_Line_1__c,Billing_Address_Line_2__c,
                                 Billing_Address_Line_3__c,Billing_City__c,Billing_State__c,Billing_Country__c,Billing_Postal_Code__c,
                                 RMIT_Alumni__c,Account.Membership_Active__c,Alternative_Attention__c,Alternative_Billing_Address1__c,
                                 Alternative_Phone__c,Alternative_Billing_Address2__c,Alternative_Email__c,
                                 Alternative_Billing_Address3__c,Alternative_City__c,Alternative_State__c,Alternative_PostalCode__c,
                                 Alternative_Country__c,NRIC_Type__c,Account.Id,Account.RecordType.DeveloperName,Account.Billing_Address_Line_1__c, 
                                 Account.Billing_Address_Line_2__c,Account.Billing_Address_Line_3__c,Account.Billing_City__c, 
                                 Account.Billing_Country__c, Account.Billing_Postal_Code__c,Account.billing_state__c, Account.City__c, 
                                 Account.IsPersonAccount,Office_No__c,account.UEN_No__c,Primary_Email_Address__c,
                                 Preferred_Certificate_Name__c,Company_Name__c,account.Preferred_Contact_Method__c,account.Address_Type__c,
                                 Account.Billing_Contact_Person__c,Account.Country__c,Account.Name,Account.Membership_No__c,Account.Membership_Payment_Status__c
                                 FROM Contact WHERE Id=:userInfo.ContactId]){
                                     //
                                     if(iterator.Account.IsPersonAccount){
                                         objContactInformation = new ContactInformation(iterator,
                                                                                        iterator.account.Billing_Address_Line_1__c,
                                                                                        iterator.account.Billing_Address_Line_2__c,
                                                                                        iterator.account.Billing_Address_Line_3__c,
                                                                                        iterator.account.Billing_City__c,
                                                                                        iterator.account.Billing_Country__c,
                                                                                        iterator.account.Billing_Postal_Code__c,
                                                                                        iterator.account.Billing_State__c,
                                                                                        null,
                                                                                        null);
                                     }else if(iterator.Account.RecordType.DeveloperName == 'B2B_Account'){
                                         objContactInformation = new ContactInformation(iterator,
                                                                                        iterator.Account.Billing_Address_Line_1__c,
                                                                                        iterator.Account.Billing_Address_Line_2__c,
                                                                                        iterator.Account.Billing_Address_Line_3__c,
                                                                                        iterator.Account.Billing_City__c,
                                                                                        iterator.Account.Billing_Country__c,
                                                                                        iterator.Account.Billing_Postal_Code__c,
                                                                                        iterator.Account.Billing_state__c,
                                                                                        iterator.Account.City__c,
                                                                                        iterator.Account.Country__c);
                                     }
                                 }
        return objContactInformation;
        // if contact is person account then current logic remains is PersonAccount == true
        // if contact-Account recordtype is = B2b Account then replace all  the Billing fields from contact to Account
        
    }
    
    @AuraEnabled
    public static Course_Run__c getCourseRunRecord(string courseRunCode) {
        Course_Run__c courseRun = B2bUtility.getCourseRunRecord(courseRunCode);
        return  courseRun ;  
    }   
    
    @AuraEnabled
    public static Course_Run__c getCourseRunRecordPE(string courseRunId) {
        Course_Run__c courseRun = new Course_Run__c();
        Id userId = UserInfo.getUserId();
        system.debug('95 userId ----> '+userId);
        system.debug('courseRunCode ----> '+courseRunId);
        if(courseRunId != null) {
            List<Course_Run__c> courseRuns = [select Id,Name,Course__c,Course_Run_Code__c,Start_Date__c,End_Date__c,Course__r.Name,Course__r.Course_Type__c,
                                              Course__r.Member_Fee__c,Certificate_Course_Name__c,
                                              Course__r.Non_Member_Fee__c,Course__r.Full_Fee__c,CourseRecordType__c,
                                              Registration_Open_Date__c,Registration_Close_Date__c,Active__c,Capacity__c,course__r.Funding__c,
                                              Course__r.Provider__c,(select id,Registration_Status__c,Payment_Status__c,RecordType.Name from Course_Registrations__r), Course__r.AccountId__c, 
                                              Course__r.Full_Fee_with_GST__c,Course__r.RMIT_Alumni_Fee__c, Course__r.Course_Title__c, Course__r.Member_Total_Fee__c, Course__r.Non_Member_Total_Fee__c, 
                                              Course__r.RMIT_Total_Fee__c,
                                              Course__r.Need_PII__c,Course__r.RecordType.Name
                                              from Course_Run__c where Id =: courseRunId];
            if (courseRuns.size() > 0) {
                courseRun = courseRuns[0].Course__r.AccountId__c == null ? courseRuns[0] : new Course_Run__c();
            }
        }
        
        return courseRun;
    }   
    
    @AuraEnabled
    public static contact getContactSearchRecord(string contactId) {
        system.debug('contactId --> '+contactId);
        contact con=B2bUtility.getContactSearch(contactId);
        return con;
    }
    
    @AuraEnabled
    public static List<Course_Registration__c> checkContactRegistration(string courseRegistrationId) {
        system.debug('courseRegistrationId --> '+courseRegistrationId);
        List<Course_Registration__c> courseReg=B2bUtility.checkContactRegistration(courseRegistrationId);
        // List<Course_Registration__c> courseReg=new List<Course_Registration__c>();
        return courseReg;
    }
    @AuraEnabled
    public static List<Course_Registration__c> getDraftRegistrations(string courseRunid,string ContactId) {
        if(string.isEmpty(ContactId))
            ContactId=[select ContactId from User where id=:Userinfo.getUserId()].ContactId;
        
        
        List<Course_Registration__c> listcourseReg=new List<Course_Registration__c>();
        
        system.debug('courseRunid --> '+courseRunid);
        system.debug('ContactId --> '+ContactId);
        
        if(!string.isEmpty(ContactId)){
            listcourseReg = [SELECT Id,Salutation__c,IsMember__c,First_Name__c,Contact__c,
                             RMIT_Alumni__c,Last_Name__c,Date_of_Birth__c,Parent_Registration__c,
                             Preferred_Certificate_Name__c,Gender__c,Email_Address__c,Mobile_No__c,Nationality__c,
                             Race__c,Office_No__c,Residency_Status__c,Education_Level__c,NRIC_Type__c,NRIC__c,
                             Secondary_Salutation__c,Secondary_Name__c,Secondary_Email_Address__c,Secondary_Mobile__c,Remarks__c,
                             Employment_Status__c,Designation_Level__c,Job_Title__c,How_did_you_get_to_know_us__c,
                             PDPA_Consent_Clause__c,Marketing_Consent_Clause__c,Need_User_Account__c,Parent_Registration__r.Promo_Code__c,
                             Parent_Registration__r.Promo_Code__r.Name,
                             Parent_Registration__r.Promo_Code__r.Is_Active__c, Parent_Registration__r.Promo_Code__r.Start_Date__c, Parent_Registration__r.Promo_Code__r.End_Date__c, Parent_Registration__r.Promo_Code__r.Discount_Type__c, 
                             Parent_Registration__r.Promo_Code__r.Discount_Amount__c, Parent_Registration__r.Promo_Code__r.Discount_Percentage__c, Parent_Registration__r.Promo_Code__r.Course__c, Parent_Registration__r.Promo_Code__r.Account__c, 
                             Parent_Registration__r.Promo_Code__r.Applicable_on__c
                             from Course_Registration__c 
                             WHERE Parent_Registration__r.Course_Run_id__c =:courseRunid  AND Parent_Registration__r.RecordType.Name='Master Course Registration'
                             AND Parent_Registration__r.Contact__c=:ContactId AND Parent_Registration__r.Registration_Status__c='Draft'
                             AND Parent_Registration__r.Payment_Status__c='Unpaid'];
            
        }
        system.debug('listcourseReg --> '+listcourseReg);
        return listcourseReg;
    }
    
    /*@AuraEnabled
public static List<Course_Registration__c> checkContactRegistrationTest(string courseRegistrationId) {
system.debug('courseRegistrationId --> '+courseRegistrationId);
List<Course_Registration__c> courseReg=B2bUtility.checkContactRegistration(courseRegistrationId);
return courseReg;
}*/
    
    @AuraEnabled
    public static Id checkContactRegistration1(Id courseRunId) {
        Id courseRegistrationId = null;
        try {
            Id userId = UserInfo.getUserId();
            User userInfo = [SELECT ContactId FROM User WHERE Id=:userId];
            //2101281715 Desmond Check for Status Not Cancelled
            List<Course_Registration__c> courseReg = [SELECT Id FROM Course_Registration__c 
                                                      WHERE Contact__c =: userInfo.ContactId 
                                                      AND Course_Run_Id__c =: courseRunId
                                                      AND Registration_Status__c!='Cancelled'];
            if (courseReg.size() > 0) {
                courseRegistrationId = courseReg[0].Id;
            }
        } catch (Exception e) {
            Application_Log__c appLog = AppLogUtility.createApplicationLog(e.getMessage() + '\n' + e.getStackTraceString() + '\nUser Id: ' + UserInfo.getUserId() + '\nCourse Run Id: ' + courseRunId, 
                                                                           'CourseRegistrationController', 
                                                                           'contactId');
            insert appLog;
        }
        return courseRegistrationId;
    }
    @AuraEnabled
    public static string returnInvoice(id courseRegId,List<string> listcourseRegId ) {
        string invoiceId;
        system.debug('courseRegId --> '+courseRegId);
        system.debug('listcourseRegId --> '+listcourseRegId);
        //if(string.isNotBlank(courseRegId)){
        if(courseRegId != null){
            invoiceId = B2BInvoiceUtility.generateInvoiceForRegistration(courseRegId,listcourseRegId);
        }
        system.debug('invoiceId --> in B2BCourRescls'+invoiceId);
        if(String.isNotBlank(invoiceId)) {
            try {
                List<Generate_Invoice__e> invoiceList = new List<Generate_Invoice__e>();
                invoice__c invoice = [select id,Status__c from invoice__c where id =: invoiceId limit 1];
                invoice.Status__c = 'Invoice Generation - In Progress';
                update invoice;
                
                Application_Log__c appLog = new Application_Log__c();
                appLog.Platform_Event_Name__c = 'Generate_Invoice__e';
                appLog.RecordId__c = invoiceId;
                appLog.RequestedBy__c = userinfo.getuserid();
                insert appLog;
                
                Generate_Invoice__e invoiceEvent = new Generate_Invoice__e();
                invoiceEvent.ApplicationLogId__c = appLog.id;
                invoiceEvent.RecordId__c = invoiceId;
                invoiceList.add(invoiceEvent);
                
                List<Database.SaveResult> results = EventBus.publish(invoiceList);
                
                // Inspect publishing result for each event
                for (Database.SaveResult sr : results) {
                    if (sr.isSuccess()) {
                        System.debug('Successfully published event.');
                    } else {
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('Error returned: ' +
                                         err.getStatusCode() +' - ' + err.getMessage());
                        }
                    }       
                }
                
            } catch(Exception e){
                insert AppLogUtility.createApplicationLog(e.getStackTraceString(), 'InvoiceUtility', courseRegId);
            }
        }
        
        return invoiceId;
    }
    @AuraEnabled
    public static void DeleteCourseRegistration(List<string> lstDeleteCourseRegistration){
        try{
            system.debug('lstDeleteCourseRegistration --> '+lstDeleteCourseRegistration);
            Set<id> SetContactId=New  Set<id> ();
            List<Contact> DeleteContact;
            List<Course_Registration__c> DeleteCourseRegistration=[select id,Contact__r.id from Course_Registration__c 
                                                                   WHERE Id IN: lstDeleteCourseRegistration];
            if(DeleteCourseRegistration.size()>0){
                for(Course_Registration__c corReg:DeleteCourseRegistration){
                    SetContactId.add(corReg.Contact__r.id);
                } 
            }
            /*if(SetContactId.size()>0){
DeleteContact=[select Id from contact where Id IN:SetContactId];
}*/
            if(DeleteCourseRegistration.size()>0)
                delete DeleteCourseRegistration;
            /*if(DeleteContact.size()>0)
delete DeleteContact;*/
        }
        catch(Exception e){
            throw e;
        }   
    }
    
    @AuraEnabled
    public static courseRegformation SaveCourseRegistration(List<Course_Registration__c> lstCourseRegistration,string courseRunCode,string RegistrationStatus,list<string> lookupContactId,string UserId,string PromoCode) {
        system.debug('lstCourseRegistration ---> '+lstCourseRegistration);
        system.debug('courseRunCode ---> '+courseRunCode);
        system.debug('UserId SaveCourseRegistration ---> '+UserId);
        courseRegformation objcourseRegformation=New courseRegformation();
        try{
            string courseRegId='';
            Set<Id> SetOfcourseReg;
            Map<string,string> mapOfExistingLookUpContact=New Map<string,string>();
            if(lookupContactId.size()>0){
                for(string str:lookupContactId){
                    mapOfExistingLookUpContact.put(str,str);
                }
            }
            Set<string> SetOfContact=B2bUtility.CreateContact(lstCourseRegistration,mapOfExistingLookUpContact,UserId);
            system.debug('SetOfContact ---> '+SetOfContact);
            if(SetOfContact.size()>0){
                courseRegId=B2bUtility.CreateMasterCourseRegistration(lstCourseRegistration,courseRunCode,RegistrationStatus,UserId,PromoCode);
                system.debug('CourseRegistrationId ---> '+courseRegId);
                if(string.isNotEmpty(courseRegId))
                    SetOfcourseReg=B2bUtility.CreateCourseRegistration(SetOfContact,lstCourseRegistration,courseRegId,courseRunCode,RegistrationStatus,UserId);
            }
            objcourseRegformation.courseRegId=courseRegId;
            objcourseRegformation.setOfcourseReg=SetOfcourseReg;
            
            if(string.isNotEmpty(courseRegId) && RegistrationStatus.toUpperCase()=='NEW' ){
                List<string> lstCoursReg=New List<string>();
                lstCoursReg.add(courseRegId);
                B2bUtility.sendRegistrationEmail(lstCoursReg);
            } 
            return objcourseRegformation;
        }catch(exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    @AuraEnabled
    public static User getContactDetails(string userId){
        return [SELECT ContactId,AccountId,Contact.name,Account.name,profile.Name FROM User where id=:userId];
    }
    
    
    @AuraEnabled
    public static courseRegformation UpdateCourseRegistration(List<Course_Registration__c> lstCourseRegistration,string CourseRegistrationMasterId,string RegistrationStatus,list<string> lookupContactId,string UserId,string courseRunCode,string PromoCode) {
        system.debug('lookupContactId 			---> '+lookupContactId);
        Map<string,Course_Registration__c> MapOfExistingContact=New Map<string,Course_Registration__c>();
        Map<Id,Course_Registration__c> MapOfExistingCourseRegistration=New Map<Id,Course_Registration__c>();
        Map<string,string> mapOfExistingLookUpContact=New Map<string,string>();
        courseRegformation objcourseRegformation=new courseRegformation();
        
        for (Course_Registration__c CouReg : [SELECT Id,Salutation__c,IsMember__c,First_Name__c,
                                              RMIT_Alumni__c,Last_Name__c,Date_of_Birth__c,
                                              Preferred_Certificate_Name__c,Gender__c,Email_Address__c,Mobile_No__c,Nationality__c,
                                              Race__c,Office_No__c,Residency_Status__c,Education_Level__c,NRIC_Type__c,NRIC__c,
                                              Secondary_Salutation__c,Secondary_Name__c,Secondary_Email_Address__c,Secondary_Mobile__c,Remarks__c,
                                              
                                              Contact__c,Contact__r.Secondary_Salutation__c,Contact__r.firstname,
                                              Contact__r.lastname,Contact__r.Date_of_Birth__c,Contact__r.Preferred_Certificate_Name__c,
                                              Contact__r.Gender__c,Contact__r.Email,Contact__r.MobilePhone,
                                              Contact__r.Mobile_Number__c,Contact__r.Nationality__c,Contact__r.HomePhone,
                                              Contact__r.Office_No__c,Contact__r.Employment_Status__c,Contact__r.Title,
                                              Contact__r.Designation_Level__c,Contact__r.NRIC_Type__c,Contact__r.NRIC__c	
                                              from Course_Registration__c  where Parent_Registration__c=:CourseRegistrationMasterId]) { 
                                                  MapOfExistingCourseRegistration.put(CouReg.Id,CouReg);
                                                  MapOfExistingContact.put(CouReg.Contact__c,CouReg);
                                              }
        
        if(lookupContactId.size()>0){
            for(string str:lookupContactId){
                mapOfExistingLookUpContact.put(str,str);
            }
        }
        
        try{
            Set<string> SetOfContact=B2bUtility.UpsertContact(MapOfExistingContact,lstCourseRegistration,mapOfExistingLookUpContact,UserId);
            system.debug('SetOfContact ---> '+SetOfContact);
            Course_Registration__c obj=new Course_Registration__c();
            obj.Id=CourseRegistrationMasterId;
            //system.debug('PromoCode ---> '+PromoCode);
            if(string.isNotEmpty(PromoCode))
                obj.Promo_Code__c=PromoCode;
            else
                obj.Promo_Code__c=null;
            obj.Registration_Status__c=RegistrationStatus;
            update obj;
            //B2bUtility.UpdateRegistration(CourseRegistrationMasterId,RegistrationStatus);
            
            Set<Id> setCourseRegistrationId=B2bUtility.UpdateCourseRegistration(SetOfContact,lstCourseRegistration,CourseRegistrationMasterId,courseRunCode,MapOfExistingCourseRegistration,UserId);
            objcourseRegformation.courseRegId=CourseRegistrationMasterId;
            objcourseRegformation.setOfcourseReg=setCourseRegistrationId;
            
            if(string.isNotEmpty(CourseRegistrationMasterId) && RegistrationStatus.toUpperCase()=='NEW' ){
                List<string> lstCoursReg=New List<string>();
                lstCoursReg.add(CourseRegistrationMasterId);
                B2bUtility.sendRegistrationEmail(lstCoursReg);
            }
            
            return objcourseRegformation;
        }catch(exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<String> getIdentificationType(){
        list<string> listIdentificationType=new list<string>();
        Schema.DescribeFieldResult fieldResult = Course_Registration__c.NRIC_Type__c.getDescribe();
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues)
            listIdentificationType.add(p.getLabel());
        return listIdentificationType;   
    }
    @AuraEnabled
    public static list<string> getNationality(){
        list<string> listNationality=new list<string>();
        Schema.DescribeFieldResult fieldResult = Course_Registration__c.Nationality__c.getDescribe();
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues) 
            listNationality.add(p.getValue());
        return  listNationality;
    }
    @AuraEnabled
    public static list<string> getEmploymentStatus(){
        list<string> listEmploymentStatus=new list<string>();
        Schema.DescribeFieldResult fieldResult = Course_Registration__c.Employment_Status__c.getDescribe();
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues) 
            listEmploymentStatus.add(p.getLabel());
        return  listEmploymentStatus;
    }
    @AuraEnabled
    public static list<string> getDesignationLevel(){
        list<string> listCourseRegistration=new list<string>();   
        Schema.DescribeFieldResult fieldResult = Course_Registration__c.Designation_Level__c.getDescribe();
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues) 
            listCourseRegistration.add(p.getLabel());
        return  listCourseRegistration;
    }
    @AuraEnabled
    public static string validateNRICValue(string nricVal) {
        string isValid = 'valid';
        Map<Decimal,string> nricMap = CourseRegistrationTriggerHandler.returnNRICGrid();
        Map<Decimal,string> nricMapone = CourseRegistrationTriggerHandler.returnNRICGrid_F();
        Integer nricsum = 2 * Integer.valueOf(nricVal.substring(1,2)) +
            7 * Integer.valueOf(nricVal.substring(2, 3)) +
            6 * Integer.valueOf(nricVal.substring(3, 4)) +
            5 * Integer.valueOf(nricVal.substring(4, 5)) +
            4 * Integer.valueOf(nricVal.substring(5,6)) +
            3 * Integer.valueOf(nricVal.substring(6, 7)) +
            2 * Integer.valueOf(nricVal.substring(7, 8)); 
        if(nricVal.substring(0,1) == 'S') {
            Integer nricremainder = Math.mod(nricsum , 11);   
            if(nricMap.containskey(nricremainder) &&  nricMap.get(nricremainder)!= null &&
               nricMap.get(nricremainder) != nricVal.substring(8, 9)) {
                   isValid = 'invalid';
               }
        } 
        else if(nricVal.substring(0,1) == 'T') {
            Integer nricremainder = Math.mod(nricsum + 4, 11);               
            if(nricMap.containskey(nricremainder) &&  nricMap.get(nricremainder)!= null &&
               nricMap.get(nricremainder) != nricVal.substring(8, 9)) {
                   isValid = 'invalid'; 
               }
        }
        else if(nricVal.substring(0,1) == 'F') {
            Integer nricremainder=Math.mod(nricsum , 11);               
            if(nricMapone.containskey(nricremainder) &&  nricMapone.get(nricremainder)!= null &&
               nricMapone.get(nricremainder) != nricVal.substring(8, 9)) {
                   isValid = 'invalid'; 
               }
        }
        else if(nricVal.substring(0,1)=='G'){
            Integer nricremainder=Math.mod(nricsum + 4, 11);               
            if(nricMapone.containskey(nricremainder) &&  nricMapone.get(nricremainder)!= null &&
               nricMapone.get(nricremainder) != nricVal.substring(8, 9)) {
                   isValid = 'invalid';  
               }
        }        
        return isValid;
    }
    @AuraEnabled
    public static List<string> checkUserWithContact(List<string> emailList){
        // defined to store the email and corresponding msg where user exist with same email
        List<string> setOfEmailAndExistingMsg = new List<string>();
        set<string> userList = new set<string>();
        set<string> resuserList = new set<string>();
        for(String str:emailList){
            resuserList.add(str);
        }
        for(String str:resuserList){
            String usernameDomain = 'sso.sim.edu.sg';
            String username = str;
            username = username.split('@')[0] + '.' + username.split('@')[1] + '@' + usernameDomain;
            userList.add(username);
        }
        // getting user exist with particular Email
        List<User> usrRecord=  [select Id,Email from User where UserName in:userList];
        if(usrRecord.size()>0){
            for(User u:usrRecord){
                setOfEmailAndExistingMsg.add(u.Email);
            }
        }
        system.debug('setOfEmailAndExistingMsg --> '+setOfEmailAndExistingMsg);
        return setOfEmailAndExistingMsg;
    }
    public class courseRegformation{
        @AuraEnabled
        public string courseRegId { get; set; }
        @AuraEnabled
        public set<id> setOfcourseReg { get; set; }
    }
    
    public class ContactInformation{
        @AuraEnabled
        public Contact objContact { get; set; }
        @AuraEnabled
        public string billingAddressLine1 { get; set; }
        @AuraEnabled
        public string billingAddressLine2 { get; set; }
        @AuraEnabled
        public string billingAddressLine3 { get; set; }
        @AuraEnabled
        public string billingCity { get; set; }
        @AuraEnabled
        public string billingCountry { get; set; }
        @AuraEnabled
        public string billingPostalCode{ get; set; }
        @AuraEnabled
        public string billingState{ get; set; }
        @AuraEnabled
        public string city { get; set; }
        @AuraEnabled
        public string country { get; set; }
        
        public ContactInformation(Contact objContact,
                                  string billingAddressLine1,
                                  string billingAddressLine2,
                                  string billingAddressLine3,
                                  string billingCity,
                                  string billingCountry ,
                                  string billingPostalCode,
                                  string billingState,
                                  string city,
                                  string country){
                                      //
                                      this.objContact=objContact;
                                      this.billingAddressLine1=billingAddressLine1;
                                      this.billingAddressLine2=billingAddressLine2;
                                      this.billingAddressLine3=billingAddressLine3;
                                      this.billingCity=billingCity;
                                      this.billingCountry=billingCountry;
                                      this.billingPostalCode=billingPostalCode;
                                      this.billingState=billingState;
                                      this.city=city;
                                      this.country=country;
                                  }
    }
    // MVP1.1:Added by Devender on 13 april 2021 to check the Promo code
    @AuraEnabled
    public static Wrapper getPromoCode(string promocode,string courseId, Date registrationStartDate,string UserId) {
        system.debug('promocode --> '+promocode);
        system.debug('courseId --> '+courseId);
        system.debug('registrationStartDate --> '+registrationStartDate);
        Date sToday=System.today();
        Wrapper objWrapper=New Wrapper();
        Promo_Code__c  recPromoCode=New Promo_Code__c();
        /*Id userId = UserInfo.getUserId();
        User userInfo = [SELECT ContactId FROM User WHERE Id=:userId];
        Contact contactInfo = [SELECT AccountId FROM Contact WHERE Id=:userInfo.ContactId];*/
        
        Contact con=B2bUtility.getContact(UserId);
        system.debug('B2bUtility AccountId ---> '+con.AccountId);
        string sownerAccount=B2bUtility.getOwnerId(con.AccountId);
        
        if(string.isNotEmpty(promocode)){
            List<Promo_Code__c> recPromoCodes=[SELECT Account__c, Id, Name, Is_Active__c, Start_Date__c, End_Date__c, 
                                               Discount_Type__c, Applicable_on__c,Discount_Amount__c,Discount_Percentage__c, 
                                               Course__c
                                               FROM Promo_Code__c WHere Name =:promocode AND Is_Active__c=True
                                               AND Start_Date__c<=:sToday AND End_Date__c>=:sToday];
            if (recPromoCodes.size() > 0) {
                recPromoCode=recPromoCodes[0].Account__c == null || recPromoCodes[0].Account__c == sownerAccount ? recPromoCodes[0] : null;
                if(recPromoCode!=null){
                    recPromoCode=recPromoCodes[0].Course__c == null || recPromoCodes[0].Course__c == courseId ? recPromoCodes[0] : null;
                }
            }
            else
                recPromoCode=null;
        }
        if(recPromoCode!=null){
            List<Course_Discount__c> cdisc = [SELECT Id,Course__r.Id, 
                                              Discount__r.No_of_Days__c,
                                              Discount__r.Percentage__c,
                                              Discount__r.Amount__c,
                                              Discount__r.GST_Amount__c
                                              FROM Course_Discount__c
                                              WHERE Course__c =: courseId];
            system.debug('registrationStartDate --> '+registrationStartDate);
            system.debug('cdisc --> '+cdisc);
            if(cdisc.size()>0){
                Integer noOfDays = Integer.valueOf(cdisc[0].Discount__r.No_of_Days__c) * -1;
                system.debug('noOfDays <= --> '+noOfDays);
                
                if (Date.today() >= registrationStartDate.addDays(noOfDays)) {
                    objWrapper.lstDiscount=cdisc;   
                }
            }
        }
        objWrapper.lstPromoCode=recPromoCode;
        
        return objWrapper;
    } 
    public class Wrapper{
        @AuraEnabled
        public Promo_Code__c lstPromoCode  { get; set; }
        @AuraEnabled
        public List<Course_Discount__c > lstDiscount  { get; set; }
    }
}