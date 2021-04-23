public with sharing class CourseRunTriggerHandler {
    public static void generateCourseCode(List<Course_Run__c> courseRunList) {
        List<Course_Run__c> courseRunWithCodes = new List<Course_Run__c>();

        Map<Id, Integer> courseRunNoMap = new Map<Id, Integer>();
        Map<String, String> courseCodeMap = new Map<String, String>();
        Set<Id> courseIds = new Set<Id>();

        for (Course_Run__c courseRun : courseRunList) {
            courseIds.add(courseRun.Course__c);
        }

        for (Course__c course : [SELECT Id, Course_Code__c FROM Course__c WHERE Id =: courseIds]) {
            courseCodeMap.put(course.Id, course.Course_Code__c);
        }

        for (AggregateResult ar : [SELECT Course__c, COUNT(Id) 
                                    FROM Course_Run__c 
                                    WHERE Course_Run_Code__c != ''
                                    AND Course__c =: courseIds
                                    GROUP BY Course__c]) {
            courseRunNoMap.put((Id)ar.get('Course__c'), Integer.valueOf(ar.get('expr0')));
        }

        for (Course_Run__c courseRun : courseRunList) {
            if (String.isNotBlank(courseRun.Course_Run_Code__c)) {
                continue; //Skip Course Run
            }

            String courseRunCode = courseCodeMap.get(courseRun.Course__c);
            if (courseRunNoMap.containsKey(courseRun.Course__c)) {
                Integer currentNo = courseRunNoMap.get(courseRun.Course__c) + 1;
                courseRunCode = courseRunCode + '-' + String.valueOf(currentNo).leftPad(4, '0');
                courseRunNoMap.remove(courseRun.Course__c);
                courseRunNoMap.put(courseRun.Course__c, currentNo);
            }
            else {
                courseRunCode = courseRunCode + '-' + String.valueOf(1).leftPad(4, '0');
                courseRunNoMap.put(courseRun.Course__c, 1);
            }
            
            
            Course_Run__c cr = new Course_Run__c();
            cr.Id = courseRun.Id;
            cr.Course_Run_Code__c = courseRunCode;

            courseRunWithCodes.add(cr);
        }

        List<Id> duplicateCodes = new List<Id>();
        if (courseRunWithCodes.size() > 0) {
            List<Database.SaveResult> resList = Database.update(courseRunWithCodes, false);
            for (Database.SaveResult res : resList) {
                if (!res.success) {
                    duplicateCodes.add(res.getId());
                }
            }
        }

        if (duplicateCodes.size() > 0) {
            retryGenerateCourseCode(duplicateCodes);
        }
    }

    private static void retryGenerateCourseCode(List<Id> courseRunWithDuplicateCodeList) {
        List<Course_Run__c> courseRunList = [SELECT Id, Course__c, Course__r.Course_Code__c, Course__r.Id
                                        FROM Course_Run__c
                                        WHERE Id =: courseRunWithDuplicateCodeList];
        
        if (courseRunList.size() > 0) {
            generateCourseCode(courseRunList);
        }
    }
}