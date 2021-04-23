public without sharing class CourseTriggerHandler {
    public static void beforeInsert(List<Course__c> courseList) {
        updateWhoShouldEnroll(courseList, new Map<Id, Course__c>());
    }

    public static void beforeUpdate(List<Course__c> courseList, Map<id, Course__c> courseOldMap) {
        updateWhoShouldEnroll(courseList, courseOldMap);
    }

    public static void afterInsert(List<course__c> courseList) {
        createCourseCategories(courseList);
        calculateGST(courseList, new Map<Id, Course__c>());
        generateCourseCode(courseList);
    }
    
    public static void afterUpdate(Map<id,course__c> courseNewMap, Map<id,course__c> courseOldMap, List<course__c> courseList) {
        updateOnCourse(courseNewMap,courseOldMap);
        calculateGST(courseList, courseOldMap);
    }
    
    public static void createCourseCategories(List<course__c> courseList) {
        set<string> courseCategorySet = new set<string>();
        Map<Id,String> categoriesMap = new Map<Id,String>();
        Map<Id,List<String>> CourseSelectedPickListMap = new Map<Id,List<String>>();
       // Map<Id,Set<Id>> courseCategoriesMapToInsert = new Map<Id,Set<Id>>();        
        List<Course_Category__c> courseCategoryListToInsert = new List<Course_Category__c>();
        
        for(course__c c : courseList) {
            if(c.Category__c != null) {
                list<String> catList = new List<String>();
                catList.addAll(c.Category__c.split(';'));
                courseCategorySet.addAll(c.Category__c.split(';'));
                CourseSelectedPickListMap.put(c.Id, catList);
            }
        }
        
        List<category__c> categoryList = [select id,category__c from category__c where category__c in : courseCategorySet];
        for(category__c category : categoryList) {
            categoriesMap.put(category.Id, category.Category__c);
        }
        
        for(id courseRecid : CourseSelectedPickListMap.keyset()) {            
             for(Id category: categoriesMap.keySet()) {
                 if(CourseselectedPickListMap.containskey(courseRecid) &&
                    categoriesMap.containskey(category) && 
                    CourseselectedPickListMap.get(courseRecid).contains(categoriesMap.get(category))) {                     
                          Course_Category__c  cc = new Course_Category__c();
                          cc.Course__c = courseRecid;
                          cc.Category__c= category;
                          cc.Category_Picklist__c = categoriesMap.get(category);
                          courseCategoryListToInsert.add(cc);                       
                  }
             }
        }
        
        if(courseCategoryListToInsert.size() > 0) {
            insert courseCategoryListToInsert;
        }
    }
    
    public static void updateOnCourse(Map<id,course__c> courseNewMap, Map<id,course__c> courseOldMap) {
        Map<Id,List<String>> newCourseMap = new Map<Id,List<String>>();
        Map<Id,List<String>> oldCourseMap = new Map<Id,List<String>>();
        Map<Id,String> categoriesMap = new Map<Id,String>();
        set<string> categorySet = new set<string>();
        Map<Id,List<String>> removedCategories = new Map<Id,List<String>>();
        Map<Id,Set<Id>> delteteCategoriesMap = new Map<Id,Set<Id>>();
        Map<Id,List<String>> categoriesToAdd = new Map<Id,List<String>>();
        List<Course_Category__c> courseCategoryToInsert = new List<Course_Category__c>();
        
        for(Course__c co : courseNewMap.values()){
            if(co.Category__c != null) {
                newCourseMap.put(co.Id, co.Category__c.split(';'));
                categorySet.addall(co.Category__c.split(';'));                
            }
            if(courseOldMap.get(co.id).Category__c != null) {
                oldCourseMap.put(co.Id, courseOldMap.get(co.id).Category__c.split(';'));
                categorySet.addall(courseOldMap.get(co.id).Category__c.split(';'));
            } 
            
        }       
        
        List<category__c> categoriesList = [select id,category__c from category__c where category__c in : categorySet];
        
        if(categoriesList.size() > 0){
            for(category__c category : categoriesList){
                categoriesMap.put(category.Id, category.Category__c);
            }
        }
        
        for(Id OldId : oldCourseMap.keySet()) {
            for(String category : oldCourseMap.get(OldId)) {
                 if(newCourseMap.get(OldId) != null && !newCourseMap.get(OldId).contains(category)) {
                  if(removedCategories.containsKey(OldId)) {
                        List<String> categoryList = removedCategories.get(OldId);
                        categoryList.add(category);
                        removedCategories.put(OldId, categoryList);
                    }else{
                        removedCategories.put(OldId, new List<String> {category});
                    }
                 }
                 if(newCourseMap.get(OldId) == null) {
                  if(removedCategories.containsKey(OldId)) {
                        List<String> categoryList = removedCategories.get(OldId);
                        categoryList.add(category);
                        removedCategories.put(OldId, categoryList);
                    }else{
                        removedCategories.put(OldId, new List<String> {category});
                    }
                 }                
            }
        }
        
        for(Id courserecId : removedCategories.keySet()) {
            for(Id category: categoriesMap.keySet()) {
                 if(categoriesMap.containskey(category) && 
                    removedCategories.get(courserecId).contains(categoriesMap.get(category))) {
                      if(delteteCategoriesMap.containsKey(courserecId)) {
                            Set<Id> categoryIdSet = delteteCategoriesMap.get(courserecId);
                            categoryIdSet.add(category);
                            delteteCategoriesMap.put(courserecId, categoryIdSet);
                        } else {
                            delteteCategoriesMap.put(courserecId, new Set<Id> {category});
                        }
                 }  
            }
        }
        List<Id> deletedCatList = new List<Id>();
        if(delteteCategoriesMap.size() > 0){
            for(Id deleteId : delteteCategoriesMap.keySet()){
                deletedCatList.addAll(delteteCategoriesMap.get(deleteId));
            }
        }
        
        if(delteteCategoriesMap.size() > 0) {
            List<Course_Category__c> courseCategoriesListToDelete = [SELECT Id,Course__c,Category__c FROM Course_Category__c 
                                                         WHERE Course__c IN :delteteCategoriesMap.keyset() 
                                                         AND Category__c IN :deletedCatList];
            if(courseCategoriesListToDelete.size() > 0) {
                delete courseCategoriesListToDelete;
            }
        }
        
        for(Id newId : newCourseMap.keySet()) {
            for(String category : newCourseMap.get(newId)) {
              if(oldCourseMap.containskey(newID) && oldCourseMap.get(newId) != null && !oldCourseMap.get(newId).contains(category)) {
                    if(categoriesToAdd.containsKey(newId)) {
                        List<String> categoryList = categoriesToAdd.get(newId);
                        categoryList.add(category);
                        categoriesToAdd.put(newId, categoryList);
                    } else {
                        categoriesToAdd.put(newId, new List<String> {category});
                    }                    
                } else if(oldCourseMap.get(newId) == null) {
                    if(categoriesToAdd.containsKey(newId)) {
                        List<String> categoryList = categoriesToAdd.get(newId);
                        categoryList.add(category);
                        categoriesToAdd.put(newId, categoryList);
                    } else {
                        categoriesToAdd.put(newId, new List<String> {category});
                    }
                }  
            }
        }
        
        for(Id courseRecId : categoriesToAdd.keySet()) {
            for(Id category: categoriesMap.keySet()) {
                if(categoriesToAdd.get(courseRecId).contains(categoriesMap.get(category))) {                      
                    Course_Category__c  cc = new Course_Category__c();
                    cc.Course__c = courseRecId;
                    cc.Category__c= category;
                    cc.Category_Picklist__c = categoriesMap.get(category);
                    courseCategoryToInsert.add(cc);
                    
                }
            }
        }
        
        if(courseCategoryToInsert.size() > 0) {
            insert courseCategoryToInsert;
        }
    }

    public static void calculateGST (List<Course__c> courseList, Map<Id, Course__c> courseMap) {
        Map<String, Decimal> gstCodeMap = Utility.getGSTCodeMap();
        List<Course__c> updateCourse = new List<Course__c>();
        for (Course__c course : courseList) {
            if (courseMap.containsKey(course.Id)) {
                Course__c oldCourse = courseMap.get(course.Id);
                if (oldCourse.Non_Member_Fee__c == course.Non_Member_Fee__c && 
                oldCourse.Member_Fee__c == course.Member_Fee__c && 
                oldCourse.RMIT_Alumni_Fee__c == course.RMIT_Alumni_Fee__c &&
                oldCourse.GST_Mode__c == course.GST_Mode__c && //2021-03-15 Poon Koon: Added in check for possible GST Mode change
                oldCourse.GST_Code__c == course.GST_Code__c) {
                    continue;
                }
            }
            Course__c courseUpd = new Course__c();
            courseUpd.Id = course.Id;
            //2021-03-15 Poon Koon: Added in logic to hanlde GST calculation for Nett fee calculation
            if (course.GST_Mode__c == 'Nett') {
                if(course.Non_Member_Fee__c != null) {
                    Decimal gstAmt = Utility.calculateGST(course.Non_Member_Fee__c, course.GST_Code__c, gstCodeMap, course.GST_Mode__c);
                    courseUpd.Non_Member_GST_Fee__c = gstAmt;
                }
                else{
                    courseUpd.Non_Member_GST_Fee__c = 0;
                }
                if(course.Member_Fee__c != null) {
                    Decimal gstAmt = Utility.calculateGST(course.Member_Fee__c, course.GST_Code__c, gstCodeMap, course.GST_Mode__c);
                    courseUpd.Member_GST_Fee__c = gstAmt;
                }
                else{
                    courseUpd.Member_GST_Fee__c = 0;
                }
                if(course.RMIT_Alumni_Fee__c != null) {
                    Decimal gstAmt = Utility.calculateGST(course.RMIT_Alumni_Fee__c, course.GST_Code__c, gstCodeMap, course.GST_Mode__c);
                    courseUpd.RMIT_Alumni_GST_Fee__c = gstAmt;
                }
                else{
                    courseUpd.RMIT_Alumni_GST_Fee__c = 0;
                }
            }
            else {
                courseUpd.Non_Member_GST_Fee__c = course.Non_Member_Fee__c != null ? Utility.calculateGST(course.Non_Member_Fee__c, course.GST_Code__c, gstCodeMap) : 0;
                courseUpd.Member_GST_Fee__c = course.Member_Fee__c != null ? Utility.calculateGST(course.Member_Fee__c, course.GST_Code__c, gstCodeMap) : 0;
                courseUpd.RMIT_Alumni_GST_Fee__c = course.RMIT_Alumni_Fee__c != null ? Utility.calculateGST(course.RMIT_Alumni_Fee__c, course.GST_Code__c, gstCodeMap) : 0;
            }
            /*
            courseUpd.Non_Member_GST_Fee__c = course.Non_Member_GST_Fee__c != null ? Utility.calculateGST(course.Non_Member_Fee__c, course.GST_Code__c, gstCodeMap) : 0;
            courseUpd.Member_GST_Fee__c = course.Member_Fee__c != null ? Utility.calculateGST(course.Member_Fee__c, course.GST_Code__c, gstCodeMap) : 0;
            courseUpd.RMIT_Alumni_GST_Fee__c = course.RMIT_Alumni_Fee__c != null ? Utility.calculateGST(course.RMIT_Alumni_Fee__c, course.GST_Code__c, gstCodeMap) : 0;
            */
            /*
            else {
                //Nett
                Decimal nonMemberFee = course.Non_Member_Fee__c;
                Decimal memberFee = course.Member_Fee__c;
                Decimal rmitFee = course.RMIT_Alumni_Fee__c;
                Decimal nonMemberFeeGST = Utility.calculateGST(nonMemberFee, course.GST_Code__c, gstCodeMap);
                Decimal memberFeeGST = Utility.calculateGST(memberFee, course.GST_Code__c, gstCodeMap);
                Decimal rmitFeeGST = Utility.calculateGST(rmitFee, course.GST_Code__c, gstCodeMap);
                nonMemberFee = nonMemberFee - nonMemberFeeGST;
                memberFee = memberFee - memberFeeGST;
                rmitFee = rmitFee - rmitFeeGST;
                courseUpd.Non_Member_Fee__c = nonMemberFee;
                courseUpd.Member_Fee__c = memberFee;
                courseUpd.RMIT_Alumni_Fee__c = rmitFee;
                courseUpd.Non_Member_GST_Fee__c = nonMemberFeeGST;
                courseUpd.Member_GST_Fee__c = memberFeeGST;
                courseUpd.RMIT_Alumni_GST_Fee__c = rmitFeeGST;
            }
            */
            updateCourse.add(courseUpd);
            
        }

        if (updateCourse.size() > 0) {
            update updateCourse;
        }
    }

    public static void updateWhoShouldEnroll(List<Course__c> courseList, Map<Id, Course__c> courseMap) {
        
        for (Course__c course : courseList) {
            if (courseMap.containsKey(course.Id)) {
                Course__c oldCourse = courseMap.get(course.Id);
                if (oldCourse.Who_Should_Enroll_MPL__c == course.Who_Should_Enroll_MPL__c) {
                    continue;
                }
            }
            if (course.Who_Should_Enroll_MPL__c != null) {
                List<String> whoShouldEnroll = course.Who_Should_Enroll_MPL__c.split(';');
                if (whoShouldEnroll.size() > 0) {
                    String strRTF = '<p>';
                    for (String str : whoShouldEnroll) {
                        strRTF += str + '<br/>';
                    }
                    strRTF += '</p>';
                    course.Who_Should_Enroll__c = strRTF;
                }                
            }
            else {
                course.Who_Should_Enroll__c = '<p></p>';
            }
        }
    }

    public static void generateCourseCode(List<Course__c> courseList) {
        List<Course__c> courseWithCode = new List<Course__c>();
        //Get MDT
        Map<String, String> courseTypeCodes = new Map<String, String>();
        for (Course_Type_Code__mdt courseType : [SELECT Course_Type__c, Code__c FROM Course_Type_Code__mdt]) {
            courseTypeCodes.put(courseType.Course_Type__c, courseType.Code__c);
        }
        Map<String, String> recordTypeCodes = new Map<String, String>();
        for (Course_Record_Code__mdt recordType : [SELECT Record_Type__c, Code__c FROM Course_Record_Code__mdt]) {
            recordTypeCodes.put(recordType.Record_Type__c, recordType.Code__c);
        }
        Map<Id, String> rtDevnameMap = new Map<Id, String>();
        for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = 'Course__c']) {
            rtDevnameMap.put(rt.Id, rt.DeveloperName);
        }
        for (Course__c course : courseList) {
            if (String.isNotBlank(course.Course_Code__c)) {
                continue;
            }
            if (!courseTypeCodes.containsKey(course.Course_Type__c)) {
                continue;
            }
            System.debug(rtDevnameMap.get(course.RecordTypeId));
            System.debug(course.RecordTypeId);
            if (!recordTypeCodes.containsKey(rtDevnameMap.get(course.RecordTypeId))) {
                continue;
            }
            Course__c updatedCourse = new Course__c();
            updatedCourse.Id = course.Id;
            updatedCourse.Course_Code__c = courseTypeCodes.get(course.Course_Type__c) +
                                    recordTypeCodes.get(rtDevnameMap.get(course.RecordTypeId)) +
                                    course.Course_Code_Running_No__c;

            courseWithCode.add(updatedCourse);
        }

        if (courseWithCode.size() > 0) {
            update courseWithCode;
        }
    }
}