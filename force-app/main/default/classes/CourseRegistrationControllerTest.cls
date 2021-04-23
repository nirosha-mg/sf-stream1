@IsTest
public class CourseRegistrationControllerTest {   
    public static testmethod void testB2bLearner() {
        List<Learner_Funding__c> ListOfFundingRecords = new list<Learner_Funding__c>();
        List<Learner_Funding__c> lfund=new List<Learner_Funding__c>();
        
        userrole role = TestDataFactory.returnUserRole();
        user adminUser = TestDataFactory.createSystemAdmin(role.id);
        insert adminUser;
        
        Course__c objCourse;
        Course_Run__c cr;
        Course_Registration__c objCourseRegistration;
        blob file =  Blob.valueOf('sample text');
        attachment att;
        user portaluser; 
        Contact con;
        
        System.runAs (adminUser) {    
            Account account = TestDataFactory.createB2BAccount('TestAccount');
            account.ownerid = adminUser.id;
            insert account;
            
            con = TestDataFactory.createContact(account.id);
            con.FirstName = 'Test';
            con.Email = 'testCon@test.com';
            con.Company_Name__c = 'TestAccount';
            insert con;
            
            objCourse  = TestDataFactory.createCourse(account.Id);
            objCourse.Public_Course__c = true;
            objCourse.Funding__c='SkillsFuture Credit';
            insert objCourse;
            
            cr = TestDataFactory.createCourseRun();
            cr.Course__c = objCourse.id;
            cr.Public_Course__c = true;
            insert cr;
            
            
            portalUser = [SELECT Id FROM User WHERE ContactId =: con.Id];                       
        }
       
        system.runas(portaluser) {
            objCourseRegistration = TestDataFactory.createCourseRegistrationB2B(cr.id , con.id);
            objCourseRegistration.Sync_Learner_s_Record__c = true;
                insert objCourseRegistration;
                
                Learner_Funding__c fund = TestDataFactory.createLearnerFunding(objCourseRegistration.id);       
                ListOfFundingRecords.add(fund);
                
                att = TestDataFactory.createAttachment(file,objCourseRegistration.id,'testAttachment');
                insert att;
            Test.startTest();
                CourseRegistrationController.getContactRecord();      
                CourseRegistrationController.getCourseRunRecord(cr.Course_Run_Code__c);
                CourseRegistrationController.insertFundingRecords(lfund,objCourseRegistration.id);
                CourseRegistrationController.validateNRICValue('S1234567D');
                CourseRegistrationController.saveChunk(objCourseRegistration.id,'testAttachment',file.toString(),'jpg',att.Id);
                CourseRegistrationController.ContactInformation courseReg = new CourseRegistrationController.ContactInformation(con,'Test','Test','Test','Test','test','NY','NY','NY','US');
                
                String encodedString = EncodingUtil.urlEncode('TestString','UTF-8');
                CourseRegistrationController.saveTheFile(con.Id, 'fileName',encodedString , 'contentType');
                
                CourseRegistrationController.getLearnerFundingValues(objCourse.id);
            Test.stopTest();
                          
             Course_Registration__c cReg = [select id,Salutation__c,First_Name__c,Last_Name__c,Date_of_Birth__c,
             Preferred_Certificate_Name__c,Gender__c,NRIC_Type__c,NRIC__c,Primary_Email_Address__c,Nationality__c,
             Mobile_No__c,Race__c,Home_No__c,Residency_Status__c,Office_No__c,Education_Level__c,
              Persons_with_Disabilities__c,Employment_Status__c,Company_Name__c,Designation_Level__c,Secondary_Salutation__c,
              Secondary_Email_Address__c,Secondary_Mobile__c,Remarks__c,Attention__c,contact__c,Designation__c,
              Billing_State__c,Billing_Address_Line_1__c,Address_Type__c,Preferred_Contact_Method__c,
              Billing_City__c,Billing_Address_Line_2__c,Billing_Country__c,Billing_Address_Line_3__c,Billing_Postal_Code__c
               from Course_Registration__c
              where id =: objCourseRegistration.id];
              
            contact conRec = [SELECT Id,Name,FirstName,LastName,Salutation,Persons_with_Disabilities__c,Education_Level__c,NRIC__c,
                         Employment_Status__c,Gender__c,Monthly_Basic_Salary__c,Date_of_Birth__c,Designation_Level__c,
                         Nationality__c,Designation__c,Residency_Status__c,title,Race__c,MobilePhone,email,
                         Secondary_Salutation__c,homephone,Secondary_Email_Address__c,Secondary_Mobile_Number__c,Remarks__c,
                         Secondary_Contact_Name__c,Attention__c,OtherPhone,phone,Billing_Address_Line_1__c,Billing_Address_Line_2__c,
                         Billing_Address_Line_3__c,Billing_City__c,Billing_State__c,Billing_Country__c,Billing_Postal_Code__c,
                         RMIT_Alumni__c,Account.Membership_Active__c,Alternative_Attention__c,Alternative_Billing_Address1__c,
                         Alternative_Phone__c,Alternative_Billing_Address2__c,Alternative_Email__c,
                         Alternative_Billing_Address3__c,Alternative_City__c,Alternative_State__c,Alternative_PostalCode__c,
                         Alternative_Country__c,NRIC_Type__c,Account.RecordType.DeveloperName,Account.Billing_Address_Line_1__c, 
                         Account.Billing_Address_Line_2__c,Account.Billing_Address_Line_3__c,Account.Billing_City__c, 
                         Account.Billing_Country__c, Account.Billing_Postal_Code__c,Account.billing_state__c, Account.City__c, Account.Country__c,
                         Account.IsPersonAccount,Office_No__c,account.UEN_No__c,Primary_Email_Address__c,
                         Preferred_Certificate_Name__c,Company_Name__c,account.Preferred_Contact_Method__c,account.Address_Type__c
                         FROM Contact WHERE Id=:cReg.contact__c]; 
                         
                         
            System.assertEquals(conRec.Salutation, cReg.Salutation__c);
            System.assertEquals(conRec.FirstName, cReg.First_Name__c); 
            System.assertEquals(conRec.LastName, cReg.Last_Name__c);
             System.assertEquals(conRec.Date_of_Birth__c, objCourseRegistration.Date_of_Birth__c);
             System.assertEquals(conRec.Preferred_Certificate_Name__c, objCourseRegistration.Preferred_Certificate_Name__c);
             System.assertEquals(conRec.Gender__c, cReg.Gender__c);
             System.assertEquals(conRec.NRIC_Type__c, cReg.NRIC_Type__c);
             System.assertEquals(conRec.NRIC__c, cReg.NRIC__c);
             System.assertEquals(conRec.Primary_Email_Address__c, cReg.Primary_Email_Address__c);
             System.assertEquals(conRec.Nationality__c, cReg.Nationality__c);
             System.assertEquals(conRec.MobilePhone, cReg.Mobile_No__c);
             System.assertEquals(conRec.Race__c, cReg.Race__c);
             System.assertEquals(conRec.Phone, cReg.Home_No__c);
             System.assertEquals(conRec.Residency_Status__c, cReg.Residency_Status__c);
             System.assertEquals(conRec.Office_No__c, cReg.Office_No__c);
             System.assertEquals(conRec.Education_Level__c, cReg.Education_Level__c);
             System.assertEquals(conRec.Persons_with_Disabilities__c, cReg.Persons_with_Disabilities__c);
             System.assertEquals(conRec.Employment_Status__c, cReg.Employment_Status__c);
             System.assertEquals(conRec.Company_Name__c, cReg.Company_Name__c);
             System.assertEquals(conRec.Designation__c, cReg.Designation__c);
             System.assertEquals(conRec.Designation_Level__c, cReg.Designation_Level__c);
             System.assertEquals(conRec.Secondary_Salutation__c, cReg.Secondary_Salutation__c);
             System.assertEquals(conRec.Secondary_Email_Address__c, cReg.Secondary_Email_Address__c);
             System.assertEquals(conRec.Secondary_Mobile_Number__c, cReg.Secondary_Mobile__c);
             System.assertEquals(conRec.Remarks__c, cReg.Remarks__c);
             System.assertEquals(conRec.Attention__c, cReg.Attention__c);
             // Checks billing address for b2b
             System.assertNotEquals(conRec.account.Billing_State__c, cReg.Billing_State__c);
             System.assertNotEquals(conRec.account.Billing_Address_Line_1__c, cReg.Billing_Address_Line_1__c);
             System.assertNotEquals(conRec.account.Billing_City__c, cReg.Billing_City__c);
             System.assertNotEquals(conRec.account.Billing_Address_Line_2__c, cReg.Billing_Address_Line_2__c);
            // System.assertNotEquals(conRec.account.Billing_Country__c, cReg.Billing_Country__c);
             System.assertNotEquals(conRec.account.Billing_Address_Line_3__c, cReg.Billing_Address_Line_3__c);
             System.assertNotEquals(conRec.account.Billing_Postal_Code__c, cReg.Billing_Postal_Code__c);
             System.assertNotEquals(conRec.account.Address_Type__c, cReg.Address_Type__c);
            
        }
    }
    
    public static testmethod void testNRICPositiveVal_S() {
        Id personAccountRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        account acc = TestDataFactory.createAccount(personAccountRT);
        acc.lastname ='Test Account';
        insert acc;

        contact con = [select id from contact where accountid =: acc.id];
        
        course__c course = TestDataFactory.createCourse(acc.id);
        insert course;
        
        course_run__c cr = TestDataFactory.createCourseRun();  
        cr.course__c = course.id;      
        insert cr;
        
        course_registration__c reg = TestDataFactory.createCourseRegistrationB2B(cr.id,con.id);
        reg.NRIC_Type__c  = 'FIN';
        reg.NRIC__c = 'S1234567D';
        reg.Nationality__c = 'Singapore_CITIZEN'; 
        
        CourseRegistrationController.validateNRICValue(reg.NRIC__c);
        Database.insert(reg);
        system.assertEquals(reg.NRIC__c,'S1234567D');
    }
    
    public static testmethod void testNRICPositiveVal_T() {
        Id personAccountRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        account acc = TestDataFactory.createAccount(personAccountRT);
        acc.lastname ='Test Account';
        insert acc;

        contact con = [select id from contact where accountid =: acc.id];
        
        course__c course = TestDataFactory.createCourse(acc.id);
        insert course;
        
        course_run__c cr = TestDataFactory.createCourseRun();  
        cr.course__c = course.id;      
        insert cr;
        
        course_registration__c reg = TestDataFactory.createCourseRegistrationB2B(cr.id,con.id);
        reg.NRIC_Type__c  = 'FIN';
        reg.NRIC__c = 'T4080623C';
        reg.Nationality__c = 'Singapore_CITIZEN'; 
        
        CourseRegistrationController.validateNRICValue(reg.NRIC__c);
        Database.insert(reg);
        system.assertEquals(reg.NRIC__c,'T4080623C');
    }
    
    public static testmethod void testNRICPositiveVal_F() {
        Id personAccountRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        account acc = TestDataFactory.createAccount(personAccountRT);
        acc.lastname ='Test Account';
        insert acc;

        contact con = [select id from contact where accountid =: acc.id];
        
        course__c course = TestDataFactory.createCourse(acc.id);
        insert course;
        
        course_run__c cr = TestDataFactory.createCourseRun();  
        cr.course__c = course.id;      
        insert cr;
        
        course_registration__c reg = TestDataFactory.createCourseRegistrationB2B(cr.id,con.id);
        reg.NRIC_Type__c  = 'FIN';
        reg.NRIC__c = 'F0427356R';
        reg.Nationality__c = 'Singapore_CITIZEN'; 
        
        CourseRegistrationController.validateNRICValue(reg.NRIC__c);
        Database.insert(reg);
        system.assertEquals(reg.NRIC__c,'F0427356R');
    }
    
    public static testmethod void testNRICPositiveVal_G() {
        Id personAccountRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        account acc = TestDataFactory.createAccount(personAccountRT);
        acc.lastname ='Test Account';
        insert acc;

        contact con = [select id from contact where accountid =: acc.id];
        
        course__c course = TestDataFactory.createCourse(acc.id);
        insert course;
        
        course_run__c cr = TestDataFactory.createCourseRun();  
        cr.course__c = course.id;      
        insert cr;
        
        course_registration__c reg = TestDataFactory.createCourseRegistrationB2B(cr.id,con.id);
        reg.NRIC_Type__c  = 'FIN';
        reg.NRIC__c = 'G3918827P';
        reg.Nationality__c = 'Singapore_CITIZEN'; 
        
        CourseRegistrationController.validateNRICValue(reg.NRIC__c);
        Database.insert(reg);
        system.assertEquals(reg.NRIC__c,'G3918827P');
    }
    
     public static testmethod void testNRICNegativeVal_S() {
        Id personAccountRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        account acc = TestDataFactory.createAccount(personAccountRT);
        acc.lastname ='Test Account';
        insert acc;

        contact con = [select id from contact where accountid =: acc.id];
        
        course__c course = TestDataFactory.createCourse(acc.id);
        insert course;
        
        course_run__c cr = TestDataFactory.createCourseRun();  
        cr.course__c = course.id;      
        insert cr;
        
        course_registration__c reg = TestDataFactory.createCourseRegistrationB2B(cr.id,con.id);        
       try {
             reg.NRIC_Type__c  = 'FIN';
             reg.NRIC__c = 'S1234567A';
            CourseRegistrationController.validateNRICValue(reg.NRIC__c);           
            insert reg;
            
        } catch(exception e) {
        }
    } 
    public static testmethod void testNRICNegativeVal_T() {
        Id personAccountRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        account acc = TestDataFactory.createAccount(personAccountRT);
        acc.lastname ='Test Account';
        insert acc;

        contact con = [select id from contact where accountid =: acc.id];
        
        course__c course = TestDataFactory.createCourse(acc.id);
        insert course;
        
        course_run__c cr = TestDataFactory.createCourseRun();  
        cr.course__c = course.id;      
        insert cr;
        
        course_registration__c reg = TestDataFactory.createCourseRegistrationB2B(cr.id,con.id);        
       try {  
             reg.NRIC_Type__c  = 'FIN';
             reg.NRIC__c = 'T9113754A';         
            CourseRegistrationController.validateNRICValue(reg.NRIC__c);           
            insert reg;
            
        } catch(exception e) {
        }
    }   
    
     public static testmethod void testNRICNegativeVal_F() {
        Id personAccountRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        account acc = TestDataFactory.createAccount(personAccountRT);
        acc.lastname ='Test Account';
        insert acc;

        contact con = [select id from contact where accountid =: acc.id];
        
        course__c course = TestDataFactory.createCourse(acc.id);
        insert course;
        
        course_run__c cr = TestDataFactory.createCourseRun();  
        cr.course__c = course.id;      
        insert cr;
        
        course_registration__c reg = TestDataFactory.createCourseRegistrationB2B(cr.id,con.id);        
       try { 
            reg.NRIC_Type__c  = 'FIN';
            reg.NRIC__c = 'F6121351B';         
            CourseRegistrationController.validateNRICValue(reg.NRIC__c);            
            insert reg;
            
        } catch(exception e) {
        }
    }  
    
     public static testmethod void testNRICNegativeVal_G() {
        Id personAccountRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        account acc = TestDataFactory.createAccount(personAccountRT);
        acc.lastname ='Test Account';
        insert acc;

        contact con = [select id from contact where accountid =: acc.id];
        
        course__c course = TestDataFactory.createCourse(acc.id);
        insert course;
        
        course_run__c cr = TestDataFactory.createCourseRun();  
        cr.course__c = course.id;      
        insert cr;
        
        course_registration__c reg = TestDataFactory.createCourseRegistrationB2B(cr.id,con.id);        
       try { 
            reg.NRIC_Type__c  = 'FIN';
            reg.NRIC__c = 'G8290888C';         
            CourseRegistrationController.validateNRICValue(reg.NRIC__c);
            insert reg;
            
        } catch(exception e) {
        }
    }  
    
    public static testmethod void testB2cLearner() {
        List<Learner_Funding__c> ListOfFundingRecords = new list<Learner_Funding__c>();
        List<Learner_Funding__c> lfund=new List<Learner_Funding__c>();
        
        userrole role = TestDataFactory.returnUserRole();
        user adminUser = TestDataFactory.createSystemAdmin(role.id);
        insert adminUser;
        
        Course__c objCourse;
        Course_Run__c cr;
        Course_Registration__c objCourseRegistration;
        blob file =  Blob.valueOf('sample text');
        attachment att;
        user portaluser; 
        Contact con;
        
        System.runAs (adminUser) {  
            Id personAccountRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();          
            Account portalAccount = TestDataFactory.createAccount(personAccountRT);
            portalAccount.OwnerId = adminUser.Id;
            portalAccount.LastName = 'Test Account';
            portalAccount.Billing_State__c = 'AP';
            portalAccount.Billing_Address_Line_1__c = 'test line1';
            portalAccount.Billing_City__c= 'test city';
            portalAccount.Billing_Address_Line_2__c = 'test line2';
            portalAccount.Billing_Country__c = 'Singapore';
            portalAccount.Billing_Address_Line_3__c = 'test line3';
            portalAccount.Billing_Postal_Code__c = '500050';
            Database.insert(portalAccount);
            
            con = [SELECT Id FROM Contact WHERE AccountId =: portalAccount.Id ];
            con.Email = 'testCon@test.com';
            con.Company_Name__c = 'TestAccount';
            update con;
            
            objCourse  = TestDataFactory.createCourse(portalAccount.Id);
            objCourse.Public_Course__c = true;
            objCourse.Funding__c='SkillsFuture Credit';
            insert objCourse;
                       
            cr = TestDataFactory.createCourseRun();
            cr.Course__c = objCourse.id;
            cr.Public_Course__c = true;
            insert cr;
            
            objCourseRegistration = TestDataFactory.createCourseRegistrationB2B(cr.id , con.id);
            objCourseRegistration.Nationality__c = 'Singapore_CITIZEN';
            objCourseRegistration.Sync_Learner_s_Record__c = true;
            insert objCourseRegistration;
            
            
            Learner_Funding__c fund = TestDataFactory.createLearnerFunding(objCourseRegistration.id);       
            ListOfFundingRecords.add(fund);
            
            att = TestDataFactory.createAttachment(file,objCourseRegistration.id,'testAttachment');
            insert att;
            // portalUser = [SELECT Id FROM User WHERE ContactId =: con.Id]; 
            portalUser = TestDataFactory.createPortalUser(portalAccount.id,con.id);
            
        }
        
        system.runas(portaluser) {
            test.startTest();
                CourseRegistrationController.getContactRecord();      
                CourseRegistrationController.getCourseRunRecord(cr.Course_Run_Code__c);  
                CourseRegistrationController.insertFundingRecords(lfund,objCourseRegistration.id);
                CourseRegistrationController.validateNRICValue('S1234567D');
                CourseRegistrationController.saveChunk(objCourseRegistration.id,'testAttachment',file.toString(),'jpg',att.Id);
                CourseRegistrationController.ContactInformation courseReg = new CourseRegistrationController.ContactInformation(con,'Test','Test','Test','Test','test','NY','NY','NY','US');
                
                String encodedString = EncodingUtil.urlEncode('TestString','UTF-8');
                CourseRegistrationController.saveTheFile(con.Id, 'fileName',encodedString , 'contentType');
                
                CourseRegistrationController.getLearnerFundingValues(objCourse.id);
            test.stopTest();
            
            Course_Registration__c cReg = [select id,Salutation__c,First_Name__c,Last_Name__c,Date_of_Birth__c,
             Preferred_Certificate_Name__c,Gender__c,NRIC_Type__c,NRIC__c,Primary_Email_Address__c,Nationality__c,
             Mobile_No__c,Race__c,Home_No__c,Residency_Status__c,Office_No__c,Education_Level__c,
              Persons_with_Disabilities__c,Employment_Status__c,Company_Name__c,Designation_Level__c,Secondary_Salutation__c,
              Secondary_Email_Address__c,Secondary_Mobile__c,Remarks__c,Attention__c,Billing_State__c,Billing_Address_Line_1__c,
              Billing_City__c,Billing_Address_Line_2__c,Billing_Country__c,Billing_Address_Line_3__c,Billing_Postal_Code__c,
              Address_Type__c,Preferred_Contact_Method__c,Designation__c from Course_Registration__c
              where id =: objCourseRegistration.id];
              
            contact retrieveCon = [SELECT Id,Name,FirstName,LastName,Salutation,Persons_with_Disabilities__c,Education_Level__c,NRIC__c,
                         Employment_Status__c,Gender__c,Monthly_Basic_Salary__c,Date_of_Birth__c,Designation_Level__c,
                         Nationality__c,Designation__c,Residency_Status__c,title,Race__c,MobilePhone,email,
                         Secondary_Salutation__c,homephone,Secondary_Email_Address__c,Secondary_Mobile_Number__c,Remarks__c,
                         Secondary_Contact_Name__c,Attention__c,OtherPhone,phone,Billing_Address_Line_1__c,Billing_Address_Line_2__c,
                         Billing_Address_Line_3__c,Billing_City__c,Billing_State__c,Billing_Country__c,Billing_Postal_Code__c,
                         RMIT_Alumni__c,Account.Membership_Active__c,Alternative_Attention__c,Alternative_Billing_Address1__c,
                         Alternative_Phone__c,Alternative_Billing_Address2__c,Alternative_Email__c,
                         Alternative_Billing_Address3__c,Alternative_City__c,Alternative_State__c,Alternative_PostalCode__c,
                         Alternative_Country__c,NRIC_Type__c,Account.RecordType.DeveloperName,Account.Billing_Address_Line_1__c, 
                         Account.Billing_Address_Line_2__c,Account.Billing_Address_Line_3__c,Account.Billing_City__c, 
                         Account.Billing_Country__c, Account.Billing_Postal_Code__c,Account.billing_state__c, Account.City__c, Account.Country__c,
                         Account.IsPersonAccount,Office_No__c,account.UEN_No__c,Primary_Email_Address__c,
                         Preferred_Certificate_Name__c,Company_Name__c,account.Preferred_Contact_Method__c,account.Address_Type__c
                         FROM Contact WHERE Id=:objCourseRegistration.contact__c];
                         
           System.assertEquals(retrieveCon.Salutation, cReg.Salutation__c);
             System.assertEquals(retrieveCon.FirstName, cReg.First_Name__c);
             System.assertEquals(retrieveCon.LastName, cReg.Last_Name__c);
             System.assertEquals(retrieveCon.Date_of_Birth__c, cReg.Date_of_Birth__c);
             System.assertEquals(retrieveCon.Preferred_Certificate_Name__c, cReg.Preferred_Certificate_Name__c);
             System.assertEquals(retrieveCon.Gender__c, cReg.Gender__c);
             System.assertEquals(retrieveCon.NRIC_Type__c, cReg.NRIC_Type__c);
             System.assertEquals(retrieveCon.NRIC__c, cReg.NRIC__c);
             System.assertEquals(retrieveCon.Primary_Email_Address__c, cReg.Primary_Email_Address__c);
             System.assertEquals(retrieveCon.Nationality__c, cReg.Nationality__c);
             System.assertEquals(retrieveCon.MobilePhone, cReg.Mobile_No__c);
             System.assertEquals(retrieveCon.Race__c, cReg.Race__c);
             System.assertEquals(retrieveCon.Phone, cReg.Home_No__c);
             System.assertEquals(retrieveCon.Residency_Status__c, cReg.Residency_Status__c);
             System.assertEquals(retrieveCon.Office_No__c, cReg.Office_No__c);
             System.assertEquals(retrieveCon.Education_Level__c, cReg.Education_Level__c);
             System.assertEquals(retrieveCon.Persons_with_Disabilities__c, cReg.Persons_with_Disabilities__c);
             System.assertEquals(retrieveCon.Employment_Status__c, cReg.Employment_Status__c);
             System.assertEquals(retrieveCon.Company_Name__c, cReg.Company_Name__c);
             System.assertEquals(retrieveCon.Designation__c, cReg.Designation__c);
             System.assertEquals(retrieveCon.Designation_Level__c, cReg.Designation_Level__c);
             System.assertEquals(retrieveCon.Secondary_Salutation__c, cReg.Secondary_Salutation__c);
             System.assertEquals(retrieveCon.Secondary_Email_Address__c, cReg.Secondary_Email_Address__c);
             System.assertEquals(retrieveCon.Secondary_Mobile_Number__c, cReg.Secondary_Mobile__c);
             System.assertEquals(retrieveCon.Remarks__c, cReg.Remarks__c);
             System.assertEquals(retrieveCon.Attention__c, cReg.Attention__c);
             System.assertEquals(retrieveCon.account.Billing_State__c, cReg.Billing_State__c);
             System.assertEquals(retrieveCon.account.Billing_Address_Line_1__c, cReg.Billing_Address_Line_1__c);
             System.assertEquals(retrieveCon.account.Billing_City__c, cReg.Billing_City__c);
             System.assertEquals(retrieveCon.account.Billing_Address_Line_2__c, cReg.Billing_Address_Line_2__c);
             System.assertEquals(retrieveCon.account.Billing_Country__c, cReg.Billing_Country__c);
             System.assertEquals(retrieveCon.account.Billing_Address_Line_3__c, cReg.Billing_Address_Line_3__c);
             System.assertEquals(retrieveCon.account.Billing_Postal_Code__c, cReg.Billing_Postal_Code__c);
             System.assertEquals(retrieveCon.account.Address_Type__c, cReg.Address_Type__c);
             System.assertEquals(retrieveCon.account.Preferred_Contact_Method__c, cReg.Preferred_Contact_Method__c);
                          
           
        }
    }
    
    //2021-03-31 Poon Koon: Update account creation steps
    public static testmethod void invoiceTest() {
        Id b2cLearnerRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('B2C_Learner').getRecordTypeId();
        Account acct = new Account();
        acct.RecordTypeId = b2cLearnerRT;
        acct.FirstName = 'Test';
        acct.LastName = 'Account';
        acct.PersonEmail = 'testApexUser@sim.edu.sg';
        acct.Credit_Term_Days__c = 14;
        insert acct;
        acct = [SELECT Id, PersonContactId FROM Account];

        Id courseRT = Schema.SObjectType.Course__c.getRecordTypeInfosByDeveloperName().get('Course').getRecordTypeId();
        Course__c course = TestDataFactory.createCourse(null);
        course.RecordTypeId = courseRT;
        insert course;

        Course_Run__c courseRun = TestDataFactory.createCourseRun();
        courseRun.Course__c = course.Id;
        insert courseRun;

        //Create Course Registration from TestDataFactory
        Course_Registration__c reg = TestDataFactory.createCourseRegistration(courseRun.Id, acct.PersonContactId);
        insert reg;
        
        Test.startTest();
        Course_Registration__c reg1 = [SELECT Id FROM Course_Registration__c];
        id invoiceId = CourseRegistrationController.returnInvoice(reg1.Id);
        Test.stopTest();
        
        system.assertNotEquals(invoiceId,null);
        List<Invoice__c> invoice = [SELECT Id,Status__c FROM Invoice__c];
        System.assertEquals(1, invoice.size());
        System.assertEquals(invoice[0].Status__c, 'Invoice Generation - In Progress');
        List<Application_Log__c> appLogList = [select id from Application_Log__c where RecordId__c =: invoice[0].id];
        System.assertEquals(1, appLogList.size());
    }
    
  
}