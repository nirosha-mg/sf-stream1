@IsTest
public without sharing class InvoiceLineItemTriggerHandlerTest {

    //2021-03-31 Poon Koon: Update data preparation class
    static void prepareDataForCourse(){
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
        course.Non_Member_Fee__c = 100;
        insert course;

        Course_Run__c courseRun = TestDataFactory.createCourseRun();
        courseRun.Course__c = course.Id;
        insert courseRun;

        //Create Course Registration from TestDataFactory
        Course_Registration__c reg = TestDataFactory.createCourseRegistration(courseRun.Id, acct.PersonContactId);
        insert reg;
    }

    @IsTest
    static void calculateGST(){
        prepareDataForCourse();

        Test.startTest();
        Course_Registration__c reg = [SELECT Id FROM Course_Registration__c];
        InvoiceUtility.generateInvoiceForRegistration(reg.Id);
        Test.stopTest();
        List<Invoice__c> invoice = [SELECT Id, Amount__c, GST_Amount__c FROM Invoice__c];
        List<Invoice_Line_Item__c> invoiceLineItems = [SELECT Id, Amount__c, GST_Amount__c FROM Invoice_Line_Item__c WHERE Invoice__c =: invoice[0].Id];
        System.assertEquals(1, invoiceLineItems.size());
        System.assertEquals(100, invoiceLineItems[0].Amount__c);
        System.assertEquals(7, invoiceLineItems[0].GST_Amount__c);
        
    }
}