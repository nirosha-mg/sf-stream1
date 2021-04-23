@IsTest
public with sharing class CourseRunTriggerHandlerTest {
    
    @IsTest
    static void generateCourseRunCode(){
        Course__c course = TestDataFactory.createCourse(null);
        insert course;
        Course_Run__c courseRun = TestDataFactory.createCourseRun();
        courseRun.Course_Run_Code__c = '';
        courseRun.Course__c = course.Id;

        Test.startTest();
        insert courseRun;
        Test.stopTest();

        Course_Run__c courseRunAfter = [SELECT Course_Run_Code__c FROM Course_Run__c WHERE Id=: courseRun.Id];
        System.assert(courseRunAfter.Course_Run_Code__c != '');
        
    }

    @IsTest
    static void generateCourseRunCodeMultiInsert(){
        Course__c course = TestDataFactory.createCourse(null);
        insert course;
        Course_Run__c courseRun = TestDataFactory.createCourseRun();
        courseRun.Course_Run_Code__c = '';
        courseRun.Course__c = course.Id;
        Course_Run__c courseRun2 = TestDataFactory.createCourseRun();
        courseRun2.Course_Run_Code__c = '';
        courseRun2.Course__c = course.Id;

        List<Course_Run__c> courseRuns = new List<Course_Run__c>();
        courseRuns.add(courseRun);
        courseRuns.add(courseRun2);
        Test.startTest();
        insert courseRuns;
        Test.stopTest();

        List<Course_Run__c> courseRunAfter = [SELECT Course_Run_Code__c FROM Course_Run__c];
        System.assert(courseRunAfter[0].Course_Run_Code__c != '');
        System.assert(courseRunAfter[1].Course_Run_Code__c != '');
    }

    @IsTest
    static void generateCourseRunCodeExisting(){
        Course__c course = TestDataFactory.createCourse(null);
        insert course;
        Course_Run__c courseRun = TestDataFactory.createCourseRun();
        courseRun.Course_Run_Code__c = '';
        courseRun.Course__c = course.Id;
        insert courseRun;

        Course_Run__c courseRun2 = TestDataFactory.createCourseRun();
        courseRun2.Course_Run_Code__c = '';
        courseRun2.Course__c = course.Id;
        Test.startTest();
        insert courseRun2;
        Test.stopTest();

        List<Course_Run__c> courseRunAfter = [SELECT Course_Run_Code__c FROM Course_Run__c];
        System.assert(courseRunAfter[0].Course_Run_Code__c != '');
        System.assert(courseRunAfter[1].Course_Run_Code__c != '');
    }
}