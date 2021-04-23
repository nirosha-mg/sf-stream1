/*************************************************************************************************************
 * @name             ShortenURLInvocableForAnonSurveyTest
 * @author           Poon Koon
 * @created          2021-03-10
 * @description      Description of your code
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 *               No.     Date            Author                  Description
 *               ----    ------------    --------------------    ----------------------------------------------
 * @version      1.0     2021-03-10      Poon Koon               Initial Version
 **************************************************************************************************************/
@isTest(seeAllData = false)
private class ShortenURLInvocableForAnonSurveyTest {
    /**
     * @description 
     * @author Poon Koon | 2021-03-10 
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
                cr.Course_Run_Code__c = 'testCode1234';
                insert cr;
            }
    }

    /**
     * @description 
     * @author Poon Koon | 2021-03-10 
     **/
    static testMethod void shortenAsyncForAnonSurveyTest() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new ShortenURLMock());
        List < List < String >> listCourseRegistrationSurveyURL = new List < List < String >> ();
        List < String > listCrsRegSurveyURL = new List < String > ();

        Course_Run__c courseRun = [SELECT Id FROM Course_Run__c LIMIT 1];

        listCrsRegSurveyURL.add('https://www.InvitationLinkAnonymous.com');
        listCrsRegSurveyURL.add(courseRun.Id);
        listCourseRegistrationSurveyURL.add(listCrsRegSurveyURL);


        ShortenURLInvocableForAnonSurvey.shortenForAnonSurvey(listCourseRegistrationSurveyURL);
        
        Test.stopTest();
    }

}