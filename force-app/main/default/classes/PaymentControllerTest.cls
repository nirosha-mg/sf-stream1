/*************************************************************************************************************
 * @name            PaymentControllerTest
 * @author          BLR\rohit.pal <rohit.pal@crmit.com>
 * @created         09 / 10 / 2020
 * @description     Test Class for PaymentController
 * 
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 *              No.     Date            Author                  Description
 *              ----    ------------    --------------------    ----------------------------------------------
 * @version     1.0     2020-10-09      BLR\rohit.pal           Changes desription
 *              1.1     2020-10-31      Alvin Tayag             Removed runAs due to it being redundant by running as the same user, added Asserts and renamed method names
 *              1.2     2020-02-01      Poon Koon               Added in new test method for getting course info and payment options
**************************************************************************************************************/
@isTest(seeAllData=false isParallel = false)
private class PaymentControllerTest {
    /**
    * @description 
    * @author Rohit Pal | 10-09-2020 
    **/
    @testSetup
    static void setupTestData() {
        User thisUser = [SELECT FirstName, LastName, Email FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            Invoice__c objInvoice= TestDataFactory.createInvoice();
            objInvoice.Status__c = 'Draft';
            insert objInvoice;
            Payment__c objPayment = TestDataFactory.createPayment();
            objPayment.Transaction_Date__c = system.today();
            objPayment.AuthResp__c = 'OK';
            objPayment.Receipt_Created__c = false;
            insert objPayment;
        }
    }
    /**
    * @description : 
    * @author Rohit Pal | 10-09-2020 
    * @return void 
    **/
    static testMethod void getInvoiceInformation(){
        Test.startTest();
        Invoice__c objInvoice = [SELECT Id,
                    Name,
                    Amount__c,
                    GST_Amount__c,
                    Course_Registration__c 
            FROM Invoice__c WHERE Status__c = 'Draft' limit 1];
        PaymentController.getPaymentGateway();
        PaymentController.getInvoiceRecordInformation(objInvoice.Id);
        Test.stopTest();
    } 

    //
    /**
    * @description : 
    * @author Rohit Pal | 10-09-2020 
    * @return void 
    **/
    static testMethod void createReceiptOnSuccessfulPayment(){
        Test.startTest();
        Payment__c objPayment = [SELECT Id,
                                        Name,
                                        Invoice__c,
                                        Transaction_Status__c
                                FROM Payment__c WHERE Transaction_Date__c =: system.today() limit 1];
        List<String> result = PaymentController.handlePayment(objPayment.Id);
        PaymentController.getPaymentGateway();
        Test.stopTest();

        System.assertEquals('Success', result[0]);        

        List<Receipt__c> receipts = [SELECT Id FROM Receipt__c WHERE Payment__c =: objPayment.Id];
        System.assertEquals(1, receipts.size());
    } 
     /**
    * @description : 
    * @author Rohit Pal | 10-09-2020 
    * @return void 
    **/
    static testMethod void doNotReceiptOnSuccessfulPaymentWithReceipt(){
        Test.startTest();
        Payment__c objPayment = [SELECT Id,
                                        Name,
                                        Invoice__c,
                                        Transaction_Status__c,
                                        Receipt_Created__c,
                                        AuthResp__c
                                FROM Payment__c WHERE Transaction_Date__c =: system.today() limit 1];
        objPayment.Receipt_Created__c = True;
        update objPayment;
        List<String> result = PaymentController.handlePayment(objPayment.Id);
        PaymentController.getPaymentGateway();
        Test.stopTest();

        System.assertEquals('Success', result[0]);

        List<Receipt__c> receipts = [SELECT Id FROM Receipt__c WHERE Payment__c =: objPayment.Id];
        System.assertEquals(0, receipts.size());
    } 
    /**
    * @description : 
    * @author Rohit Pal | 10-09-2020 
    * @return void 
    **/
    static testMethod void doNotCreateReceiptOnUnsuccessfulPayment() {
        Test.startTest();
        Payment__c objPayment = [SELECT Id,
                                        Name,
                                        Invoice__c,
                                        Transaction_Status__c,
                                        Receipt_Created__c,
                                        AuthResp__c
                                FROM Payment__c WHERE Transaction_Date__c =: system.today() limit 1];
        objPayment.AuthResp__c = 'Pending';
        update objPayment;
        List<String> result = PaymentController.handlePayment(objPayment.Id);
        PaymentController.getPaymentGateway();
        Test.stopTest();

        System.assertEquals('Failure', result[0]);

        List<Receipt__c> receipts = [SELECT Id FROM Receipt__c WHERE Payment__c =: objPayment.Id];
        System.assertEquals(0, receipts.size());
    } 
    /**
    * @description : 
    * @author Rohit Pal | 10-09-2020 
    * @return void 
    **/
    static testMethod void doNotCreateReceiptOnUnsuccessfulPayment2() {
        Test.startTest();
        Payment__c objPayment = [SELECT Id,
                                        Name,
                                        Invoice__c,
                                        Transaction_Status__c,
                                        Receipt_Created__c,
                                        AuthResp__c
                                FROM Payment__c WHERE Transaction_Date__c =: system.today() limit 1];
        objPayment.AuthResp__c = '';
        update objPayment;
        List<String> result = PaymentController.handlePayment('');
        PaymentController.getPaymentGateway();
        Test.stopTest();

        System.assertEquals('Invalid Record', result[0]);
        
        List<Receipt__c> receipts = [SELECT Id FROM Receipt__c WHERE Payment__c =: objPayment.Id];
        System.assertEquals(0, receipts.size());
    }
    
        /**
    * @description : 
    * @author Poon Koon | 01-02-2021 
    * @return void 
    **/
    static testMethod void getCourseRecordInformation(){
        Test.startTest();
        Payment__c objPayment = [SELECT Id,
                                        Name,
                                        Invoice__c,
                                        Course_Registration__c
                                FROM Payment__c WHERE Course_Registration__r.Contact__r.Account.LastName = 'Test Account' limit 1];
        Invoice__c objInvoice = [SELECT Id,
                                        Name,
                                        Course_Registration__c 
                                FROM Invoice__c WHERE Id =: objPayment.Invoice__c limit 1];
        objInvoice.Course_Registration__c = objPayment.Course_Registration__c;
        update objInvoice;
        PaymentController.getPaymentGateway();
        PaymentController.getCourseRecordInformation(objInvoice.Id);
        Test.stopTest();
    } 
}