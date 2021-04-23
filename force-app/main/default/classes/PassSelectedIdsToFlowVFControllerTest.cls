@isTest
public class PassSelectedIdsToFlowVFControllerTest {
	@isTest static void PassSelectedIds() {
        List<Course_Registration__c> accList1 = new List<Course_Registration__c>();
        List<Course_Registration__c> accList  =[Select 
                                                Course_Run_Id__c,
                                                Course_Run_Owner_Email__c,
                                                Registration_Status__c,
                                                Payment_Status__c,
                                                Marketing_Consent_Clause__c,
                                                PDPA_Consent_Clause__c,
                                                Contact__c,
                                                IsMember__c,
                                                RMIT_Alumni__c,
                                                Salutation__c,
                                                First_Name__c,
                                                Email_Address__c,
                                                Last_Name__c,
                                                Job_Title__c,
                                                Preferred_Certificate_Name__c,
                                                Mobile_No__c,
                                                Office_No__c,
                                                Nationality__c,
                                                Race__c,
                                                Residency_Status__c,
                                                Stop_Survey__c,
                                                Send_Survey__c,
                                                Country__c,
                                                Attention__c,
                                                Billing_Address_Line_1__c,
                                                Billing_Country__c,
                                                Billing_Postal_Code__c,
                                                Address_Type__c,
                                                Preferred_Contact_Method__c,
                                                Provider_Status__c,
                                                RecordTypeId
                                               from Course_Registration__c limit 1];
        
        Course_Registration__c cr1 = accList[0].clone();
        List<string> crList = new List<string>();
        crList.add(cr1.Id);
        acclist1.add(cr1);
        insert acclist1;
        
        Test.startTest();
        //Test.setCurrentPage(Page.PassSelectedIdsToFlowVFController);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(acclist1);
        stdSetController.setSelected(acclist1);
        PassSelectedIdsToFlowVFController ext = new PassSelectedIdsToFlowVFController(stdSetController);
        Test.stopTest();
        
        
         
    }
}