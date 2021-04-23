/**
 * @description       : 
 * @author            : Mark Alvin Tayag (mtayag@salesforce.com)
 * @group             : 
 * @last modified on  : 10-31-2020
 * @last modified by  : Mark Alvin Tayag (mtayag@salesforce.com)
 * Modifications Log 
 * Ver   Date         Author                                     Modification
 * 1.0   10-31-2020   Mark Alvin Tayag (mtayag@salesforce.com)   Initial Version
 * 1.1   2021-03-15   Poon Koon                                  Updated Assertion Values for Nett GST calculation
**/
@istest
public class CourseTriggerHandlerTest {
    @TestSetup
    static void makeData() {
        category__c cat = TestDataFactory.createCategory();
        cat.Category__c = 'Agility';
        insert cat;
        
        category__c cat2 = TestDataFactory.createCategory();
        cat2.Category__c = 'Innovation';
        insert cat2;        
        
        Id personAccountRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        account acc = TestDataFactory.createAccount(personAccountRT);
        acc.LastName = 'test';
        insert acc;
    }

    public static testmethod void singleInsertCategory() {
        Account acc = [SELECT Id FROM Account];
        Test.startTest();
        course__c course = TestDataFactory.createCourse(acc.id);
        course.category__c = 'Agility';
        insert course;
        Test.stopTest();
        
        List<Course_Category__c> cc = [SELECT id,
                                              Category_Picklist__c 
                                        FROM Course_Category__c 
                                        WHERE Course__c =: course.id];
        System.assertEquals(1, cc.size());
        System.assertEquals(cc[0].Category_Picklist__c, 'Agility');
    }

    public static testmethod void multipleInsertCategories() {
        Account acc = [SELECT Id FROM Account];

        Test.startTest();
        course__c course = TestDataFactory.createCourse(acc.id);
        course.category__c = 'Agility;Innovation';
        insert course;
        Test.stopTest();
        
        List<Course_Category__c> cc = [SELECT id,
                                              Category_Picklist__c 
                                        FROM Course_Category__c 
                                        WHERE Course__c =: course.id];
        System.assertEquals(2, cc.size());
        for (Course_Category__c ccat : cc) {
            System.assert(ccat.Category_Picklist__c == 'Agility' || 
                            ccat.Category_Picklist__c == 'Innovation');
        }
    }

    public static testmethod void updateCategory() {
        Account acc = [SELECT Id FROM Account];

        course__c course = TestDataFactory.createCourse(acc.id);
        course.category__c = 'Agility;Innovation';
        insert course;

        Test.startTest();
        course.category__c = 'Agility';
        update course;
        Test.stopTest();
        
        List<Course_Category__c> cc = [SELECT id,
                                              Category_Picklist__c 
                                        FROM Course_Category__c 
                                        WHERE Course__c =: course.id];

        System.assertEquals(1, cc.size());
        System.assertEquals(cc[0].Category_Picklist__c, 'Agility');
    }

    public static testmethod void multipleUpdateCategories() {
        Account acc = [SELECT Id FROM Account];

        course__c course = TestDataFactory.createCourse(acc.id);
        course.category__c = 'Agility';
        insert course;

        Test.startTest();
        course.category__c = 'Agility;Innovation';
        update course;
        Test.stopTest();
        
        List<Course_Category__c> cc = [SELECT id,
                                              Category_Picklist__c 
                                                 FROM Course_Category__c 
                                        WHERE Course__c =: course.id];

        System.assertEquals(2, cc.size());
        for (Course_Category__c ccat : cc) {
            System.assert(ccat.Category_Picklist__c == 'Agility' || 
                            ccat.Category_Picklist__c == 'Innovation');
        }
    }

    public static testmethod void testGSTCalculationOnInsert(){
        Account acc = [SELECT Id FROM Account];
        Course__c courseFull = TestDataFactory.createCourse(acc.id);
        courseFull.GST_Code__c = '12';
        courseFull.GST_Mode__c = 'Full';
        courseFull.Non_Member_Fee__c = 1000;
        courseFull.Non_Member_GST_Fee__c = 0;
        courseFull.Member_Fee__c = 2000;
        courseFull.Member_GST_Fee__c = 0;
        courseFull.RMIT_Alumni_Fee__c = 3000;
        courseFull.RMIT_Alumni_GST_Fee__c = 0;

        Course__c courseNett = TestDataFactory.createCourse(acc.id);
        courseNett.Course_Code__c = 'Nett GST';
        courseNett.GST_Code__c = '12';
        courseNett.GST_Mode__c = 'Nett';
        courseNett.Non_Member_Fee__c = 1000;
        courseNett.Non_Member_GST_Fee__c = 0;
        courseNett.Member_Fee__c = 2000;
        courseNett.Member_GST_Fee__c = 0;
        courseNett.RMIT_Alumni_Fee__c = 3000;
        courseNett.RMIT_Alumni_GST_Fee__c = 0;

        Test.startTest();
        insert courseFull;
        insert courseNett;
        Test.stopTest();
        
        Course__c courseFullAfter = [SELECT Non_Member_Fee__c, 
                                            Non_Member_GST_Fee__c, 
                                            Member_Fee__c, 
                                            Member_GST_Fee__c,
                                            RMIT_Alumni_Fee__c,
                                            RMIT_Alumni_GST_Fee__c
                                    FROM Course__c
                                    WHERE Id=:courseFull.Id];
        System.assertEquals(1000, courseFullAfter.Non_Member_Fee__c);
        System.assertEquals(2000, courseFullAfter.Member_Fee__c);
        System.assertEquals(3000, courseFullAfter.RMIT_Alumni_Fee__c);
        System.assertEquals(70, courseFullAfter.Non_Member_GST_Fee__c);
        System.assertEquals(140, courseFullAfter.Member_GST_Fee__c);
        System.assertEquals(210, courseFullAfter.RMIT_Alumni_GST_Fee__c);
        
        Course__c courseNettAfter = [SELECT Non_Member_Fee__c, 
                                            Non_Member_GST_Fee__c, 
                                            Member_Fee__c, 
                                            Member_GST_Fee__c,
                                            RMIT_Alumni_Fee__c,
                                            RMIT_Alumni_GST_Fee__c
                                    FROM Course__c
                                    WHERE Id=:courseNett.Id];
        System.assertEquals(1000, courseFullAfter.Non_Member_Fee__c);
        System.assertEquals(2000, courseFullAfter.Member_Fee__c);
        System.assertEquals(3000, courseFullAfter.RMIT_Alumni_Fee__c);
        //2021-03-15 Poon Koon: Updated Assertion Values for Nett GST calculation
        System.assertEquals(65.42, courseNettAfter.Non_Member_GST_Fee__c);
        System.assertEquals(130.84, courseNettAfter.Member_GST_Fee__c);
        System.assertEquals(196.26, courseNettAfter.RMIT_Alumni_GST_Fee__c);
    }

    public static testmethod void testGSTCalculationOnUpdate(){
        Account acc = [SELECT Id FROM Account];
        Course__c courseFull = TestDataFactory.createCourse(acc.id);
        courseFull.GST_Code__c = '12';
        courseFull.GST_Mode__c = 'Full';
        courseFull.Non_Member_Fee__c = 100;
        courseFull.Non_Member_GST_Fee__c = 0;
        courseFull.Member_Fee__c = 200;
        courseFull.Member_GST_Fee__c = 0;
        courseFull.RMIT_Alumni_Fee__c = 300;
        courseFull.RMIT_Alumni_GST_Fee__c = 0;
        Course__c courseNett = TestDataFactory.createCourse(acc.id);
        courseNett.Course_Code__c = 'Nett GST';
        courseNett.GST_Code__c = '12';
        courseNett.GST_Mode__c = 'Nett';
        courseNett.Non_Member_Fee__c = 100;
        courseNett.Non_Member_GST_Fee__c = 0;
        courseNett.Member_Fee__c = 200;
        courseNett.Member_GST_Fee__c = 0;
        courseNett.RMIT_Alumni_Fee__c = 300;
        courseNett.RMIT_Alumni_GST_Fee__c = 0;
        insert courseFull;
        insert courseNett;

        Test.startTest();
        courseFull.Non_Member_Fee__c = 1000;
        courseFull.Member_Fee__c = 2000;
        courseFull.RMIT_Alumni_Fee__c = 3000;
        courseNett.Non_Member_Fee__c = 1000;
        courseNett.Member_Fee__c = 2000;
        courseNett.RMIT_Alumni_Fee__c = 3000;
        update courseFull;
        update courseNett;
        Test.stopTest();
        
        Course__c courseFullAfter = [SELECT Non_Member_Fee__c, 
                                            Non_Member_GST_Fee__c, 
                                            Member_Fee__c, 
                                            Member_GST_Fee__c,
                                            RMIT_Alumni_Fee__c,
                                            RMIT_Alumni_GST_Fee__c
                                    FROM Course__c
                                    WHERE Id=:courseFull.Id];
        System.assertEquals(1000, courseFullAfter.Non_Member_Fee__c);
        System.assertEquals(2000, courseFullAfter.Member_Fee__c);
        System.assertEquals(3000, courseFullAfter.RMIT_Alumni_Fee__c);
        System.assertEquals(70, courseFullAfter.Non_Member_GST_Fee__c);
        System.assertEquals(140, courseFullAfter.Member_GST_Fee__c);
        System.assertEquals(210, courseFullAfter.RMIT_Alumni_GST_Fee__c);
        
        Course__c courseNettAfter = [SELECT Non_Member_Fee__c, 
                                            Non_Member_GST_Fee__c, 
                                            Member_Fee__c, 
                                            Member_GST_Fee__c,
                                            RMIT_Alumni_Fee__c,
                                            RMIT_Alumni_GST_Fee__c
                                    FROM Course__c
                                    WHERE Id=:courseNett.Id];
        System.assertEquals(1000, courseFullAfter.Non_Member_Fee__c);
        System.assertEquals(2000, courseFullAfter.Member_Fee__c);
        System.assertEquals(3000, courseFullAfter.RMIT_Alumni_Fee__c);
        //2021-03-15 Poon Koon: Updated Assertion Values for Nett GST calculation
        System.assertEquals(65.42, courseNettAfter.Non_Member_GST_Fee__c);
        System.assertEquals(130.84, courseNettAfter.Member_GST_Fee__c);
        System.assertEquals(196.26, courseNettAfter.RMIT_Alumni_GST_Fee__c);
    }


    public static testmethod void generateCourseCode() {
        Test.startTest();
        Course__c course = TestDataFactory.createCourse(null);
        course.category__c = 'Agility';
        course.Course_Code__c = '';
        insert course;
        Test.stopTest();

        Course__c courseAfter = [SELECT Id, Course_Code__c FROM Course__c WHERE Id =: course.Id];

        System.assert(courseAfter.Course_Code__c != '');
    }
}