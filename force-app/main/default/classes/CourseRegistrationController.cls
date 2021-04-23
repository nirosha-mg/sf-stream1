/*************************************************************************************************************
 * @name            CourseRegistrationController
 * @author          BLR\Laxmi (Salesforce)
 * @created         14 / 10 / 2020
 * @description     Description of your code
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 *              No.     Date            Author                  Description
 *              ----    ------------    --------------------    ----------------------------------------------
 * @version     1.0     2020-10-14      BLR\Laxmi           Changes desription
 * @version     1.0     2020-10-14      BLR\rohit.pal       Change getContactRecord method to get the contact address information
 * @version     1.1     2021-03-05      Poon Koon           Update getContactRecord method to get the PDPA and Marketing consents info
 * @version     1.1     2021-04-13      Devender Singh      Added the getPromoCode method for Promo code functinality 
 * @version     1.2     2021-03-05      Poon Koon           Update getContactRecord method to get the Marketing channels info
**************************************************************************************************************/
public without sharing class CourseRegistrationController {
    
    @AuraEnabled
    public static ContactInformation getContactRecord(){
        ContactInformation objContactInformation;
        Contact contactRecord = new Contact();
        Id userId = UserInfo.getUserId();
        User userInfo = [SELECT ContactId FROM User WHERE Id=:userId];
        for(contact iterator :  [SELECT Id,Name,FirstName,LastName,Salutation,Persons_with_Disabilities__c,Education_Level__c,NRIC__c,
                         Employment_Status__c,Gender__c,Monthly_Basic_Salary__c,Date_of_Birth__c,Designation_Level__c,
                         Nationality__c,Designation__c,Residency_Status__c,title,Race__c,MobilePhone,email,
                         Secondary_Salutation__c,homephone,Secondary_Email_Address__c,Secondary_Mobile_Number__c,Remarks__c,
                         Secondary_Contact_Name__c,Attention__c,OtherPhone,phone,Billing_Address_Line_1__c,Billing_Address_Line_2__c,
                         Billing_Address_Line_3__c,Billing_City__c,Billing_State__c,Billing_Country__c,Billing_Postal_Code__c,
                         RMIT_Alumni__c,Account.Membership_Active__c,Alternative_Attention__c,Alternative_Billing_Address1__c,
                         Alternative_Phone__c,Alternative_Billing_Address2__c,Alternative_Email__c,How_did_you_get_to_know_us__c,
                         Alternative_Billing_Address3__c,Alternative_City__c,Alternative_State__c,Alternative_PostalCode__c,
                         Alternative_Country__c,NRIC_Type__c,Account.RecordType.DeveloperName,Account.Billing_Address_Line_1__c, 
                         Account.Billing_Address_Line_2__c,Account.Billing_Address_Line_3__c,Account.Billing_City__c, 
                         Account.Billing_Country__c, Account.Billing_Postal_Code__c,Account.billing_state__c, Account.City__c, 
                         Account.IsPersonAccount,Office_No__c,account.UEN_No__c,Primary_Email_Address__c,
                         Preferred_Certificate_Name__c,Company_Name__c,account.Preferred_Contact_Method__c,account.Address_Type__c,
                         Account.Billing_Contact_Person__c,Account.Country__c,Account.Name,Account.Membership_No__c,Account.Membership_Payment_Status__c,
                         Marketing_Consent_Clause__c, PDPA_Consent_Clause__c, Marketing_Channel_Consented__c
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
        Course_Run__c courseRun = new Course_Run__c();
        Id userId = UserInfo.getUserId();
        User userInfo = [SELECT ContactId FROM User WHERE Id=:userId];
        Contact contactInfo = [SELECT AccountId FROM Contact WHERE Id=:userInfo.ContactId];
        if(courseRunCode != null) {
            // mvp 1.1 :added by Ravi. 25th marh 2021 field Course__r.Need_PII__c inorder to enable or disble the PII section 
            List<Course_Run__c> courseRuns = [select Id,Name,Course__r.Need_PII__c,Course__c,Course_Run_Code__c,Start_Date__c,End_Date__c,Course__r.Name,
                         Course__r.Member_Fee__c,Course__r.Non_Member_Fee__c,Course__r.Full_Fee__c,CourseRecordType__c,
                         Registration_Open_Date__c,Registration_Close_Date__c,Active__c,Capacity__c,course__r.Funding__c,
                         Course__r.Provider__c,(select id from Course_Registrations__r), Course__r.AccountId__c, 
                         Course__r.Full_Fee_with_GST__c,Course__r.RMIT_Alumni_Fee__c, Course__r.Course_Title__c, Course__r.Member_Total_Fee__c, Course__r.Non_Member_Total_Fee__c, 
                         Course__r.RMIT_Total_Fee__c
                         from Course_Run__c where Course_Run_Code__c =: courseRunCode];
            if (courseRuns.size() > 0) {
                courseRun = courseRuns[0].Course__r.AccountId__c == null || courseRuns[0].Course__r.AccountId__c == contactInfo.AccountId ? courseRuns[0] : new Course_Run__c();
            }
        }
        return courseRun;
    }    
    
    @AuraEnabled
    public static Id checkContactRegistration(Id courseRunId) {
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
    public static List<String> getLearnerFundingValues(id courseId) {
      List<String> options = new List<String>();       
        course__c course = new course__c();
        
        if(courseId != null) {
           course = [select id,Funding__c from course__c where id=: courseId limit 1];
           if(course != null && course.Funding__c != null) {
               for(string s : course.Funding__c.split(';')) {
                   if(s != 'UTAP Funding') {
                      options.add(s);
                   }
               }
           }
        }
        return options;
    }
    
    @AuraEnabled
    public static string returnInvoice(id courseRegId) {
        string invoiceId;
        //if(string.isNotBlank(courseRegId)){
        if(courseRegId != null){
          invoiceId = InvoiceUtility.generateInvoiceForRegistration(courseRegId);
        }
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
    public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) {         
        if (fileId == '') {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        } else {
            appendToFile(fileId, base64Data);
        }
 
        return Id.valueOf(fileId);
    }
 
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
 
        Attachment oAttachment = new Attachment();
        oAttachment.parentId = parentId;
 
        oAttachment.Body = EncodingUtil.base64Decode(base64Data);
        oAttachment.Name = fileName;
        oAttachment.ContentType = contentType;
 
        insert oAttachment;
 
        return oAttachment.Id;
    }
 
    private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
 
        Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id =: fileId
        ];
 
        String existingBody = EncodingUtil.base64Encode(a.Body);
 
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);
 
        update a;
    }
    
    @AuraEnabled
    public static void insertFundingRecords(List<Learner_Funding__c> learnerFundList, id courseRegId) {
        List<Learner_Funding__c> learnerFundListToInsert = new list<Learner_Funding__c>();
        if(learnerFundList.size() > 0) {
            for(Learner_Funding__c l : learnerFundList) {
                l.Course_Registration__c = courseRegId;
                learnerFundListToInsert.add(l);
            }
        }
        
        if(learnerFundListToInsert.size() > 0) {
            insert learnerFundListToInsert;
        }
    }
    
  
    /*************************************************************************************************************
     * @name            CourseRegistrationController
     * @author          BLR\rohit.pal <rohit.pal@crmit.com>
     * @created         14 / 10 / 2020
     * @description     Description of your code
     *
     * Changes (version)
     * -----------------------------------------------------------------------------------------------------------
     *              No.     Date            Author                  Description
     *              ----    ------------    --------------------    ----------------------------------------------
     * @version     1.0     2020-10-14      BLR\rohit.pal           Changes desription
     *
    **************************************************************************************************************/
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
    
    // MVP1.1:checkUserProfile::Added by Ravi on 1 april 2021 to check the Profile of logged in user 
    @AuraEnabled
    public static boolean checkUserProfile(){
        String profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
        if(profileName =='B2B SPOC'){
            return true;
        }
        return false;
    }
    
    // MVP1.1:Added by Devender on 13 april 2021 to check the Promo code
    @AuraEnabled
    public static Wrapper getPromoCode(string promocode,string courseId, Date registrationStartDate) {
        system.debug('promocode --> '+promocode);
        system.debug('courseId --> '+courseId);
        Date sToday=System.today();
        Wrapper objWrapper=New Wrapper();
        Promo_Code__c  recPromoCode=New Promo_Code__c();
        Id userId = UserInfo.getUserId();
        User userInfo = [SELECT ContactId FROM User WHERE Id=:userId];
        Contact contactInfo = [SELECT AccountId FROM Contact WHERE Id=:userInfo.ContactId];
        if(string.isNotEmpty(promocode)){
            List<Promo_Code__c> recPromoCodes=[SELECT Account__c, Id, Name, Is_Active__c, Start_Date__c, End_Date__c, 
                                               Discount_Type__c, Applicable_on__c,Discount_Amount__c,Discount_Percentage__c, 
                                               Course__c
                                               FROM Promo_Code__c WHere Name =:promocode AND Is_Active__c=True
                                               AND Start_Date__c<=:sToday AND End_Date__c>=:sToday];
            if (recPromoCodes.size() > 0) {
                recPromoCode=recPromoCodes[0].Account__c == null || recPromoCodes[0].Account__c == contactInfo.AccountId ? recPromoCodes[0] : null;
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