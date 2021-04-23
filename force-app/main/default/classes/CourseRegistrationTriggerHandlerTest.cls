@isTest
public class CourseRegistrationTriggerHandlerTest {
public static testmethod void Testingmethod() {
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
        
        List<Course_Registration__c> listcreg=new List<Course_Registration__c>();
        Course_Registration__c creg=TestDataFactory.createCourseRegistration(cr.id,con.id);
        creg.NRIC_Type__c = 'Singapore Citizen/PR';
        creg.NRIC__c='S1021308H';
        insert creg;
        creg.NRIC__c='S4405529E';
        
        Course_Registration__c cregone=TestDataFactory.createCourseRegistration(cr.id,con.id);
        cregone.NRIC_Type__c = 'Singapore Citizen/PR';
        cregone.NRIC__c='S1021308H';
        insert cregone;
        cregone.NRIC__c='T6228669A';
        
        Course_Registration__c cregtwo=TestDataFactory.createCourseRegistration(cr.id,con.id);
        cregtwo.NRIC_Type__c = 'Singapore Citizen/PR';
        cregtwo.NRIC__c='S1021308H';
        insert cregtwo;
        cregtwo.NRIC__c='G4450556N';
        
        Course_Registration__c cregthree=TestDataFactory.createCourseRegistration(cr.id,con.id);
        cregthree.NRIC_Type__c = 'Singapore Citizen/PR';
        cregthree.NRIC__c='S1021308H';
        insert cregthree;
        cregthree.NRIC__c='F1402597U';
        listcreg.add(creg);
        listcreg.add(cregone);
        listcreg.add(cregtwo);
        listcreg.add(cregthree);
        
        Test.startTest();
            update listcreg;
        Test.stopTest();   
        System.assertEquals(creg.NRIC__c, 'S4405529E');
        System.assertEquals(cregone.NRIC__c, 'T6228669A');
        System.assertEquals(cregtwo.NRIC__c, 'G4450556N');
        System.assertEquals(cregthree.NRIC__c, 'F1402597U');
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
        
        Course_Registration__c reg = TestDataFactory.createCourseRegistration(cr.id,con.id);      
       try {  
             reg.NRIC_Type__c  = 'Singapore Citizen/PR';
             reg.NRIC__c = 'T9113754A'; 
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
        
        Course_Registration__c reg = TestDataFactory.createCourseRegistration(cr.id,con.id);    
       try { 
            reg.NRIC_Type__c  = 'FIN';
            reg.NRIC__c = 'F6121351B'; 
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
        
       Course_Registration__c reg = TestDataFactory.createCourseRegistration(cr.id,con.id);    
       try { 
            reg.NRIC_Type__c  = 'FIN';
            reg.NRIC__c = 'G8290888C'; 
            insert reg;
            
        } catch(exception e) {
        }
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
        
        course_registration__c reg = TestDataFactory.createCourseRegistration(cr.id,con.id);        
       try {
             reg.NRIC_Type__c  = 'FIN';
             reg.NRIC__c = 'S1234567A';       
            insert reg;
            
        } catch(exception e) {
        }
    } 
    
    public static testmethod void testB2BFlow() {
         userrole role = TestDataFactory.returnUserRole();
        user adminUser = TestDataFactory.createSystemAdmin(role.id);
        insert adminUser;
        
        Course__c objCourse;
        Course_Run__c cr;
        Course_Registration__c objCourseRegistration;
        Course_Registration__c parentRegistration;
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
            
            parentRegistration = TestDataFactory.createCourseRegistrationB2B(cr.id , con.id);
            parentRegistration.email_address__c = 'test0123@test.com';
            insert parentRegistration;
           
            List<course_registration__c> courseRegList = new List<course_registration__c>();            
            test.startTest();
            course_registration__c parentReg = [select id from course_registration__c where id =: parentRegistration.id];
            for(integer i = 0; i < 104 ; i++) {
                objCourseRegistration = TestDataFactory.createCourseRegistrationB2B(cr.id,null);
                 objCourseRegistration.First_Name__c = 'Test' + i;
                 objCourseRegistration.Last_Name__c = 'Lname' + i;
                 objCourseRegistration.Email_Address__c = 'testXXX000' + i + '@test.com';
                 objCourseRegistration.parent_registration__c = parentReg.id;
                 objCourseRegistration.contact__c = null;
                 courseRegList.add(objCourseRegistration);
            }
            system.debug(courseRegList[0].Email_Address__c + 'email==' + courseRegList[1].Email_Address__c);
            insert courseRegList;
            system.debug(courseRegList[0].Email_Address__c + 'test==');
            test.stopTest();
        }
    }
    
     public static testmethod void testSyncLogic() {
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
    

}