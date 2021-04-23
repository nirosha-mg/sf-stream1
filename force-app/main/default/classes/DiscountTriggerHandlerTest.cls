@IsTest
public without sharing class DiscountTriggerHandlerTest {
    @IsTest
    static void calculateGST(){
        Discount__c disc = TestDataFactory.createDiscount();
        disc.Amount__c = 100;
        disc.GST_Amount__c = 0;
        disc.GST_Code__c = '12';
        disc.Percentage__c = false;
        
        Test.startTest();
        insert disc;
        Test.stopTest();
        
        Discount__c discAfter = [SELECT GST_Amount__c FROM Discount__c WHERE Id=: disc.Id];
        System.assertEquals(7, discAfter.GST_Amount__c);
    }

    @IsTest
    static void calculateGSTPercentage(){
        Discount__c disc = TestDataFactory.createDiscount();
        disc.Amount__c = 100;
        disc.GST_Amount__c = 0;
        disc.Percentage__c = true;
        disc.GST_Code__c = '12';
        Test.startTest();
        insert disc;
        Test.stopTest();
        
        Discount__c discAfter = [SELECT GST_Amount__c FROM Discount__c WHERE Id=: disc.Id];
        System.assertEquals(0, discAfter.GST_Amount__c);
    }
}