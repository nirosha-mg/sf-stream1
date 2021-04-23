/*************************************************************************************************************
 * @name             ShortenURLInvocableTest
 * @author           BLR\rohit.pal <rohit.pal@crmit.com>
 * @created          28 / 10 / 2020
 * @description      Description of your code
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 *               No.     Date            Author                  Description
 *               ----    ------------    --------------------    ----------------------------------------------
 * @version      1.0     2020-10-28      BLR\rohit.pal           Changes desription
 *
 **************************************************************************************************************/
@isTest(seeAllData = false)
private class ShortenURLInvocableTest {
    /**
     * @description 
     * @author Rohit Pal | 28-13-2020 
     **/

    @testSetup
    static void setupTestData() {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];  
        
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner1 = new User(
                                            UserRoleId = portalRole.Id,
                                            ProfileId = profile1.Id,
                                            Username = System.now().millisecond() + 'test222@test.com',
                                            Alias = 'batman',
                                            Email='bruce.wayne@wayneenterprises.com',
                                            EmailEncodingKey='UTF-8',
                                            Firstname='Bruce',
                                            Lastname='Wayne',
                                            LanguageLocaleKey='en_US',
                                            LocaleSidKey='en_US',
                                            TimeZoneSidKey='America/Chicago'
                                            );
        Database.insert(portalAccountOwner1);
        user portaluser; 
        Course_Run__c cr;
        Course_Registration__c objCourseRegistration;
        blob file =  Blob.valueOf('sample text');
        attachment att;
        Contact contact1;
        Course__c objCourse;

        System.runAs ( portalAccountOwner1 ) {    
         Account portalAccount1 = new Account(
                                            Name = 'TestAccount'
                                            );
                Database.insert(portalAccount1);
                
                //Create contact
                contact1 = new Contact(
                FirstName = 'Test',
                Lastname = 'McTesty',
                AccountId = portalAccount1.Id,
                Email = 'testCon@test.com',
                Company_Name__c = 'TestAccount'                
                );
                Database.insert(contact1);
                
                objCourse  = TestDataFactory.createCourse(portalAccount1.Id);
                objCourse.Public_Course__c = true;
                objCourse.Funding__c='SkillsFuture Credit';
                //update objCourse;
                insert objCourse;
                       
                cr = TestDataFactory.createCourseRun();
                cr.Course__c = objCourse.id;
                cr.Public_Course__c = true;
                insert cr;
                
                objCourseRegistration = TestDataFactory.createCourseRegistration(cr.id , contact1.id);
                objCourseRegistration.Salutation__c = 'Mr';
                objCourseRegistration.First_Name__c = 'test';
                objCourseRegistration.Last_Name__c = 'Lname';
                objCourseRegistration.Date_of_Birth__c = system.today().addyears(-10);
                objCourseRegistration.Preferred_Certificate_Name__c= 'test certificate name';
                objCourseRegistration.Gender__c = 'Male';
                objCourseRegistration.NRIC_Type__c = 'Passport';
                objCourseRegistration.NRIC__c = 'SA0001';
                objCourseRegistration.Email_Address__c = 'testCon@test.com';
                objCourseRegistration.Primary_Email_Address__c = 'test1@test.com';
                objCourseRegistration.Nationality__c = 'Singapore PR';
                objCourseRegistration.Mobile_No__c = '1234567890';
                objCourseRegistration.Race__c = 'CHINESE';
                objCourseRegistration.Home_No__c = '1234567891';
                objCourseRegistration.Residency_Status__c = 'Citizen';
                objCourseRegistration.Office_No__c = '3232325555';
                objCourseRegistration.Education_Level__c = 'Others';
                objCourseRegistration.Persons_with_Disabilities__c = 'No';
                objCourseRegistration.Employment_Status__c = 'Employed';
                objCourseRegistration.Job_Title__c = 'developer';
                objCourseRegistration.Company_Name__c = 'TestAccount';
                objCourseRegistration.Designation__c = 'Clerical Workers';
                objCourseRegistration.Monthly_Basic_Salary__c= 'Below $1000';
                objCourseRegistration.Designation_Level__c = 'Student';
                objCourseRegistration.Secondary_Salutation__c = 'Ms';
                objCourseRegistration.Secondary_Name__c = 'test name';
                objCourseRegistration.Secondary_Email_Address__c = 'second@test.com';
                objCourseRegistration.Secondary_Mobile__c = '1234567890';
                objCourseRegistration.Remarks__c = 'test remarks';
                objCourseRegistration.Attention__c = 'test attentions';
                objCourseRegistration.Billing_State__c = 'AP';
                objCourseRegistration.Billing_Address_Line_1__c = 'test line1';
                objCourseRegistration.Billing_City__c= 'test city';
                objCourseRegistration.Billing_Address_Line_2__c = 'test line2';
                objCourseRegistration.Billing_Country__c = 'Singapore';
                objCourseRegistration.Billing_Address_Line_3__c = 'test line3';
                objCourseRegistration.Billing_Postal_Code__c = '500050';
                objCourseRegistration.Address_Type__c = 'Home';
                objCourseRegistration.Preferred_Contact_Method__c = 'Email';
                objCourseRegistration.Alternative_Attention__c = 'test attention';
                objCourseRegistration.Alternative_State__c = 'test state';
                objCourseRegistration.Alternative_Billing_Line_1__c = 'test alternative line1';
                objCourseRegistration.Alternative_City__c  = 'test alter city';
                objCourseRegistration.Alternative_Billing_Line_2__c = 'test alter line2';
                objCourseRegistration.Alternative_Country__c = 'Singapore';
                objCourseRegistration.Alternative_Billing_Line_3__c = 'test alter line3';
                objCourseRegistration.Alternative_Postal_Code__c = '500070';
                objCourseRegistration.Alternative_Email__c = 'testAlter@test.com';
                objCourseRegistration.Alternative_Phone__c = '4544545454';   
                objCourseRegistration.Company_UEN_No__c = '123';
                insert objCourseRegistration;
                 system.debug('objCourseRegistration ==>' + objCourseRegistration.Email_Address__c);
              
          }
    }

    /**
     * @description : 
     * @author Rohit Pal | 2020-10-28 
     * @return void 
     **/
    static testMethod void shortenAsyncTest() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new ShortenURLMock());
        List < List < String >> listCourseRegistrationSurveyURL = new List < List < String >> ();
        List < String > listCrsRegSurveyURL = new List < String > ();
        Account acc = [SELECT Id FROM Account];
        Contact con = [SELECT Id, Email FROM Contact WHERE AccountId =: acc.Id];
        Course_Registration__c course_Registration = [SELECT Id, 
                                                                Course_Run_Id__c,
                                                                Email_Address__c, 
                                                                Contact__c, 
                                                                Contact__r.Email, 
                                                                Contact__r.Primary_Email_Address__c, 
                                                                Contact__r.Alternative_Email__c 
                                                        FROM Course_Registration__c 
                                                        WHERE Email_Address__c = 'testCon@test.com'];

        system.debug('inside test class' + course_Registration.Email_Address__c + ' @@@ >> ' + course_Registration.Contact__c + ' << Email >>' + course_Registration.Contact__r.Email);
        listCrsRegSurveyURL.add('https://www.InvitationLinkAnonymous.com');
        listCrsRegSurveyURL.add('https://www.wstrInvitationLink.com');
        listCrsRegSurveyURL.add(course_Registration.Id);
        listCrsRegSurveyURL.add(course_Registration.Course_Run_Id__c);
        listCourseRegistrationSurveyURL.add(listCrsRegSurveyURL);


        ShortenURLInvocable.shorten(listCourseRegistrationSurveyURL);
        
        Test.stopTest();
    }

}