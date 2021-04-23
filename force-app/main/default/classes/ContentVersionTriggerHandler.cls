/**
 * @description       : 
 * @author            : Mark Alvin Tayag (mtayag@salesforce.com)
 * @group             : 
 * @last modified on  : 10-20-2020
 * @last modified by  : Mark Alvin Tayag (mtayag@salesforce.com)
 * Modifications Log 
 * Ver   Date         Author                                     Modification
 * 1.0   10-20-2020   Mark Alvin Tayag (mtayag@salesforce.com)   Initial Version
**/
public without sharing class ContentVersionTriggerHandler {
    public static void afterInsert(list<ContentVersion> contentVersionList) {
        updateThumbnailURL(contentVersionList);
    }

    public static void afterUpdate(list<ContentVersion> contentVersionList) {
        updateThumbnailURL(contentVersionList);
    }
    
    //Add afterUpdate
     public static void updateThumbnailURL(list<ContentVersion> contentVersionList) {
        
        Set<Id> contentDocumentIdSet = new Set<Id>(); 
        Map<Id, Id> cdlMapwithLinkedEntityId = new Map<Id, Id>();
        Set<Id> attachmentDocIds = new Set<Id>();
        Set<Id> thumbnailDocIds = new Set<Id>();
        Map<Id, String> cvExtMap = new Map<Id, String>();
        List<ContentDistribution> cdList = new List<ContentDistribution>();
        List<Category__c> catList = new List<Category__c>();
        List<Course__c> courseList = new List<Course__c>();
        List<Id> cvIds = new List<Id>();

        for(ContentVersion cv : contentVersionList) {
            if(cv.File_Type__c == 'Attachment' &&
                cv.ContentDocumentId != null && 
                cv.IsLatest == true) {
                contentDocumentIdSet.add(cv.ContentDocumentId);
                attachmentDocIds.add(cv.ContentDocumentId);
                cvIds.add(cv.Id);
            }
            else if(cv.File_Type__c == 'Thumbnail' &&
                cv.ContentDocumentId != null && 
                cv.IsLatest == true) {
                contentDocumentIdSet.add(cv.ContentDocumentId);
                thumbnailDocIds.add(cv.ContentDocumentId);
                cvIds.add(cv.Id);
            }
        }
        if(contentDocumentIdSet.size() > 0) {
            List<ContentDocumentLink> cdlList = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink 
                                                 WHERE ContentDocumentId IN : contentDocumentIdSet];
            
            for(ContentDocumentLink cdl : cdlList) {
                Id linkedEntityId = cdl.LinkedEntityId;
                //This logic is only applicable for Course and Category 
                if (linkedEntityId.getSobjectType() == Course__c.sObjectType || 
                    linkedEntityId.getSobjectType() == Category__c.sObjectType) {
                    cdlMapwithLinkedEntityId.put(cdl.ContentDocumentId, linkedEntityId);
                }
                
            }          
            
            //Check if there is an existing Content Delivery Record for the Content Version
            Set<Id> contentVersionWithDelivery = new Set<Id>();
            for (ContentDistribution cd : [SELECT ContentVersionId FROM ContentDistribution WHERE ContentVersionId =: cvIds]) {
                contentVersionWithDelivery.add(cd.ContentVersionId);
            }

            for (ContentVersion cv : contentVersionList) {
                if (cdlMapwithLinkedEntityId.containsKey(cv.ContentDocumentId) &&
                    !contentVersionWithDelivery.contains(cv.Id)) {
                    ContentDistribution cd = new ContentDistribution();
                    cd.Name = cv.Id + '-Url';
                    cd.ContentVersionId = cv.id;
                    cd.PreferencesAllowViewInBrowser= true;
                    cd.PreferencesLinkLatestVersion=true;
                    cd.PreferencesNotifyOnVisit=false;
                    cd.PreferencesPasswordRequired=false;
                    cd.PreferencesAllowOriginalDownload= true;
                    cdList.add(cd);
                }
            }
            
            if (cdList.size() > 0) {
                insert cdList;
            }         
            
            //Get the ContentVersion Extension
            for (ContentVersion cv : [SELECT ContentDocumentId, FileExtension FROM ContentVersion WHERE Id =: cvIds]) {
                cvExtMap.put(cv.ContentDocumentId, cv.FileExtension);
                
            }
            
            for (ContentDistribution cd : [select DistributionPublicUrl,ContentDownloadUrl, ContentVersionID, contentDocumentId from ContentDistribution 
                                           where contentDocumentId =: cdlMapwithLinkedEntityId.keySet()]) {
                Id linkedEntityId = cdlMapwithLinkedEntityId.get(cd.contentDocumentId);
                if (linkedEntityId.getSobjectType() == Course__c.sObjectType) {
                    Course__c course = new Course__c();
                    course.Id = linkedEntityId;
                    if (thumbnailDocIds.contains(cd.contentDocumentId)) {
                        //course.ThumbnailURL__c = cd.DistributionPublicUrl;
                        course.ThumbnailURL__c = cd.ContentDownloadUrl;
                        course.ThumbnailURL_Ext__c = cvExtMap.get(cd.contentDocumentId);
                    }
                    else if (attachmentDocIds.contains(cd.contentDocumentId)) {
                        course.AttachmentURL__c = cd.ContentDownloadUrl;
                        //course.AttachmentURL__c = cd.DistributionPublicUrl;
                        course.AttachmentURL_Ext__c = cvExtMap.get(cd.contentDocumentId);
                    }
                    courseList.add(course);
                }
                if (linkedEntityId.getSobjectType() == Category__c.sObjectType && 
                    thumbnailDocIds.contains(cd.contentDocumentId)) {
                    Category__c category = new Category__c();
                    category.Id = linkedEntityId;
                    category.Thumbnail_URL__c = cd.ContentDownloadUrl;
                    //category.Thumbnail_URL__c = cd.DistributionPublicUrl;
                    category.ThumbnailURL_Ext__c = cvExtMap.get(cd.contentDocumentId);
                    catList.add(category);
                }
            }
        }
        if (catList.size() > 0) {
            update catList;
        }
         
        if (courseList.size() > 0) {
            update courseList;
        }
         
     }
}