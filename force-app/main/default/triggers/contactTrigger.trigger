trigger contactTrigger on Contact (before insert,before update, after insert,after update) {
    if(trigger.isBefore && (trigger.isInsert||trigger.isUpdate))
    {
        contactTriggerHandler.contactMethod(trigger.new);
        // MVP1.1:Added by ravi ..to validate the user exist with contact email or not
       /* Id b2bLearnerRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('B2B_Learner').getRecordTypeId();
        List<Contact> conList = new List<Contact>();
        for(Contact cObj:Trigger.new){
            if( trigger.isInsert && cObj.RecordTypeId == b2bLearnerRT && ( (cObj.Need_User_Account__c =='Yes'|| cObj.Registration_Submitted__c) || (cObj.Need_User_Account__c =='Yes'&& cObj.Registration_Submitted__c) )){
                conList.add(cObj);
            }
        }
        if(conList.size()>0){
         	UserCreatehandler.checkUserExistWithContactEmail(conList);   
        }*/
    }

    if (trigger.isAfter && trigger.isInsert) {
        // MVP1.1 added by Ravi.. for creating the user
        Id b2bLearnerRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('B2B_Learner').getRecordTypeId();
        set<Id> contactIds = new set<Id>();
        map<string,List<string>> mapIdAndEmail = new map<string,List<string>>();
        for(Contact cObj:Trigger.new){
            if(cObj.RecordTypeId == b2bLearnerRT && (cObj.Need_User_Account__c =='Yes'  && cObj.Registration_Submitted__c)){
                contactIds.add(cObj.Id);
                if(mapIdAndEmail.containsKey(cObj.Email)) {
                    List<string> contactId = mapIdAndEmail.get(cObj.Email);
                    contactId.add(cObj.Id);
                    mapIdAndEmail.put(cObj.Email, contactId);
                } else {
                    mapIdAndEmail.put(cObj.Email, new List<string> { cObj.Id });
                }
            }
        }
        if(contactIds.size()>0){
            // MVP1.1 added by Ravi.. for creating the user
            UserCreatehandler.createUser(contactIds,mapIdAndEmail);
        }
        //Disable until Azure B2C is ready
       // contactTriggerHandler.createSSOUser(trigger.new);
        
    }
    if (trigger.isAfter && trigger.isUpdate) {
        // MVP1.1 added by Ravi.. for creating the user
        Id b2bLearnerRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('B2B_Learner').getRecordTypeId();
        map<string,List<string>> mapIdAndEmail = new map<string,List<string>>();
        set<Id> contactIds = new set<Id>();
        for(Contact cObj:Trigger.new){
            if(cObj.RecordTypeId == b2bLearnerRT && (cObj.Need_User_Account__c =='Yes' && cObj.Registration_Submitted__c && (Trigger.OldMap.get(cObj.Id).Need_User_Account__c != cObj.Need_User_Account__c 
                       ||   Trigger.OldMap.get(cObj.Id).Registration_Submitted__c != cObj.Registration_Submitted__c)) ){
                contactIds.add(cObj.Id);
                if(mapIdAndEmail.containsKey(cObj.Email)) {
                    List<string> contactId = mapIdAndEmail.get(cObj.Email);
                    contactId.add(cObj.Id);
                    mapIdAndEmail.put(cObj.Email, contactId);
                } else {
                    mapIdAndEmail.put(cObj.Email, new List<string> { cObj.Id });
                }
            }
        }
        if(contactIds.size()>0){
            // MVP1.1 added by Ravi.. for creating the user
            UserCreatehandler.createUser(contactIds,mapIdAndEmail);
        }
        
    }

}