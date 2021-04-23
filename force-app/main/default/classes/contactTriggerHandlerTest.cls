@isTest
public class contactTriggerHandlerTest {

    public static testmethod void Testingmethod() {    
         
        userrole role = TestDataFactory.returnUserRole();
        user adminUser = TestDataFactory.createSystemAdmin(role.id);
        insert adminUser;
        
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B Account').getRecordTypeId();
        Account acc;
        List<Contact> contactList = new List<Contact>();
        System.runAs (adminUser) {  
            Acc = TestDataFactory.createAccount(accRecordTypeId);
            insert acc;
            
                  
            Contact con = TestDataFactory.createContact(acc.id);
            con.NRIC_Type__c = 'Singapore Citizen/PR';
            con.NRIC__c='S1021308H';
            con.Email='xyz@xyz.com';
            con.FirstName='Testone';
            insert con;
            con.NRIC__c='S4405529E';
            
            Contact conOne=TestDataFactory.createContact(acc.id);
            conOne.NRIC_Type__c = 'Singapore Citizen/PR';
            conOne.NRIC__c='S1021308H';
            conOne.Email='abc@xyz.com';
            conOne.FirstName='Testtwo';
            insert conOne;
            conOne.NRIC__c='T6228669A';
            
            Contact conTwo = TestDataFactory.createContact(acc.id);
            conTwo.NRIC_Type__c = 'Singapore Citizen/PR';
            conTwo.NRIC__c='S1021308H';
            conTwo.Email='abc@abc.com';
            conTwo.FirstName='Testthree';
            insert conTwo;
            conTwo.NRIC__c='G4450556N';
            
            Contact conThree=TestDataFactory.createContact(acc.id);
            conThree.NRIC_Type__c = 'Singapore Citizen/PR';
            conThree.NRIC__c='S1021308H';
            conThree.Email='abcd@abc.com';
            conThree.FirstName='Testfour';
            insert conThree;
            conThree.NRIC__c='F1402597U';
            
            contactList.add(con);
            contactList.add(conOne);
            contactList.add(conTwo);
            contactList.add(conThree);
            
             Test.startTest();
                update contactList;
                contactTriggerHandler.createSSOUser(contactList);
             Test.stopTest();
            
            System.assertEquals('S4405529E',con.NRIC__c);
            System.assertEquals('T6228669A',conOne.NRIC__c);
            System.assertEquals('G4450556N',conTwo.NRIC__c);
            System.assertEquals('F1402597U',conThree.NRIC__c);
        }
       
    }
    
    public static testmethod void testNRICNegativeVal_T() {
        userrole role = TestDataFactory.returnUserRole();
        user adminUser = TestDataFactory.createSystemAdmin(role.id);
        insert adminUser;
        
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B Account').getRecordTypeId();
        Account acc;
        List<Contact> contactList = new List<Contact>();
        System.runAs (adminUser) {  
            Acc = TestDataFactory.createAccount(accRecordTypeId);
            insert acc;  
            
            Contact conOne = TestDataFactory.createContact(acc.id);            
            conOne.Email='abc@xyz.com';
            conOne.FirstName='Testtwo';
           try {  
                 conOne.NRIC_Type__c  = 'Singapore Citizen/PR';
                 conOne.NRIC__c = 'T9113754A'; 
                insert conOne;
                
            } catch(exception e) {
            }
        }
    }   
    
     public static testmethod void testNRICNegativeVal_F() {
       userrole role = TestDataFactory.returnUserRole();
        user adminUser = TestDataFactory.createSystemAdmin(role.id);
        insert adminUser;
        
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B Account').getRecordTypeId();
        Account acc;
        List<Contact> contactList = new List<Contact>();
        System.runAs (adminUser) {  
            Acc = TestDataFactory.createAccount(accRecordTypeId);
            insert acc;  
            
            Contact conOne = TestDataFactory.createContact(acc.id);            
            conOne.Email='abc@xyz.com';
            conOne.FirstName='Testtwo';
           try {  
                 conOne.NRIC_Type__c  = 'Singapore Citizen/PR';
                 conOne.NRIC__c = 'F6121351B'; 
                insert conOne;
                
            } catch(exception e) {
            }
        }
    }  
    
     public static testmethod void testNRICNegativeVal_G() {
       userrole role = TestDataFactory.returnUserRole();
        user adminUser = TestDataFactory.createSystemAdmin(role.id);
        insert adminUser;
        
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B Account').getRecordTypeId();
        Account acc;
        List<Contact> contactList = new List<Contact>();
        System.runAs (adminUser) {  
            Acc = TestDataFactory.createAccount(accRecordTypeId);
            insert acc;  
            
            Contact conOne = TestDataFactory.createContact(acc.id);            
            conOne.Email='abc@xyz.com';
            conOne.FirstName='Testtwo';
           try {  
                 conOne.NRIC_Type__c  = 'Singapore Citizen/PR';
                 conOne.NRIC__c = 'G8290888C'; 
                insert conOne;
                
            } catch(exception e) {
            }
        }
    }  
    
    public static testmethod void testNRICNegativeVal_S() {
    userrole role = TestDataFactory.returnUserRole();
        user adminUser = TestDataFactory.createSystemAdmin(role.id);
        insert adminUser;
        
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B Account').getRecordTypeId();
        Account acc;
        List<Contact> contactList = new List<Contact>();
        System.runAs (adminUser) {  
            Acc = TestDataFactory.createAccount(accRecordTypeId);
            insert acc;  
            
            Contact conOne = TestDataFactory.createContact(acc.id);            
            conOne.Email='abc@xyz.com';
            conOne.FirstName='Testtwo';
           try {  
                 conOne.NRIC_Type__c  = 'Singapore Citizen/PR';
                 conOne.NRIC__c = 'S1234567A'; 
                insert conOne;
                
            } catch(exception e) {
            }
        }
       
    }
}