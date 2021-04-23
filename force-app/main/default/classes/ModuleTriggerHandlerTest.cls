@IsTest
public without sharing class ModuleTriggerHandlerTest {
    @IsTest
    static void calculateGST(){
        
        Module__c module = TestDataFactory.createModule();

        module.Full_Fee_GST_Amount__c = 0;
        module.SME_Grant_GST_Amount__c = 0;
        module.Non_SME_Grant_GST_Amount__c = 0;
        module.Baseline_Grant_GST_Amount__c = 0;
        module.Workfare_GST_Amount__c = 0;
        module.Mid_Career_GST_Amount__c = 0;
        Test.startTest();
        insert module;
        Test.stopTest();
        
        Module__c moduleAfter = [SELECT Full_Fee_GST_Amount__c,
                                SME_Grant_GST_Amount__c,
                                Non_SME_Grant_GST_Amount__c,
                                Baseline_Grant_GST_Amount__c,
                                Workfare_GST_Amount__c,
                                Mid_Career_GST_Amount__c
                                FROM Module__c
                                WHERE Id =: module.Id];

        Decimal fullFeeGSTAmount = 70;
        Decimal smeGrantGSTAmount = 35;
        Decimal nonSMEGrantGSTAmount = 49;
        Decimal baselineGrantGSTAmount = 56;
        Decimal workfareGSTAmount = 56;
        Decimal midCareerGSTAmount = 49;

        System.assertEquals(fullFeeGSTAmount, moduleAfter.Full_Fee_GST_Amount__c);
        /*System.assertEquals(smeGrantGSTAmount, moduleAfter.SME_Grant_GST_Amount__c);
        System.assertEquals(nonSMEGrantGSTAmount, moduleAfter.Non_SME_Grant_GST_Amount__c);
        System.assertEquals(baselineGrantGSTAmount, moduleAfter.Baseline_Grant_GST_Amount__c);
        System.assertEquals(workfareGSTAmount, moduleAfter.Workfare_GST_Amount__c);
        System.assertEquals(midCareerGSTAmount, moduleAfter.Mid_Career_GST_Amount__c);*/
    }

    @IsTest
    static void updateCourseModules(){
        Course__c course = TestDataFactory.createCourse(null);
        insert course;
        Module__c module = TestDataFactory.createModule();
        insert module;
        Course_Module__c cm = new Course_Module__c();
        cm.Module__c = module.Id;
        cm.Course__c = course.Id;
        insert cm;
        
        Test.startTest();
        Module__c moduleUpdate = new Module__c();
        moduleUpdate.Id = module.Id;
        moduleUpdate.Full_Fee__c = 100;
        update moduleUpdate;
        Test.stopTest();

        Course_Module__c cmAfter = [SELECT Full_Fee__c, Full_Fee_GST_Amount__c FROM Course_Module__c];
        System.assertEquals(7, cmAfter.Full_Fee_GST_Amount__c);
        System.assertEquals(100, cmAfter.Full_Fee__c);
        
    }
}