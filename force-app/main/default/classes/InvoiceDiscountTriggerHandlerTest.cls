@IsTest
public without sharing class InvoiceDiscountTriggerHandlerTest {


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
        
        Id earlyBirdRT = Schema.SObjectType.Discount__c.getRecordTypeInfosByDeveloperName().get('Early_Bird').getRecordTypeId();
        Discount__c disc = TestDataFactory.createDiscount();
        disc.Amount__c = 50;
        disc.GST_Amount__c = 0;
        disc.GST_Code__c = '12';
        disc.Percentage__c = false;
        disc.RecordTypeId = earlyBirdRT;
        insert disc;

        Course_Registration__c reg = [SELECT Id FROM Course_Registration__c];
        InvoiceUtility.generateInvoiceForRegistration(reg.Id);
        List<Invoice__c> invoice = [SELECT Id, Amount__c, GST_Amount__c FROM Invoice__c];
        Test.startTest();
        List<Invoice_Line_Item__c> invoiceLineItems = [SELECT Id, Amount__c, GST_Amount__c FROM Invoice_Line_Item__c WHERE Invoice__c =: invoice[0].Id];
        Invoice_Discount__c invdisc = new Invoice_Discount__c();
        invdisc.Discount__c = disc.Id;
        invdisc.Invoice_Line_Item__c = invoiceLineItems[0].Id;
        invdisc.GST_Code__c = '12';
        invdisc.GST_Mode__c = 'Full';
        insert invdisc;

        Invoice_Discount__c invdiscUpdate = new Invoice_Discount__c();
        invdiscUpdate.Id = invdisc.Id;
        invdiscUpdate.Amount__c = 10;
        update invdiscUpdate;
        Test.stopTest();

        Invoice_Discount__c invDiscAfter = [SELECT Amount__c, GST_Amount__c FROM Invoice_Discount__c];
        System.assertEquals(10, invDiscAfter.Amount__c);
        System.assertEquals(0.7, invDiscAfter.GST_Amount__c);
    }



    @IsTest
    static void calculateGSTNett(){
        prepareDataForCourse();
        
        Id earlyBirdRT = Schema.SObjectType.Discount__c.getRecordTypeInfosByDeveloperName().get('Early_Bird').getRecordTypeId();
        Discount__c disc = TestDataFactory.createDiscount();
        disc.Amount__c = 50;
        disc.GST_Amount__c = 0;
        disc.GST_Code__c = '12';
        disc.Percentage__c = false;
        disc.RecordTypeId = earlyBirdRT;
        insert disc;

        Course_Registration__c reg = [SELECT Id FROM Course_Registration__c];
        InvoiceUtility.generateInvoiceForRegistration(reg.Id);
        List<Invoice__c> invoice = [SELECT Id, Amount__c, GST_Amount__c FROM Invoice__c];
        Test.startTest();
        List<Invoice_Line_Item__c> invoiceLineItems = [SELECT Id, Amount__c, GST_Amount__c FROM Invoice_Line_Item__c WHERE Invoice__c =: invoice[0].Id];
        Invoice_Discount__c invdisc = new Invoice_Discount__c();
        invdisc.Discount__c = disc.Id;
        invdisc.Invoice_Line_Item__c = invoiceLineItems[0].Id;
        invdisc.GST_Code__c = '12';
        invdisc.GST_Mode__c = 'Nett';
        insert invdisc;

        Invoice_Discount__c invdiscUpdate = new Invoice_Discount__c();
        invdiscUpdate.Id = invdisc.Id;
        invdiscUpdate.Amount__c = 10;
        update invdiscUpdate;
        Test.stopTest();

        Invoice_Discount__c invDiscAfter = [SELECT Amount__c, GST_Amount__c FROM Invoice_Discount__c];
        //2001211130 Desmond
        Decimal gstAmt = 10 - (10 / 1.07);
        //Decimal AmountWoGST = (10 / 1.07).setScale(2,RoundingMode.HALF_UP);
        //Decimal gstAmt = 10 - AmountWoGST;

        System.assertEquals(10 - gstAmt.setScale(2, RoundingMode.HALF_UP), invDiscAfter.Amount__c);
        System.assertEquals(gstAmt.setScale(2, RoundingMode.HALF_UP), invDiscAfter.GST_Amount__c);
        System.assertEquals(10, invDiscAfter.Amount__c + invDiscAfter.GST_Amount__c);
    }
}