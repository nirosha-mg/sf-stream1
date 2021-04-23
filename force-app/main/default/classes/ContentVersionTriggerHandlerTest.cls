@istest
public class ContentVersionTriggerHandlerTest {
    public static testmethod void testThumbnailUpdateonCategory() {     
        List<ContentVersion> cvList = new List<ContentVersion>();
        category__c category = TestDataFactory.createCategory();
        //2021-03-31 Poon Koon: Update Category with valid picklist value
        category.Category__c = 'Management';
        insert category;
        
        contentVersion contentVersionVar = TestDataFactory.createContentVersion();
        insert contentVersionVar; 
        System.assertEquals( contentVersionVar.Title , 'Thumbnail' );               
       
        cvList  = [SELECT Id, Title,PathOnClient,VersionData,File_Type__c,IsMajorVersion,ContentDocumentId,isLatest 
                   FROM ContentVersion WHERE Id = :contentVersionVar.Id];               

        ContentDocumentLink contentDocLink = TestDataFactory.createContentDocumentLink(category.Id,cvList[0].ContentDocumentId);
        insert contentDocLink;
        
        Test.startTest();
        ContentVersionTriggerHandler.updateThumbnailURL(cvList);
        category__c updateCategory = [select id,Thumbnail_URL__c,ThumbnailURL_Ext__c from category__c where id=: category.id];
        System.assertEquals( updateCategory.ThumbnailURL_Ext__c , 'jpg' );               
        Test.stopTest();
    }
    
    public static testmethod void testThumnailUpdateonCourse() {
        List<ContentVersion> cvList = new List<ContentVersion>();
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B Account').getRecordTypeId();
        Account acc = TestDataFactory.createAccount(devRecordTypeId);
        insert acc;
        
        Course__c course = TestDataFactory.createCourse(acc.Id);
        insert course;       
        
        contentVersion contentVerThumbNail = TestDataFactory.createContentVersion();
        insert contentVerThumbNail;
        System.assertEquals( contentVerThumbNail.Title , 'Thumbnail' );
        
        cvList  = [SELECT Id, Title,PathOnClient,VersionData,IsMajorVersion,File_Type__c,ContentDocumentId,isLatest FROM 
                   ContentVersion WHERE Id =: contentVerThumbNail.id];               
        
        ContentDocumentLink contentDocLinkThumnail = TestDataFactory.createContentDocumentLink(course.Id,cvList[0].ContentDocumentId);
        insert contentDocLinkThumnail;        
       
        Test.startTest();
        ContentVersionTriggerHandler.updateThumbnailURL(cvList);
        Course__c updateCourse = [select id,ThumbnailURL__c,ThumbnailURL_Ext__c from course__c where id=: course.id];
        System.assertEquals( updateCourse.ThumbnailURL_Ext__c , 'jpg' );               
        Test.stopTest();
    }
    
    public static testmethod void testAttachmentUpdateonCourse() {
        List<ContentVersion> cvList = new List<ContentVersion>();
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B Account').getRecordTypeId();
        Account acc = TestDataFactory.createAccount(devRecordTypeId);
        insert acc;
        
        Course__c course = TestDataFactory.createCourse(acc.Id);
        insert course;        
      
       
        contentVersion contentVerAttachment = TestDataFactory.createContentVersionAttachment();
       // contentVerAttachment.Title = 'Attachment';
       // contentVerAttachment.PathOnClient = 'Attachment.jpg';
        insert contentVerAttachment; 
        System.assertEquals( contentVerAttachment.Title , 'Attachment' );
        
        cvList  = [SELECT Id, Title,PathOnClient,VersionData,IsMajorVersion,ContentDocumentId,isLatest,File_Type__c 
                   FROM ContentVersion WHERE Id =: contentVerAttachment.id];                       
      
        ContentDocumentLink contentDocLinkAttachment = TestDataFactory.createContentDocumentLink(course.Id,cvList[0].ContentDocumentId);
        insert contentDocLinkAttachment;
        
        Test.startTest();
        ContentVersionTriggerHandler.updateThumbnailURL(cvList);
        Course__c updateCourse = [select id,AttachmentURL__c,AttachmentURL_Ext__c from course__c where id=: course.id];
        System.assertEquals( updateCourse.AttachmentURL_Ext__c , 'jpg' );
        Test.stopTest();
    }
    
    
       public static testmethod void testFileUploadCategoryTest() {     
        List<ContentVersion> cvList = new List<ContentVersion>();
        category__c category = TestDataFactory.createCategory();
        //2021-03-31 Poon Koon: Update Category with valid picklist value
        category.Category__c = 'Management';
        insert category;
        
        contentVersion contentVersionVar = TestDataFactory.createContentVersionTest();
        insert contentVersionVar; 
        System.assertEquals( contentVersionVar.Title , 'Test' );               
       
        cvList  = [SELECT Id, Title,PathOnClient,VersionData,IsMajorVersion,ContentDocumentId,isLatest,File_Type__c 
                   FROM ContentVersion WHERE Id = :contentVersionVar.Id];               

        ContentDocumentLink contentDocLink = TestDataFactory.createContentDocumentLink(category.Id,cvList[0].ContentDocumentId);
        insert contentDocLink;
        
        Test.startTest();
        ContentVersionTriggerHandler.updateThumbnailURL(cvList);
        Test.stopTest();
    }
    
      public static testmethod void testFileUploadonCourseTest() {
        List<ContentVersion> cvList = new List<ContentVersion>();
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B Account').getRecordTypeId();
        Account acc = TestDataFactory.createAccount(devRecordTypeId);
        insert acc;
        
        Course__c course = TestDataFactory.createCourse(acc.Id);
        insert course;        
      
        
        contentVersion contentVerThumbNail = TestDataFactory.createContentVersionTest();
        insert contentVerThumbNail;
        System.assertEquals( contentVerThumbNail.Title , 'Test' );
        
        cvList  = [SELECT Id, Title,PathOnClient,VersionData,IsMajorVersion,ContentDocumentId,isLatest,File_Type__c 
                   FROM ContentVersion WHERE Id =: contentVerThumbNail.id];               
        
        ContentDocumentLink contentDocLinkThumnail = TestDataFactory.createContentDocumentLink(course.Id,cvList[0].ContentDocumentId);
        insert contentDocLinkThumnail;        
       
        Test.startTest();
        ContentVersionTriggerHandler.updateThumbnailURL(cvList);
        Test.stopTest();
    }

   
}