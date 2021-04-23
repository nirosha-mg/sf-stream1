/**
 * @description       : 
 * @author            : Mark Alvin Tayag (mtayag@salesforce.com)
 * @group             : 
 * @last modified on  : 11-13-2020
 * @last modified by  : Mark Alvin Tayag (mtayag@salesforce.com)
 * Modifications Log 
 * Ver   Date         Author                                     Modification
 * 1.0   11-13-2020   Mark Alvin Tayag (mtayag@salesforce.com)   Initial Version
**/
@IsTest
public without sharing class InvoiceAdvanceTriggerHandlerTest {
    @TestSetup
    static void testSetup(){
        //Prepare Data
        Advance__c advance = new Advance__c();
        advance.Amount__c = 100;
        advance.GST_Amount__c = 7;
        advance.GST_Code__c = '12';
        advance.Advance_No__c = '888888888';
        advance.Status__c = 'New';

        Advance__c advance2 = new Advance__c();
        advance2.Amount__c = 200;
        advance2.GST_Amount__c = 14;
        advance2.GST_Code__c = '12';
        advance2.Advance_No__c = '99999999';
        advance2.Status__c = 'New';

        List<Advance__c> advList = new List<Advance__c> { advance, advance2 };
        insert advList;
    }

    @IsTest
    static void utilizeAdvance(){
        

        Invoice__c invoice = TestDataFactory.createInvoice();
        insert invoice;

        Invoice_Line_Item__c lineItem = new Invoice_Line_Item__c();
        lineItem.Invoice__c = invoice.Id;
        lineItem.Amount__c = 500;
        lineItem.GST_Amount__c = 35;
        lineItem.Invoice__c = invoice.Id;
        insert lineItem;

        Advance__c advance = [SELECT Id, Amount__c, GST_Amount__c FROM Advance__c WHERE Advance_No__c = '888888888'];

        Test.startTest();
        Invoice_Advance__c invAdv = new Invoice_Advance__c();
        invAdv.Invoice_Line_Item__c = lineItem.Id;
        invAdv.Advance__c = advance.Id;
        invAdv.Description__c = 'Test Advance';
        insert invAdv;
        Test.stopTest();

        Invoice_Line_Item__c lineItemAfter = [SELECT Nett_Amount__c, 
                                                    Nett_GST_Amount__c, 
                                                    Utilized_Advance_Amount__c, 
                                                    Utilized_Advance_GST_Amount__c
                                              FROM Invoice_Line_Item__c
                                              WHERE Id =: lineItem.Id];

        Advance__c advanceAfter = [SELECT Status__c FROM Advance__c WHERE Id=:advance.Id];
        System.assertEquals('In Use', advanceAfter.Status__c);

        System.assertEquals(lineItem.Amount__c - advance.Amount__c, lineItemAfter.Nett_Amount__c);
        System.assertEquals(lineItem.GST_Amount__c - advance.GST_Amount__c, lineItemAfter.Nett_GST_Amount__c);
    }
}