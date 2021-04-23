@IsTest
public without sharing class RedirectToProfileControllerTest {
    @IsTest
    static void getURL(){
        //Just needed for coverage
        Test.startTest();
        RedirectToProfileController.getProfileURL();
        Test.stopTest();
        
    }
}