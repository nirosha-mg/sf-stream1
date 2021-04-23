@IsTest
public with sharing class DeductionTriggerHandlerTest {
    //2021-03-31 Poon Koon: Update data preparation class
    @TestSetup
    static void makeData(){
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
        course.Fee_Code__c = 'PROGRM';
        course.Cost_Center__c = 'SM1040';
        insert course;

        Course_Run__c courseRun = TestDataFactory.createCourseRun();
        courseRun.Course__c = course.Id;
        courseRun.Fee_Code__c = 'PROGRM';
        courseRun.Cost_Center__c = 'SM1040';
        insert courseRun;

        //Create Course Registration from TestDataFactory
        Course_Registration__c reg = TestDataFactory.createCourseRegistration(courseRun.Id, acct.PersonContactId);
        insert reg;

        InvoiceUtility.generateInvoiceForRegistration(reg.Id);
    }

    @IsTest
    static void calculateGSTWithDeduction() {

        Id invoiceId = [SELECT Id FROM Invoice__c LIMIT 1].Id;
        Accounting_Notes__c acct = new Accounting_Notes__c();
        acct.Invoice__c = invoiceId;
        acct.Attention_To__c = 'Test';
        
        insert acct;
        Invoice_Line_Item__c lineItem = [SELECT Fee_Code__c, Department__c, Cost_Center__c FROM Invoice_Line_Item__c LIMIT 1];
        Deduction__c deduction = new Deduction__c();
        deduction.GST_Code__c = '12';
        deduction.Amount__c = 100;
        deduction.GST_Amount__c = 10;
        deduction.Accounting_Notes__c = acct.Id;
        deduction.Fee_Code__c = lineItem.Fee_Code__c;
        deduction.Deduction_Amount__c = 200;
        deduction.Deduction_GST_Code__c = '12';
        deduction.Deduction_Fee_Code__c = lineItem.Fee_Code__c;
        Test.startTest();
        insert deduction;
        Test.stopTest();
        
        Deduction__c deductionAfter = [SELECT GST_Amount__c, Deduction_GST_Amount__c FROM Deduction__c WHERE Id=: deduction.Id];
        System.assertEquals(10, deductionAfter.GST_Amount__c);
        System.assertEquals(14, deductionAfter.Deduction_GST_Amount__c);
    }

    @IsTest
    static void calculateGST() {

        Id invoiceId = [SELECT Id FROM Invoice__c LIMIT 1].Id;
        Accounting_Notes__c acct = new Accounting_Notes__c();
        acct.Invoice__c = invoiceId;
        acct.Attention_To__c = 'Test';
        
        insert acct;
        Invoice_Line_Item__c lineItem = [SELECT Fee_Code__c, Department__c, Cost_Center__c FROM Invoice_Line_Item__c LIMIT 1];
        Deduction__c deduction = new Deduction__c();
        deduction.GST_Code__c = '12';
        deduction.Amount__c = 100;
        deduction.GST_Amount__c = 0;
        deduction.Accounting_Notes__c = acct.Id;
        deduction.Fee_Code__c = lineItem.Fee_Code__c;
        deduction.Deduction_Amount__c = 0;
        deduction.Deduction_GST_Code__c = '12';
        deduction.Deduction_Fee_Code__c = lineItem.Fee_Code__c;
        Test.startTest();
        insert deduction;
        Test.stopTest();
        
        Deduction__c deductionAfter = [SELECT GST_Amount__c, Deduction_GST_Amount__c FROM Deduction__c WHERE Id=: deduction.Id];
        System.assertEquals(0, deductionAfter.GST_Amount__c);
        System.assertEquals(0, deductionAfter.Deduction_GST_Amount__c);
    }
}