/**
 * @description       : 
 * @author            : Laxmi Boggarapu <laxmi.boggarapu@crmit.com>
 * @group             : 
 * @last modified on  : 11-13-2020
 * @last modified by  : Mark Alvin Tayag (mtayag@salesforce.com)
 * Modifications Log 
 * Ver   Date         Author                                     Modification
 * 1.0   10-11-2020   Laxmi Boggarapu <laxmi.boggarapu@crmit.com>   Initial Version
 * 1.1   10-11-2020   Mark Alvin Tayag (mtayag@salesforce.com)   Added New Objects
 * 1.2   10-03-2021   Poon Koon                                  Update Course Run Generation to fit new Course Run Code No requirement
 * 1.3   2021-04-08   Poon Koon                                  Update salutation value to match latest set
**/
@isTest
public class TestDataFactory {
    
    public static testmethod ContentVersion createContentVersion(){
        contentVersion cv = new contentVersion();
        cv.Title = 'Thumbnail';
        cv.PathOnClient = 'Thumbnail.jpg';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;    
        cv.File_Type__c = 'Thumbnail';        
        return cv;
    }
    
    public static testmethod ContentVersion createContentVersionAttachment(){
        contentVersion cv = new contentVersion();
        cv.Title = 'Attachment';
        cv.PathOnClient = 'Attachment.jpg';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;    
        cv.File_Type__c = 'Attachment';        
        return cv;
    }
    
    public static testmethod ContentVersion createContentVersionTest(){
        contentVersion cv = new contentVersion();
        cv.Title = 'Test';
        cv.PathOnClient = 'test.jpg';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;            
        return cv;
    }
    
    
    public static ContentDocumentLink createContentDocumentLink(id LinkedEntityId, id ContentDocumentId){
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = ContentDocumentId;
        cdl.LinkedEntityId = LinkedEntityId;
        return cdl;
       
    }
    
    public static Account createAccount(id recordTypeId) {
        Id personAccountRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();

       account acc = new account();
        if (recordTypeId != personAccountRT) {
            acc.name = 'Test Account';
        }
        acc.recordTypeId = recordTypeId;
        return acc;
    }
    
    public static contact createContact(id accountId){
        contact con = new contact();
        con.AccountId = accountId;
        con.LastName = 'Testdata';
        return con;
    }
    
    public static Course__c createCourse(id accountId){
        Course__c course = new Course__c();
        //course.Name = 'Test Course'; //Changed to Auto-Number
        course.Active__c = true;
        course.CMS_Request_By__c = userinfo.getUserId();
        course.Publish_Status__c = 'New';
        course.Cost_Center__c  = 'SM1040';
        course.Course_Overview__c = 'Test course overview';
        course.Course_Type__c = 'Self-Paced';
        course.Member_Fee__c = 10000;
        course.Member_GST_Fee__c = 700;
        course.Non_Member_Fee__c = 12000;
        course.Non_Member_GST_Fee__c = 840;
        course.Mode_Of_Study__c = 'Online';
        course.provider__c ='SIM';
        course.Department__c = 'PM';
        course.Fee_Code__c = 'PROGRM'; 
        course.AccountId__c = accountId;   
        course.Course_Code__c = '123';
        course.GST_Code__c = '12';
        course.GST_Mode__c = 'Full';
        
        return course;
    }
    
    public static category__c createCategory(){
        category__c category = new category__c();
        category.Name = 'Test Category';
        category.Active__c = true;
        category.Category__c = 'Category 1';
        category.CMS_Request_By__c = userinfo.getUserid();
        category.CMS_Request_Date__c = system.now();
        category.Publish_Date__c = system.now();
        category.Published_By__c = userinfo.getUserid();
        category.Published_Name__c = 'Test Category';
        category.Publish_Status__c = 'New';
        return category;
    }
    
    public static Discount__c createDiscount(){
        Discount__c discount = new Discount__c();
        discount.Name = 'Test Discount';
        discount.Amount__c = 10;
        discount.GST_Amount__c = 7;
        discount.Percentage__c = true;
        discount.No_of_Days__c = 10;
        discount.Valid_From__c = System.today();
        discount.Valid_To__c = System.today()+2;
        discount.Terms_and_Conditions__c = 'test';
        discount.Publish_Status__c = 'New';
        discount.Active__c = true;
        discount.Publish_Date__c = system.now();
        discount.CMS_Request_By__c = userinfo.getUserid();
        return discount;
    }
    
    public static Course_Run__c createCourseRun(){
        Course_Run__c courseRun = new Course_Run__c();
        //courseRun.Name = 'Test Discount';
        //courseRun.Course__c = '';
        courseRun.CMS_Request_By__c = userinfo.getUserid();
        courseRun.Provider_Id__c = 'test12';
        courseRun.Course_Run_Code__c = 'testCode1234';
        courseRun.Registration_Open_Date__c = System.today();
        courseRun.Registration_Close_Date__c = System.today()+2;
        courseRun.Start_Date__c = System.today();
        courseRun.End_Date__c = System.today()+2;
        courseRun.Venue__c = 'test Venue';
        courseRun.Publish_Date__c = System.today();
        courseRun.CMS_Request_Date__c = system.now();
        courseRun.Certificate_Course_Name__c = 'test';
        courseRun.Certificate_Instructor_Name__c = 'Test';
        courseRun.Active__c = true;
        courseRun.Publish_Status__c = 'New';
       // courseRun.No_of_Registrations__c = 10;
        courseRun.Capacity__c = 10;
        return courseRun;
    }

    public static Module__c createModule() {
        Module__c module = new Module__c();

        module.Code__c = 'ACC101X';
        module.Category__c = Module__c.Category__c.getDescribe().getPicklistValues()[0].getValue();
        module.Sub_Category__c = Module__c.Sub_Category__c.getDescribe().getPicklistValues()[0].getValue();
        module.Competency__c = Module__c.Competency__c.getDescribe().getPicklistValues()[0].getValue();
        module.Competency_Level__c = Module__c.Competency_Level__c.getDescribe().getPicklistValues()[0].getValue();
        module.Full_Fee__c = 1000;
        module.SME_Grant__c = 500;
        module.Non_SME_Grant__c = 700;
        module.Baseline_Grant__c = 800;
        module.Workfare__c = 800;
        module.Mid_Career__c = 700;
        module.Full_Fee_GST_Amount__c = 70;
        module.SME_Grant_GST_Amount__c = 35;
        module.Non_SME_Grant_GST_Amount__c = 49;
        module.Baseline_Grant_GST_Amount__c = 56;
        module.Workfare_GST_Amount__c = 56;
        module.Mid_Career_GST_Amount__c = 49;
        module.GST_Code__c = '12';
        return module;
    }
    
    public static EmailTemplate createEmailTemplate() {
        EmailTemplate e = new EmailTemplate (
        developerName = 'Test' + UserInfo.getUserId(), 
        FolderId = UserInfo.getUserId(), 
        TemplateType= 'custom', 
        Name = 'Test' + UserInfo.getUserId(),
        HtmlValue='<div></div>');

        return e;
    }

    public static Course_Registration__c createCourseRegistration(Id courseRunId, Id contactId) {
        Course_Registration__c reg = new Course_Registration__c();
        reg.Course_Run_Id__c = courseRunId;
        reg.Contact__c = contactId;
        reg.Registration_Status__c = 'New';
        reg.Payment_Status__c = 'Unpaid';

        return reg;
    }

    public static Certificate_Template_Folder__c createCertFolderSetting(String folderName) {
        Certificate_Template_Folder__c folder = new Certificate_Template_Folder__c();
        folder.Folder_Name__c = folderName;

        return folder;
    }

    public static User createUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 

        User u = new User(Alias = 'standt', Email='apexTestUser@sim.edu.sg', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='apexTestUser@sim.edu.sg');

        return u;
    }

    public static Invoice__c createInvoice(){
        Invoice__c objInvoice = new Invoice__c();
        return objInvoice;
    }
    public static Payment__c createPayment(){
        Id personAccountRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();

            Account objAccount = TestDataFactory.createAccount(personAccountRT);
            objAccount.LastName = 'Test Account';
            insert objAccount;
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: objAccount.Id ];
        Invoice__c objInvoice = createInvoice();
        insert objInvoice;
        Course__c objCourse = createCourse(objAccount.Id);
        insert objCourse;
        Course_Run__c objCourseRun = createCourseRun();
        objCourseRun.Course__c =objCourse.id;
        insert objCourseRun;
       
        Course_Registration__c reg = createCourseRegistration(objCourseRun.id , con.id);
        insert reg;
        Payment__c objPayment = new Payment__c();
        objPayment.Course_Registration__c = reg.id;
        objPayment.Invoice__c = objInvoice.Id;
        return objPayment;
    }
    public static Learner_Funding__c createLearnerFunding(id courseRegId){
        Learner_Funding__c fundingList = new Learner_Funding__c();
        fundingList.Amount__c = 1000;
        fundingList.Course_Registration__c = courseRegId;
        fundingList.Funding__c = 'SkillsFuture Credit';
        return fundingList;
    }
    
    public static attachment createAttachment(blob file,id parentid,string filename) {       
        Attachment objAttachment = new Attachment(); 
        objAttachment.Body= file;
        objAttachment.Name = filename;
        objAttachment.ParentId = parentid;
        return objAttachment;
    }

    public static Account createB2CAccount(String firstName, String lastName, String email) {
        Id b2cLearnerRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('B2C_Learner').getRecordTypeId();
        Account acct = new Account();
        acct.RecordTypeId = b2cLearnerRT;
        acct.FirstName = firstName;
        acct.LastName = lastName;
        acct.PersonEmail = email;
        acct.Primary_Email_Address__pc = email;
        acct.Self_Registration__pc = true;
        return acct;
    }
    
    public static userrole returnUserRole() {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1]; 
        return portalRole;
    }
    
    public static user createSystemAdmin(id portalroleId) {
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User adminUser = new User();
        adminUser.UserRoleId = portalroleId;
        adminUser.ProfileId = profile1.Id;
        adminUser.Username = System.now().millisecond() + 'test222@test.com';
        adminUser.Alias = 'batman';
        adminUser.Email='bruce.wayne@wayneenterprises.com';
        adminUser.EmailEncodingKey='UTF-8';
        adminUser.Firstname='Bruce';
        adminUser.Lastname='Wayne';
        adminUser.LanguageLocaleKey='en_US';
        adminUser.LocaleSidKey='en_US';
        adminUser.TimeZoneSidKey='America/Chicago';
        return adminUser;
         
    }
    
    public static account createB2BAccount(string accName) {
        Account account = new account();
        account.name  = accName;
        return account;
    }
    
    public static Course_Registration__c createCourseRegistrationB2B(Id courseRunId, Id contactId) {
        Course_Registration__c reg = new Course_Registration__c();
        reg.Course_Run_Id__c = courseRunId;
        reg.Contact__c = contactId;
        reg.Registration_Status__c = 'New';
        reg.Payment_Status__c = 'Unpaid';
        //2021-04-08 Poon Koon: Updated salutation from Mr. to Mr
        reg.Salutation__c = 'Mr';
        reg.First_Name__c = 'Test';
        reg.Last_Name__c = 'Lname';
        reg.Date_of_Birth__c = system.today().addyears(-10);
        reg.Preferred_Certificate_Name__c= 'test certificate name';
        reg.Gender__c = 'Male';
        reg.NRIC_Type__c = 'Passport';
        reg.NRIC__c = 'SA0001';
        reg.Email_Address__c = 'testCon@test.com';
        reg.Primary_Email_Address__c = 'test1@test.com';
        reg.Nationality__c = 'Singapore PR';
        reg.Mobile_No__c = '1234567890';
        reg.Race__c = 'CHINESE';
        reg.Home_No__c = '1234567891';
        reg.Residency_Status__c = 'Citizen';
        reg.Office_No__c = '3232325555';
        reg.Education_Level__c = 'Others';
        reg.Persons_with_Disabilities__c = 'No';
        reg.Employment_Status__c = 'Employed';
        reg.Job_Title__c = 'developer';
        reg.Company_Name__c = 'TestAccount';
        reg.Designation__c = 'Clerical Workers';
        reg.Monthly_Basic_Salary__c= 'Below $1000';
        reg.Designation_Level__c = 'Student';
        reg.Secondary_Salutation__c = 'Ms';
        reg.Secondary_Name__c = 'test name';
        reg.Secondary_Email_Address__c = 'second@test.com';
        reg.Secondary_Mobile__c = '1234567890';
        reg.Remarks__c = 'test remarks';
        reg.Attention__c = 'test attentions';
        reg.Billing_State__c = 'AP';
        reg.Billing_Address_Line_1__c = 'test line1';
        reg.Billing_City__c= 'test city';
        reg.Billing_Address_Line_2__c = 'test line2';
        reg.Billing_Country__c = 'Singapore';
        reg.Billing_Address_Line_3__c = 'test line3';
        reg.Billing_Postal_Code__c = '500050';
        reg.Address_Type__c = 'Home';
        reg.Preferred_Contact_Method__c = 'Email';
        reg.Alternative_Attention__c = 'test attention';
        reg.Alternative_State__c = 'test state';
        reg.Alternative_Billing_Line_1__c = 'test alternative line1';
        reg.Alternative_City__c  = 'test alter city';
        reg.Alternative_Billing_Line_2__c = 'test alter line2';
        reg.Alternative_Country__c = 'Singapore';
        reg.Alternative_Billing_Line_3__c = 'test alter line3';
        reg.Alternative_Postal_Code__c = '500070';
        reg.Alternative_Email__c = 'testAlter@test.com';
        reg.Alternative_Phone__c = '4544545454';   
        reg.Company_UEN_No__c = '123';
        reg.How_did_you_get_to_know_us__c = 'Online Website';
        return reg;
    }  
    
    public static user createPortalUser(id accountid, id contactid) {
        //Create user
        Profile portalProfile = [SELECT Id FROM Profile where name =:'B2B Learner' Limit 1];
        User portaluser = new User();
        portaluser.Username = System.now().millisecond() + 'test125@test.com';
        portaluser.ContactId = contactid;
        portaluser.ProfileId = portalProfile.Id;
        portaluser.Alias = 'test123';
        portaluser.Email = 'test12345@test.com';
        portaluser.EmailEncodingKey = 'UTF-8';
        portaluser.LastName = 'McTesty';
        portaluser.CommunityNickname = 'test12345';
        portaluser.TimeZoneSidKey = 'America/Los_Angeles';
        portaluser.LocaleSidKey = 'en_US';
        portaluser.LanguageLocaleKey = 'en_US';
        return portaluser;
        
    }
    
    
}