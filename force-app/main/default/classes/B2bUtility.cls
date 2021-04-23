/*************************************************************************************************************
* @name            B2bUtility
* @author          TMC\Devender Singh (tmc)
* @created         16/ 03 / 2021
* @description     Description of your code
*
* Changes (version)
* -----------------------------------------------------------------------------------------------------------
*              No.     Date            Author                       Description
*              ----    ------------    --------------------    ----------------------------------------------
**************************************************************************************************************/

public without sharing class B2bUtility {
    
    public static set<string> UpsertContact( Map<string,Course_Registration__c> MapMapOfExistingContact,List<Course_Registration__c> ListCourseRegistration, Map<string,string> mapOfExistingLookUpContact, string UserId) {
        Set<string> SetOfContact=New Set<string>();
        Contact con=getContact(UserId);
        system.debug('B2bUtility AccountId ---> '+con.AccountId);
        string sownerAccount=getOwnerId(con.AccountId);
        map<string,Contact> mapAccountContact=getmapContact(con.AccountId);
        system.debug('B2bUtility mapOfExistingLookUpContact ---> '+mapOfExistingLookUpContact);
        List<Contact>ListContact=New List<Contact>(); 
        //try {
            for(Course_Registration__c objcr:ListCourseRegistration){
                Contact objContact=New Contact();     
                if(MapMapOfExistingContact.containsKey(objcr.Contact__c)){
                    objContact.id=MapMapOfExistingContact.get(objcr.Contact__c).Contact__c; 
                }
                else if(mapOfExistingLookUpContact.containsKey(objcr.Contact__c)){
                    objContact.id=mapOfExistingLookUpContact.get(objcr.Contact__c); 
                }else{
                    string sKey=objcr.First_Name__c+objcr.Last_Name__c+objcr.Email_Address__c;
                    if (mapAccountContact.containsKey(sKey.trim().toLowerCase())){
                        objContact.id=mapAccountContact.get(sKey.trim().toLowerCase()).Id; 
                    }
                }
                objContact.Salutation=objcr.Salutation__c; 
                objContact.AccountId=con.AccountId; 
                objContact.firstname =objcr.First_Name__c;
                objContact.lastname  =objcr.Last_Name__c;
                objContact.Date_of_Birth__c=objcr.Date_of_Birth__c;
                objContact.Preferred_Certificate_Name__c=objcr.Preferred_Certificate_Name__c;
                objContact.Gender__c=objcr.Gender__c;
                objContact.Email=objcr.Email_Address__c;
                objContact.MobilePhone=objcr.Mobile_No__c;
                objContact.Mobile_Number__c=objcr.Mobile_No__c;
                objContact.Nationality__c=objcr.Nationality__c;
                objContact.HomePhone=objcr.Home_No__c;
                objContact.Office_No__c=objcr.Office_No__c;
                objContact.Employment_Status__c=objcr.Employment_Status__c;
                objContact.Title=objcr.Job_Title__c;
                objContact.Designation_Level__c=objcr.Designation_Level__c;
                objContact.NRIC_Type__c=objcr.NRIC_Type__c;
                objContact.NRIC__c=objcr.NRIC__c;
                objContact.PDPA_Consent_Clause__c=objcr.PDPA_Consent_Clause__c;
                objContact.Marketing_Consent_Clause__c=objcr.Marketing_Consent_Clause__c;
                objContact.How_did_you_get_to_know_us__c=objcr.How_did_you_get_to_know_us__c;
                objContact.Need_User_Account__c=objcr.Need_User_Account__c;
                objContact.Billing_Address_Line_1__c=con.Billing_Address_Line_1__c;
                objContact.Billing_Address_Line_2__c=con.Billing_Address_Line_2__c;
                objContact.Billing_Address_Line_3__c=con.Billing_Address_Line_3__c;
                objContact.Billing_State__c=con.Billing_State__c;
                objContact.Billing_City__c=con.Billing_City__c;
                objContact.Billing_Country__c=con.Billing_Country__c;
                objContact.Billing_Postal_Code__c=con.Billing_Postal_Code__c;
                objContact.OwnerId= sownerAccount;
                
                if(objcr.Registration_Status__c=='New')
                    objContact.Registration_Submitted__c=true;
                
                objContact.RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('B2B_Learner').getRecordTypeId();
                ListContact.add(objContact);
            }
            system.debug('ListContact --> '+ListContact);
            if(ListContact.size()>0){
                upsert ListContact;
                for(Contact cont:ListContact){
                    SetOfContact.add(cont.Id);
                }
                //insert ListContact;
                /*Database.UpsertResult[] srList = Database.upsert(ListContact, false);
                for (Database.UpsertResult sr : srList) {
                    if (sr.isSuccess()) {
                        System.debug('  account. Account ID: ' + sr.getId());
                        SetOfContact.add(sr.getId());
                    }
                    else {            
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                    }
                }*/
            }
            return SetOfContact;
        /*}
        catch (Exception e) {
            throw e; 
        }*/
        
        
    }
    
    public static Set<Id> UpdateCourseRegistration(Set<String> setContactId,List<Course_Registration__c> lstCourseRegistration,string CourseRegistrationId,string courseRunCode,Map<Id,Course_Registration__c> MapOfExistingCourseRegistration,string UserId) {
        Map<string,Contact> MapOfExistingContact=New Map<string,Contact>();
        List<Course_Run__c> courseRuns= getvalcourseRuns(courseRunCode);
        List<Course_Registration__c>InsertCourseRegistration=New List<Course_Registration__c>(); 
        Set<Id> setCourseRegistrationId=New Set<Id>();
        Contact recCon=getContact(UserId);
        //string sownerAccount=getOwnerId(recCon.AccountId);
        system.debug('setContactId ---> '+setContactId);
        system.debug('lstCourseRegistration ---> '+lstCourseRegistration);
        system.debug('CourseRegistrationId ---> '+CourseRegistrationId);
       // system.debug('99 sownerAccount ---> '+sownerAccount);
        
        
        try{
            for (Contact con : [SELECT Id, Name,Email FROM Contact WHERE Id IN :setContactId]) { 
                MapOfExistingContact.put(string.valueOf(con.Email).toLowercase(),con);
            }
            system.debug('MapOfExistingContact ---> '+MapOfExistingContact);
            
            
            for(Course_Registration__c objcr:lstCourseRegistration){
                Course_Registration__c objCourseRegistration=New Course_Registration__c();
                if(MapOfExistingCourseRegistration.containsKey(objcr.id)){
                    objCourseRegistration.id=MapOfExistingCourseRegistration.get(objcr.id).id; 
                    objCourseRegistration.Contact__c=MapOfExistingCourseRegistration.get(objcr.id).Contact__c;
                }else{
                    objCourseRegistration.Contact__c=MapOfExistingContact.get(string.valueOf(objcr.Email_Address__c).toLowercase()).Id;
                }
                
                if(string.isNotEmpty(UserId))
                    objCourseRegistration.OwnerId=UserId;
                objCourseRegistration.Salutation__c=objcr.Salutation__c;
                objCourseRegistration.Parent_Registration__c=CourseRegistrationId;
                objCourseRegistration.Provider_Access_Start_Date__c=courseRuns[0].Registration_Open_Date__c;
                objCourseRegistration.Provider_Access_End_Date__c=courseRuns[0].Registration_Close_Date__c;
                objCourseRegistration.Course_Run_Id__c=courseRuns[0].Id;
                objCourseRegistration.Registration_Status__c=objcr.Registration_Status__c;
                objCourseRegistration.First_Name__c =objcr.First_Name__c;
                objCourseRegistration.Last_Name__c  =objcr.Last_Name__c;
                objCourseRegistration.Date_of_Birth__c=objcr.Date_of_Birth__c;
                objCourseRegistration.Preferred_Certificate_Name__c=objcr.Preferred_Certificate_Name__c;
                objCourseRegistration.Gender__c=objcr.Gender__c;
                objCourseRegistration.Email_Address__c=objcr.Email_Address__c;
                objCourseRegistration.Job_Title__c=objcr.Job_Title__c;
                objCourseRegistration.Mobile_No__c=objcr.Mobile_No__c;
                objCourseRegistration.Office_No__c=objcr.Office_No__c;
                objCourseRegistration.Nationality__c=objcr.Nationality__c;
                objCourseRegistration.Employment_Status__c=objcr.Employment_Status__c;
                objCourseRegistration.Designation_Level__c=objcr.Designation_Level__c;
                objCourseRegistration.NRIC_Type__c=objcr.NRIC_Type__c;
                objCourseRegistration.NRIC__c=objcr.NRIC__c;
                objCourseRegistration.PDPA_Consent_Clause__c=objcr.PDPA_Consent_Clause__c;
                objCourseRegistration.Marketing_Consent_Clause__c=objcr.Marketing_Consent_Clause__c;
                objCourseRegistration.How_did_you_get_to_know_us__c=objcr.How_did_you_get_to_know_us__c;
                objCourseRegistration.Need_User_Account__c=objcr.Need_User_Account__c;
                objCourseRegistration.Billing_Address_Line_1__c=recCon.Billing_Address_Line_1__c;
                objCourseRegistration.Billing_Address_Line_2__c=recCon.Billing_Address_Line_2__c;
                objCourseRegistration.Billing_Address_Line_3__c=recCon.Billing_Address_Line_3__c;
                objCourseRegistration.Billing_State__c=recCon.Billing_State__c;
                objCourseRegistration.Billing_City__c=recCon.Billing_City__c;
                objCourseRegistration.Billing_Country__c=recCon.Billing_Country__c;
                objCourseRegistration.Billing_Postal_Code__c=recCon.Billing_Postal_Code__c;
                objCourseRegistration.RecordTypeId=Schema.SObjectType.Course_Registration__c.getRecordTypeInfosByDeveloperName().get('Course_Registration').getRecordTypeId();
                InsertCourseRegistration.add(objCourseRegistration);
            }
            system.debug('InsertCourseRegistration ---> '+InsertCourseRegistration);
            if(InsertCourseRegistration.size()>0){
                system.debug('ListContact --> '+InsertCourseRegistration);
                upsert InsertCourseRegistration;
                for(Course_Registration__C cr:InsertCourseRegistration){
                    setCourseRegistrationId.add(cr.Id);
                }
                //insert ListContact;
                /*Database.UpsertResult[] srList = Database.upsert(InsertCourseRegistration, false);
                for (Database.UpsertResult sr : srList) {
                    if (sr.isSuccess()) {
                        System.debug('  account. Account ID: ' + sr.getId());
                        setCourseRegistrationId.add(sr.getId());
                    }
                    else {            
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                    }
                }*/
                
            }
             return setCourseRegistrationId;
        }
        catch (Exception e) {
            throw e;
        }
       
    }
    
    public static set<string> CreateContact(List<Course_Registration__c> lstCourseRegistration,Map<string,string> mapOfExistingLookUpContact, string UserId) {
        Set<string> SetOfContact=New Set<string>();
       // try {
            Contact recCon=getContact(UserId);
            system.debug('B2bUtility AccountId ---> '+recCon.AccountId);
            string sownerAccount=getOwnerId(recCon.AccountId);
            map<string,Contact> mapAccountContact=getmapContact(recCon.AccountId);
            system.debug('mapAccountContact ---> '+mapAccountContact);
            system.debug('B2bUtility ownerAccount ---> '+sownerAccount);
            List<Contact>ListContact=New List<Contact>();        
            for(Course_Registration__c objcr:lstCourseRegistration){
                Contact objContact=New Contact();
                if(mapOfExistingLookUpContact.containsKey(objcr.Contact__c)){
                    objContact.id=mapOfExistingLookUpContact.get(objcr.Contact__c); 
                }
                else{
                    string sKey=objcr.First_Name__c+objcr.Last_Name__c+objcr.Email_Address__c;
                    if(mapAccountContact.containsKey(sKey.trim().toLowerCase())){
                        objContact.id=mapAccountContact.get(sKey.trim().toLowerCase()).Id;
                    }
                }
               // if(!string.isEmpty(UserId))
                 //   objContact.OwnerId=UserId;
                //else
                //********* Added salutation in contact from cr
                objContact.Salutation=objcr.Salutation__c;
                objContact.OwnerId= sownerAccount;
                objContact.AccountId=recCon.AccountId; 
                objContact.firstname =objcr.First_Name__c;
                objContact.lastname  =objcr.Last_Name__c;
                objContact.Date_of_Birth__c=objcr.Date_of_Birth__c;
                objContact.Preferred_Certificate_Name__c=objcr.Preferred_Certificate_Name__c;
                objContact.Gender__c=objcr.Gender__c;
                objContact.Email=objcr.Email_Address__c;
                objContact.MobilePhone=objcr.Mobile_No__c;
                objContact.Mobile_Number__c=objcr.Mobile_No__c;
                objContact.Nationality__c=objcr.Nationality__c;
                objContact.HomePhone=objcr.Home_No__c;
                objContact.Office_No__c=objcr.Office_No__c;
                objContact.Employment_Status__c=objcr.Employment_Status__c;
                objContact.Title=objcr.Job_Title__c;
                objContact.Designation_Level__c=objcr.Designation_Level__c;
                objContact.NRIC_Type__c=objcr.NRIC_Type__c;
                objContact.NRIC__c=objcr.NRIC__c;
                objContact.PDPA_Consent_Clause__c=objcr.PDPA_Consent_Clause__c;
                objContact.Marketing_Consent_Clause__c=objcr.Marketing_Consent_Clause__c;
                objContact.How_did_you_get_to_know_us__c=objcr.How_did_you_get_to_know_us__c;
                objContact.Need_User_Account__c=objcr.Need_User_Account__c;
                objContact.Billing_Address_Line_1__c=recCon.Billing_Address_Line_1__c;
                objContact.Billing_Address_Line_2__c=recCon.Billing_Address_Line_2__c;
                objContact.Billing_Address_Line_3__c=recCon.Billing_Address_Line_3__c;
                objContact.Billing_State__c=recCon.Billing_State__c;
                objContact.Billing_City__c=recCon.Billing_City__c;
                objContact.Billing_Country__c=recCon.Billing_Country__c;
                objContact.Billing_Postal_Code__c=recCon.Billing_Postal_Code__c;
                if(objcr.Registration_Status__c=='New')
                    objContact.Registration_Submitted__c=true;
                objContact.RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('B2B_Learner').getRecordTypeId();
                ListContact.add(objContact);
            }
            system.debug('ListContact --> '+ListContact);
            if(ListContact.size()>0){
                upsert ListContact;
                
                for(Contact str:ListContact){
                    SetOfContact.add(str.id);
                }
                
              //  Database.SaveResult[] srList = Database.insert(ListContact, false);
               /*  Database.UpsertResult[] srList = Database.upsert(ListContact, false);
                for (Database.UpsertResult sr : srList) {
                    if (sr.isSuccess()) {
                        System.debug('  account. Account ID: ' + sr.getId());
                        SetOfContact.add(sr.getId());
                    }
                    else {            
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                    }
                }*/
            }
            return SetOfContact;
       /* }
        catch (Exception e) {
            throw e; 
        }*/
        
        
    }
    public static string CreateMasterCourseRegistration(List<Course_Registration__c> lstCourseRegistration,string courseRunCode,string RegistrationStatus,string UserId,string PromoCode) {
        
        system.debug('***************** CreateMasterCourseRegistration START **************');
        system.debug('lstCourseRegistration--> '+lstCourseRegistration);
        system.debug('Promo_Code__c        --> '+PromoCode);
        system.debug('courseRunCode--> '+courseRunCode);
        system.debug('***************** CreateMasterCourseRegistration END **************');
        string sRecordId='';
        try{
            List<Course_Run__c> courseRuns= getvalcourseRuns(courseRunCode);
            Contact recCon=getContact(UserId);
            List<Contact> ListContact=[Select id,firstname,lastname,Date_of_Birth__c,Secondary_Salutation__c,Salutation,
                                       Preferred_Certificate_Name__c,Gender__c,Email,MobilePhone,Mobile_Number__c,
                                       Nationality__c,HomePhone,Office_No__c,Employment_Status__c,Title,Designation_Level__c,
                                       NRIC_Type__c,NRIC__c from Contact where id=:getContactId(UserId)];
            system.debug('ListContact --->'+ListContact);
            system.debug('courseRuns --->'+courseRuns)	;
            if(ListContact.size()>0){
                Course_Registration__c objCourseRegistration=New Course_Registration__c();
                //objCourseRegistration.Salutation__c='Mr.';
               /* if(ListContact[0].Secondary_Salutation__c.indexOf('.')>0)
                    objCourseRegistration.Salutation__c=string.valueOf(ListContact[0].Secondary_Salutation__c) ;
                else    
                    objCourseRegistration.Salutation__c=string.valueOf(ListContact[0].Secondary_Salutation__c)+'.';*/
                //objCourseRegistration.Salutation__c='Mr.';
                if(string.isNotEmpty(UserId))
                    objCourseRegistration.OwnerId=UserId;
                objCourseRegistration.Salutation__c=string.isNotEmpty(ListContact[0].Salutation)?ListContact[0].Salutation:'';
                objCourseRegistration.Account__c=recCon.AccountId;
                objCourseRegistration.Provider_Access_Start_Date__c=courseRuns[0].Registration_Open_Date__c;
                objCourseRegistration.Provider_Access_End_Date__c=courseRuns[0].Registration_Close_Date__c;
                objCourseRegistration.Course_Run_Id__c=courseRuns[0].Id;
                objCourseRegistration.Registration_Status__c=RegistrationStatus;
                objCourseRegistration.Contact__c=ListContact[0].Id;
                objCourseRegistration.First_Name__c =ListContact[0].firstname;
                objCourseRegistration.Last_Name__c  =ListContact[0].lastname;
                objCourseRegistration.Date_of_Birth__c=ListContact[0].Date_of_Birth__c;
                objCourseRegistration.Preferred_Certificate_Name__c=ListContact[0].Preferred_Certificate_Name__c;
                objCourseRegistration.Gender__c=ListContact[0].Gender__c;
                objCourseRegistration.Email_Address__c=ListContact[0].Email;
                objCourseRegistration.Job_Title__c=ListContact[0].Title;
                objCourseRegistration.Mobile_No__c=ListContact[0].Mobile_Number__c;
                objCourseRegistration.Office_No__c=ListContact[0].Office_No__c;
                objCourseRegistration.Nationality__c=ListContact[0].Nationality__c;
                objCourseRegistration.Employment_Status__c=ListContact[0].Employment_Status__c;
                objCourseRegistration.Designation_Level__c=ListContact[0].Designation_Level__c;
                objCourseRegistration.NRIC_Type__c=ListContact[0].NRIC_Type__c;
                objCourseRegistration.NRIC__c=ListContact[0].NRIC__c;
                objCourseRegistration.PDPA_Consent_Clause__c=lstCourseRegistration[0].PDPA_Consent_Clause__c;
                objCourseRegistration.Marketing_Consent_Clause__c=lstCourseRegistration[0].Marketing_Consent_Clause__c;
                objCourseRegistration.How_did_you_get_to_know_us__c=lstCourseRegistration[0].How_did_you_get_to_know_us__c;
                objCourseRegistration.Billing_Address_Line_1__c=recCon.Billing_Address_Line_1__c;
                objCourseRegistration.Billing_Address_Line_2__c=recCon.Billing_Address_Line_2__c;
                objCourseRegistration.Billing_Address_Line_3__c=recCon.Billing_Address_Line_3__c;
                objCourseRegistration.Billing_State__c=recCon.Billing_State__c;
                objCourseRegistration.Billing_City__c=recCon.Billing_City__c;
                objCourseRegistration.Billing_Country__c=recCon.Billing_Country__c;
                objCourseRegistration.Billing_Postal_Code__c=recCon.Billing_Postal_Code__c;
                if(string.isNotEmpty(PromoCode))
                    objCourseRegistration.Promo_Code__c=PromoCode;
                else
                    objCourseRegistration.Promo_Code__c=null;
                    
                objCourseRegistration.RecordTypeId=Schema.SObjectType.Course_Registration__c.getRecordTypeInfosByDeveloperName().get('Master_Course_Registration').getRecordTypeId();
                insert objCourseRegistration;
                system.debug('objCourseRegistration --> '+objCourseRegistration.Id);
                sRecordId=objCourseRegistration.Id; 

            }
           return sRecordId; 
        }
        catch (Exception e) {
            throw e;
        }
        
    }
    public static Set<Id> CreateCourseRegistration(Set<String> setContactId,List<Course_Registration__c> lstCourseRegistration,string CourseRegistrationId,string courseRunCode,string RegistrationStatus,string UserId) {
        Map<string,Contact> MapOfExistingContact=New Map<string,Contact>();
        Set<Id> setOfcourseRegId=New Set<Id>();
        Contact recCon=getContact(UserId);
        map<string,Contact> mapAccountContact=getmapContact(recCon.AccountId);
        system.debug('setContactId ---> '+setContactId);
        system.debug('lstCourseRegistration ---> '+lstCourseRegistration);
        system.debug('CourseRegistrationId ---> '+CourseRegistrationId);
        try{
            for (Contact con : [SELECT Id, Name,firstname,lastname,Email FROM Contact WHERE Id IN :setContactId]) { 
                MapOfExistingContact.put(string.valueOf(con.Email).toLowercase(),con);
            }
            system.debug('MapOfExistingContact ---> '+MapOfExistingContact);
            List<Course_Run__c> courseRuns= getvalcourseRuns(courseRunCode);
            List<Course_Registration__c>insertListcourseReg=New List<Course_Registration__c>();        
            for(Course_Registration__c objcr:lstCourseRegistration){
                Course_Registration__c objCourseReg=New Course_Registration__c();
                objCourseReg.Salutation__c=objcr.Salutation__c;
                objCourseReg.Parent_Registration__c=CourseRegistrationId;
                objCourseReg.Provider_Access_Start_Date__c=courseRuns[0].Registration_Open_Date__c;
                objCourseReg.Provider_Access_End_Date__c=courseRuns[0].Registration_Close_Date__c;
                objCourseReg.Course_Run_Id__c=courseRuns[0].Id;
                objCourseReg.Registration_Status__c=RegistrationStatus;
               
                string sKey=objcr.First_Name__c+objcr.Last_Name__c+objcr.Email_Address__c;
                if(mapAccountContact.containsKey(sKey.trim().toLowerCase())){
                    objCourseReg.Contact__c=mapAccountContact.get(sKey.trim().toLowerCase()).Id;
                }
                if(MapOfExistingContact.containsKey(string.valueOf(objcr.Email_Address__c).touppercase()))
                  objCourseReg.Contact__c=MapOfExistingContact.get(objcr.Email_Address__c).Id;
                objCourseReg.First_Name__c =objcr.First_Name__c;
                objCourseReg.Last_Name__c  =objcr.Last_Name__c;
                objCourseReg.Date_of_Birth__c=objcr.Date_of_Birth__c;
                objCourseReg.Preferred_Certificate_Name__c=objcr.Preferred_Certificate_Name__c;
                objCourseReg.Gender__c=objcr.Gender__c;
                objCourseReg.Email_Address__c=objcr.Email_Address__c;
                objCourseReg.Job_Title__c=objcr.Job_Title__c;
                objCourseReg.Mobile_No__c=objcr.Mobile_No__c;
                objCourseReg.Office_No__c=objcr.Office_No__c;
                objCourseReg.Nationality__c=objcr.Nationality__c;
                objCourseReg.Employment_Status__c=objcr.Employment_Status__c;
                objCourseReg.Designation_Level__c=objcr.Designation_Level__c;
                objCourseReg.NRIC_Type__c=objcr.NRIC_Type__c;
                objCourseReg.NRIC__c=objcr.NRIC__c;
                objCourseReg.PDPA_Consent_Clause__c=objcr.PDPA_Consent_Clause__c;
                objCourseReg.Marketing_Consent_Clause__c=objcr.Marketing_Consent_Clause__c;
                objCourseReg.How_did_you_get_to_know_us__c=objcr.How_did_you_get_to_know_us__c;
                objCourseReg.Need_User_Account__c=objcr.Need_User_Account__c;
                objCourseReg.Billing_Address_Line_1__c=recCon.Billing_Address_Line_1__c;
                objCourseReg.Billing_Address_Line_2__c=recCon.Billing_Address_Line_2__c;
                objCourseReg.Billing_Address_Line_3__c=recCon.Billing_Address_Line_3__c;
                objCourseReg.Billing_State__c=recCon.Billing_State__c;
                objCourseReg.Billing_City__c=recCon.Billing_City__c;
                objCourseReg.Billing_Country__c=recCon.Billing_Country__c;
                objCourseReg.Billing_Postal_Code__c=recCon.Billing_Postal_Code__c;
                system.debug(' 385 UserId ---> '+UserId);
                if(string.isNotEmpty(UserId)){
                    system.debug('UserId ---> '+UserId);
                    objCourseReg.OwnerId=UserId;
                }
                objCourseReg.RecordTypeId=Schema.SObjectType.Course_Registration__c.getRecordTypeInfosByDeveloperName().get('Course_Registration').getRecordTypeId();
                insertListcourseReg.add(objCourseReg);
            }
            system.debug('courseReg --> '+insertListcourseReg);
            if(insertListcourseReg.size()>0){
                insert insertListcourseReg;
                
                for(Course_Registration__c cr: insertListcourseReg){
                    setOfcourseRegId.add(cr.Id);
                }
                
                /*Database.SaveResult[] srList = Database.insert(insertListcourseReg, false);
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        System.debug('  account. Account ID: ' + sr.getId());
                        setOfcourseRegId.add(sr.getId());
                    }
                    else {            
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                    }
                }*/
            }
            return setOfcourseRegId;
        }
        catch (Exception e) {
            throw e;
        }
        
    }    
    public static string getContactId(string UserId){
        string sWhereCondition='';
        if(string.isNotEmpty(UserId))
            sWhereCondition=UserId;
        else
            sWhereCondition=UserInfo.getUserId();
        string sContactId=[Select ContactId from User  where Id =:sWhereCondition].ContactId;
        return sContactId;
    }
    public static Contact getContact(string UserId){
        system.debug('UserInfo.getUserId ---> '+UserInfo.getUserId());
        string sWhereCondition='';
        if(string.isNotEmpty(UserId))
            sWhereCondition=UserId;
        else
            sWhereCondition=UserInfo.getUserId();
        Contact listContact=[SELECT Id,AccountId,Account.Name,Account.Billing_Address_Line_1__c,Account.Billing_Address_Line_2__c
                ,Account.Billing_Address_Line_3__c,Account.Billing_State__c,Account.Billing_City__c,Account.Billing_Country__c
                ,Account.Billing_Postal_Code__c,Billing_Address_Line_1__c,Billing_Address_Line_2__c,Billing_Address_Line_3__c,Billing_State__c
                ,Billing_City__c,Billing_Country__c,Billing_Postal_Code__c
                FROM Contact
                where Id in(Select ContactId from User  where Id =:sWhereCondition)];
        return listContact;
    }
    public static string getOwnerId(string sAccountId){
        return [SELECT Id, OwnerId FROM Account where id=:sAccountId].OwnerId;   
    }
    public static List<Course_Run__c> getvalcourseRuns(string courseRunCode){
        return [select Id,Name,Course__c,Course_Run_Code__c,Start_Date__c,End_Date__c,Course__r.Name,Course__r.Course_Type__c,
                Course__r.Member_Fee__c,Certificate_Course_Name__c,Course__r.Non_Member_Fee__c,Course__r.Full_Fee__c,CourseRecordType__c,
                Registration_Open_Date__c,Registration_Close_Date__c,Active__c,Capacity__c,course__r.Funding__c,
                Course__r.Provider__c, Course__r.AccountId__c, 
                Course__r.Full_Fee_with_GST__c,Course__r.RMIT_Alumni_Fee__c, Course__r.Course_Title__c, Course__r.Member_Total_Fee__c, Course__r.Non_Member_Total_Fee__c, 
                Course__r.RMIT_Total_Fee__c
                from Course_Run__c where Course_Run_Code__c =: courseRunCode];
    }
    
    Public static void sendRegistrationEmail(liST<string> masterCourseRegIds){
		Id masterRegRecordTypeId =Schema.SObjectType.Course_Registration__c.getRecordTypeInfosByDeveloperName().get('Master_Course_Registration').getRecordTypeId();
        List<Course_Registration__c> masterCourseRegList = [Select id,Course_Run_Owner_Email__c,Course_Run_Id__r.Course__r.Course_Type__c,Course_Run_Id__r.Course__r.Course_Title__c,Course_Run_Id__r.Start_Date__c,Course_Run_Id__r.End_Date__c,account__r.Membership_No__c,account__r.Name,account__r.Billing_Postal_Code__c,account__r.Billing_Country__c,account__r.Billing_Address_Line_1__c,account__r.Billing_Address_Line_2__c,account__r.Billing_Address_Line_3__c,account__r.Billing_Phone_No__c,account__r.Billing_Fax_No__c,Contact__c,Contact__r.Name,Contact__r.Email,Contact__r.Title,Contact__r.MobilePhone,Course_Run_Id__r.Registration_Link__c,(Select id,First_Name__c,Last_Name__c,Salutation__c,Nationality__c,Job_Title__c from Course_Registrations__r where Registration_Status__c='New') from Course_Registration__c where Id=:masterCourseRegIds and Registration_Status__c='New' and recordTypeId=:masterRegRecordTypeId];
        If(masterCourseRegList.size()>0){
            List<OrgWideEmailAddress> orgEmailAddrList = [select id, Address from OrgWideEmailAddress where DisplayName='simdigital_noreply'];
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            for(Course_Registration__c masterCourseReg:masterCourseRegList){
                string subject = 'CONFIDENTIAL SIM SEMINAR('+masterCourseReg.Course_Run_Id__r.Course__r.Course_Type__c+') REGISTRATION : '+masterCourseReg.Course_Run_Id__r.Course__r.Course_Title__c+'';
                
                string htmlBody = '<html><body>';
                
                String logoUrl = PageReference.forResource('SIMPDELogo').getUrl();
				logoUrl = logoUrl.subString(0, logoUrl.indexOf('?'));
                
                htmlBody += '<div align="center" style="margin:0cm;margin-bottom:.0001pt;font-size:16px;font-family:"Times New Roman",serif;">';
                htmlBody += '<table cellspacing="3" style="border: none;width:90.0%;"><tbody><tr><td style="padding:.75pt .75pt .75pt .75pt;">';
                htmlBody += '<p style="margin-right:0cm;margin-left:0cm;font-size:16px;font-family:Times New Roman,serif;margin:0cm;margin-bottom:.0001pt;text-align:right;">';
        		htmlBody += '<img width="106" height="74" src="'+label.Community_URL+logoUrl+'" alt="'+label.Community_URL+logoUrl+'">';
				htmlBody += '</p></td></tr><tr><td style="padding:.75pt .75pt .75pt .75pt;">';
                
                htmlBody += 'Thank you for registering for the programme.<br/>';
                htmlBody += '<p>The registration is confirmed and has been processed in accordance to your agreement of the terms and conditions governing personal data protection, which can be accessed via <a href="http://pd.sim.edu.sg/personal-data-protection-policy">http://pd.sim.edu.sg/personal-data-protection-policy</a>.</p><br/>';
                htmlBody += 'Please take note of the following Registration Policy :<br/><br/>';
                htmlBody += 'Any changes in your registration (withdrawal / deferment) must be in writing via email, with notice period of:';
                htmlBody += '<ul><li>Less than 14 days prior to the commencement of course - 25% of course fee will be levied</li>';
                htmlBody += '<li>NO show on the day of course - 100% of course fee will be charged</li>';
                htmlBody += '<li>We accept replacement at no extra charge.</li></ul><br/>';
                If(masterCourseReg.Course_Run_Id__r.Course__r.Course_Title__c!=null){
                	htmlBody += masterCourseReg.Course_Run_Id__r.Course__r.Course_Title__c+'<br/>';
                }
                If(masterCourseReg.Course_Run_Id__r.Start_Date__c!=null && masterCourseReg.Course_Run_Id__r.End_Date__c!=null){
                    htmlBody += masterCourseReg.Course_Run_Id__r.Start_Date__c.day()+'/'+masterCourseReg.Course_Run_Id__r.Start_Date__c.month()+'/'+masterCourseReg.Course_Run_Id__r.Start_Date__c.Year()+' - '+masterCourseReg.Course_Run_Id__r.End_Date__c.day()+'/'+masterCourseReg.Course_Run_Id__r.End_Date__c.month()+'/'+masterCourseReg.Course_Run_Id__r.End_Date__c.year();
                }
                htmlBody +='<br/><br/>';
                
                If(masterCourseReg.Course_Registrations__r.size()>0){
                    htmlBody += 'Participant Details<br/>';
                    
                    Integer count = 1;
                    //htmlBody += '<table role=“presentation” cellspacing=“0” cellpadding=“0” border=“0” style="border-collapse: collapse;"><tr><td style="border: 1px solid black;">Participant No.</td><td style="border: 1px solid black;">Participant Name</td><td style="border: 1px solid black;">Salutation</td><td style="border: 1px solid black;">Nationality</td><td style="border: 1px solid black;">Job Title</td></tr>';
                    for(Course_Registration__c courseReg:masterCourseReg.Course_Registrations__r){
                        /*
                        htmlBody += '<tr>';
                        htmlBody += '<td style="border: 1px solid black;">'+count+'</td>';
                        htmlBody += '<td style="border: 1px solid black;">'+courseReg.First_Name__c + '' + courseReg.Last_Name__c+'</td>';
                        htmlBody += '<td style="border: 1px solid black;">'+courseReg.Salutation__c+'</td>';
                        htmlBody += '<td style="border: 1px solid black;">'+courseReg.Nationality__c+'</td>';
                        htmlBody += '<td style="border: 1px solid black;">'+courseReg.Job_Title__c+'</td>';
                        htmlBody += '</tr>';*/
                        
                        htmlBody += 'Participant No. : '+count+'<br/>';
                        htmlBody += 'Participant Name : '+courseReg.First_Name__c + '' + courseReg.Last_Name__c +'<br/>';
                        htmlBody += 'Salutation : '+courseReg.Salutation__c+'<br/>';
                        htmlBody += 'Nationality : '+courseReg.Nationality__c+'<br/>';
                        htmlBody += 'Job Title : '+courseReg.Job_Title__c+'<br/><br/><br/>';
                        count++;
                    }
                    //htmlBody += '</table><br/>';
                }
                
                htmlBody += 'Company Details<br/>';
                htmlBody += 'Membership No :'+(masterCourseReg.account__r.Membership_No__c!=null?masterCourseReg.account__r.Membership_No__c:'')+'<br/>';
                htmlBody += 'Registered Company Name :'+(masterCourseReg.account__r.Name!=null?masterCourseReg.account__r.Name:'')+'<br/>';
                
                string address = masterCourseReg.account__r.Billing_Address_Line_1__c;
                If(masterCourseReg.account__r.Billing_Address_Line_2__c!=null && masterCourseReg.account__r.Billing_Address_Line_2__c.trim().length()>0){
                    If(address!=null && address.trim().length()>0){
                        address += ', '+masterCourseReg.account__r.Billing_Address_Line_2__c;
                    }else{
                        address = masterCourseReg.account__r.Billing_Address_Line_2__c;
                    }
                }
                
                If(masterCourseReg.account__r.Billing_Address_Line_3__c!=null && masterCourseReg.account__r.Billing_Address_Line_3__c.trim().length()>0){
                    If(address!=null && address.trim().length()>0){
                        address += ', '+masterCourseReg.account__r.Billing_Address_Line_3__c;
                    }else{
                        address = masterCourseReg.account__r.Billing_Address_Line_3__c;
                    }
                }
                
                htmlBody += 'Address :'+(address!=null?address:'')+'<br/>';
                htmlBody += 'Country :'+(masterCourseReg.account__r.Billing_Country__c!=null?masterCourseReg.account__r.Billing_Country__c:'')+'<br/>';
                htmlBody += 'Postal Code :'+(masterCourseReg.account__r.Billing_Postal_Code__c!=null?masterCourseReg.account__r.Billing_Postal_Code__c:'')+'<br/><br/><br/>';
                
                htmlBody += 'Billing Address : '+(address!=null?address:'')+'<br/>';
                htmlBody += 'Country : '+(masterCourseReg.account__r.Billing_Country__c!=null?masterCourseReg.account__r.Billing_Country__c:'')+'<br/>';
                htmlBody += 'Postal Code : '+(masterCourseReg.account__r.Billing_Postal_Code__c!=null?masterCourseReg.account__r.Billing_Postal_Code__c:'')+'<br/>';
                htmlBody += 'Telephone : '+(masterCourseReg.account__r.Billing_Phone_No__c!=null?masterCourseReg.account__r.Billing_Phone_No__c:'')+'<br/>';
                htmlBody += 'Fax : '+(masterCourseReg.account__r.Billing_Fax_No__c!=null?masterCourseReg.account__r.Billing_Fax_No__c:'')+'<br/>';
                htmlBody += 'Industry : <br/>';
                htmlBody += 'Payment Mode : <br/><br/>';
                
                htmlBody += 'Contact Person Information<br/>';
                htmlBody += 'Name : '+masterCourseReg.Contact__r.Name+'<br/>';
                htmlBody += 'Job Title : '+masterCourseReg.Contact__r.Title+'<br/>';
                htmlBody += 'Telephone : '+masterCourseReg.Contact__r.MobilePhone+'<br/>';
                htmlBody += 'Email Address : '+masterCourseReg.Contact__r.Email+'<br/>';
                htmlBody += 'How did you know about this seminar : <br/><br/><br/>';
                
                htmlBody += '<p>We will write to you again about 2 weeks before programme commencement with more details. For further assistance, please contact '+masterCourseReg.Course_Run_Owner_Email__c+'</p><br/>';
                
                htmlBody += 'To view programme outline and fees, please visit :<br/>';
                htmlBody += '<a href="'+masterCourseReg.Course_Run_Id__r.Registration_Link__c+'">'+masterCourseReg.Course_Run_Id__r.Registration_Link__c+'</a><br/>';
                htmlBody += '<p>For foreign delegates who are sponsored by their companies, GST is not applicable. If payment is made through a local company, GST will apply.</p>';
                htmlBody += '<p>By submitting this registration, I have taken note of the registration policy.</p>';
                htmlBody += '<p>I confirm that the information is correct and I guarantee the payment of programme fee.</p>';
            	
                htmlBody += '</td></tr></table></div>';
                
                htmlBody += '</body></html>';
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSubject(subject);
                If(masterCourseReg.Course_Run_Owner_Email__c!=null){
                    String[] toAddresses = new String[] {masterCourseReg.Course_Run_Owner_Email__c};
                    mail.setToAddresses(toAddresses);
                }
                mail.setTargetObjectId(masterCourseReg.Contact__c);
                mail.setHtmlBody(htmlBody);
                If(orgEmailAddrList.size()>0){
                	mail.setOrgWideEmailAddressId(orgEmailAddrList[0].Id);
                }
                mail.setSaveAsActivity(false);
                emails.add(mail);
            }
            
            If(emails.size()>0){
                List<Messaging.sendEmailResult> sendEmailResults = Messaging.sendEmail(emails);
                system.debug('Errors===='+sendEmailResults[0].getErrors());
            }
        }
    }
    public static contact getContactSearch(string contactId){
         return [select Id,Salutation,Secondary_Salutation__c,firstname,lastname,Date_of_Birth__c,Preferred_Certificate_Name__c,
                           Gender__c,Email,MobilePhone,Mobile_Number__c,Nationality__c,How_did_you_get_to_know_us__c,
                           Office_No__c,Employment_Status__c,Title,Designation_Level__c,NRIC_Type__c,NRIC__c,
                           PDPA_Consent_Clause__c,Marketing_Consent_Clause__c,Need_User_Account__c  from contact where Id=:contactId];
       
    }
    public static Course_Run__c getCourseRunRecord(string courseRunCode) {
        Course_Run__c courseRun = new Course_Run__c();
        if(courseRunCode != null) {
            List<Course_Run__c> courseRuns = [select Id,Name,Course__c,Course_Run_Code__c,Start_Date__c,End_Date__c,Course__r.Name,Course__r.Course_Type__c,
                                              Course__r.Member_Fee__c,Certificate_Course_Name__c,Course__r.Non_Member_Fee__c,Course__r.Full_Fee__c,CourseRecordType__c,
                                              Registration_Open_Date__c,Registration_Close_Date__c,Active__c,Capacity__c,course__r.Funding__c,
                                              Course__r.Provider__c,
                                              (select id,Registration_Status__c,Payment_Status__c,
                                               RecordType.Name from Course_Registrations__r), Course__r.AccountId__c, 
                                              Course__r.Full_Fee_with_GST__c,Course__r.RMIT_Alumni_Fee__c, Course__r.Course_Title__c, Course__r.Member_Total_Fee__c, Course__r.Non_Member_Total_Fee__c, 
                                              Course__r.RMIT_Total_Fee__c,
                                              Course__r.Need_PII__c,Course__r.RecordType.Name
                                              from Course_Run__c where Course_Run_Code__c =: courseRunCode];
            if (courseRuns.size() > 0) {
                courseRun = courseRuns[0].Course__r.AccountId__c == null ? courseRuns[0] : new Course_Run__c();
            }
        }
        return courseRun;
    }
    public static List<Course_Registration__c> checkContactRegistration(string courseRegistrationId) {
        system.debug('courseRegistrationId --> '+courseRegistrationId);
        List<Course_Registration__c> courseReg;
        try {
            courseReg = [SELECT Id,Salutation__c,IsMember__c,First_Name__c,Contact__c,
                         RMIT_Alumni__c,Last_Name__c,Date_of_Birth__c,Parent_Registration__c,
                         Preferred_Certificate_Name__c,Gender__c,Email_Address__c,Mobile_No__c,Nationality__c,
                         Race__c,Office_No__c,Residency_Status__c,Education_Level__c,NRIC_Type__c,NRIC__c,
                         Secondary_Salutation__c,Secondary_Name__c,Secondary_Email_Address__c,Secondary_Mobile__c,Remarks__c,
                         Employment_Status__c,Designation_Level__c,Job_Title__c,How_did_you_get_to_know_us__c,
                         PDPA_Consent_Clause__c,Marketing_Consent_Clause__c,Need_User_Account__c
                         from Course_Registration__c WHERE Parent_Registration__c=:courseRegistrationId AND RecordType.Name!='Master Course Registration'];
            
            system.debug('courseReg --> '+courseReg);
            
            if (courseReg.size() > 0) {
                return courseReg;
            }
        } catch (Exception e) {
            // Application_Log__c appLog = AppLogUtility.createApplicationLog(e.getMessage() + '\n' + e.getStackTraceString() + '\nUser Id: ' + UserInfo.getUserId() + '\nCourse Run Id: ' + courseRunId, 
            // 'CourseRegistrationController', 
            //    'contactId');
            //insert appLog;
            throw e;
        }
        return courseReg;
    }
    public static void UpdateRegistration(string CourseRegistrationMasterId,string RegistrationStatus) {
        Course_Registration__c obj=new Course_Registration__c();
        obj.Id=CourseRegistrationMasterId;
        obj.Registration_Status__c=RegistrationStatus;
        update obj;   
    }
    public static map<string,Contact> getmapContact(string AccountId){
        map<string,Contact> mapOfAccountContact=New map<string,Contact> ();
        for (Contact con  : [SELECT Id,FirstName,LastName,Email,AccountId FROM Contact where AccountId=:AccountId]) {
            string sKey=con.FirstName+con.LastName+con.Email;
            mapOfAccountContact.put(sKey.trim().toLowerCase(),con);    
        }
        return mapOfAccountContact;
    }
    
    
}