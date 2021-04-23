({
    onInit : function(component, event, helper) {
        helper.getIdentificationType(component, event);
        helper.getNationality(component, event);
        helper.getEmploymentStatus(component, event);
        helper.getDesignationLevel(component, event);
        var cmpTarget = component.find('MainDiv');
        var crCode;
        var courseRunId;
        var PEContactId='';
        
        //alert("source --> "+component.get("v.source"))
        if(component.get("v.source")){
            crCode=component.get("v.courseRunCode");
            component.set("v.selTabId" , 'particulars');
            component.set("v.declaration",false);
            component.set("v.Payment",false);
            component.set("v.accid",component.get('v.AccountIdPE'));
            component.set("v.AccountName",component.get('v.AccountName'));
            component.set("v.ContactName",component.get('v.ContactName'));
            component.set("v.courseRunStartDate",component.get('v.courseRunStartDatePE'));
            component.set("v.courseId",component.get('v.CourseIdPE'));
            courseRunId=component.get('v.courserunIdPE');
            $A.util.removeClass(cmpTarget, 'custommargin1');
            $A.util.addClass(cmpTarget, 'custommargin');
            //alert('searchContactPE 23 '+component.get('v.searchContactPE'))
            PEContactId=component.get('v.searchContactPE');
            if(!$A.util.isEmpty(component.get('v.searchContactPE'))){
                //helper.getSelectedContactRecord(component, event);
                helper.getDraftRegistrationsPE(component, event,courseRunId);
                component.set("v.isContactNull",true);
            }
        }else{
            crCode = helper.getJsonFromUrl().courseruncode;
            component.set("v.courseRunCode", crCode);
            component.set("v.SelectedUserId",'')
            $A.util.removeClass(cmpTarget, 'custommargin');
            $A.util.addClass(cmpTarget, 'custommargin1');
        }
        
        console.log("35 crCode --> "+ crCode)
        var getCourseRunRecord = component.get('c.getCourseRunRecord');
        getCourseRunRecord.setParams({courseRunCode: crCode});
        getCourseRunRecord.setCallback(this, function(response) {
            console.log(' 42 on page load '+response.getState());
            if(response.getState() === "SUCCESS") {
                helper.getContactAction(component,event);
                component.set("v.courseRunRecord", response.getReturnValue());
                var courseRunRec = response.getReturnValue();
                //console.log("courseRunRec --> "+JSON.stringify(courseRunRec));
                courseRunId=courseRunRec.Id;
                if (courseRunRec.Id != null) {                    
                    if(courseRunRec.Course__r.Need_PII__c || courseRunRec.Course__r.RecordType.Name=="Funded Course")
                        component.set("v.piiSection",true);
                    else
                        component.set("v.piiSection",false);
                    //MVP1.1: added by Devender 15 April 2021 for Promo code START 
                    component.set("v.courseId",courseRunRec.Course__c);
                    component.set("v.courseRunStartDate",courseRunRec.Start_Date__c);
                    component.set("v.MemberPrice",courseRunRec.Course__r.Member_Fee__c);
                    component.set("v.NonMemberPrice",courseRunRec.Course__r.Non_Member_Fee__c);
                    //MVP1.1: added by Devender 15 April 2021 for Promo code END 
                    component.set("v.CourseStartDate",$A.localizationService.formatDate(courseRunRec.Registration_Open_Date__c, "DD MMM YYYY"));
                    component.set("v.CourseEndDate",$A.localizationService.formatDate(courseRunRec.Registration_Close_Date__c, "DD MMM YYYY"));
                    component.set("v.courseId", courseRunRec.Course__c);
                    if(!$A.util.isEmpty(courseRunRec.CourseRecordType__c)){
                        if(courseRunRec.CourseRecordType__c=='Funded Course')
                            component.set("v.fundedtemplate", true);
                        else if(courseRunRec.CourseRecordType__c=='Course')
                            component.set("v.nonfundedtemplate", true);
                    }
                    
                    var cRunRegStartDt = courseRunRec.Registration_Open_Date__c;
                    var cRunregCloseDt = courseRunRec.Registration_Close_Date__c;
                    var cRunActive = courseRunRec.Active__c;
                    var cRunCapacity = courseRunRec.Capacity__c;                 
                    var regChildRecs = courseRunRec.Course_Registrations__r;
                    var cRun_regCount = 0;
                    if(!$A.util.isEmpty(regChildRecs)) {cRun_regCount = regChildRecs.length; }
                    var todayDate = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");  
                    var overlap = (cRunRegStartDt <= todayDate) && (todayDate <= cRunregCloseDt) ? 'true' : 'false';                
                    
                    // alert("overlap ---> "+overlap)
                    if(overlap == 'false' || cRunActive == false || (cRunCapacity == cRun_regCount || cRunCapacity < cRun_regCount)) {                        
                        component.set("v.isOpen", true);
                        var currentTab = component.get("v.selTabId");        
                        component.set("v.selTabId" , 'declaration');
                    }
                    
                    if(!component.get("v.source")){
                        var checkRegistration = component.get('c.getDraftRegistrations');
                        checkRegistration.setParams({ 
                            "courseRunid": courseRunId,
                            "ContactId": PEContactId
                        });
                        checkRegistration.setCallback(this, function(response1) {
                            if(response1.getState() === "SUCCESS") {
                                var courseRegId = response1.getReturnValue();
                                if (!$A.util.isEmpty(courseRegId)) {

                                   // console.log("courseRegId 99 "+JSON.stringify(courseRegId));                                    
                                    component.set("v.CourseRegistrationMasterId",courseRegId[0].Parent_Registration__c);
                                    component.set("v.courseRegistrationId",courseRegId[0].Parent_Registration__c);
                                   
                                    
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
                                    //alert('icountNeedUsrAcc --> '+icountNeedUsrAcc + ' courseRegId.length -> '+courseRegId.length)
                                    if(icountNeedUsrAcc==courseRegId.length){
                                        // alert(' 118 icountNeedUsrAcc --> '+icountNeedUsrAcc + ' courseRegId.length -> '+courseRegId.length)
                                        //component.find("selectAllId").set("v.value",true);
                                        
                                    }
                                    component.set("v.CourseRegistrationList", updatedcourseReg);
                                    if(!component.get("v.isOpen")){
                                        var currentTab = component.get("v.selTabId");        
                                        component.set("v.selTabId" , 'particulars');
                                        
                                        console.log("Promo code --> "+courseRegId[0].Parent_Registration__r.Promo_Code__r.Name);
                                        
                                        if(!$A.util.isEmpty(courseRegId[0].Parent_Registration__r.Promo_Code__r.Name)){
                                            var sPromoCode= courseRegId[0].Parent_Registration__r.Promo_Code__r.Name;
                                            component.set("v.PromoCodeValue",sPromoCode);
                                            if(!$A.util.isEmpty(sPromoCode)){
                                                helper.getPromoCode(component, event,sPromoCode);
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
                    }
                }
                else {
                    //alert('in the else--')
                    helper.createModal(component, "", "Course is not available. Please contact us via the Help Center", "c.redirectToHelpCenter", false);
                }
            } 
        });
        $A.enqueueAction(getCourseRunRecord);      
    },
    redirectToHelpCenter : function (component) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/s/contactsupport"
        });
        urlEvent.fire();
    },
    handleOnSubmit : function(component, event, helper) {
        event.preventDefault(); 
        var fields = event.getParam("fields");
        var buttonLabel = component.get('v.buttonlabel');
        
        console.log('Add Learner --> '+JSON.stringify(fields));
        var CourseRegistrationList = component.get("v.CourseRegistrationList");
        if(buttonLabel == 'Add' && !component.get("v.iSEditRecord")){
            
            if(!$A.util.isEmpty(fields["Need_User_Account__c"]))
                if(fields["Need_User_Account__c"]=="Yes")
                    fields["isChecked"]=true;
            if(component.get("v.source")){
                if(component.get("v.editMarketing"))
                    fields["Marketing_Consent_Clause__c"] = true;
                fields["PDPA_Consent_Clause__c"] = true;
                
            }else{
                var checkVarmarketing = component.find("checkbox_marketing");
                if(checkVarmarketing.get("v.value"))
                    fields["Marketing_Consent_Clause__c"] = true;
                fields["PDPA_Consent_Clause__c"] = true; 
            }
            
            var CurrentCourseRegistrationList= component.get("v.CourseRegistrationList");
            console.log('Add Learner CurrentCourseRegistrationList --> '+JSON.stringify(CurrentCourseRegistrationList));
            var iSDublicate=false;
            var iSDuplicateContact=false;
            if(CurrentCourseRegistrationList.length>0){
                for(var i=0;i<CurrentCourseRegistrationList.length;i++){ 
                    console.log(CurrentCourseRegistrationList[i].Contact__c+" Exsiting con /  New Con -> "+fields["Contact__c"])
                    if(CurrentCourseRegistrationList[i].Contact__c===fields["Contact__c"] &&  !$A.util.isEmpty(fields["Contact__c"])){
                        iSDuplicateContact=true;
                    }
                    if(CurrentCourseRegistrationList[i].First_Name__c.trim().toUpperCase()===fields["First_Name__c"].toString().trim().toUpperCase() && CurrentCourseRegistrationList[i].Last_Name__c.trim().toUpperCase()===fields["Last_Name__c"].toString().trim().toUpperCase() && CurrentCourseRegistrationList[i].Email_Address__c.trim().toUpperCase()===fields["Email_Address__c"].toString().trim().toUpperCase()){
                        iSDublicate=true;
                    }  
                }
            }
            if(!iSDublicate && !iSDuplicateContact){
                if(fields["Need_User_Account__c"]=="Yes"){
                    var checkUserEmail = component.get('c.checkUserWithContact');
                    checkUserEmail.setParams({ 
                        "emailList": fields["Email_Address__c"]
                    });
                    checkUserEmail.setCallback(this, function(response) {
                        console.log('  In getDraftRegistrations '+response.getState());
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
                                    console.log('Add Learner 1 --> '+JSON.stringify(fields));
                                    CourseRegistrationList.push(fields);
                                    component.set("v.CourseRegistrationList", CourseRegistrationList);
                                    //fields["Contact__c"] =null;
                                    component.set("v.isContactNull",false);
                                    helper.ClearFieldValue(component, event);
                                    helper.ShowToastEvent(component, event,$A.get("$Label.c.CourseRegistrationInsertMsg"),'Success','success'); 
                                    
                                } 
                            }else{
                                
                                component.set("v.EmailError",false);
                                console.log('Add Learner 2 --> '+JSON.stringify(fields));
                                CourseRegistrationList.push(fields);
                                component.set("v.CourseRegistrationList", CourseRegistrationList);
                                // fields["Contact__c"] =null;
                                component.set("v.isContactNull",false);
                                helper.ClearFieldValue(component, event);
                                helper.ShowToastEvent(component, event,$A.get("$Label.c.CourseRegistrationInsertMsg"),'Success','success'); 
                                
                            }  
                        }
                    });
                    $A.enqueueAction(checkUserEmail); 
                }
                else{
                    component.set("v.EmailError",false);
                    console.log('Add Learner 3 --> '+JSON.stringify(fields));
                    CourseRegistrationList.push(fields);
                    component.set("v.CourseRegistrationList", CourseRegistrationList);
                    // fields["Contact__c"] =null;
                    component.set("v.isContactNull",false);
                    helper.ClearFieldValue(component, event);
                    console.log('Add Learner CourseRegistrationList 3 --> '+JSON.stringify( component.get("v.CourseRegistrationList")));
                    console.log('Add Learner after delete 3 --> '+JSON.stringify(fields));
                    helper.ShowToastEvent(component, event,$A.get("$Label.c.CourseRegistrationInsertMsg"),'Success','success'); 
                    
                }
                
            }
            else{                            
                helper.ShowToastEvent(component, event,$A.get("$Label.c.CourseRegistrationDuplicateMsg"),'Warning','warning' ); 
            }
            //component.set("v.Spinner", false);
        } 
        if(buttonLabel == 'Add' && component.get("v.iSEditRecord")){
            if(fields["Need_User_Account__c"]=="Yes"){
                var checkUserEmail = component.get('c.checkUserWithContact');
                checkUserEmail.setParams({ 
                    "emailList": fields["Email_Address__c"]
                });
                checkUserEmail.setCallback(this, function(response) {
                    console.log('  In getDraftRegistrations '+response.getState());
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
                                helper.UpdateRecord(component, event,fields);
                                // component.set("v.iSEditRecord",false);
                                // helper.ClearFieldValue(component, event);
                                // helper.ShowToastEvent(component, event,$A.get("$Label.c.CourseRegistrationUpdateMsg"),'Success','success');
                            } 
                        }else{
                            component.set("v.EmailError",false);
                            helper.UpdateRecord(component, event,fields);
                            // component.set("v.iSEditRecord",false);
                            //  helper.ClearFieldValue(component, event);
                            //  helper.ShowToastEvent(component, event,$A.get("$Label.c.CourseRegistrationUpdateMsg"),'Success','success');
                        }  
                    }
                });
                $A.enqueueAction(checkUserEmail); 
            }
            else{
                component.set("v.EmailError",false);
                helper.UpdateRecord(component, event,fields);
                //component.set("v.iSEditRecord",false);
                // helper.ClearFieldValue(component, event);
                // helper.ShowToastEvent(component, event,$A.get("$Label.c.CourseRegistrationUpdateMsg"),'Success','success');
            }
            
        }
    },
    AddLearner : function(component, event, helper) {
        //var checkVar = component.find("checkbox_pdpa");
        var salutationId=component.find("salutationId");
        var fNameId=component.find("fNameId");
        var lNameId=component.find("lNameId");
        var prefCertificateId=component.find("prefCertificateId");
        var genderId=component.find("genderId");
        var emailId=component.find("emailId");
        var MblenoId=component.find("MblenoId");
        var NricTypeId=component.find("NricTypeId");
        var NricId=component.find("NricId");
        var dobId=component.find("dobId");
        if(component.get('v.piiSection')){
            if(!$A.util.isEmpty(salutationId.get("v.value")) && !$A.util.isEmpty(fNameId.get("v.value"))
               && !$A.util.isEmpty(lNameId.get("v.value")) && !$A.util.isEmpty(lNameId.get("v.value"))
               && !$A.util.isEmpty(prefCertificateId.get("v.value")) && !$A.util.isEmpty(genderId.get("v.value"))
               && !$A.util.isEmpty(emailId.get("v.value")) && !$A.util.isEmpty(MblenoId.get("v.value"))
               && !$A.util.isEmpty(NricTypeId.get("v.value")) && !$A.util.isEmpty(NricId.get("v.value"))
               && !$A.util.isEmpty(dobId.get("v.value"))){
                if(helper.ValidateNricTypeInApex(component, event)){
                    // helper.getDuplicateUser(component, event,emailId.get("v.value"));
                    /* alert("EmailError--> "+component.get("v.EmailError"));
                    if(!component.get("v.EmailError")){
                        component.set('v.buttonlabel','Add');
                    }*/
                    component.set('v.buttonlabel','Add');
                }
                else if(!helper.ValidateNricTypeInApex(component, event))
                    component.set('v.buttonlabel','invalidnric');
            }
        }
        
        if(!component.get('v.piiSection')){
            if(!$A.util.isEmpty(salutationId.get("v.value")) && !$A.util.isEmpty(fNameId.get("v.value"))
               && !$A.util.isEmpty(lNameId.get("v.value")) && !$A.util.isEmpty(lNameId.get("v.value"))
               && !$A.util.isEmpty(prefCertificateId.get("v.value")) && !$A.util.isEmpty(genderId.get("v.value"))
               && !$A.util.isEmpty(emailId.get("v.value")) && !$A.util.isEmpty(MblenoId.get("v.value"))){
                
                /* alert("EmailError--> "+component.get("v.EmailError"));
                if(!component.get("v.EmailError")){
                    component.set('v.buttonlabel','Add');
                }*/
                component.set('v.buttonlabel','Add');
            }
        } 
        
        
        
    },
    onClickPdpa: function(component, event, helper) {
        var checkVar = component.find("checkbox_pdpa");
        if (checkVar.get("v.value")){
            component.set('v.buttonlabel','');
        }
    },
    itemsChange: function(component, event, helper) {
        console.log('searchContactId -->'+ component.get('v.searchContactId'));
        if(!$A.util.isEmpty(component.get('v.searchContactId'))){
            helper.getSelectedContactRecord(component, event);
            component.set("v.isContactNull",true);
        } 
    },
    handleSubmit : function(component,event,helper) {
        //console.log('********************** Create Records for Course Registration Start***********');
        var crCode = component.get("v.courseRunCode");
        var getCourseRun = component.get('c.getCourseRunRecord');
        getCourseRun.setParams({courseRunCode: crCode});
        getCourseRun.setCallback(this, function(response) {             
            if(response.getState() === "SUCCESS") {               
                var courseRun = response.getReturnValue(); 
                var cRunCapacity = courseRun.Capacity__c;
                var regChildRecs = courseRun.Course_Registrations__r;
                var cRun_regCount = 0;
                if(!$A.util.isEmpty(regChildRecs)) {                 
                    cRun_regCount = regChildRecs.length;
                }
                if(cRunCapacity == cRun_regCount || cRunCapacity < cRun_regCount) {
                    component.set("v.isOpen", true);
                }else {
                    component.set('v.buttonlabel','Submit');
                    //alert('CourseRegistrationMasterId --> '+component.get("v.CourseRegistrationMasterId"))
                    if($A.util.isEmpty(component.get("v.CourseRegistrationMasterId"))){
                        helper.SaveRecord(component,event);
                    }
                    else if(!$A.util.isEmpty(component.get("v.CourseRegistrationMasterId"))){
                        if(!$A.util.isEmpty(component.get("v.DeleteCourseRegistrationList")))
                            helper.DeleteRecord(component,event);
                        helper.UpdateCourseRegistrationRecord(component,event);
                    }
                    
                }
            }else if(response.getState() == "ERROR"){
                var errors = response.getError();    
                alert(errors[0].message);
            }
        });
        $A.enqueueAction(getCourseRun);
        console.log('********************** END **********************');  
    },
    handleSaveAsDraft : function(component,event,helper) {
        var crCode = component.get("v.courseRunCode");
        var getCourseRun = component.get('c.getCourseRunRecord');
        getCourseRun.setParams({courseRunCode: crCode});
        getCourseRun.setCallback(this, function(response) {             
            if(response.getState() === "SUCCESS") {               
                var courseRun = response.getReturnValue(); 
                var cRunCapacity = courseRun.Capacity__c;   
                var regChildRecs = courseRun.Course_Registrations__r;
                var cRun_regCount = 0;
                if(!$A.util.isEmpty(regChildRecs)) {                 
                    cRun_regCount = regChildRecs.length;
                }
                if(cRunCapacity == cRun_regCount || cRunCapacity < cRun_regCount) {
                    component.set("v.isOpen", true);
                }else {
                    //          console.log('***** CourseRegistrationMasterId -> '+component.get("v.CourseRegistrationMasterId"));
                    //         console.log('***** On Save As Draft Button Call.if CourseRegistrationMasterId is null the new Course Registration will Create *****'+JSON.stringify(component.get("v.CourseRegistrationList")));
                    component.set('v.buttonlabel','Draft')
                    // alert('in save as draft CourseRegistrationMasterId---> '+component.get("v.CourseRegistrationMasterId"));
                    if($A.util.isEmpty(component.get("v.CourseRegistrationMasterId"))){
                        //    alert('Save call on Save as draf button');
                        helper.SaveRecord(component,event);
                    }
                    else if(!$A.util.isEmpty(component.get("v.CourseRegistrationMasterId"))){
                        //   alert('Edit call on Save as draf button');
                        if(!$A.util.isEmpty(component.get("v.DeleteCourseRegistrationList")))
                            helper.DeleteRecord(component,event);
                        helper.UpdateCourseRegistrationRecord(component,event);
                    } 
                    
                }
            }else if(response.getState() == "ERROR"){
                var errors = response.getError();    
                alert(errors[0].message);
            }
        });
        $A.enqueueAction(getCourseRun);
    },
    closeModelLater: function(component, event, helper) {
        component.set("v.PaymentModalOpen", false);
        component.set("v.isExecutiveModalOpen", true);
    },
    closeModelLaterPE: function(component, event, helper) {
        component.set("v.SubmitPopUpForPE", false);
        component.set("v.isExecutiveModalOpen", true);
    },
    
    redirectToPaymentPE: function(component, event, helper) {
        // alert(' 362 navigateToSObject run'+component.get("v.courseRegistrationId"));
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.courseRegistrationId"),
            "slideDevName": "related"
        });
        navEvt.fire();
        $A.get('e.force:refreshView').fire();
    },
    redirectToPayment: function(component, event, helper) {
        component.set("v.PaymentModalOpen", false);
        var regId = component.get("v.courseRegistrationId");   
        var getinvoice = component.get('c.returnInvoice');
        getinvoice.setParams({
            "courseRegId": regId,
            "listcourseRegId":component.get('v.listcourseRegId')
        });
        getinvoice.setCallback(this, function(response) {
            ////  alert('payment response.getState() ---> '+response.getState());
            if(response.getState() === "SUCCESS") {
                var invoiceId = response.getReturnValue();
                ////   alert('invoiceId ---> '+response.getReturnValue());
                component.set("v.invoiceId" , invoiceId);  				                
                component.set("v.selTabId" , 'Payment');         
            }else if(response.getState() == "ERROR"){
                var errors = response.getError();    
                console.log(errors[0].message);
            }
        }); 
        $A.enqueueAction(getinvoice);    
    },
    redirectToHome : function (component, event, helper) {
        var cRegId =component.get("v.courseRegistrationId");
        if(!component.get("v.source")){
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "/s/course-registration/" + cRegId
            });
            urlEvent.fire();
        }else{
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": cRegId,
                "slideDevName": "related"
            });
            navEvt.fire();
            $A.get('e.force:refreshView').fire();
        }
    },
    remove : function(component, event, helper) {
        var indexPosition = event.target.name;
        var existingCourseRegistration = component.get("v.CourseRegistrationList");
        //-------- Below Code for delete the Course Registraition and their associated contact -----//
        //console.log('id --> '+JSON.stringify(existingCourseRegistration[indexPosition]));
        if(!$A.util.isEmpty(existingCourseRegistration[indexPosition].Id)){
            var sCourseReg=existingCourseRegistration[indexPosition].Id;
            var DeleteRegistrationList = component.get("v.DeleteCourseRegistrationList");
            DeleteRegistrationList.push(sCourseReg);
            component.set("v.DeleteCourseRegistrationList", DeleteRegistrationList);
        }
        //console.log('DeleteCourseRegistrationList --> '+component.get("v.DeleteCourseRegistrationList"));
        //-------- END -----//
        // console.log("indexPosition",indexPosition);
        existingCourseRegistration.splice(indexPosition, 1);
        component.set("v.CourseRegistrationList", existingCourseRegistration);
    },
    EditLearner : function(component, event, helper) {
        
        component.set("v.iSEditRecord",true);
        var indexPosition = event.target.name;
        component.set("v.IndexPosition",indexPosition);
        var existingCourseRegistration = component.get("v.CourseRegistrationList");
        component.set("v.EditcourseRegistrationId",existingCourseRegistration[indexPosition].Id);
        if(!component.get("v.source")){
            if(existingCourseRegistration[indexPosition].PDPA_Consent_Clause__c)
                component.find("checkbox_pdpa").set("v.value",true);
            else
                component.find("checkbox_pdpa").set("v.value",false);
            
            if(existingCourseRegistration[indexPosition].Marketing_Consent_Clause__c)
                component.find("checkbox_marketing").set("v.value",true);
            else
                component.find("checkbox_marketing").set("v.value",false);
        }
        component.set("v.EditCourseRegistrationList",existingCourseRegistration[indexPosition]);
    },
    handleAcceptClick : function(component, event, helper) {        
        var checkVar = component.find("checkbox");
        var checkVarpdpa = component.find("checkbox_pdpa");
        if (checkVar.get("v.value") == true)  {
            if (!checkVarpdpa.get("v.value")){
                component.set("v.PDPAModalOpen", true);
            }else{
                var currentTab = component.get("v.selTabId");        
                component.set("v.selTabId" , 'particulars');
                helper.getContactAction(component,event);
            }
        } else {           
            component.set("v.acceptModalOpen", true);
        }   
    },
    file: function (component, event,helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            var fileName = event.getSource().get("v.files")[0].name;
            var file = event.getSource().get("v.files")[0];
            component.set("v.fileStorage" , file);
            component.set("v.fileName", fileName);
            component.set("v.fileLenght",event.getSource().get("v.files").length);
        }
    },
    savefile: function (component, event,helper) {
        if(component.get("v.fileLenght")>0){
            //alert("piiSection ---> "+component.get("v.piiSection"))
            var ExcelHeader;
            if(component.get("v.piiSection"))
                ExcelHeader=["Salutation", "FirstName","LastName","Date of Birth (DD/MM/YYYY)","Preferred Certificate Name","Gender", "Email", "Contact No","Identification Type","Identification Number","Nationality","Office Number","Employment Status","Job Title","Designation Level","Need User Account?"];
            else if(!component.get("v.piiSection"))
                ExcelHeader=["Salutation", "FirstName","LastName","Preferred Certificate Name","Gender", "Email", "Contact No","Nationality","Office Number","Employment Status","Job Title","Designation Level","Need User Account?"];
            
            
            var iSValidate=true;var iSValidateHeader=true;
            var file=component.get("v.fileStorage");
            const reader = new FileReader();
            var sMsgDatefrmt ="";
            var sMsgdate ="";
            var sMsgMobile ="";
            var sMsgEmail ="";
            var sMsgNRICType ="";
            var sMsgNationality ="";
            var sMsgEmploymentStatus ="";
            var sMsgDesignation ="";
            var sMsgNRICNumber="";
            var sMsgNRICInvalid="";
            var sMsgSalutation="";
            var sMsgFname="";
            var sMsgLname="";
            var sMsgPDPA="";
            var sMsgPerferCertification="";
            var sMsgGender="";
            var sMsg ="";
            var iSValidateDateformate;
            var sMobileMsg ="";
            var sValidateDateformate ="";
            reader.readAsText(file);
            reader.onload = function (event) {
                var csv = event.target.result;
                var allTextLines = csv.split(/\r\n|\n/);
                var lines = [];
                //  alert(' 84 allTextLines --> '+ allTextLines.length);
                component.set("v.DublicateCourseRegistrationList",component.get("v.CourseRegistrationList"));
                var CourseRegistrationRecordForDublicate=[];
                var existingUserEmail=[];
                var emailIndex=[];
                let indexOfEmail = new Map();
                var iCount=0;
                for (var i=0; i<allTextLines.length-1; i++) {
                    var data = allTextLines[i].split(';');
                    // alert(" data 501 "+JSON.stringify(data));
                    var tarr = [];
                    
                    var DublicateCourRegistrationList=component.get("v.DublicateCourseRegistrationList");
                    for (var j=0; j<data.length; j++) {
                        tarr.push(data[j]);
                        var InnerData=data[j].split(',');
                        if(i==0){
                            for (var k=0; k<InnerData.length; k++) {
                                if(InnerData[k].replace(/ /g, "").toUpperCase()!=ExcelHeader[k].replace(/ /g, "").toUpperCase()){
                                    iSValidateHeader=false;
                                    helper.ShowToastEvent(component, event,$A.get("$Label.c.CourseRegistrationInvalidHeaderMsg"),'Error','error');
                                    Break;
                                }  
                            }  
                        }
                        //alert('iSValidateHeader result test 1 '+iSValidateHeader)
                        //************ Validation for Email  *************//
                        if(i>0 && iSValidateHeader){
                            //alert('DublicateCourRegistrationList --> '+JSON.stringify(DublicateCourRegistrationList))
                            if(DublicateCourRegistrationList.length>0){
                                for (var l=0; l<DublicateCourRegistrationList.length; l++) {
                                    var sMsgduplicate='';
                                    if(component.get('v.piiSection')){
                                        if(DublicateCourRegistrationList[l].First_Name__c.trim().toUpperCase()===InnerData[1].toString().trim().toUpperCase() && DublicateCourRegistrationList[l].Last_Name__c.trim().toUpperCase()===InnerData[2].toString().trim().toUpperCase() && DublicateCourRegistrationList[l].Email_Address__c.trim().toUpperCase()===InnerData[6].toString().trim().toUpperCase()){
                                            sMsgduplicate='Row '+iCount+', '+$A.get("$Label.c.CourseRegistrationDuplicateMsg"); 
                                            helper.ShowToastEvent(component, event,sMsgduplicate,'Warning','warning' ); 
                                            Break;
                                        }  
                                    }
                                    
                                    if(!component.get('v.piiSection')){
                                        if(DublicateCourRegistrationList[l].First_Name__c.trim().toUpperCase()===InnerData[1].toString().trim().toUpperCase() && DublicateCourRegistrationList[l].Last_Name__c.trim().toUpperCase()===InnerData[2].toString().trim().toUpperCase() && DublicateCourRegistrationList[l].Email_Address__c.trim().toUpperCase()===InnerData[5].toString().trim().toUpperCase()){
                                            sMsgduplicate='Row '+iCount+', '+$A.get("$Label.c.CourseRegistrationDuplicateMsg"); 
                                            helper.ShowToastEvent(component, event,sMsgduplicate,'Warning','warning' ); 
                                            Break;
                                        }  
                                    }
                                }
                            }
                            var fileEmail='';
                            var needUserAccount=false;
                            if(component.get('v.piiSection')){
                                fileEmail=InnerData[6];
                                if(InnerData[15].toUpperCase()=="YES")
                                    needUserAccount=true;
                            }
                            if(!component.get('v.piiSection')){
                                fileEmail=InnerData[5];   
                                if(InnerData[12].toUpperCase()=="YES")
                                    needUserAccount=true;
                            }
                            
                            if(iCount>0){
                                CourseRegistrationRecordForDublicate = {
                                    First_Name__c:InnerData[1],
                                    Last_Name__c: InnerData[2],
                                    Email_Address__c:fileEmail
                                }
                                if(needUserAccount){
                                    existingUserEmail.push(fileEmail.trim().toLowerCase());
                                    emailIndex.push(iCount);
                                    indexOfEmail.set(fileEmail,iCount);
                                }
                            }
                            
                            
                            // var CourseRegistrationList = component.get("v.CourseRegistrationList");
                            //************ Validation for Salutation  CourseRegistrationSalutation *************//
                            if($A.util.isEmpty(InnerData[0])){
                                // sMsgSalutation+='Row '+i+', Salutation should not null.\n';
                                sMsgSalutation+='Row '+i+', '+$A.get("$Label.c.CourseRegistrationSalutation")+'\n'; 
                                
                                iSValidate=false;
                            }
                            
                            //************ Validation for First Name CourseRegistrationFirstnameMsg  *************//
                            if($A.util.isEmpty(InnerData[1])){
                                sMsgFname+='Row '+i+', '+$A.get("$Label.c.CourseRegistrationFirstnameMsg")+'.\n'; 
                                iSValidate=false;
                            }
                            
                            //************ Validation for Last Name CourseRegistrationLastnameMsg *************//
                            if($A.util.isEmpty(InnerData[2])){
                                sMsgLname+='Row '+i+', '+$A.get("$Label.c.CourseRegistrationLastnameMsg")+'.\n'; 
                                iSValidate=false;
                            }
                            
                            
                            // alert(' 577 iSValidate --> '+iSValidate)
                            
                            //************ Validation for NRIC Type *************//                         
                            if(component.get('v.piiSection')){
                                
                                //************ Validation for Date of birthday for testing only  *************//
                                // alert('Date ----> '+InnerData[3])
                                //alert('Date ----> function '+helper.ValidateDateformate(InnerData[3]))
                                if(!$A.util.isEmpty(InnerData[3])){
                                    // alert('Date ----> '+InnerData[3]) CourseRegistrationDateOfBirthInvalidFormateMsg
                                    if(!helper.ValidateDateformate(InnerData[3])){
                                        sMsgDatefrmt+='Row '+i+', '+$A.get("$Label.c.CourseRegistrationDateOfBirthInvalidFormateMsg")+'.\n'; 
                                        iSValidate=false;
                                    }else{
                                        iSValidateDateformate=true;
                                        if(!helper.ValidateDateOfBirth(InnerData[3])){
                                            //alert(' in date greater Date ----> '+InnerData[3])CourseRegistrationDateOfBirthNullMsg
                                            sMsgdate+='Row '+i+', '+$A.get("$Label.c.CourseRegistrationDateOfBirthNullMsg")+'.\n'; 
                                            iSValidate=false;
                                        }
                                    }
                                }else{
                                    if($A.util.isEmpty(InnerData[3]))//CourseRegistrationDateOfBirthGreaterorLessMsg
                                        sMsgDatefrmt+='Row '+i+', '+$A.get("$Label.c.CourseRegistrationDateOfBirthGreaterorLessMsg")+'.\n';     
                                }
                                
                                
                                //************ Validation for Preferred Certificate Name  CourseRegistrationPreferredCertificateMsg *************//
                                // alert('PreferredCertificate ----> '+InnerData[4])
                                if($A.util.isEmpty(InnerData[4])){
                                    sMsgPerferCertification+='Row '+i+', '+$A.get("$Label.c.CourseRegistrationPreferredCertificateMsg")+'.\n';     
                                    iSValidate=false;
                                }
                                
                                //************ Validation for Gender  CourseRegistrationGenderMsg *************//
                                //  alert('Gender ----> '+InnerData[5])
                                if($A.util.isEmpty(InnerData[5])){
                                    sMsgGender+='Row '+i+', '+$A.get("$Label.c.CourseRegistrationGenderMsg")+'.\n';     
                                    iSValidate=false;
                                }
                                
                                //************ Validation for Email  CourseRegistrationInvalidEmailMsg *************//
                                // alert('Email ----> '+InnerData[6])
                                if(!$A.util.isEmpty(InnerData[6])){
                                    if(!helper.ValidateEmail(InnerData[6])){
                                        sMsgEmail+='Row '+i+', '+$A.get("$Label.c.CourseRegistrationInvalidEmailMsg")+'.\n';
                                        iSValidate=false;
                                    }
                                }else{
                                    if($A.util.isEmpty(InnerData[6])){//CourseRegistrationNullEmailMsg
                                        sMsgEmail+='Row '+i+', '+$A.get("$Label.c.CourseRegistrationNullEmailMsg")+'.\n';
                                        iSValidate=false;
                                    }
                                }
                                //************ Validation for identification  number CourseRegistrationContactnumberNullMsg *************//
                                
                                //  alert('Contact number ----> '+InnerData[7])
                                if($A.util.isEmpty(InnerData[7])){
                                    sMsgMobile+='Row '+i+', '+$A.get("$Label.c.CourseRegistrationContactnumberNullMsg")+'.\n';
                                    iSValidate=false;
                                }
                                
                                
                                // alert("NRIC Type  --> i "+InnerData[8]); 
                                if(!$A.util.isEmpty(InnerData[8])){
                                    let myMap = new Map(); myMap=component.get("v.mapIdentificationType");
                                    //alert("NRIC Type  --> "+myMap.has(InnerData[8]));
                                    if(!myMap.has(InnerData[8])){
                                        sMsgNRICType+='Row '+i+', '+$A.get("$Label.c.CourseRegistrationInvalidNRICTypeMsg")+'.\n';   
                                        iSValidate=false; 
                                    } 
                                    // alert(" 644 NRIC Type  --> i "+myMap.has(InnerData[8])); 
                                    if(myMap.has(InnerData[8])){//CourseRegistrationNRICnumberNullMsg
                                        if($A.util.isEmpty(InnerData[9])){
                                            sMsgNRICNumber+='Row '+i+', '+$A.get("$Label.c.CourseRegistrationNRICnumberNullMsg")+'.\n';   
                                            iSValidate=false;
                                        }
                                    }
                                    // alert(" 644 NRIC Type  --> i "+myMap.has(InnerData[8])); 
                                    if(myMap.has(InnerData[8])){
                                        if(!$A.util.isEmpty(InnerData[9])){//CourseRegistrationinvalidNRICnumberMsg
                                            // alert(i+ " 654 NRIC Type valid --> "+helper.ValidateNricVal(InnerData[8],InnerData[9]));
                                            //alert("NRIC Name "+InnerData[8].toUpperCase())
                                            if(InnerData[8].toUpperCase()!="PASSPORT"){
                                                if(!helper.ValidateNricVal(InnerData[8],InnerData[9])){
                                                    sMsgNRICInvalid+='Row '+i+', '+$A.get("$Label.c.CourseRegistrationinvalidNRICnumberMsg")+'.\n';  
                                                    iSValidate=false;
                                                }
                                            }
                                        }
                                    }   
                                }
                                // alert('NRIC Type complete ')
                                
                                //************ Validation for Nationality Type CourseRegistrationinvalidNationalityMsg *************//
                                // alert('Nationality ----> '+InnerData[10])
                                if(!$A.util.isEmpty(InnerData[10])){
                                    let myMap = new Map();
                                    myMap=component.get("v.mapnationality");
                                    // alert(InnerData[10]+" Nationality Type 338 myMap -> "+myMap.has(InnerData[10])+"      sMsg ==> "+component.get("v.sMessage"))
                                    if(!myMap.has(InnerData[10])){
                                        sMsgNationality+='Row '+i+', '+$A.get("$Label.c.CourseRegistrationinvalidNationalityMsg")+'.\n';  
                                        iSValidate=false;
                                    } 
                                }
                                
                                //************ Validation for Employment Status Type CourseRegistrationinvalidEmploymentMsg *************//
                                //  alert('Employment Status ----> '+InnerData[12])
                                if(!$A.util.isEmpty(InnerData[12])){
                                    let myMap = new Map();myMap=component.get("v.mapemploymentStatus");
                                    //alert(InnerData[12]+" invalid Employment Status Type -> "+myMap.has(InnerData[12])+"      sMsg ==> "+component.get("v.sMessage"))
                                    if(!myMap.has(InnerData[12])){
                                        sMsgEmploymentStatus+='Row '+i+', '+$A.get("$Label.c.CourseRegistrationinvalidEmploymentMsg")+'.\n'; 
                                        iSValidate=false;
                                    } 
                                }
                                
                                //************ Validation for Designation Level Type CourseRegistrationinvalidDesignationMsg *************//
                                // alert('Designation Level ----> '+InnerData[14])
                                if(!$A.util.isEmpty(InnerData[14])){
                                    let myMap = new Map();
                                    myMap=component.get("v.mapdesignationLevel");
                                    //alert(InnerData[14]+" Designation Level Type 349 myMap -> "+myMap.has(InnerData[14])+"      sMsg ==> "+component.get("v.sMessage"))
                                    if(!myMap.has(InnerData[14])){
                                        sMsgDesignation+='Row '+i+', '+$A.get("$Label.c.CourseRegistrationinvalidDesignationMsg")+'.\n';
                                        iSValidate=false;
                                    } 
                                }
                                
                            }
                            if(!component.get('v.piiSection')){
                                //************ Validation for Preferred Certificate Name CourseRegistrationPreferredCertificateMsg  *************//
                                if($A.util.isEmpty(InnerData[3])){
                                    sMsgPerferCertification+='Row '+i+', '+$A.get("$Label.c.CourseRegistrationPreferredCertificateMsg")+'.\n';
                                    iSValidate=false;
                                }
                                ///************ Validation for Last Name   CourseRegistrationGenderMsg *************//
                                if($A.util.isEmpty(InnerData[4])){
                                    sMsgGender+='Row '+i+', '+$A.get("$Label.c.CourseRegistrationGenderMsg")+'.\n';
                                    iSValidate=false;
                                }
                                
                                //************ Validation for Email  CourseRegistrationInvalidEmailMsg *************//
                                //alert('Email at 776 possition --> '+$A.util.isEmpty(InnerData[5]));
                                if(!$A.util.isEmpty(InnerData[5])){
                                    //alert("Email Test 1")
                                    if(!helper.ValidateEmail(InnerData[5])){
                                        sMsgEmail+='Row '+i+', '+$A.get("$Label.c.CourseRegistrationInvalidEmailMsg")+'.\n';
                                        iSValidate=false;
                                    }
                                }
                                if($A.util.isEmpty(InnerData[5])){
                                    //alert("Email Test 2")
                                    sMsgEmail+='Row '+i+', '+$A.get("$Label.c.CourseRegistrationNullEmailMsg")+'.\n';     
                                    iSValidate=false;
                                }
                                //************ Validation for identification  number *************//
                                
                                //alert('line number 685 Mobile number --> '+InnerData[6])
                                if($A.util.isEmpty(InnerData[6])){
                                    sMsgMobile+='Row '+i+', '+$A.get("$Label.c.CourseRegistrationContactnumberNullMsg")+'.\n';
                                    iSValidate=false;
                                }
                                
                                //************ Validation for Nationality Type  CourseRegistrationinvalidNationalityMsg *************//
                                if(!$A.util.isEmpty(InnerData[7])){
                                    let myMap = new Map();
                                    myMap=component.get("v.mapnationality");
                                    //alert(InnerData[10]+" Nationality Type 338 myMap -> "+myMap.has(InnerData[10])+"      sMsg ==> "+component.get("v.sMessage"))
                                    if(!myMap.has(InnerData[7])){
                                        sMsgNationality+='Row '+i+', '+$A.get("$Label.c.CourseRegistrationinvalidNationalityMsg")+'.\n';     
                                        iSValidate=false;
                                    } 
                                }
                                
                                //************ Validation for Employment Status Type CourseRegistrationinvalidEmploymentMsg*************//
                                if(!$A.util.isEmpty(InnerData[9])){
                                    let myMap = new Map();
                                    myMap=component.get("v.mapemploymentStatus");
                                    //alert(InnerData[12]+" invalid Employment Status Type -> "+myMap.has(InnerData[12])+"      sMsg ==> "+component.get("v.sMessage"))
                                    if(!myMap.has(InnerData[9])){
                                        sMsgEmploymentStatus+='Row '+i+', '+$A.get("$Label.c.CourseRegistrationinvalidEmploymentMsg")+'.\n';
                                        iSValidate=false;
                                    } 
                                }
                                
                                //************ Validation for Designation Level Type CourseRegistrationinvalidDesignationMsg*************//
                                if(!$A.util.isEmpty(InnerData[11])){
                                    let myMap = new Map();
                                    myMap=component.get("v.mapdesignationLevel");
                                    //alert(InnerData[14]+" Designation Level Type 349 myMap -> "+myMap.has(InnerData[14])+"      sMsg ==> "+component.get("v.sMessage"))
                                    if(!myMap.has(InnerData[11])){
                                        sMsgDesignation+='Row '+i+', '+$A.get("$Label.c.CourseRegistrationinvalidDesignationMsg")+'.\n';
                                        iSValidate=false;
                                    } 
                                }  
                            } 
                        } 
                    }
                    
                    
                    var sMessageVal=sMsgSalutation+''+sMsgFname+''+sMsgLname+''+sMsgDatefrmt+''+sMsgdate+''+sMsgPerferCertification+''+sMsgGender+''+sMsgMobile+''+sMsgEmail+''+sMsgNRICType+''+sMsgNRICNumber+''+sMsgNRICInvalid+''+sMsgNationality+''+sMsgEmploymentStatus+''+sMsgDesignation+''+sMsgPDPA;
                    /*alert("allTextLines --> "+(allTextLines.length-1));
                    alert("i count --> "+(i+1))
                    alert("iSValidate --> "+iSValidate)
                    alert("sMessageVal --> "+sMessageVal)*/
                    
                    if((allTextLines.length-1)==(i+1) && !iSValidate){
                        //component.set("v.CourseRegistrationList",null);
                        helper.ShowToastEvent(component, event,sMessageVal,'Error','error');
                    }
                    if(iCount>0){
                        //alert(i + " 820   CourseRegistrationRecordForDublicate-->  "+CourseRegistrationRecordForDublicate)
                        if(!$A.util.isEmpty(CourseRegistrationRecordForDublicate)){
                            DublicateCourRegistrationList.push(CourseRegistrationRecordForDublicate);
                            component.set("v.DublicateCourseRegistrationList",DublicateCourRegistrationList);
                        }
                    }
                    iCount=iCount+1;
                }
                
                var checkVarmarketingVal=false;
                if(component.get("v.source")){
                    if(component.get("v.editMarketing"))
                        checkVarmarketingVal=true;   
                }else{
                    var checkVarmarketing = component.find("checkbox_marketing");
                    if(checkVarmarketing.get("v.value"))
                        checkVarmarketingVal=true;
                }
                console.log("existingUserEmail --> "+existingUserEmail);
                console.log("emailIndex --> "+emailIndex);
                if(!$A.util.isEmpty(existingUserEmail)){
                    needUserAccount=true;
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
                                    iSValidate=false;
                                    helper.ShowToastEvent(component, event,sMsgEmail,'Error','error');
                                }
                            }
                            //alert("needUserAccount --> "+needUserAccount);
                            if($A.util.isEmpty(sMsgEmail) && needUserAccount){
                                // component.set("v.EmailError",false);
                                if(iSValidate){
                                    for (var i=0; i<allTextLines.length-1; i++) {
                                        var data = allTextLines[i].split(';');
                                        var tarr = [];
                                        for (var j=0; j<data.length; j++) {
                                            tarr.push(data[j]);
                                            console.log(' 96 j --> '+ i);
                                            var iSDublicate
                                            var InnerData=data[j].split(',');
                                            console.log('iSValidateHeader  183 '+iSValidateHeader)
                                            if(i>0 && iSValidateHeader){
                                                var CourseRegistrationList = component.get("v.CourseRegistrationList");
                                                for (var k=0; k<InnerData.length; k++) {
                                                    var needYourAcc=false;
                                                    
                                                    if(iSValidate){
                                                        if(component.get('v.piiSection')){
                                                            if(!$A.util.isEmpty(InnerData[15]))
                                                                if(InnerData[15].toUpperCase()=="YES")
                                                                    needYourAcc=true;
                                                            var parts = InnerData[3].toString().split("/");
                                                            var DateOfBirth = new Date(Number(parts[2]), Number(parts[1]) - 1, Number(parts[0])); 
                                                            var CourseRegistrationRecord = {
                                                                Salutation__c:  InnerData[0],
                                                                First_Name__c:InnerData[1],
                                                                Last_Name__c: InnerData[2],
                                                                Date_of_Birth__c:$A.localizationService.formatDate(DateOfBirth, "yyyy-MM-dd"),
                                                                Preferred_Certificate_Name__c: InnerData[4],
                                                                Gender__c:  InnerData[5],
                                                                Email_Address__c: InnerData[6],
                                                                Mobile_No__c: InnerData[7],
                                                                NRIC_Type__c: InnerData[8],
                                                                NRIC__c: InnerData[9],
                                                                Nationality__c: InnerData[10],
                                                                Office_No__c: InnerData[11],
                                                                Employment_Status__c: InnerData[12],
                                                                Job_Title__c: InnerData[13],
                                                                Designation_Level__c: InnerData[14],
                                                                Need_User_Account__c:InnerData[15],
                                                                PDPA_Consent_Clause__c:true,
                                                                Marketing_Consent_Clause__c:checkVarmarketingVal,
                                                                isChecked:needYourAcc,
                                                            }; 
                                                        }
                                                        if(!component.get('v.piiSection')){
                                                            if(!$A.util.isEmpty(InnerData[12]))
                                                                if(InnerData[12].toUpperCase()=="YES")
                                                                    needYourAcc=true;
                                                            var CourseRegistrationRecord = {
                                                                Salutation__c:  InnerData[0],
                                                                First_Name__c:InnerData[1],
                                                                Last_Name__c: InnerData[2],
                                                                Preferred_Certificate_Name__c: InnerData[3],
                                                                Gender__c:  InnerData[4],
                                                                Email_Address__c: InnerData[5],
                                                                Mobile_No__c: InnerData[6],
                                                                Nationality__c: InnerData[7],
                                                                Office_No__c: InnerData[8],
                                                                Employment_Status__c: InnerData[9],
                                                                Job_Title__c: InnerData[10],
                                                                Designation_Level__c: InnerData[11],
                                                                Need_User_Account__c:InnerData[12],
                                                                PDPA_Consent_Clause__c:true,
                                                                Marketing_Consent_Clause__c:checkVarmarketingVal, 
                                                                isChecked:needYourAcc,
                                                            }; 
                                                        }
                                                        if(InnerData.length==(k+1)){
                                                            // DublicateCourRegistrationList.push(CourseRegistrationRecord);
                                                            CourseRegistrationList.push(CourseRegistrationRecord);
                                                            
                                                            component.set("v.CourseRegistrationList",CourseRegistrationList);
                                                            helper.ShowToastEvent(component, event,$A.get("$Label.c.CourseRegistrationCsvImportMsg"),'Success','success');  
                                                        }  
                                                    }  
                                                }
                                            } 
                                        }
                                        if((allTextLines.length-1)==(i+1) && !iSValidate){
                                            component.set("v.CourseRegistrationList",null);
                                            helper.ShowToastEvent(component, event,sMsg,'Error','error');
                                        }
                                    } 
                                }  
                            }  
                        }
                    });
                    $A.enqueueAction(checkUserEmail);  
                }else{
                    if(iSValidate){
                        for (var i=0; i<allTextLines.length-1; i++) {
                            var data = allTextLines[i].split(';');
                            var tarr = [];
                            for (var j=0; j<data.length; j++) {
                                tarr.push(data[j]);
                                console.log(' 96 j --> '+ i);
                                var iSDublicate
                                var InnerData=data[j].split(',');
                                console.log('iSValidateHeader  183 '+iSValidateHeader)
                                if(i>0 && iSValidateHeader){
                                    var CourseRegistrationList = component.get("v.CourseRegistrationList");
                                    for (var k=0; k<InnerData.length; k++) {
                                        var needYourAcc=false;
                                        
                                        if(iSValidate){
                                            if(component.get('v.piiSection')){
                                                if(!$A.util.isEmpty(InnerData[15]))
                                                    if(InnerData[15].toUpperCase()=="YES")
                                                        needYourAcc=true;
                                                var parts = InnerData[3].toString().split("/");
                                                var DateOfBirth = new Date(Number(parts[2]), Number(parts[1]) - 1, Number(parts[0])); 
                                                var CourseRegistrationRecord = {
                                                    Salutation__c:  InnerData[0],
                                                    First_Name__c:InnerData[1],
                                                    Last_Name__c: InnerData[2],
                                                    Date_of_Birth__c:$A.localizationService.formatDate(DateOfBirth, "yyyy-MM-dd"),
                                                    Preferred_Certificate_Name__c: InnerData[4],
                                                    Gender__c:  InnerData[5],
                                                    Email_Address__c: InnerData[6],
                                                    Mobile_No__c: InnerData[7],
                                                    NRIC_Type__c: InnerData[8],
                                                    NRIC__c: InnerData[9],
                                                    Nationality__c: InnerData[10],
                                                    Office_No__c: InnerData[11],
                                                    Employment_Status__c: InnerData[12],
                                                    Job_Title__c: InnerData[13],
                                                    Designation_Level__c: InnerData[14],
                                                    Need_User_Account__c:InnerData[15],
                                                    PDPA_Consent_Clause__c:true,
                                                    Marketing_Consent_Clause__c:checkVarmarketingVal,
                                                    isChecked:needYourAcc,
                                                }; 
                                            }
                                            if(!component.get('v.piiSection')){
                                                if(!$A.util.isEmpty(InnerData[12]))
                                                    if(InnerData[12].toUpperCase()=="YES")
                                                        needYourAcc=true;
                                                var CourseRegistrationRecord = {
                                                    Salutation__c:  InnerData[0],
                                                    First_Name__c:InnerData[1],
                                                    Last_Name__c: InnerData[2],
                                                    Preferred_Certificate_Name__c: InnerData[3],
                                                    Gender__c:  InnerData[4],
                                                    Email_Address__c: InnerData[5],
                                                    Mobile_No__c: InnerData[6],
                                                    Nationality__c: InnerData[7],
                                                    Office_No__c: InnerData[8],
                                                    Employment_Status__c: InnerData[9],
                                                    Job_Title__c: InnerData[10],
                                                    Designation_Level__c: InnerData[11],
                                                    Need_User_Account__c:InnerData[12],
                                                    PDPA_Consent_Clause__c:true,
                                                    Marketing_Consent_Clause__c:checkVarmarketingVal, 
                                                    isChecked:needYourAcc,
                                                }; 
                                            }
                                            if(InnerData.length==(k+1)){
                                                // DublicateCourRegistrationList.push(CourseRegistrationRecord);
                                                CourseRegistrationList.push(CourseRegistrationRecord);
                                                
                                                component.set("v.CourseRegistrationList",CourseRegistrationList);
                                                helper.ShowToastEvent(component, event,$A.get("$Label.c.CourseRegistrationCsvImportMsg"),'Success','success');  
                                            }  
                                        }  
                                    }
                                } 
                            }
                            if((allTextLines.length-1)==(i+1) && !iSValidate){
                                component.set("v.CourseRegistrationList",null);
                                helper.ShowToastEvent(component, event,sMsg,'Error','error');
                            }
                        } 
                    }
                    
                }
            }
            component.set("v.fileStorage" , null);
            component.set("v.fileName", null);
            component.set("v.fileLenght",0);
        }else{
            helper.ShowToastEvent(component, event,$A.get("$Label.c.CourseRegistrationCsvIsNullMsg"),'Warning','warning');                             
        }
    },
    handleDeclineClick : function(component, event, helper) {   
        var checkVar = component.find("checkbox");
        if (checkVar.get("v.value") == true)  {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "/s/"  
            });
            urlEvent.fire();
        } else {
            component.set("v.declineModalOpen", true);            
        }   
    }, 
    closeDeclineModel: function(component, event, helper) {
        component.set("v.declineModalOpen", false);
    },
    dateOfBirthChange: function(component, event, helper) {     	
        var dobField = component.find("dobId");
        var dobValue = dobField.get("v.value");
        var todayDate = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        console.log(dobValue + 'dob==');
        console.log(todayDate + 'for==');
        if(dobValue != '' && dobValue > todayDate) {
            component.set("v.dateValidationError" , true);
        } else{
            component.set("v.dateValidationError" , false);
        }
    },
    firstOrLastNameChange: function(component, event, helper) {
        console.log('firstOrLastNameChange');
        var fNameField = component.find("fNameId");
        var fNameValue = fNameField.get("v.value");
        var lNameField = component.find("lNameId");
        var lNameValue = lNameField.get("v.value");
        var prefCertificateName=(!$A.util.isEmpty(lNameValue)?lNameValue:"") + " " + (!$A.util.isEmpty(fNameValue)?fNameValue:"");
        component.find("prefCertificateId").set("v.value", prefCertificateName);
        
        /*var prefCertificateName='';
        if(!$A.util.isEmpty(fNameValue))
            prefCertificateName=fNameValue;
        if(!$A.util.isEmpty(lNameValue) &&!$A.util.isEmpty(prefCertificateName))
            lNameValue=lNameValue+ " " +prefCertificateName
            component.find("prefCertificateId").set("v.value", lNameValue);*/
    } ,
    closeNricModel: function(component, event, helper) {      
        var nricLength = component.get("v.NricLengthValidation");
        var firstCharMsg = component.get("v.NricFirstCharValidation");
        var nricMiddleMsg = component.get("v.NricMiddleValValidation");
        var nricEndCharMsg = component.get("v.NricEndCharValidation");
        if(nricLength == true) {
            component.set("v.NricLengthValidation", false);
        }
        if(firstCharMsg == true) {
            component.set("v.NricFirstCharValidation", false);
        }
        if(nricMiddleMsg == true) {
            component.set("v.NricMiddleValValidation", false);
        }
        if(nricEndCharMsg == true) {
            component.set("v.NricEndCharValidation", false);
        }
        component.set("v.NricModalOpen", false);
    },
    onclickOk: function(component, event, helper) {  
        component.set("v.acceptModalOpen", false);     
        component.find("checkbox").focus();    
    },
    onclickOkPdpa: function(component, event, helper) {  
        component.set("v.PDPAModalOpen", false);     
        component.find("checkbox_pdpa").focus();    
    },
    onclickOkEmailError: function(component, event, helper) {  
        component.set("v.EmailError", false);     
    },
    selectAllCheckbox: function(component, event, helper) {
        
        var checkVar = component.find("selectAllId");
        var updatedAllRecords = [];
        // alert('parent selection-- '+checkVar.get("v.value"));
        var existingCourseRegistration = component.get("v.CourseRegistrationList");
        for (var i = 0; i < existingCourseRegistration.length; i++) {
            if (checkVar.get("v.value")) {
                existingCourseRegistration[i].isChecked = true;
            } else {
                existingCourseRegistration[i].isChecked = false;
            }
            updatedAllRecords.push(existingCourseRegistration[i]);
        }
        component.set("v.CourseRegistrationList",updatedAllRecords);
    },
    applyPromocode:function(component, event, helper) {
        // MPV1.1 Added by Devender to Promo Code Proccess
        var PromoCode = component.find("PromoCode");
        console.log('1231 PromoCode --> '+PromoCode.get("v.value"));
        if(!$A.util.isEmpty(PromoCode.get("v.value"))){
            helper.getPromoCode(component, event,PromoCode.get("v.value"))
            component.set("v.PromoCode", PromoCode.get("v.value"));
        }else{
            console.log('in else PromoCode --> '+PromoCode.get("v.value"));
            helper.ShowToastEvent(component, event,$A.get("$Label.c.CourseRegistrationPromoCodeNullMsg"),'Warning','warning' ); 
        }  
    },
    RemovePromocode : function (component, event, helper) {
        component.find("PromoCode").set("v.value","");
        component.set("v.PromoCodeId","");
        component.set("v.PromoCodeApply",false);
    }
})