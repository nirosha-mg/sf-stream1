({
    getJsonFromUrl : function () {
        var query = location.search.substr(1);
        var result = {};
        query.split("&").forEach(function(part) {
            var item = part.split("=");
            result[item[0]] = decodeURIComponent(item[1]);
        });
        return result;
    }
    , 
    ValidateEmail: function (inputText){
        //alert('Helper call inputText Email ==> '+inputText)
        let mailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        if(inputText.match(mailformat)) 
            return true;
        else  
            return false;
    }
    , ValidateMobile: function (inputText){
        console.log('Helper mobile for only inputText ==> '+inputText)
        var phoneno = /^\d{10}$/;
        if(inputText.match(phoneno)) 
            return true;
        else  
            return false;
    }
    , ValidateDateOfBirth: function (inputText){
        var m = inputText.match(/^(\d\d?)\/(\d\d?)\/(\d{4})$/);
        //new Date(m[3], m[2]-1, m[1])
        var myDate = new Date(m[3], m[2]-1, m[1]); //new Date(inputText);
        // alert('inputText Date --> '+myDate) 
        var today = new Date();
        // alert(today+ '      ValidateDateOfBirth ==>    '+myDate)
        if ( myDate > today ) 
            return false;
        else
            return true;
    },
    ValidateDateformate: function (inputText){
        const regExp = /^(\d\d?)\/(\d\d?)\/(\d{4})$/;
        let isvalidDate;
        let matches = inputText.match(regExp);
        let isValid = matches;
        let maxDate = [0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
        
        if (matches) {
            /*alert('Date --> '+parseInt(matches[1]));
            alert('month --> '+parseInt(matches[2]));
            alert('year --> '+parseInt(matches[3]));*/
            const date = parseInt(matches[1]);
            const month = parseInt(matches[2]);
            const year = parseInt(matches[3]);
            isValid = month <= 12 && month > 0;
            isValid &= date <= maxDate[month] && date > 0;
            const leapYear = (year % 400 == 0)
            || (year % 4 == 0 && year % 100 != 0);
            isValid &= month != 2 || leapYear || date <= 28; 
        }
        if(isValid==1)
            isvalidDate=true;
        else if(isValid==0)
            isvalidDate=false;
        
        return isvalidDate;
    }
    ,ValidateDateformate1: function (inputText){
        // const regExp = /^(\d\d?)\-(\d\d?)\-(\d{4})$/;
        //var m = str.match(/^(\d{1,2})-(\d{1,2})-(\d{4})$/);
        // const regExp = /^\d{2}-\d{2}-\d{4}$/;
        //const regExp = /^(\d{1,2})-(\d{1,2})-(\d{4})$/;
        //  alert('Date ---> '+inputText)
        const regExp = /^(\d\d?)\/(\d\d?)\/(\d{4})$/;
        let isvalidDate;
        let matches = inputText.match(regExp);
        let isValid = matches;
        let maxDate = [0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
        
        if (matches) { // DD/MM/YYYY
            const date  = parseInt(matches[1]);
            const month = parseInt(matches[2]);
            const year = parseInt(matches[3]);
            isValid = month <= 12 && month > 0;
            isValid &= date <= maxDate[month] && date > 0;
            const leapYear = (year % 400 == 0)
            || (year % 4 == 0 && year % 100 != 0);
            isValid &= month != 2 || leapYear || date <= 28; 
        }
        
        if(isValid==1)
            isvalidDate=true;
        else if(isValid==0)
            isvalidDate=false;
        
        return isvalidDate;
        //var m = inputText.match(/^(\d{1,2})-(\d{1,2})-(\d{4})$/);
        /* let isvalidDate;
        let isValid = m;
        const date  = parseInt(m[1]);
        const month = parseInt(m[2]);
        const year = parseInt(m[3]);
         let maxDate = [0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
        
        isValid = month <= 12 && month > 0;
        isValid &= date <= maxDate[month] && date > 0;
        const leapYear = (year % 400 == 0)
        || (year % 4 == 0 && year % 100 != 0);
        isValid &= month != 2 || leapYear || date <= 28;
        if(isValid==1)
            isvalidDate=true;
        else if(isValid==0)
            isvalidDate=false;
        
        return isvalidDate;*/
        //  return (m) ? new Date(m[3], m[2]-1, m[1]) : false;
    }
    ,ValidateNricVal: function (inputText,NricNumber){
        //alert("Nric type --> "+inputText+"  Nric Number  --> "+NricNumber)
        if((inputText.toUpperCase()==("Singapore Citizen/PR").toUpperCase()) || (inputText.toUpperCase()==("FIN").toUpperCase())){
            //  const regExp = /^[STFG]\d{7}[A-Z]$/;
            //  let matches = NricNumber.match(regExp);
            //s alert("Invalid NRIC --> "+matches);
            //  if(!NricNumber.match(/^[STFG]\d{7}[A-Z]$/)){
            //     alert("Invalid NRIC");
            //     return false;
            // } 
            //alert("charAt NRIC "+NricNumber.charAt(0) );
            if(NricNumber.charAt(0)!='undefined'){
                var firstchar = NricNumber.charAt(0);
                var lastchar = NricNumber.charAt(NricNumber.length - 1);
                //  alert("firstchar NRIC "+firstchar );
                //  alert("lastchar NRIC "+ lastchar);
                if(firstchar != 'S' && firstchar != 's' && firstchar != 'F' && firstchar != 'f' &&
                   firstchar != 'T' && firstchar != 't' && firstchar != 'G' && firstchar != 'g') {
                    return false;
                }
                if(!NricNumber.match(/^[STFG]\d{7}[A-Z]$/)){
                    return false;
                }else{  
                    return true;
                } 
            }
            else{
                return false;
            }
        }
    }
    ,ValidateDublicateRecord: function (component,firstName,lastName,Email){
        var CurrentCourseRegistrationList= component.get("v.CourseRegistrationList");
        var iSDublicate=false;
        if(CurrentCourseRegistrationList.length>0){
            for(var i=0;i<CurrentCourseRegistrationList.length;i++){
                
                alert("Exsting First_Name__c  "+CurrentCourseRegistrationList[i].First_Name__c)
                alert("Exsting Last_Name__c  "+CurrentCourseRegistrationList[i].Last_Name__c)
                alert("Exsting Email_Address__c "+CurrentCourseRegistrationList[i].Email_Address__c)
                
                alert("New First_Name__c  "+firstName)
                alert("New Last_Name__c  "+flastName)
                alert("New Email_Address__c "+Email)
                
                if(CurrentCourseRegistrationList[i].First_Name__c===firstName && CurrentCourseRegistrationList[i].Last_Name__c===flastName && CurrentCourseRegistrationList[i].Email_Address__c===Email){
                    iSDublicate=true;
                }  
            }
        }
        alert('record already Exist.. > '+iSDublicate);
        return iSDublicate;
    }
    ,ValidateNricTypeInApex: function(component, event){
        
        var nricTypeField = component.find("NricTypeId");
        var nricField = component.find("NricId");
        if((nricTypeField.get("v.value") == 'FIN' ||
            nricTypeField.get("v.value") == 'Singapore Citizen/PR')){
            if(!$A.util.isEmpty(nricField.get("v.value"))){
                if(!$A.util.isEmpty(nricField.get("v.value")) && 
                   (nricTypeField.get("v.value") == 'FIN' || 
                    nricTypeField.get("v.value") == 'Singapore Citizen/PR')) {
                    var nricval = nricField.get("v.value"); 
                    //alert("nricval --> "+ nricval)
                    if (nricval.length != 9) {
                        component.set("v.NricLengthValidation", true);
                        component.set("v.NricModalOpen", true); 
                        return false;
                    }
                    
                    var firstchar = nricval.charAt(0);
                    var lastchar = nricval.charAt(nricval.length - 1);
                    // alert("lastchar --> "+ lastchar)
                    if(firstchar != 'S' && firstchar != 's' && firstchar != 'F' && firstchar != 'f' &&
                       firstchar != 'T' && firstchar != 't' && firstchar != 'G' && firstchar != 'g') {
                        // alert('First character of NRIC is not Invalid');
                        component.set("v.NricFirstCharValidation", true);
                        component.set("v.NricModalOpen", true);
                        return false;
                    }
                    if(!nricval.match(/^[STFG]\d{7}[A-Z]$/)){
                        component.set("v.NricEndCharValidation", true);
                        component.set("v.NricModalOpen", true);
                        return false;
                    }else{ 
                        var nricField = component.find("NricId");
                        nricField.reportValidity();  
                        return true;
                    } 
                }
            }else{
                component.set("v.NricNotNull", true);
                component.set("v.NricModalOpen", true);
                return false;
            }  
        }else{
            return true; 
        }  
    }
    ,validateFields : function(component, event) {
        
        var salutationField = component.find("salutationId");
        salutationField.reportValidity();
        var fNameField = component.find("fNameId");
        fNameField.reportValidity();
        var lNameField = component.find("lNameId");
        lNameField.reportValidity();
        var genderField = component.find("genderId");
        genderField.reportValidity();
        var emailField = component.find("emailId");
        emailField.reportValidity();
        var nationalityField = component.find("NationalityId");
        nationalityField.reportValidity();
        
    }
    ,ShowToastEvent: function(component, event,Message,title,type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: Message,
            duration:' 50000',
            // key: 'info_alt',
            type: type,
            // mode: 'pester'
        });
        toastEvent.fire();
    },
    UpdateRecord : function(component, event,fields) {
        console.log('in helper 34 fields ---> '+ JSON.stringify(fields.Mobile_No__c)); 
        console.log('35 Submit List ---> '+ component.get("v.IndexPosition"));
        
        var CurrentCourseRegistrationList= component.get("v.CourseRegistrationList");
        var iSDublicate=false;
        if(CurrentCourseRegistrationList.length>0){
            for(var i=0;i<CurrentCourseRegistrationList.length;i++){   
                if(component.get("v.IndexPosition")!=i){
                    // if(CurrentCourseRegistrationList[i].First_Name__c.trim().toUpperCase()===fields[component.get("v.IndexPosition")].First_Name__c.trim().toString().toUpperCase() && CurrentCourseRegistrationList[i].Last_Name__c.trim().toUpperCase()===existingCourseRegistration[component.get("v.IndexPosition")].Last_Name__c.trim().toString().toUpperCase() && CurrentCourseRegistrationList[i].Email_Address__c.trim().toUpperCase()===existingCourseRegistration[component.get("v.IndexPosition")].Email_Address__c.trim().toString().toUpperCase()){
                    if(CurrentCourseRegistrationList[i].First_Name__c.trim().toUpperCase()===fields["First_Name__c"].toString().trim().toUpperCase() && CurrentCourseRegistrationList[i].Last_Name__c.trim().toUpperCase()===fields["Last_Name__c"].toString().trim().toUpperCase() && CurrentCourseRegistrationList[i].Email_Address__c.trim().toUpperCase()===fields["Email_Address__c"].toString().trim().toUpperCase()){
                        
                        iSDublicate=true;
                    }  
                }
            }
        }
        if(!iSDublicate){
            var existingCourseRegistration = component.get("v.CourseRegistrationList");
            existingCourseRegistration[component.get("v.IndexPosition")]=fields;
            existingCourseRegistration[component.get("v.IndexPosition")].Id=component.get("v.EditcourseRegistrationId");
            if(!component.get("v.source")){
                var checkVarmarketing = component.find("checkbox_marketing");
                if(checkVarmarketing.get("v.value")) 
                    existingCourseRegistration[component.get("v.IndexPosition")].Marketing_Consent_Clause__c=true;
            }else{
                if(component.get("v.editMarketing"))
                    existingCourseRegistration[component.get("v.IndexPosition")].Marketing_Consent_Clause__c=true;
                else
                    existingCourseRegistration[component.get("v.IndexPosition")].Marketing_Consent_Clause__c=false;
            }
            existingCourseRegistration[component.get("v.IndexPosition")].PDPA_Consent_Clause__c=true;
            
            if(!$A.util.isEmpty(existingCourseRegistration[component.get("v.IndexPosition")].Need_User_Account__c)){
                if(existingCourseRegistration[component.get("v.IndexPosition")].Need_User_Account__c=="Yes"){
                    existingCourseRegistration[component.get("v.IndexPosition")].isChecked=true; 
                }else{
                    existingCourseRegistration[component.get("v.IndexPosition")].isChecked=false; 
                }
            }
            
            
            component.set("v.CourseRegistrationList",existingCourseRegistration);
            component.set("v.EditcourseRegistrationId","");
            component.set("v.iSEditRecord",false);
            this.ClearFieldValue(component, event);
            this.ShowToastEvent(component, event,$A.get("$Label.c.CourseRegistrationUpdateMsg"),'Success','success'); 
        }else{                            
            this.ShowToastEvent(component, event,$A.get("$Label.c.CourseRegistrationDuplicateMsg"),'Warning','warning' ); 
        }
        
        if(!component.get("v.source")){
            //component.find("checkbox_pdpa").set("v.value",false);
            //component.find("checkbox_marketing").set("v.value",false);
        }
    },
    ClearFieldValue : function(component, event) {
        
        component.find('salutationId').set('v.value',''); 
        component.find('fNameId').set('v.value','');  
        component.find('lNameId').set('v.value','');  
        component.find('prefCertificateId').set('v.value',''); 
        component.find('genderId').set('v.value',''); 
        component.find('emailId').set('v.value',''); 
        component.find('MblenoId').set('v.value',''); 
        component.find('NationalityId').set('v.value',''); 
        component.find('ofceNoId').set('v.value',''); 
        component.find('EmploymentStatus').set('v.value',''); 
        component.find('JobTitle').set('v.value',''); 
        component.find('DesignationLevel').set('v.value',''); 
        component.find('EmploymentStatus').set('v.value',''); 
        component.find('NeedUserAccount').set('v.value',''); 
        component.find('courseRun').set('v.value',''); 
        component.find('ContactRecordId').set('v.value',''); 
        
        
        if(component.get('v.piiSection')){
            component.find('NricTypeId').set('v.value',''); 
            component.find('NricId').set('v.value','');
            component.find('dobId').set('v.value','');
        }
    },
    createLearnerFunding : function(component, event) {
        //// alert('calling createLearnerFunding i helper')
        var buttonLabel = component.get('v.buttonlabel');
        if(buttonLabel == 'Draft'){
            component.set("v.isDraftOpen", true);    
        } 
        if(buttonLabel == 'Submit') {
            component.set("v.isExecutiveModalOpen", true);               
            
        }
        
    },
    SaveRecord : function(component,event) {
        var existingUserEmail=[];
        var emailIndex=[];
        //let indexOfEmail = new Map();
        console.log('on Save '+component.get("v.PromoCodeId"));
        component.set("v.Spinner", true);
        var buttonLabel = component.get('v.buttonlabel');var sRegistrationStatus='';
        var CourseRegistration = component.get("v.CourseRegistrationList");
        for(var i=0;i<CourseRegistration.length;i++){
            if(buttonLabel == 'Draft') {
                CourseRegistration[i].Registration_Status__c='Draft';sRegistrationStatus='Draft';
            } if(buttonLabel == 'Submit') {
                CourseRegistration[i].Registration_Status__c='New';sRegistrationStatus='New';                
            }
            CourseRegistration[i].Sync_Learner_s_Record__c = true;
            CourseRegistration[i].Course_Run_Id__c = component.get("v.courseRunRecord.Id");
            var accountRecordtype = component.get("v.contactRecord.Account.RecordType.DeveloperName");        
            if(accountRecordtype == 'B2B_Account') {
                CourseRegistration[i].Company_UEN_No__c = component.get("v.contactRecord.Account.UEN_No__c"); 
            }  
            if(!$A.util.isEmpty(CourseRegistration[i].isChecked)){
                if(CourseRegistration[i].isChecked){
                    CourseRegistration[i].Need_User_Account__c="Yes";
                    existingUserEmail.push(CourseRegistration[i].Email_Address__c.trim().toLowerCase());
                    emailIndex.push((i+1));
                    //indexOfEmail.set(CourseRegistration[i].Email_Address__c,(i+1));
                }
                else
                    CourseRegistration[i].Need_User_Account__c="No";
            }
            
            component.set("v.CourseRegistrationList",CourseRegistration);
        } 
        
        console.log('existingUserEmail --> '+existingUserEmail);
        console.log('emailIndex --> '+JSON.stringify(emailIndex));
        
        if(!$A.util.isEmpty(existingUserEmail)){
            var checkUserEmail = component.get('c.checkUserWithContact');
            checkUserEmail.setParams({ 
                "emailList": existingUserEmail
            });
            checkUserEmail.setCallback(this, function(response) {
                if(response.getState() === "SUCCESS") {
                    console.log('emailIndex Response --> '+JSON.stringify(response.getReturnValue()));
                    var sMsgEmail='';
                    if(!$A.util.isEmpty(response.getReturnValue())){
                        for(var i=0;i< response.getReturnValue().length;i++){
                            var emailIndexOf=existingUserEmail.indexOf(response.getReturnValue()[i].trim().toLowerCase());
                            if(emailIndexOf!=-1)
                                sMsgEmail+='Row '+emailIndex[emailIndexOf]+', User with email '+response.getReturnValue()[i]+' already present \n';                        
                        }
                        if(!$A.util.isEmpty(sMsgEmail)){
                            component.set("v.Spinner", false);
                            this.ShowToastEvent(component, event,sMsgEmail,'Error','error');
                        }
                    }else{
                        
                        var action = component.get("c.SaveCourseRegistration");
                        action.setParams({ 
                            "lstCourseRegistration" : JSON.stringify(component.get("v.CourseRegistrationList")), 
                            "courseRunCode":  component.get('v.courseRunCode'),
                            "RegistrationStatus":sRegistrationStatus,
                            "lookupContactId":component.get("v.lookupContactId"),
                            "UserId":  $A.util.isEmpty(component.get('v.SelectedUserId'))?'':component.get('v.SelectedUserId'),
                            "PromoCode": $A.util.isEmpty(component.get('v.PromoCodeId'))?null:component.get('v.PromoCodeId')
                        });
                        action.setCallback(this, function(response) {
                            var state = response.getState();
                            console.log('state --> '+state)
                            if (response.getState() == "SUCCESS") {
                                var courseRegId = response.getReturnValue();
                                component.set("v.Spinner", false);
                                component.set("v.courseRegistrationId",courseRegId.courseRegId);
                                component.set("v.listcourseRegId",courseRegId.setOfcourseReg);
                                if(buttonLabel == 'Draft') {
                                    //component.set("v.isDraftOpen", true);
                                    var courseRunCode=component.get("v.courseRunCode");
                                    if(!component.get("v.source")){
                                        var urlEvent = $A.get("e.force:navigateToURL");
                                        urlEvent.setParams({
                                            "url": "/s/bulk-registration/?courseruncode="+courseRunCode
                                        });
                                        urlEvent.fire();
                                    }
                                    else{
                                        //alert("navigation is calling in Save")
                                        component.set("v.SaveAsDraftPopUpForPE", true);
                                    } 
                                } 
                                if(buttonLabel == 'Submit') {      
                                    var provider = component.get("v.courseRunRecord.Course__r.Provider__c");
                                    var courseRecordType = component.get("v.courseRunRecord.CourseRecordType__c");
                                    /* alert(" on save as Draft courseRecordType --> "+courseRecordType);
                    alert(" on save as Draft memberCheckbox --> "+component.get("v.memberCheckbox"));
                    alert(" on save as Draft provider --> "+provider);*/
                                    if (courseRecordType == 'Funded_Course') {
                                        if(!component.get("v.source"))
                                            component.set("v.isExecutiveModalOpen", true); 
                                        else{
                                            component.set("v.SubmitPopUpForPE", true);	 
                                        }
                                    }
                                    else {
                                        if (!component.get("v.memberCheckbox") && provider == 'SIM') {
                                            if(!component.get("v.source"))
                                                component.set("v.PaymentModalOpen", true);  
                                            else{
                                                component.set("v.SubmitPopUpForPE", true);	 
                                            }
                                        }
                                        else {
                                            if(!component.get("v.source"))
                                                component.set("v.isExecutiveModalOpen", true); 
                                            else{
                                                component.set("v.SubmitPopUpForPE", true);	 
                                            }
                                        }
                                    }
                                }
                            }else if (state === "ERROR") {
                                var errors = response.getError();
                                if (errors) {
                                    component.set("v.Spinner",false);
                                    if (errors[0] && errors[0].message) {
                                        console.log("Error message: " + 
                                                    errors[0].message);
                                        //alert("Error --> "+errors[0].message);
                                        this.ShowToastEvent(component, event,"Error occured! Please contact the system admin.",'Error','error');
                                    }
                                } else {
                                    console.log("Unknown error");
                                }
                            }
                        });
                        $A.enqueueAction(action);
                        
                    }    
                }
            });
            $A.enqueueAction(checkUserEmail); 
        }else{
            console.log("Before save list "+JSON.stringify(component.get("v.CourseRegistrationList")));
            var action = component.get("c.SaveCourseRegistration");
            action.setParams({ 
                "lstCourseRegistration" : JSON.stringify(component.get("v.CourseRegistrationList")), 
                "courseRunCode":  component.get('v.courseRunCode'),
                "RegistrationStatus":sRegistrationStatus,
                "lookupContactId":component.get("v.lookupContactId"),
                "UserId":  $A.util.isEmpty(component.get('v.SelectedUserId'))?'':component.get('v.SelectedUserId'),
           		"PromoCode":$A.util.isEmpty(component.get('v.PromoCodeId'))?null:component.get('v.PromoCodeId')
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('state --> '+state)
                if (response.getState() == "SUCCESS") {
                    var courseRegId = response.getReturnValue();
                    component.set("v.Spinner", false);
                    component.set("v.courseRegistrationId",courseRegId.courseRegId);
                    component.set("v.listcourseRegId",courseRegId.setOfcourseReg);
                    if(buttonLabel == 'Draft') {
                        //component.set("v.isDraftOpen", true);
                        var courseRunCode=component.get("v.courseRunCode");
                        if(!component.get("v.source")){
                            var urlEvent = $A.get("e.force:navigateToURL");
                            urlEvent.setParams({
                                "url": "/s/bulk-registration/?courseruncode="+courseRunCode
                            });
                            urlEvent.fire();
                        }
                        else{
                            //alert("navigation is calling in Save")
                            component.set("v.SaveAsDraftPopUpForPE", true);
                        } 
                    } 
                    if(buttonLabel == 'Submit') {      
                        var provider = component.get("v.courseRunRecord.Course__r.Provider__c");
                        var courseRecordType = component.get("v.courseRunRecord.CourseRecordType__c");
                        /* alert(" on save as Draft courseRecordType --> "+courseRecordType);
                    alert(" on save as Draft memberCheckbox --> "+component.get("v.memberCheckbox"));
                    alert(" on save as Draft provider --> "+provider);*/
                        if (courseRecordType == 'Funded_Course') {
                            if(!component.get("v.source"))
                                component.set("v.isExecutiveModalOpen", true); 
                            else{
                                component.set("v.SubmitPopUpForPE", true);	 
                            }
                        }
                        else {
                            if (!component.get("v.memberCheckbox") && provider == 'SIM') {
                                if(!component.get("v.source"))
                                    component.set("v.PaymentModalOpen", true);  
                                else{
                                    component.set("v.SubmitPopUpForPE", true);	 
                                }
                            }
                            else {
                                if(!component.get("v.source"))
                                    component.set("v.isExecutiveModalOpen", true); 
                                else{
                                    component.set("v.SubmitPopUpForPE", true);	 
                                }
                            }
                        }
                    }
                }else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        component.set("v.Spinner",false);
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                            //alert("Error --> "+errors[0].message);
                            this.ShowToastEvent(component, event,"Error occured! Please contact the system admin.",'Error','error');
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        }
        
        
    },
    UpdateCourseRegistrationRecord : function(component,event) {
        
        var existingUserEmail=[];
        var emailIndex=[];
        let indexOfEmail = new Map();
        
        console.log('on update '+component.get("v.PromoCodeId"));
        
        component.set("v.Spinner", true);
       // console.log("update list --> "+JSON.stringify(component.get("v.CourseRegistrationList")))
       // console.log("CourseRegistrationMasterId list --> "+component.get("v.CourseRegistrationMasterId"))
        var buttonLabel = component.get('v.buttonlabel');var sRegistrationStatus='';
        var CourseRegistration = component.get("v.CourseRegistrationList");
        for(var i=0;i<CourseRegistration.length;i++){
            if(buttonLabel == 'Draft') {
                CourseRegistration[i].Registration_Status__c='Draft';sRegistrationStatus='Draft'; 
            } if(buttonLabel == 'Submit') {
                CourseRegistration[i].Registration_Status__c='New';sRegistrationStatus='New'; 
            }
            CourseRegistration[i].Sync_Learner_s_Record__c = true;
            var accountRecordtype = component.get("v.contactRecord.Account.RecordType.DeveloperName");        
            if(accountRecordtype == 'B2B_Account') {
                CourseRegistration[i].Company_UEN_No__c = component.get("v.contactRecord.Account.UEN_No__c"); 
            }  
            if(!$A.util.isEmpty(CourseRegistration[i].isChecked)){
                if(CourseRegistration[i].isChecked){
                    CourseRegistration[i].Need_User_Account__c="Yes";
                    existingUserEmail.push(CourseRegistration[i].Email_Address__c.trim().toLowerCase());
                    emailIndex.push((i+1));
                }
                else
                    CourseRegistration[i].Need_User_Account__c="No";
            }
            component.set("v.CourseRegistrationList",CourseRegistration);
        } 
        
        //console.log('lIST TO UPDATE --> '+JSON.stringify(component.get("v.CourseRegistrationList")));
       // console.log('CourseRegistrationMasterId --> '+component.get("v.CourseRegistrationMasterId"));
       // console.log('RegistrationStatus --> '+sRegistrationStatus);
       // console.log('lookupContactId --> '+component.get("v.lookupContactId"));
       // console.log('UserId --> '+component.get("v.SelectedUserId"));
       // console.log('courseRunCode --> '+component.get("v.courseRunCode"));
        
        if(!$A.util.isEmpty(existingUserEmail)){
            var checkUserEmail = component.get('c.checkUserWithContact');
            checkUserEmail.setParams({ 
                "emailList": existingUserEmail
            });
            checkUserEmail.setCallback(this, function(response) {
                if(response.getState() === "SUCCESS") {
                    var sMsgEmail='';
                    if(!$A.util.isEmpty(response.getReturnValue())){
                        for(var i=0;i< response.getReturnValue().length;i++){
                            var emailIndexOf=existingUserEmail.indexOf(response.getReturnValue()[i].trim().toLowerCase());
                            if(emailIndexOf!=-1)
                                sMsgEmail+='Row '+emailIndex[emailIndexOf]+', User with email '+response.getReturnValue()[i]+' already present \n';                        
                        }
                        if(!$A.util.isEmpty(sMsgEmail)){
                            component.set("v.Spinner", false);
                            this.ShowToastEvent(component, event,sMsgEmail,'Error','error');
                        }
                    }else{
                        console.log(" 625 in else PromoCodeId "+$A.util.isEmpty(component.get('v.PromoCodeId'))?null:component.get('v.PromoCodeId'));
                        var action = component.get("c.UpdateCourseRegistration");
                        action.setParams({ 
                            "lstCourseRegistration" : JSON.stringify(component.get("v.CourseRegistrationList")), 
                            "CourseRegistrationMasterId":  component.get("v.CourseRegistrationMasterId"),
                            "RegistrationStatus":sRegistrationStatus,
                            "lookupContactId":component.get("v.lookupContactId"),
                            "UserId":component.get("v.SelectedUserId"),
                            "courseRunCode":component.get('v.courseRunCode'),
                            "PromoCode":$A.util.isEmpty(component.get('v.PromoCodeId'))?"":component.get('v.PromoCodeId')
                        });
                        action.setCallback(this, function(response) {
                            var state = response.getState();
                            // alert('buttonLabel ---> '+buttonLabel)
                            if (response.getState() == "SUCCESS") {
                                var courseRegId = response.getReturnValue();
                                console.log('177 courseRegId --> '+courseRegId);
                                //component.set("v.courseRegistrationId",courseRegId);
                                component.set("v.courseRegistrationId",courseRegId.courseRegId);
                                component.set("v.listcourseRegId",courseRegId.setOfcourseReg);
                                component.set("v.Spinner", false);
                                if(buttonLabel == 'Draft') {
                                    //component.set("v.isDraftOpen", true);
                                    var courseRunCode=component.get("v.courseRunCode");
                                    if(!component.get("v.source")){
                                        var urlEvent = $A.get("e.force:navigateToURL");
                                        urlEvent.setParams({
                                            "url": "/s/bulk-registration/?courseruncode="+courseRunCode
                                        });
                                        urlEvent.fire();
                                    }else{
                                        //  alert("navigation is calling in update");
                                        component.set("v.SaveAsDraftPopUpForPE", true);
                                    }
                                    
                                } if(buttonLabel == 'Submit') {      
                                    var provider = component.get("v.courseRunRecord.Course__r.Provider__c");
                                    var courseRecordType = component.get("v.courseRunRecord.CourseRecordType__c");
                                    // alert("189 provider ---> "+provider+  "  courseRecordType --> "+courseRecordType +"   component.get ---> "+component.get("v.memberCheckbox"));
                                    if (courseRecordType == 'Funded_Course') {
                                        component.set("v.isExecutiveModalOpen", true); 
                                    }
                                    else {
                                        if (!component.get("v.memberCheckbox") && provider == 'SIM') {
                                            if(!component.get("v.source"))
                                                component.set("v.PaymentModalOpen", true);  
                                            else{
                                                component.set("v.SubmitPopUpForPE", true);	 
                                            }
                                        }
                                        else {
                                            if(!component.get("v.source"))
                                                component.set("v.isExecutiveModalOpen", true);  
                                            else{
                                                component.set("v.SubmitPopUpForPE", true);	 
                                            }
                                        }
                                    }
                                }
                            }else if (state === "ERROR") {
                                component.set("v.Spinner",false);
                                var errors = response.getError();
                                if (errors) {
                                    if (errors[0] && errors[0].message) {
                                        console.log("Error message: " + 
                                                    errors[0].message);
                                        this.ShowToastEvent(component, event,"Error occured! Please contact the system admin.",'Error','error');
                                    }
                                } else {
                                    console.log("Unknown error");
                                }
                            }
                        });
                        $A.enqueueAction(action);
                        
                    }    
                }
            });
            $A.enqueueAction(checkUserEmail); 
        }
        else{
            
            console.log(" 708 in else PromoCodeId "+component.get('v.PromoCodeId'));
            var action = component.get("c.UpdateCourseRegistration");
            action.setParams({ 
                "lstCourseRegistration" : JSON.stringify(component.get("v.CourseRegistrationList")), 
                "CourseRegistrationMasterId":  component.get("v.CourseRegistrationMasterId"),
                "RegistrationStatus":sRegistrationStatus,
                "lookupContactId":component.get("v.lookupContactId"),
                "UserId":component.get("v.SelectedUserId"),
                "courseRunCode":component.get('v.courseRunCode'),
                "PromoCode":component.get('v.PromoCodeId')
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                // alert('buttonLabel ---> '+buttonLabel)
                if (response.getState() == "SUCCESS") {
                    var courseRegId = response.getReturnValue();
                    console.log('177 courseRegId --> '+courseRegId);
                    //component.set("v.courseRegistrationId",courseRegId);
                    component.set("v.courseRegistrationId",courseRegId.courseRegId);
                    component.set("v.listcourseRegId",courseRegId.setOfcourseReg);
                    component.set("v.Spinner", false);
                    if(buttonLabel == 'Draft') {
                        //component.set("v.isDraftOpen", true);
                        var courseRunCode=component.get("v.courseRunCode");
                        if(!component.get("v.source")){
                            var urlEvent = $A.get("e.force:navigateToURL");
                            urlEvent.setParams({
                                "url": "/s/bulk-registration/?courseruncode="+courseRunCode
                            });
                            urlEvent.fire();
                        }else{
                            //  alert("navigation is calling in update");
                            component.set("v.SaveAsDraftPopUpForPE", true);
                        }
                        
                    } if(buttonLabel == 'Submit') {      
                        var provider = component.get("v.courseRunRecord.Course__r.Provider__c");
                        var courseRecordType = component.get("v.courseRunRecord.CourseRecordType__c");
                        // alert("189 provider ---> "+provider+  "  courseRecordType --> "+courseRecordType +"   component.get ---> "+component.get("v.memberCheckbox"));
                        if (courseRecordType == 'Funded_Course') {
                            component.set("v.isExecutiveModalOpen", true); 
                        }
                        else {
                            if (!component.get("v.memberCheckbox") && provider == 'SIM') {
                                if(!component.get("v.source"))
                                    component.set("v.PaymentModalOpen", true);  
                                else{
                                    component.set("v.SubmitPopUpForPE", true);	 
                                }
                            }
                            else {
                                if(!component.get("v.source"))
                                    component.set("v.isExecutiveModalOpen", true);  
                                else{
                                    component.set("v.SubmitPopUpForPE", true);	 
                                }
                            }
                        }
                    }
                }else if (state === "ERROR") {
                    component.set("v.Spinner",false);
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                            this.ShowToastEvent(component, event,"Error occured! Please contact the system admin.",'Error','error');
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
            
        }
        
        
    },
    DeleteRecord: function(component,event) {
        component.set("v.Spinner", true);
        console.log("DeleteCourseRegistrationList ---> "+component.get("v.DeleteCourseRegistrationList"))
        var action = component.get("c.DeleteCourseRegistration");
        action.setParams({ 
            "lstDeleteCourseRegistration" : component.get("v.DeleteCourseRegistrationList")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.Spinner", false);
            ////  alert("response ---> "+response.getState())
            if (response.getState() == "SUCCESS") {
                console.log("SUCCESS message: " +response.getState());
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        this.ShowToastEvent(component, event,"Error occured! Please contact the system admin.",'Error','error');
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);  
    },
    getIdentificationType: function(component, event, helper) {
        var getIdentificationType = component.get('c.getIdentificationType');
        getIdentificationType.setParams({});
        let myMap = new Map();
        getIdentificationType.setCallback(this, function(response) {
            console.log('response.getState() ---> '+response.getState());
            if(response.getState() === "SUCCESS") {
                if(response.getReturnValue().length>0){
                    for(var i=0;i< response.getReturnValue().length;i++){
                        myMap.set(response.getReturnValue()[i], response.getReturnValue()[i])
                    }
                    component.set("v.mapIdentificationType" , myMap);
                }
            }else if(response.getState() == "ERROR"){
                var errors = response.getError();    
                console.log(errors[0].message);
            }
        }); 
        $A.enqueueAction(getIdentificationType);    
    },
    getNationality: function(component, event, helper) {
        var getNationality = component.get('c.getNationality');
        let myMap = new Map();
        getNationality.setParams({});
        getNationality.setCallback(this, function(response) {
            console.log('response.getState() ---> '+response.getState());
            if(response.getState() === "SUCCESS") {
                if(response.getReturnValue().length>0){
                    for(var i=0;i< response.getReturnValue().length;i++){
                        myMap.set(response.getReturnValue()[i], response.getReturnValue()[i])
                    }
                    component.set("v.mapnationality" , myMap);
                }
            }else if(response.getState() == "ERROR"){
                var errors = response.getError();    
                console.log(errors[0].message);
            }
        }); 
        $A.enqueueAction(getNationality);    
    },
    getEmploymentStatus: function(component, event, helper) {
        var getEmploymentStatus = component.get('c.getEmploymentStatus');
        let myMap = new Map();
        getEmploymentStatus.setParams({});
        getEmploymentStatus.setCallback(this, function(response) {
            console.log('response.getState() ---> '+response.getState());
            if(response.getState() === "SUCCESS") {
                if(response.getReturnValue().length>0){
                    for(var i=0;i< response.getReturnValue().length;i++){
                        myMap.set(response.getReturnValue()[i], response.getReturnValue()[i])
                    }
                    component.set("v.mapemploymentStatus" , myMap);
                }            
            }else if(response.getState() == "ERROR"){
                var errors = response.getError();    
                console.log(errors[0].message);
            }
        }); 
        $A.enqueueAction(getEmploymentStatus);    
    },
    getDesignationLevel: function(component, event, helper) {
        var getDesignationLevel = component.get('c.getDesignationLevel');
        let myMap = new Map();
        getDesignationLevel.setParams({});
        getDesignationLevel.setCallback(this, function(response) {
            console.log('response.getState() ---> '+response.getState());
            if(response.getState() === "SUCCESS") {
                if(response.getReturnValue().length>0){
                    for(var i=0;i< response.getReturnValue().length;i++){
                        myMap.set(response.getReturnValue()[i], response.getReturnValue()[i])
                    }
                    component.set("v.mapdesignationLevel" , myMap);
                } 
            }else if(response.getState() == "ERROR"){
                var errors = response.getError();    
                console.log(errors[0].message);
            }
        }); 
        $A.enqueueAction(getDesignationLevel);    
    },
    getSelectedContactRecord: function(component,event){
        //'0031s00000P4cDAAAZ'
        var getContactRecord = component.get("c.getContactSearchRecord");
        getContactRecord.setParams({ 
            "contactId": component.get('v.searchContactId')
        });
        getContactRecord.setCallback(this, function(response) {
            // alert("getContactRecord getState --->  "+response.getState());
            if (response.getState() == "SUCCESS") {   
                //alert("getContactRecord getState --->  "+JSON.stringify(response.getReturnValue()));
                var sResponse=response.getReturnValue();
                console.log("sResponse ---> "+JSON.stringify(sResponse));
                // alert("getContactRecord Salutation__c --->  "+sResponse.Secondary_Salutation__c + " ssresult --> "+ssresult);
                
                // alert("getContactRecord Contact__c --->  "+sResponse.Id);
                // alert("getContactRecord lastname --->  "+sResponse.LastName);
                // alert("getContactRecord Date_of_Birth__c --->  "+sResponse.Date_of_Birth__c);
                var CourseRegistrationRecord = {
                    Salutation__c: sResponse.Salutation,
                    Contact__c:sResponse.Id,
                    First_Name__c:sResponse.FirstName,
                    Last_Name__c: sResponse.LastName,
                    Date_of_Birth__c:sResponse.Date_of_Birth__c,
                    Preferred_Certificate_Name__c: sResponse.Preferred_Certificate_Name__c,
                    Gender__c:  sResponse.Gender__c,
                    Email_Address__c:  sResponse.Email,
                    Mobile_No__c: sResponse.MobilePhone,
                    NRIC_Type__c:  sResponse.NRIC_Type__c,
                    NRIC__c:  sResponse.NRIC__c,
                    Nationality__c:  sResponse.Nationality__c,
                    Office_No__c:  sResponse.Mobile_Number__c,
                    Employment_Status__c:sResponse.Employment_Status__c,
                    Job_Title__c:  sResponse.Title,
                    Designation_Level__c:  sResponse.Designation_Level__c,
                    PDPA_Consent_Clause__c: sResponse.PDPA_Consent_Clause__c,
                    Marketing_Consent_Clause__c: sResponse.Marketing_Consent_Clause__c,
                }; 
                var lookupContactList = component.get("v.lookupContactId");
                lookupContactList.push(sResponse.Id);
                component.set("v.lookupContactId", lookupContactList);
                component.set("v.EditCourseRegistrationList",CourseRegistrationRecord);
                console.log("on lookup--> "+JSON.stringify(component.get("v.EditCourseRegistrationList")))
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                        helper.ShowToastEvent(component, event,errors[0].message,'Error','error');
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(getContactRecord);
    },
    getContactAction: function(component,event){
        var getContactAction = component.get('c.getContactRecord');
        getContactAction.setCallback(this, function(response) { 
            console.log(' 945 getState  --> '+response.getState())
            if(response.getState() === "SUCCESS") { 
                console.log(' 947 varContactInfowrapper  --> '+response.getReturnValue())
                if(!$A.util.isEmpty(response.getReturnValue())){
                    var varContactInfowrapper =  response.getReturnValue();                    
                    component.set("v.contactRecord", varContactInfowrapper.objContact);     
                    //contactInfowrapper 
                    component.set("v.contactInfowrapper", response.getReturnValue());              
                    var contactRecord = component.get("v.contactRecord");
                    // alert(" is memberCheckbox ---> "+contactRecord.Account.Membership_Active__c);
                    // alert('Account id --> '+contactRecord.Account.Id)
                    component.set("v.accid",contactRecord.Account.Id);
                    component.set("v.memberCheckbox", contactRecord.Account.Membership_Active__c); //Changed to if Membership No is populated  
                }
            }
        }); 
        $A.enqueueAction(getContactAction);   
    },
    getDraftRegistrationsPE  : function(component, event,courseRunId) {
        
        var checkRegistration = component.get('c.getDraftRegistrations');
        checkRegistration.setParams({ 
            "courseRunid": courseRunId,
            "ContactId": $A.util.isEmpty(component.get('v.searchContactPE'))?'':component.get('v.searchContactPE')
        });
        checkRegistration.setCallback(this, function(response) {
            console.log('  In getDraftRegistrations '+response.getState());
            console.log(response.getReturnValue())
            if(response.getState() === "SUCCESS") {
                var courseRegId = response.getReturnValue();
                console.log('688 courseRegId --> '+courseRegId)
                if (!$A.util.isEmpty(courseRegId)) {
                    component.set("v.CourseRegistrationMasterId",courseRegId[0].Parent_Registration__c);
                    component.set("v.courseRegistrationId",courseRegId[0].Parent_Registration__c);
                    component.set("v.editPdpa",courseRegId[0].PDPA_Consent_Clause__c);
                    component.set("v.editMarketing",courseRegId[0].Marketing_Consent_Clause__c);
                    // component.find("PromoCode").set("v.value",courseRegId[0].Promo_Code__r.Name);
                    
                    
                    var icountNeedUsrAcc=0;
                    var updatedcourseReg = [];
                    // var existingCourseRegistration = component.get("v.CourseRegistrationList");
                    for (var i = 0; i < courseRegId.length; i++) {
                        if(!$A.util.isEmpty(courseRegId[i].Need_User_Account__c)){
                            if(courseRegId[i].Need_User_Account__c=="Yes"){
                                courseRegId[i].isChecked=true;
                                icountNeedUsrAcc=icountNeedUsrAcc+1;
                            }
                            else
                                courseRegId[i].isChecked=false;
                        }
                        updatedcourseReg.push(courseRegId[i]);
                    }
                    if(icountNeedUsrAcc==courseRegId.length){
                        //alert(' 118 icountNeedUsrAcc --> '+icountNeedUsrAcc + ' courseRegId.length -> '+courseRegId.length)
                        
                    }
                    component.set("v.CourseRegistrationList", updatedcourseReg);
                    
                    // component.set("v.CourseRegistrationList", courseRegId);
                    if(!component.get("v.isOpen")){
                        var currentTab = component.get("v.selTabId");        
                        component.set("v.selTabId" , 'particulars');
                        console.log("Promo code --> "+courseRegId[0].Parent_Registration__r.Promo_Code__r.Name)
                        if(!$A.util.isEmpty(courseRegId[0].Parent_Registration__r.Promo_Code__r.Name)){
                            var sPromoCode= courseRegId[0].Parent_Registration__r.Promo_Code__r.Name;
                            component.set("v.PromoCodeValue",sPromoCode);
                            if(!$A.util.isEmpty(sPromoCode)){
                               this.getPromoCode(component, event,sPromoCode);
                            }
                        }
                    }  
                }
            }
            else {
                component.set("v.CourseRegistrationMasterId","");
                component.set("v.courseRegistrationId","");
                component.set("v.isOpen", false);
                component.set("v.isDeclareClose", true);
                
            }
        });
        $A.enqueueAction(checkRegistration); 
    },
    getDuplicateUser: function(component, event,listemail) {
        
        var checkUserEmail = component.get('c.checkUserWithContact');
        checkUserEmail.setParams({ 
            "emailList": listemail
        });
        checkUserEmail.setCallback(this, function(response) {
            console.log('  In getDraftRegistrations '+response.getState());
            console.log(JSON.stringify(response.getReturnValue()))
            if(response.getState() === "SUCCESS") {
                var sMsgEmail='';
                if(!$A.util.isEmpty(response.getReturnValue())){
                    for(var i=0;i< response.getReturnValue().length;i++){
                        sMsgEmail+=response.getReturnValue()[i]+'\n';    
                    }
                    if(!$A.util.isEmpty(sMsgEmail)){
                        component.set("v.EmailError",true);
                    }else{
                        component.set("v.EmailError",false);
                    } 
                }else{
                    component.set("v.EmailError",false);
                }  
            }
        });
        $A.enqueueAction(checkUserEmail); 
    },
    createModal : function(component, title, message, confirmHandler, showCancel) {
        //alert('in create model ')
        $A.createComponent(
            "c:Modal_Confirmation",
            {
                "title": title,
                "message": message,
                "confirm": component.getReference(confirmHandler),
                "showCancel": showCancel
            },
            function(modalWindow, status, errorMessage){
                // alert('in create model '+status+ '  modalWindow --> '+modalWindow)
                if (status === "SUCCESS") {
                    var modalBody = component.set("v.modalBody", modalWindow);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                    else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                        // Show error message
                    }
            }
        );
    },
    getPromoCode: function(component,event,promocode){
        console.log("courseRunStartDate --> "+component.get("v.courseRunStartDate"))
        console.log("courseId --> "+component.get("v.courseId"))
        console.log("courseRunStartDate --> "+component.get("v.courseRunStartDate"))
        console.log("SelectedUserId --> "+component.get("v.SelectedUserId"))
        
        var getPromocodeRecord = component.get('c.getPromoCode');
        getPromocodeRecord.setParams({promocode: promocode,courseId:component.get("v.courseId"),registrationStartDate:component.get("v.courseRunStartDate"),UserId:component.get("v.SelectedUserId"),});
        getPromocodeRecord.setCallback(this, function(response) {      
            console.log("getState ---> "+JSON.stringify(response.getState()))
            if(response.getState() === "SUCCESS") {
                console.log("getReturnValue ---> "+JSON.stringify(response.getReturnValue()));
                
                if(!$A.util.isEmpty(response.getReturnValue())){
                    var sResult=response.getReturnValue();
                    var promocodeRec = sResult.lstPromoCode;
                    var DiscountRec = sResult.lstDiscount;
                    console.log("444 promocodeRec ---> "+JSON.stringify(promocodeRec));
                    console.log("445 DiscountRec --->  "+JSON.stringify(DiscountRec));
                    console.log("getReturnValue --->   "+promocodeRec.Applicable_on__c.trim().toUpperCase());
                    console.log("memberCheckbox --->   "+component.get("v.memberCheckbox"));
                    var finalAmount=0;
                    var iSalert=false;
                    if(!$A.util.isEmpty(DiscountRec)){
                        var sMsg='';
                        console.log("DiscountRec.Discount__r.Percentage ---> "+DiscountRec[0].Discount__r.Percentage__c);
                        if(DiscountRec[0].Discount__r.Percentage__c)
                            sMsg="An early bird discount of "+DiscountRec[0].Discount__r.GST_Amount__c+"% is applicable on this Course. \n If you wish to avail the early bird discount then remove the promo code.";
                        else
                            sMsg="An early bird discount of $"+DiscountRec[0].Discount__r.Amount__c+" is applicable on this Course. \n If you wish to avail the early bird discount then remove the promo code.";
                        component.set("v.discountMsg",sMsg);
                    }
                    if(promocodeRec.Applicable_on__c.trim().toUpperCase()==="MEMBER PRICE" && component.get("v.memberCheckbox")){
                        var MemberPrice = component.get("v.MemberPrice");
                        if(promocodeRec.Discount_Type__c.trim().toUpperCase()==="AMOUNT" && !$A.util.isEmpty(promocodeRec.Discount_Amount__c)){ 
                            finalAmount=MemberPrice-promocodeRec.Discount_Amount__c;
                            component.set("v.PromoCodeMemberValue",finalAmount.toString());
                            component.set("v.PromoCodeId",promocodeRec.Id);
                            component.set("v.PromoCodeApply",true);
                            component.set("v.PromoCodeNonMemberValue","");
                        }else if(promocodeRec.Discount_Type__c.trim().toUpperCase()==="PERCENT" && !$A.util.isEmpty(promocodeRec.Discount_Percentage__c)){ 
                            var discountedPrice=(MemberPrice*promocodeRec.Discount_Percentage__c)/100;
                            finalAmount=MemberPrice-discountedPrice;
                            component.set("v.PromoCodeMemberValue",finalAmount.toString());
                            component.set("v.PromoCodeId",promocodeRec.Id);
                            component.set("v.PromoCodeApply",true);
                            component.set("v.PromoCodeNonMemberValue","");
                        }else{
                            this.ShowToastEvent(component, event,$A.get("$Label.c.CourseRegistrationPromoCodeNullMsg"),'Warning','warning' ); 
                            component.set("v.PromoCodeMemberValue","");
                            component.set("v.PromoCode", "");
                            component.set("v.PromoCodeId","");
                            component.set("v.PromoCodeValue", "");
                            component.set("v.PromoCodeApply",false);
                        }
                    }
                    else if(promocodeRec.Applicable_on__c.trim().toUpperCase()==="NON-MEMBER PRICE" && !component.get("v.memberCheckbox")){
                        var NonMemberPrice = component.get("v.NonMemberPrice");
                        if(promocodeRec.Discount_Type__c.trim().toUpperCase()==="AMOUNT" && !$A.util.isEmpty(promocodeRec.Discount_Amount__c)){ 
                            finalAmount=NonMemberPrice-promocodeRec.Discount_Amount__c;
                            component.set("v.PromoCodeNonMemberValue",finalAmount.toString());
                            component.set("v.PromoCodeId",promocodeRec.Id);
                            component.set("v.PromoCodeApply",true);
                            component.set("v.PromoCodeMemberValue","");
                        }else if(promocodeRec.Discount_Type__c.trim().toUpperCase()==="PERCENT" && !$A.util.isEmpty(promocodeRec.Discount_Percentage__c)){ 
                            var discountedPrice=(NonMemberPrice*promocodeRec.Discount_Percentage__c)/100;
                            finalAmount=NonMemberPrice-discountedPrice;
                            component.set("v.PromoCodeNonMemberValue",finalAmount.toString());
                            component.set("v.PromoCodeId",promocodeRec.Id);
                            component.set("v.PromoCodeApply",true);
                            component.set("v.PromoCodeMemberValue","");
                        }else{
                            this.ShowToastEvent(component, event,$A.get("$Label.c.CourseRegistrationPromoCodeNullMsg"),'Warning','warning' );
                            component.set("v.PromoCodeNonMemberValue","");
                            component.set("v.PromoCode", "");
                             component.set("v.PromoCodeId","");
                            component.set("v.PromoCodeValue", "");
                            component.set("v.PromoCodeApply",false);
                        }
                    }
                        else if(promocodeRec.Applicable_on__c.trim().toUpperCase()==="BOTH"){
                            
                            var MemberPrice = component.get("v.MemberPrice");
                            if(promocodeRec.Discount_Type__c.trim().toUpperCase()==="AMOUNT" && !$A.util.isEmpty(promocodeRec.Discount_Amount__c)){ 
                                finalAmount=MemberPrice-promocodeRec.Discount_Amount__c;
                                component.set("v.PromoCodeMemberValue",finalAmount.toString());
                                component.set("v.PromoCodeId",promocodeRec.Id);
                                component.set("v.PromoCodeApply",true);
                            }else if(promocodeRec.Discount_Type__c.trim().toUpperCase()==="PERCENT" && !$A.util.isEmpty(promocodeRec.Discount_Percentage__c)){ 
                                var discountedPrice=(MemberPrice*promocodeRec.Discount_Percentage__c)/100;
                                finalAmount=MemberPrice-discountedPrice;
                                component.set("v.PromoCodeMemberValue",finalAmount.toString());
                                component.set("v.PromoCodeId",promocodeRec.Id);
                                component.set("v.PromoCodeApply",true);
                            }
                            
                            var NonMemberPrice = component.get("v.NonMemberPrice");
                            if(promocodeRec.Discount_Type__c.trim().toUpperCase()==="AMOUNT" && !$A.util.isEmpty(promocodeRec.Discount_Amount__c)){ 
                                finalAmount=NonMemberPrice-promocodeRec.Discount_Amount__c;
                                component.set("v.PromoCodeNonMemberValue",finalAmount.toString());
                                component.set("v.PromoCodeId",promocodeRec.Id);
                                component.set("v.PromoCodeApply",true);
                            }else if(promocodeRec.Discount_Type__c.trim().toUpperCase()==="PERCENT" && !$A.util.isEmpty(promocodeRec.Discount_Percentage__c)){ 
                                var discountedPrice=(NonMemberPrice*promocodeRec.Discount_Percentage__c)/100;
                                finalAmount=NonMemberPrice-discountedPrice;
                                component.set("v.PromoCodeNonMemberValue",finalAmount.toString());
                                component.set("v.PromoCodeId",promocodeRec.Id);
                                component.set("v.PromoCodeApply",true);
                            }  
                        }else{
                            component.set("v.PromoCodeNonMemberValue","");
                            component.set("v.PromoCode", "");
                            component.set("v.PromoCodeId","");
                            component.set("v.PromoCodeValue", "");
                            component.set("v.PromoCodeApply",false);
                            this.ShowToastEvent(component, event,$A.get("$Label.c.CourseRegistrationPromoCodeNullMsg"),'Warning','warning' );
                            
                        }
                    
                }else{
                    component.set("v.PromoCodeNonMemberValue","");
                    component.set("v.PromoCode", "");
                    component.set("v.PromoCodeId","");
                    component.set("v.PromoCodeValue", "");
                    component.set("v.PromoCodeApply",false);
                    this.ShowToastEvent(component, event,$A.get("$Label.c.CourseRegistrationPromoCodeNullMsg"),'Warning','warning' );
                    
                }
            }else if (state === "ERROR") {
                var errors = response.getError();
                console.log(" 532 Error message: " + errors);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        component.set("v.PromoCodeNonMemberValue","");
                        component.set("v.PromoCode", "");
                        component.set("v.PromoCodeValue", "");
                        component.set("v.PromoCodeId","");
                        this.ShowToastEvent(component, event,"Error occured! Please contact the system admin.",'Warning','warning' );
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(getPromocodeRecord);
    }
})