/**
 * @description       : 
 * @author            : Mark Alvin Tayag (mtayag@salesforce.com)
 * @group             : 
 * @last modified on  : 11-04-2020
 * @last modified by  : Mark Alvin Tayag (mtayag@salesforce.com)
 * Modifications Log 
 * Ver   Date         Author                                     Modification
 * 1.0   10-11-2020   Mark Alvin Tayag (mtayag@salesforce.com)   Initial Version
 * 1.1   2021-03-12   Poon Koon                                  Update test classes to include testing for RMIT Discount
 *                                                               and for early bird calculation to be based on Course Run Start Date
 * 1.2   2021-03-22   Poon Koon                                  Update test preparation methods to include new Credit Term field
**/
@IsTest
public with sharing class InvoiceUtilityTest {
 
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
        insert course;

        Course_Run__c courseRun = TestDataFactory.createCourseRun();
        courseRun.Course__c = course.Id;
        courseRun.Start_Date__c = System.today()+2;
        courseRun.End_Date__c = System.today()+4;
        insert courseRun;

        //Create Course Registration from TestDataFactory
        Course_Registration__c reg = TestDataFactory.createCourseRegistration(courseRun.Id, acct.PersonContactId);
        insert reg;
    }
 
    static void prepareDataForCourseWithParent(){
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
        courseRun.Start_Date__c = System.today()+2;
        courseRun.End_Date__c = System.today()+4;
        insert courseRun;

        //Create Course Registration from TestDataFactory

        Course_Registration__c parentReg = TestDataFactory.createCourseRegistration(courseRun.Id, acct.PersonContactId);
        insert parentReg;

        Course_Registration__c reg = TestDataFactory.createCourseRegistration(courseRun.Id, acct.PersonContactId);
        reg.Parent_Registration__c = parentReg.Id;
        reg.Email_Address__c = 'testApexUser@sim.edu.sg';
        insert reg;

        Course_Registration__c reg2 = TestDataFactory.createCourseRegistration(courseRun.Id, acct.PersonContactId);
        reg2.Parent_Registration__c = parentReg.Id;
        reg2.Email_Address__c = 'testApexUser@sim.edu.sg';
        insert reg2;
    }

    static void prepareDataForFundedCourse(){
        Id b2cLearnerRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('B2C_Learner').getRecordTypeId();
        Account acct = new Account();
        acct.RecordTypeId = b2cLearnerRT;
        acct.FirstName = 'Test';
        acct.LastName = 'Account';
        acct.PersonEmail = 'testApexUser@sim.edu.sg';
        acct.Credit_Term_Days__c = 14;
        insert acct;
        acct = [SELECT Id, PersonContactId FROM Account];

        Id fundedSSGCourseRT = Schema.SObjectType.Course__c.getRecordTypeInfosByDeveloperName().get('Funded_Course').getRecordTypeId();
        Course__c course = TestDataFactory.createCourse(null);
        course.RecordTypeId = fundedSSGCourseRT;
        insert course;

        Module__c module = TestDataFactory.createModule();
        insert module;

        Course_Module__c cm = new Course_Module__c();
        cm.Course__c = course.Id;
        cm.Module__c = module.Id;
        insert cm;

        Course_Run__c courseRun = TestDataFactory.createCourseRun();
        courseRun.Course__c = course.Id;
        courseRun.Start_Date__c = System.today()+2;
        courseRun.End_Date__c = System.today()+4;
        insert courseRun;

        //Create Course Registration from TestDataFactory
        Course_Registration__c reg = TestDataFactory.createCourseRegistration(courseRun.Id, acct.PersonContactId);
        insert reg;
    }
 
    static void prepareDataForFundedCourseWithParent(){
        Id b2cLearnerRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('B2C_Learner').getRecordTypeId();
        Account acct = new Account();
        acct.RecordTypeId = b2cLearnerRT;
        acct.FirstName = 'Test';
        acct.LastName = 'Account';
        acct.PersonEmail = 'testApexUser@sim.edu.sg';
        acct.Credit_Term_Days__c = 14;
        insert acct;
        acct = [SELECT Id, PersonContactId FROM Account];

        Id fundedSSGCourseRT = Schema.SObjectType.Course__c.getRecordTypeInfosByDeveloperName().get('Funded_Course').getRecordTypeId();
        Course__c course = TestDataFactory.createCourse(null);
        course.RecordTypeId = fundedSSGCourseRT;
        insert course;

        Module__c module = TestDataFactory.createModule();
        insert module;

        Course_Module__c cm = new Course_Module__c();
        cm.Course__c = course.Id;
        cm.Module__c = module.Id;
        insert cm;

        Course_Run__c courseRun = TestDataFactory.createCourseRun();
        courseRun.Course__c = course.Id;
        courseRun.Start_Date__c = System.today()+2;
        courseRun.End_Date__c = System.today()+4;
        insert courseRun;

        //Create Course Registration from TestDataFactory

        Course_Registration__c parentReg = TestDataFactory.createCourseRegistration(courseRun.Id, acct.PersonContactId);
        insert parentReg;

        Course_Registration__c reg = TestDataFactory.createCourseRegistration(courseRun.Id, acct.PersonContactId);
        reg.Parent_Registration__c = parentReg.Id;
        reg.Email_Address__c = 'testApexUser@sim.edu.sg';
        insert reg;

        Course_Registration__c reg2 = TestDataFactory.createCourseRegistration(courseRun.Id, acct.PersonContactId);
        reg2.Parent_Registration__c = parentReg.Id;
        reg2.Email_Address__c = 'testApexUser@sim.edu.sg';
        insert reg2;
    }

    static void prepareDataForRMITCourse(){
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
        course.Provider__c = 'RMIT';
        insert course;

        Course_Run__c courseRun = TestDataFactory.createCourseRun();
        courseRun.Course__c = course.Id;
        courseRun.Start_Date__c = System.today()+2;
        courseRun.End_Date__c = System.today()+4;
        insert courseRun;

        //Create Course Registration from TestDataFactory
        Course_Registration__c reg = TestDataFactory.createCourseRegistration(courseRun.Id, acct.PersonContactId);
        reg.RMIT_Alumni__c = true;
        insert reg;
    }

    @IsTest
    static void createNonMemberInvoiceWOEarlyBird() {
        Id courseRT = Schema.SObjectType.Course__c.getRecordTypeInfosByDeveloperName().get('Course').getRecordTypeId();
        prepareDataForCourse();

        Course__c course = [SELECT Non_Member_Fee__c, Non_Member_GST_Fee__c  FROM Course__c];

        Test.startTest();
        Course_Registration__c reg = [SELECT Id FROM Course_Registration__c];
        InvoiceUtility.generateInvoiceForRegistration(reg.Id);
        Test.stopTest();

        List<Invoice__c> invoice = [SELECT Id, Amount__c, GST_Amount__c FROM Invoice__c];
        System.assertEquals(1, invoice.size());
        List<Invoice_Line_Item__c> invoiceLineItems = [SELECT Id, Amount__c, GST_Amount__c FROM Invoice_Line_Item__c WHERE Invoice__c =: invoice[0].Id];
        System.assertEquals(1, invoiceLineItems.size());
        System.assertEquals(course.Non_Member_Fee__c, invoice[0].Amount__c);
        System.assertEquals(course.Non_Member_GST_Fee__c, invoice[0].GST_Amount__c);
    }

    @IsTest
    static void createNonMemberInvoiceWEarlyBirdPercentage() {        
        Id courseRT = Schema.SObjectType.Course__c.getRecordTypeInfosByDeveloperName().get('Course').getRecordTypeId();
        prepareDataForCourse();

        Course__c course = [SELECT Non_Member_Fee__c, Non_Member_GST_Fee__c  FROM Course__c];

        Id earlyBirdRT = Schema.SObjectType.Discount__c.getRecordTypeInfosByDeveloperName().get('Early_Bird').getRecordTypeId();
        Discount__c discount = TestDataFactory.createDiscount();
        discount.Percentage__c = true;
        discount.Amount__c = 10;
        discount.GST_Amount__c = 7;
        discount.RecordTypeId = earlyBirdRT;
        discount.No_of_Days__c = 1;
        insert discount;

        Course_Discount__c cdisc = new Course_Discount__c();
        cdisc.Course__c = course.Id;
        cdisc.Discount__c = discount.Id;
        insert cdisc;
        

        Test.startTest();
        Course_Registration__c reg = [SELECT Id FROM Course_Registration__c];
        InvoiceUtility.generateInvoiceForRegistration(reg.Id);
        Test.stopTest();

        List<Invoice__c> invoice = [SELECT Id, Amount__c, GST_Amount__c, Discount_Amount__c, Discount_GST_Amount__c FROM Invoice__c];
        System.assertEquals(1, invoice.size());
        System.assertEquals(course.Non_Member_Fee__c, invoice[0].Amount__c);
        System.assertEquals(course.Non_Member_GST_Fee__c, invoice[0].GST_Amount__c);
        System.assertEquals(course.Non_Member_Fee__c * (discount.Amount__c / 100), invoice[0].Discount_Amount__c);
        System.assertEquals((course.Non_Member_Fee__c * (discount.Amount__c / 100)) * (discount.GST_Amount__c / 100), invoice[0].Discount_GST_Amount__c);
    }

    @IsTest
    static void createNonMemberInvoiceWEarlyBirdAmount() {        
        Id courseRT = Schema.SObjectType.Course__c.getRecordTypeInfosByDeveloperName().get('Course').getRecordTypeId();
        prepareDataForCourse();

        Course__c course = [SELECT Non_Member_Fee__c, Non_Member_GST_Fee__c  FROM Course__c];

        Id earlyBirdRT = Schema.SObjectType.Discount__c.getRecordTypeInfosByDeveloperName().get('Early_Bird').getRecordTypeId();
        Discount__c discount = TestDataFactory.createDiscount();
        discount.Percentage__c = false;
        discount.Amount__c = 100;
        discount.GST_Amount__c = 7;
        discount.RecordTypeId = earlyBirdRT;
        discount.No_of_Days__c = 1;
        insert discount;

        Course_Discount__c cdisc = new Course_Discount__c();
        cdisc.Course__c = course.Id;
        cdisc.Discount__c = discount.Id;
        insert cdisc;
        

        Test.startTest();
        Course_Registration__c reg = [SELECT Id FROM Course_Registration__c];
        InvoiceUtility.generateInvoiceForRegistration(reg.Id);
        Test.stopTest();

        List<Invoice__c> invoice = [SELECT Id, Amount__c, GST_Amount__c, Discount_Amount__c, Discount_GST_Amount__c FROM Invoice__c];
        System.assertEquals(1, invoice.size());
        System.assertEquals(course.Non_Member_Fee__c, invoice[0].Amount__c);
        System.assertEquals(course.Non_Member_GST_Fee__c, invoice[0].GST_Amount__c);
        System.assertEquals(discount.Amount__c, invoice[0].Discount_Amount__c);
        System.assertEquals(discount.GST_Amount__c, invoice[0].Discount_GST_Amount__c);
    }

    @IsTest
    static void createNonMemberInvoiceWExpiredEarlyBirdAmount() {        
        Id courseRT = Schema.SObjectType.Course__c.getRecordTypeInfosByDeveloperName().get('Course').getRecordTypeId();
        prepareDataForCourse();

        Course__c course = [SELECT Non_Member_Fee__c, Non_Member_GST_Fee__c  FROM Course__c];
        
        Id earlyBirdRT = Schema.SObjectType.Discount__c.getRecordTypeInfosByDeveloperName().get('Early_Bird').getRecordTypeId();
        Discount__c discount = TestDataFactory.createDiscount();
        discount.Percentage__c = false;
        discount.Amount__c = 100;
        discount.GST_Amount__c = 7;
        discount.RecordTypeId = earlyBirdRT;
        discount.No_of_Days__c = 100;
        insert discount;

        Course_Discount__c cdisc = new Course_Discount__c();
        cdisc.Course__c = course.Id;
        cdisc.Discount__c = discount.Id;
        insert cdisc;
        

        Test.startTest();
        Course_Registration__c reg = [SELECT Id FROM Course_Registration__c];
        InvoiceUtility.generateInvoiceForRegistration(reg.Id);
        Test.stopTest();

        List<Invoice__c> invoice = [SELECT Id, Amount__c, GST_Amount__c, Discount_Amount__c, Discount_GST_Amount__c FROM Invoice__c];
        System.assertEquals(1, invoice.size());
        System.assertEquals(course.Non_Member_Fee__c, invoice[0].Amount__c);
        System.assertEquals(course.Non_Member_GST_Fee__c, invoice[0].GST_Amount__c);
        System.assertEquals(0, invoice[0].Discount_Amount__c);
        System.assertEquals(0, invoice[0].Discount_GST_Amount__c);
    }

    //With Parent
    @IsTest
    static void createChildNonMemberInvoiceWOEarlyBird() {
        Id courseRT = Schema.SObjectType.Course__c.getRecordTypeInfosByDeveloperName().get('Course').getRecordTypeId();
        prepareDataForCourseWithParent();

        Course__c course = [SELECT Non_Member_Fee__c, Non_Member_GST_Fee__c  FROM Course__c];
        List<Course_Registration__c> childCourseRegs = [SELECT Id FROM Course_Registration__c WHERE Parent_Registration__c != null];

        Test.startTest();
        Course_Registration__c reg = [SELECT Id FROM Course_Registration__c WHERE Parent_Registration__c = null];
        InvoiceUtility.generateInvoiceForRegistration(reg.Id);
        Test.stopTest();

        List<Invoice__c> invoice = [SELECT Id, Amount__c, GST_Amount__c FROM Invoice__c];
        System.assertEquals(1, invoice.size());
        List<Invoice_Line_Item__c> invoiceLineItems = [SELECT Id, Amount__c, GST_Amount__c FROM Invoice_Line_Item__c WHERE Invoice__c =: invoice[0].Id];
        System.assertEquals(childCourseRegs.size(), invoiceLineItems.size());
        System.assertEquals(course.Non_Member_Fee__c * childCourseRegs.size(), invoice[0].Amount__c);
        System.assertEquals(course.Non_Member_GST_Fee__c * childCourseRegs.size(), invoice[0].GST_Amount__c);
    }

    @IsTest
    static void createChildNonMemberInvoiceWEarlyBirdPercentage() {
        Id courseRT = Schema.SObjectType.Course__c.getRecordTypeInfosByDeveloperName().get('Course').getRecordTypeId();
        prepareDataForCourseWithParent();

        Course__c course = [SELECT Non_Member_Fee__c, Non_Member_GST_Fee__c  FROM Course__c];
        List<Course_Registration__c> childCourseRegs = [SELECT Id FROM Course_Registration__c WHERE Parent_Registration__c != null];

        Id earlyBirdRT = Schema.SObjectType.Discount__c.getRecordTypeInfosByDeveloperName().get('Early_Bird').getRecordTypeId();
        Discount__c discount = TestDataFactory.createDiscount();
        discount.Percentage__c = true;
        discount.Amount__c = 10;
        discount.GST_Amount__c = 7;
        discount.RecordTypeId = earlyBirdRT;
        discount.No_of_Days__c = 1;
        insert discount;

        Course_Discount__c cdisc = new Course_Discount__c();
        cdisc.Course__c = course.Id;
        cdisc.Discount__c = discount.Id;
        insert cdisc;

        Test.startTest();
        Course_Registration__c reg = [SELECT Id FROM Course_Registration__c WHERE Parent_Registration__c = null];
        InvoiceUtility.generateInvoiceForRegistration(reg.Id);
        Test.stopTest();

        List<Invoice__c> invoice = [SELECT Id, Amount__c, GST_Amount__c, Discount_Amount__c, Discount_GST_Amount__c FROM Invoice__c];
        System.assertEquals(1, invoice.size());
        List<Invoice_Line_Item__c> invoiceLineItems = [SELECT Id, Amount__c, GST_Amount__c FROM Invoice_Line_Item__c WHERE Invoice__c =: invoice[0].Id];
        System.assertEquals(childCourseRegs.size(), invoiceLineItems.size());
        System.assertEquals(course.Non_Member_Fee__c * childCourseRegs.size(), invoice[0].Amount__c);
        System.assertEquals(course.Non_Member_GST_Fee__c * childCourseRegs.size(), invoice[0].GST_Amount__c);
        List<Invoice_Discount__c> invoiceDiscounts = [SELECT Amount__c, GST_Amount__c, Invoice_Line_Item__c, Id FROM Invoice_Discount__c];
        System.assertEquals(2, invoiceDiscounts.size());
        System.assertEquals(course.Non_Member_Fee__c * (discount.Amount__c / 100) * childCourseRegs.size(), invoice[0].Discount_Amount__c);
        System.assertEquals((course.Non_Member_Fee__c * (discount.Amount__c / 100)) * (discount.GST_Amount__c / 100) * childCourseRegs.size(), invoice[0].Discount_GST_Amount__c);
    }

    @IsTest
    static void createChildNonMemberInvoiceWEarlyBirdAmount() {
        Id courseRT = Schema.SObjectType.Course__c.getRecordTypeInfosByDeveloperName().get('Course').getRecordTypeId();
        prepareDataForCourseWithParent();

        Course__c course = [SELECT Non_Member_Fee__c, Non_Member_GST_Fee__c  FROM Course__c];
        List<Course_Registration__c> childCourseRegs = [SELECT Id FROM Course_Registration__c WHERE Parent_Registration__c != null];

        Id earlyBirdRT = Schema.SObjectType.Discount__c.getRecordTypeInfosByDeveloperName().get('Early_Bird').getRecordTypeId();
        Discount__c discount = TestDataFactory.createDiscount();
        discount.Percentage__c = false;
        discount.Amount__c = 100;
        discount.GST_Amount__c = 7;
        discount.RecordTypeId = earlyBirdRT;
        discount.No_of_Days__c = 1;
        insert discount;

        Course_Discount__c cdisc = new Course_Discount__c();
        cdisc.Course__c = course.Id;
        cdisc.Discount__c = discount.Id;
        insert cdisc;

        Test.startTest();
        Course_Registration__c reg = [SELECT Id FROM Course_Registration__c WHERE Parent_Registration__c = null];
        InvoiceUtility.generateInvoiceForRegistration(reg.Id);
        Test.stopTest();

        List<Invoice__c> invoice = [SELECT Id, Amount__c, GST_Amount__c, Discount_Amount__c, Discount_GST_Amount__c FROM Invoice__c];
        System.assertEquals(1, invoice.size());
        List<Invoice_Line_Item__c> invoiceLineItems = [SELECT Id, Amount__c, GST_Amount__c FROM Invoice_Line_Item__c WHERE Invoice__c =: invoice[0].Id];
        System.assertEquals(childCourseRegs.size(), invoiceLineItems.size());
        System.assertEquals(course.Non_Member_Fee__c * childCourseRegs.size(), invoice[0].Amount__c);
        System.assertEquals(course.Non_Member_GST_Fee__c * childCourseRegs.size(), invoice[0].GST_Amount__c);
        List<Invoice_Discount__c> invoiceDiscounts = [SELECT Amount__c, GST_Amount__c, Invoice_Line_Item__c, Id FROM Invoice_Discount__c];
        System.assertEquals(2, invoiceDiscounts.size());
        System.assertEquals(discount.Amount__c * childCourseRegs.size(), invoice[0].Discount_Amount__c);
        System.assertEquals(discount.GST_Amount__c * childCourseRegs.size(), invoice[0].Discount_GST_Amount__c);
    }

    @IsTest
    static void createChildNonMemberInvoiceWExpiredEarlyBirdAmount() {
        Id courseRT = Schema.SObjectType.Course__c.getRecordTypeInfosByDeveloperName().get('Course').getRecordTypeId();
        prepareDataForCourseWithParent();

        Course__c course = [SELECT Non_Member_Fee__c, Non_Member_GST_Fee__c  FROM Course__c];
        List<Course_Registration__c> childCourseRegs = [SELECT Id FROM Course_Registration__c WHERE Parent_Registration__c != null];

        Id earlyBirdRT = Schema.SObjectType.Discount__c.getRecordTypeInfosByDeveloperName().get('Early_Bird').getRecordTypeId();
        Discount__c discount = TestDataFactory.createDiscount();
        discount.Percentage__c = false;
        discount.Amount__c = 100;
        discount.GST_Amount__c = 7;
        discount.RecordTypeId = earlyBirdRT;
        discount.No_of_Days__c = 100;
        insert discount;

        Course_Discount__c cdisc = new Course_Discount__c();
        cdisc.Course__c = course.Id;
        cdisc.Discount__c = discount.Id;
        insert cdisc;

        Test.startTest();
        Course_Registration__c reg = [SELECT Id FROM Course_Registration__c WHERE Parent_Registration__c = null];
        InvoiceUtility.generateInvoiceForRegistration(reg.Id);
        Test.stopTest();

        List<Invoice__c> invoice = [SELECT Id, Amount__c, GST_Amount__c, Discount_Amount__c, Discount_GST_Amount__c FROM Invoice__c];
        System.assertEquals(1, invoice.size());
        List<Invoice_Line_Item__c> invoiceLineItems = [SELECT Id, Amount__c, GST_Amount__c FROM Invoice_Line_Item__c WHERE Invoice__c =: invoice[0].Id];
        System.assertEquals(childCourseRegs.size(), invoiceLineItems.size());
        System.assertEquals(course.Non_Member_Fee__c * childCourseRegs.size(), invoice[0].Amount__c);
        System.assertEquals(course.Non_Member_GST_Fee__c * childCourseRegs.size(), invoice[0].GST_Amount__c);
        List<Invoice_Discount__c> invoiceDiscounts = [SELECT Amount__c, GST_Amount__c, Invoice_Line_Item__c, Id FROM Invoice_Discount__c];
        System.assertEquals(0, invoiceDiscounts.size());
        System.assertEquals(0, invoice[0].Discount_Amount__c);
        System.assertEquals(0, invoice[0].Discount_GST_Amount__c);
    }

    //---- FUNDED TEST CASES ----//

    @IsTest
    static void createFundedInvoiceWEarlyBirdPercentage(){
        Id courseRT = Schema.SObjectType.Course__c.getRecordTypeInfosByDeveloperName().get('Funded_Course').getRecordTypeId();
        prepareDataForFundedCourse();

        Course__c course = [SELECT Full_Fee__c, Full_Fee_GST_Amount__c  FROM Course__c];

        Id earlyBirdRT = Schema.SObjectType.Discount__c.getRecordTypeInfosByDeveloperName().get('Early_Bird').getRecordTypeId();
        Discount__c discount = TestDataFactory.createDiscount();
        discount.Percentage__c = true;
        discount.Amount__c = 10;
        discount.GST_Amount__c = 7;
        discount.RecordTypeId = earlyBirdRT;
        discount.No_of_Days__c = 1;
        insert discount;

        Course_Discount__c cdisc = new Course_Discount__c();
        cdisc.Course__c = course.Id;
        cdisc.Discount__c = discount.Id;
        insert cdisc;
        

        Test.startTest();
        Course_Registration__c reg = [SELECT Id FROM Course_Registration__c];
        InvoiceUtility.generateInvoiceForRegistration(reg.Id);
        Test.stopTest();

        List<Invoice__c> invoice = [SELECT Id, Amount__c, GST_Amount__c, Discount_Amount__c, Discount_GST_Amount__c FROM Invoice__c];
        System.assertEquals(1, invoice.size());
        System.assertEquals(course.Full_Fee__c, invoice[0].Amount__c);
        System.assertEquals(course.Full_Fee_GST_Amount__c, invoice[0].GST_Amount__c);
        System.assertEquals(course.Full_Fee__c * (discount.Amount__c / 100), invoice[0].Discount_Amount__c);
        System.assertEquals((course.Full_Fee__c * (discount.Amount__c / 100)) * (discount.GST_Amount__c / 100), invoice[0].Discount_GST_Amount__c);
    }

    @IsTest
    static void createFundedInvoiceWEarlyBirdAmount(){
        Id courseRT = Schema.SObjectType.Course__c.getRecordTypeInfosByDeveloperName().get('Funded_Course').getRecordTypeId();
        prepareDataForFundedCourse();

        Course__c course = [SELECT Full_Fee__c, Full_Fee_GST_Amount__c  FROM Course__c];

        Id earlyBirdRT = Schema.SObjectType.Discount__c.getRecordTypeInfosByDeveloperName().get('Early_Bird').getRecordTypeId();
        Discount__c discount = TestDataFactory.createDiscount();
        discount.Percentage__c = false;
        discount.Amount__c = 100;
        discount.GST_Amount__c = 7;
        discount.RecordTypeId = earlyBirdRT;
        discount.No_of_Days__c = 1;
        insert discount;

        Course_Discount__c cdisc = new Course_Discount__c();
        cdisc.Course__c = course.Id;
        cdisc.Discount__c = discount.Id;
        insert cdisc;
        

        Test.startTest();
        Course_Registration__c reg = [SELECT Id FROM Course_Registration__c];
        InvoiceUtility.generateInvoiceForRegistration(reg.Id);
        Test.stopTest();

        List<Invoice__c> invoice = [SELECT Id, Amount__c, GST_Amount__c, Discount_Amount__c, Discount_GST_Amount__c FROM Invoice__c];
        System.assertEquals(1, invoice.size());
        System.assertEquals(course.Full_Fee__c, invoice[0].Amount__c);
        System.assertEquals(course.Full_Fee_GST_Amount__c, invoice[0].GST_Amount__c);
        System.assertEquals(discount.Amount__c, invoice[0].Discount_Amount__c);
        System.assertEquals(discount.GST_Amount__c, invoice[0].Discount_GST_Amount__c);
    }

    @IsTest
    static void createFundedInvoiceWExpiredEarlyBirdAmount(){
        Id courseRT = Schema.SObjectType.Course__c.getRecordTypeInfosByDeveloperName().get('Funded_Course').getRecordTypeId();
        prepareDataForFundedCourse();

        Course__c course = [SELECT Full_Fee__c, Full_Fee_GST_Amount__c  FROM Course__c];

        Id earlyBirdRT = Schema.SObjectType.Discount__c.getRecordTypeInfosByDeveloperName().get('Early_Bird').getRecordTypeId();
        Discount__c discount = TestDataFactory.createDiscount();
        discount.Percentage__c = false;
        discount.Amount__c = 100;
        discount.GST_Amount__c = 7;
        discount.RecordTypeId = earlyBirdRT;
        discount.No_of_Days__c = 100;
        insert discount;

        Course_Discount__c cdisc = new Course_Discount__c();
        cdisc.Course__c = course.Id;
        cdisc.Discount__c = discount.Id;
        insert cdisc;
        

        Test.startTest();
        Course_Registration__c reg = [SELECT Id FROM Course_Registration__c];
        InvoiceUtility.generateInvoiceForRegistration(reg.Id);
        Test.stopTest();

        List<Invoice__c> invoice = [SELECT Id, Amount__c, GST_Amount__c, Discount_Amount__c, Discount_GST_Amount__c FROM Invoice__c];
        System.assertEquals(1, invoice.size());
        System.assertEquals(course.Full_Fee__c, invoice[0].Amount__c);
        System.assertEquals(course.Full_Fee_GST_Amount__c, invoice[0].GST_Amount__c);
        System.assertEquals(0, invoice[0].Discount_Amount__c);
        System.assertEquals(0, invoice[0].Discount_GST_Amount__c);
    }

    @IsTest
    static void createFundedInvoiceWOEarlyBird(){
        Id courseRT = Schema.SObjectType.Course__c.getRecordTypeInfosByDeveloperName().get('Funded_Course').getRecordTypeId();
        prepareDataForFundedCourse();

        Course__c course = [SELECT Full_Fee__c, Full_Fee_GST_Amount__c  FROM Course__c];

        Test.startTest();
        Course_Registration__c reg = [SELECT Id FROM Course_Registration__c];
        InvoiceUtility.generateInvoiceForRegistration(reg.Id);
        Test.stopTest();

        List<Invoice__c> invoice = [SELECT Id, Amount__c, GST_Amount__c FROM Invoice__c];
        System.assertEquals(1, invoice.size());
        List<Invoice_Line_Item__c> invoiceLineItems = [SELECT Id, Amount__c, GST_Amount__c FROM Invoice_Line_Item__c WHERE Invoice__c =: invoice[0].Id];
        System.assertEquals(1, invoiceLineItems.size());
        System.assertEquals(course.Full_Fee__c, invoice[0].Amount__c);
        System.assertEquals(course.Full_Fee_GST_Amount__c, invoice[0].GST_Amount__c);
    }


    //With Parent

    @IsTest
    static void createChildFundedInvoiceWEarlyBirdPercentage(){
        Id courseRT = Schema.SObjectType.Course__c.getRecordTypeInfosByDeveloperName().get('Funded_Course').getRecordTypeId();
        prepareDataForFundedCourseWithParent();

        Course__c course = [SELECT Full_Fee__c, Full_Fee_GST_Amount__c  FROM Course__c];
        List<Course_Registration__c> childCourseRegs = [SELECT Id FROM Course_Registration__c WHERE Parent_Registration__c != null];

        Id earlyBirdRT = Schema.SObjectType.Discount__c.getRecordTypeInfosByDeveloperName().get('Early_Bird').getRecordTypeId();
        Discount__c discount = TestDataFactory.createDiscount();
        discount.Percentage__c = true;
        discount.Amount__c = 10;
        discount.GST_Amount__c = 7;
        discount.RecordTypeId = earlyBirdRT;
        discount.No_of_Days__c = 1;
        insert discount;

        Course_Discount__c cdisc = new Course_Discount__c();
        cdisc.Course__c = course.Id;
        cdisc.Discount__c = discount.Id;
        insert cdisc;

        Test.startTest();
        Course_Registration__c reg = [SELECT Id FROM Course_Registration__c WHERE Parent_Registration__c = null];
        InvoiceUtility.generateInvoiceForRegistration(reg.Id);
        Test.stopTest();

        List<Invoice__c> invoice = [SELECT Id, Amount__c, GST_Amount__c, Discount_Amount__c, Discount_GST_Amount__c FROM Invoice__c];
        System.assertEquals(1, invoice.size());
        List<Invoice_Line_Item__c> invoiceLineItems = [SELECT Id, Amount__c, GST_Amount__c FROM Invoice_Line_Item__c WHERE Invoice__c =: invoice[0].Id];
        System.assertEquals(childCourseRegs.size(), invoiceLineItems.size());
        System.assertEquals(course.Full_Fee__c * childCourseRegs.size(), invoice[0].Amount__c);
        System.assertEquals(course.Full_Fee_GST_Amount__c * childCourseRegs.size(), invoice[0].GST_Amount__c);
        List<Invoice_Discount__c> invoiceDiscounts = [SELECT Amount__c, GST_Amount__c, Invoice_Line_Item__c, Id FROM Invoice_Discount__c];
        System.assertEquals(2, invoiceDiscounts.size());
        System.assertEquals(course.Full_Fee__c * (discount.Amount__c / 100) * childCourseRegs.size(), invoice[0].Discount_Amount__c);
        System.assertEquals((course.Full_Fee__c * (discount.Amount__c / 100)) * (discount.GST_Amount__c / 100) * childCourseRegs.size(), invoice[0].Discount_GST_Amount__c);
    }

    @IsTest
    static void createChildFundedInvoiceWEarlyBirdAmount(){
        Id courseRT = Schema.SObjectType.Course__c.getRecordTypeInfosByDeveloperName().get('Funded_Course').getRecordTypeId();
        prepareDataForFundedCourseWithParent();

        Course__c course = [SELECT Full_Fee__c, Full_Fee_GST_Amount__c  FROM Course__c];
        List<Course_Registration__c> childCourseRegs = [SELECT Id FROM Course_Registration__c WHERE Parent_Registration__c != null];

        Id earlyBirdRT = Schema.SObjectType.Discount__c.getRecordTypeInfosByDeveloperName().get('Early_Bird').getRecordTypeId();
        Discount__c discount = TestDataFactory.createDiscount();
        discount.Percentage__c = false;
        discount.Amount__c = 100;
        discount.GST_Amount__c = 7;
        discount.RecordTypeId = earlyBirdRT;
        discount.No_of_Days__c = 1;
        insert discount;

        Course_Discount__c cdisc = new Course_Discount__c();
        cdisc.Course__c = course.Id;
        cdisc.Discount__c = discount.Id;
        insert cdisc;

        Test.startTest();
        Course_Registration__c reg = [SELECT Id FROM Course_Registration__c WHERE Parent_Registration__c = null];
        InvoiceUtility.generateInvoiceForRegistration(reg.Id);
        Test.stopTest();

        List<Invoice__c> invoice = [SELECT Id, Amount__c, GST_Amount__c, Discount_Amount__c, Discount_GST_Amount__c FROM Invoice__c];
        System.assertEquals(1, invoice.size());
        List<Invoice_Line_Item__c> invoiceLineItems = [SELECT Id, Amount__c, GST_Amount__c FROM Invoice_Line_Item__c WHERE Invoice__c =: invoice[0].Id];
        System.assertEquals(childCourseRegs.size(), invoiceLineItems.size());
        System.assertEquals(course.Full_Fee__c * childCourseRegs.size(), invoice[0].Amount__c);
        System.assertEquals(course.Full_Fee_GST_Amount__c * childCourseRegs.size(), invoice[0].GST_Amount__c);
        List<Invoice_Discount__c> invoiceDiscounts = [SELECT Amount__c, GST_Amount__c, Invoice_Line_Item__c, Id FROM Invoice_Discount__c];
        System.assertEquals(2, invoiceDiscounts.size());
        System.assertEquals(discount.Amount__c * childCourseRegs.size(), invoice[0].Discount_Amount__c);
        System.assertEquals(discount.GST_Amount__c * childCourseRegs.size(), invoice[0].Discount_GST_Amount__c);
    }

    @IsTest
    static void createChildFundedInvoiceWExpiredEarlyBirdAmount(){
        Id courseRT = Schema.SObjectType.Course__c.getRecordTypeInfosByDeveloperName().get('Funded_Course').getRecordTypeId();
        prepareDataForFundedCourseWithParent();

        Course__c course = [SELECT Full_Fee__c, Full_Fee_GST_Amount__c  FROM Course__c];
        List<Course_Registration__c> childCourseRegs = [SELECT Id FROM Course_Registration__c WHERE Parent_Registration__c != null];

        Id earlyBirdRT = Schema.SObjectType.Discount__c.getRecordTypeInfosByDeveloperName().get('Early_Bird').getRecordTypeId();
        Discount__c discount = TestDataFactory.createDiscount();
        discount.Percentage__c = false;
        discount.Amount__c = 100;
        discount.GST_Amount__c = 7;
        discount.RecordTypeId = earlyBirdRT;
        discount.No_of_Days__c = 100;
        insert discount;

        Course_Discount__c cdisc = new Course_Discount__c();
        cdisc.Course__c = course.Id;
        cdisc.Discount__c = discount.Id;
        insert cdisc;

        Test.startTest();
        Course_Registration__c reg = [SELECT Id FROM Course_Registration__c WHERE Parent_Registration__c = null];
        InvoiceUtility.generateInvoiceForRegistration(reg.Id);
        Test.stopTest();

        List<Invoice__c> invoice = [SELECT Id, Amount__c, GST_Amount__c, Discount_Amount__c, Discount_GST_Amount__c FROM Invoice__c];
        System.assertEquals(1, invoice.size());
        List<Invoice_Line_Item__c> invoiceLineItems = [SELECT Id, Amount__c, GST_Amount__c FROM Invoice_Line_Item__c WHERE Invoice__c =: invoice[0].Id];
        System.assertEquals(childCourseRegs.size(), invoiceLineItems.size());
        System.assertEquals(course.Full_Fee__c * childCourseRegs.size(), invoice[0].Amount__c);
        System.assertEquals(course.Full_Fee_GST_Amount__c * childCourseRegs.size(), invoice[0].GST_Amount__c);
        List<Invoice_Discount__c> invoiceDiscounts = [SELECT Amount__c, GST_Amount__c, Invoice_Line_Item__c, Id FROM Invoice_Discount__c];
        System.assertEquals(0, invoiceDiscounts.size());
        System.assertEquals(0, invoice[0].Discount_Amount__c);
        System.assertEquals(0, invoice[0].Discount_GST_Amount__c);
    }

    @IsTest
    static void createChildFundedInvoiceWOEarlyBird(){
        Id courseRT = Schema.SObjectType.Course__c.getRecordTypeInfosByDeveloperName().get('Funded_Course').getRecordTypeId();
        prepareDataForFundedCourseWithParent();

        Course__c course = [SELECT Full_Fee__c, Full_Fee_GST_Amount__c  FROM Course__c];
        List<Course_Registration__c> childCourseRegs = [SELECT Id FROM Course_Registration__c WHERE Parent_Registration__c != null];

        Test.startTest();
        Course_Registration__c reg = [SELECT Id FROM Course_Registration__c WHERE Parent_Registration__c = null];
        InvoiceUtility.generateInvoiceForRegistration(reg.Id);
        Test.stopTest();

        List<Invoice__c> invoice = [SELECT Id, Amount__c, GST_Amount__c, Discount_Amount__c, Discount_GST_Amount__c FROM Invoice__c];
        System.assertEquals(1, invoice.size());
        List<Invoice_Line_Item__c> invoiceLineItems = [SELECT Id, Amount__c, GST_Amount__c FROM Invoice_Line_Item__c WHERE Invoice__c =: invoice[0].Id];
        System.assertEquals(childCourseRegs.size(), invoiceLineItems.size());
        System.assertEquals(course.Full_Fee__c * childCourseRegs.size(), invoice[0].Amount__c);
        System.assertEquals(course.Full_Fee_GST_Amount__c * childCourseRegs.size(), invoice[0].GST_Amount__c);
        List<Invoice_Discount__c> invoiceDiscounts = [SELECT Amount__c, GST_Amount__c, Invoice_Line_Item__c, Id FROM Invoice_Discount__c];
        System.assertEquals(0, invoiceDiscounts.size());
        System.assertEquals(0, invoice[0].Discount_Amount__c);
        System.assertEquals(0, invoice[0].Discount_GST_Amount__c);
    }

    @IsTest
    static void createRMITInvoiceWRMITPercentage() {        
        Id courseRT = Schema.SObjectType.Course__c.getRecordTypeInfosByDeveloperName().get('Course').getRecordTypeId();
        prepareDataForRMITCourse();

        Course__c course = [SELECT Non_Member_Fee__c, Non_Member_GST_Fee__c  FROM Course__c];

        Id promotionRT = Schema.SObjectType.Discount__c.getRecordTypeInfosByDeveloperName().get('Promotion').getRecordTypeId();
        Discount__c discount = TestDataFactory.createDiscount();
        discount.Percentage__c = true;
        discount.Amount__c = 15;
        discount.GST_Amount__c = 7;
        discount.RecordTypeId = promotionRT;
        discount.No_of_Days__c = 0;
        discount.Name = 'RMIT Alumni/Student Discount';
        discount.Description__c = 'RMIT Alumni/Student Discount';
        insert discount;

        Course_Discount__c cdisc = new Course_Discount__c();
        cdisc.Course__c = course.Id;
        cdisc.Discount__c = discount.Id;
        insert cdisc;
        

        Test.startTest();
        Course_Registration__c reg = [SELECT Id FROM Course_Registration__c];
        InvoiceUtility.generateInvoiceForRegistration(reg.Id);
        Test.stopTest();

        List<Invoice__c> invoice = [SELECT Id, Amount__c, GST_Amount__c, Discount_Amount__c, Discount_GST_Amount__c FROM Invoice__c];
        System.assertEquals(1, invoice.size());
        System.assertEquals(course.Non_Member_Fee__c, invoice[0].Amount__c);
        System.assertEquals(course.Non_Member_GST_Fee__c, invoice[0].GST_Amount__c);
        System.assertEquals(course.Non_Member_Fee__c * (discount.Amount__c / 100), invoice[0].Discount_Amount__c);
        System.assertEquals((course.Non_Member_Fee__c * (discount.Amount__c / 100)) * (discount.GST_Amount__c / 100), invoice[0].Discount_GST_Amount__c);
    }
}