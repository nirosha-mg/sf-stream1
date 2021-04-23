({
    onInit : function(component, event, helper) {
        var crCode = helper.getJsonFromUrl().courseruncode;
        component.set("v.courseRunCode", crCode);
        // MPV1.1 Added by Ravi to redirect on bulk registraion if user is b2b spoc
        helper.checkUserProfile(component, event,crCode);
        //Get Course Run Record
        var getCourseRunRecord = component.get('c.getCourseRunRecord');
        getCourseRunRecord.setParams({courseRunCode: crCode});
        getCourseRunRecord.setCallback(this, function(response) {             
            if(response.getState() === "SUCCESS") {
                component.set("v.courseRunRecord", response.getReturnValue());
                var courseRunRec = response.getReturnValue();
                //MVP1.1: added by Ravi 25th march 2021 to enable or disable the PII section 
                if(courseRunRec.CourseRecordType__c=='Funded_Course' || courseRunRec.Course__r.Need_PII__c){
                    component.set("v.piiSection",true);
                }
                if (courseRunRec.Id != null) {
                     //MVP1.1: added by Devender 15 April 2021 for Promo code 
                    component.set("v.courseRunStartDate",courseRunRec.Start_Date__c);
                    var cRunRegStartDt = courseRunRec.Registration_Open_Date__c;                
                    var cRunregCloseDt = courseRunRec.Registration_Close_Date__c;
                    component.set("v.courseId", courseRunRec.Course__c);
                    var cRunActive = courseRunRec.Active__c; 
                    var cRunCapacity = courseRunRec.Capacity__c;                 
                    var regChildRecs = courseRunRec.Course_Registrations__r;                    
                    var cRun_regCount = 0;
                	if(!$A.util.isEmpty(regChildRecs)) { 
                        cRun_regCount = regChildRecs.length;
                	}
                    var todayDate = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");               
                    var overlap = (cRunRegStartDt <= todayDate) && (todayDate <= cRunregCloseDt) ? 'true' : 'false';                
                    if(overlap == 'false' || cRunActive == false || (cRunCapacity == cRun_regCount || cRunCapacity < cRun_regCount)) {                        
                        component.set("v.isOpen", true);
                    }
                    else {
                        //Check if Contact has registered for this course
                        var checkRegistration = component.get('c.checkContactRegistration');
                        checkRegistration.setParams({ courseRunId: courseRunRec.Id });
                        checkRegistration.setCallback(this, function(response) {             
                            if(response.getState() === "SUCCESS") {
                                var courseRegId = response.getReturnValue();
                                console.log(response);
                                if (courseRegId != null) {
                                    //Already Registered
                                    //2001141615 Desmond Remove the group Registration screen
                                    component.set("v.isDeclareClose", false);
                                    component.set("v.courseRegistrationId", courseRegId);
                                    helper.createModal(component, "", "You have an existing registration.\nWe will now redirect you to your existing registration", "c.redirectToHome", false);
                                }
                                else {
                                    component.set("v.isOpen", false);
                                    //2001141615 Desmond Add the group Registration screen
                                    component.set("v.isDeclareClose", true);
                                }
                            }
                            else {
                                component.set("v.isOpen", false);
                                //2001141615 Desmond Add the group Registration screen
                                component.set("v.isDeclareClose", true);
                            }
                        });
                        $A.enqueueAction(checkRegistration); 
                    }
                }
                else {
                    //Course Run Not Found
                    helper.createModal(component, "", "Course is not available. Please contact us via the Help Center", "c.redirectToHelpCenter", false);
                }
            } else if(response.getState() == "ERROR"){
                var errors = response.getError();    
                alert(errors[0].message);
            }
        });
        $A.enqueueAction(getCourseRunRecord);      
    },
    handleNext : function(component, event, helper) {        
        var currentTab = component.get("v.selTabId");
        if(currentTab == 'particulars') {
        
        
           var nricTypeField = component.find("NricTypeId");
            var nricField = component.find("NricId");
            var nricIsValid = "valid";
            // MVP1.1:commented by Ravi on 25th march as it is to be used in course section
            // NRIC validation - start     
           /* if(!$A.util.isEmpty(nricField.get("v.value")) && 
               (nricTypeField.get("v.value") == 'FIN' || 
               nricTypeField.get("v.value") == 'Singapore Citizen/PR')) {
                    nricIsValid = 'invalid';
        			var nricval = nricField.get("v.value");                    
                    if (nricval.length != 9) {
                       // alert('Invalid NRIC and length of Nric is not matched');
                      	 component.set("v.NricLengthValidation", true);
                      	 component.set("v.NricModalOpen", true); 
                        nricIsValid = 'invalid';
                    } else { 
                    	var firstchar = nricval.charAt(0);
        				var lastchar = nricval.charAt(nricval.length - 1);
                        if(firstchar != 'S' && firstchar != 's' && firstchar != 'F' && firstchar != 'f' &&
                           firstchar != 'T' && firstchar != 't' && firstchar != 'G' && firstchar != 'g') {
                            // alert('First character of NRIC is not Invalid');
                            component.set("v.NricFirstCharValidation", true);
                      	    component.set("v.NricModalOpen", true);
                            nricIsValid = 'invalid';
                        }
                        var numericNric = nricval.substr(1, nricval.length - 2);
                        if (isNaN(numericNric)) {                            
                           // alert('Invalid: NRIC Middle values is not a number');
                            component.set("v.NricMiddleValValidation", true);
                      	    component.set("v.NricModalOpen", true); 
                            nricIsValid = 'invalid';
                        }
                        var nricResult = component.get('c.validateNRICValue');
                        nricResult.setParams({nricVal: nricval});
                        nricResult.setCallback(this, function(response) {  
                            if(response.getState() === "SUCCESS") {
                            	var resultOfNric = response.getReturnValue();                               
                                if(resultOfNric == 'invalid') {
                                    nricIsValid = 'invalid';
                                   // alert('Invalid end Character'); 
                                   component.set("v.NricEndCharValidation", true);
                      	    	   component.set("v.NricModalOpen", true);
                                } else {
                                    nricIsValid = 'valid'; 
                                    helper.validateFields(component, event, nricIsValid);                                   
                                }
                            } else if(response.getState() == "ERROR"){
                                var errors = response.getError();    
                                console.log(errors[0].message);
                            }
                        });
                        $A.enqueueAction(nricResult);  
                    }
            }*/
            if(nricIsValid == "invalid") {
                component.set("v.selTabId" , 'particulars');
            }
            else {

                helper.validateFields(component, event,nricIsValid);
            }
            // Poon Koon 2021-04-22: Add in Marketing Channels check if Marketing consent checkbox is checked.
            var checkVar = component.find("checkbox_pdpa");
            var checkMarketingVar = component.find("checkbox_marketing");
            var marketingChannelsChosen = component.get("v.marketingchannelschosen");
            console.log("marketingChannelsChosen >> " + marketingChannelsChosen);
            if (checkVar.get("v.value") == false || (checkMarketingVar.get("v.value") == true && marketingChannelsChosen == ""))
            {
                //alert('Hello Error');;
                component.set("v.acceptPDPAOpen",true);
            }
            
        } else if(currentTab == 'Billing') {
            var attentionField = component.find("attentionId");
            attentionField.reportValidity();
            var BL1Field = component.find("BL1Id");
            BL1Field.reportValidity();            
            var bPostalField = component.find("BpostalId");
            bPostalField.reportValidity();
            var bCountryField = component.find("bCountryId");
            bCountryField.reportValidity();
            var bAddTypeField = component.find("BlAddressTypeId");
            bAddTypeField.reportValidity();
            var prefContactMethodField = component.find("prefContactMethodId");
            prefContactMethodField.reportValidity();
            
            if($A.util.isEmpty(bCountryField.get("v.value"))) {
               // component.set("v.contactInfowrapper.billingCountry","Singapore");               
                component.find("bCountryId").set("v.value", "Singapore");
            }
            
            if(!$A.util.isEmpty(attentionField.get("v.value")) && 
               !$A.util.isEmpty(BL1Field.get("v.value")) &&
               !$A.util.isEmpty(bPostalField.get("v.value")) && 
               !$A.util.isEmpty(bCountryField.get("v.value")) && 
               !$A.util.isEmpty(bAddTypeField.get("v.value")) &&
               !$A.util.isEmpty(prefContactMethodField.get("v.value"))) {
               var alternativeSec = component.get("v.alternativeIsOpen");
               if(alternativeSec == false) {
                    component.set("v.selTabId" , 'course');         
                } else {
                    var alterAttentionField = component.find("alterAttentionId");
                    alterAttentionField.reportValidity();
                    var alterBA1Field = component.find("alterBd1Id");
                    alterBA1Field.reportValidity();
                    var alterPhoneField = component.find("alterPhneId");
                    alterPhoneField.reportValidity();
                    var alterEmailField = component.find("alterEmailId");
                    alterEmailField.reportValidity();
                    var alterPostalField = component.find("alterPostalId");
                    alterPostalField.reportValidity();
                    var alterCountryField = component.find("alterCountryId");
                    alterCountryField.reportValidity();                                                
                    if($A.util.isEmpty(alterCountryField.get("v.value"))) {                             
                        component.find("alterCountryId").set("v.value", "Singapore");
                    }
					var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;                      
                    if(!$A.util.isEmpty(alterEmailField.get("v.value"))) {
                        var alterEmailVal = alterEmailField.get("v.value");
                        if(!alterEmailVal.match(regExpEmailformat)) {
                            alterEmailField.setCustomValidity("Enter valid Email");
                            alterEmailField.reportValidity();
                        }
                    }                   
                    if(!$A.util.isEmpty(alterAttentionField.get("v.value")) && 
                       !$A.util.isEmpty(alterBA1Field.get("v.value")) &&
                       !$A.util.isEmpty(alterPhoneField.get("v.value")) && 
                       !$A.util.isEmpty(alterEmailField.get("v.value"))&&
                       !$A.util.isEmpty(alterPostalField.get("v.value")) && 
                       !$A.util.isEmpty(alterCountryField.get("v.value"))) {
                        component.set("v.selTabId" , 'course');   
                    }
                } 
            } else {
                var accountRecordtype = component.get("v.contactRecord.Account.RecordType.DeveloperName");   
                if(accountRecordtype == 'B2B_Account') {
                   component.set("v.billingAddressModalOpen", true); 
                }
            }
        }  
        else if(currentTab == 'course') {  
            component.set('v.validFundingList',null);
            var fundingList = component.get("v.fundingList");  
            var fundingListExist = false;
            
            if(fundingList.length > 0) {
                var valueArr = fundingList.map(function(item){ return item.Funding__c });
                var isDuplicate = valueArr.some(function(item, idx) { 
                    return valueArr.indexOf(item) != idx 
                });
                console.log(isDuplicate + 'isduplicate==');
                if(isDuplicate == true) {
                    component.set("v.duplicateFundingRecord", true);
                    component.set("v.InvalidFundingModalOpen", true);   
                } 
                else {
                    var validFundingList = [];
                    let isValid = true;
                    var courseRecordType = component.get("v.courseRunRecord.CourseRecordType__c");
                    var nonMemberFee = component.get("v.courseRunRecord.Course__r.Non_Member_Fee__c");
                    var fullFee = component.get("v.courseRunRecord.Course__r.Full_Fee__c");
                    var nonMemberTotalFee = component.get("v.courseRunRecord.Course__r.Non_Member_Total_Fee__c");
                    var fullTotalFee = component.get("v.courseRunRecord.Course__r.Full_Fee_with_GST__c");
                    for (let i = 0; i < fundingList.length; i++) {
                        //Add Specific SFC condition
                        if (fundingList[i].Funding__c == 'SkillsFuture Credit') {
                            if(courseRecordType == "Funded_Course" &&                                    
                               fundingList[i].Amount__c > fullTotalFee) {
                                component.set("v.InvalidAmountFundedCourse", true);
                                component.set("v.InvalidFundingModalOpen", true);                       
                                isValid = false;
                            }  else if(courseRecordType != "Funded_Course" && 
                                       fundingList[i].Amount__c > nonMemberTotalFee) {
                                component.set("v.InvalidAmountFundedCourse", true);
                                component.set("v.InvalidFundingModalOpen", true);                       
                                isValid = false;
                            }
                        }
                        else {
                            if(courseRecordType == "Funded_Course" &&                                    
                               fundingList[i].Amount__c > fullFee) {
                                component.set("v.InvalidAmountFundedCourse", true);
                                component.set("v.InvalidFundingModalOpen", true);                       
                                isValid = false;
                            }  else if(courseRecordType != "Funded_Course" && 
                                       fundingList[i].Amount__c > nonMemberFee) {
                                component.set("v.InvalidAmountFundedCourse", true);
                                component.set("v.InvalidFundingModalOpen", true);                       
                                isValid = false;
                            }
                        }
                        if (fundingList[i].Amount__c === '' || fundingList[i].Funding__c == '') {
                            component.set("v.InvalidFundingRecord", true);
                            component.set("v.InvalidFundingModalOpen", true);                        
                            isValid = false;
                        } else if(fundingList[i].Amount__c <= 0 && 
                                  fundingList[i].Funding__c == 'SkillsFuture Credit') {
                            component.set("v.InvalidAmountRecord", true);
                            component.set("v.InvalidFundingModalOpen", true);                        
                            isValid = false;
                        }
                            else {
                                validFundingList.push(fundingList[i]);
                            }
                    }
                    console.log(validFundingList + 'li==');
                    if(validFundingList.length > 0 && isValid == true) {
                        component.set('v.validFundingList',validFundingList);
                        fundingListExist = true;
                        // mvp1.1 start: added by Ravi on 25th march 2021 for the validation of PII section field
                        if(component.get("v.piiSection")){
                         	helper.validatePIISection(component, event);   
                        }else{
                            component.set("v.selTabId" , 'summary');  
                        }
                    }
                }
                
            } else {
                    fundingListExist = false;
                // mvp1.1 start: added by Ravi on 25th march 2021 for the validation of PII section field
                if(component.get("v.piiSection")){
                    helper.validatePIISection(component, event);   
                }else{
                  component.set("v.selTabId" , 'summary');  
                }  
            }
            
        } 
    },
    handlePrevious : function(component, event, helper) {
        var currentTab = component.get("v.selTabId");
        if(currentTab == 'Billing') {
            component.set("v.selTabId" , 'particulars');
        } 
        else if(currentTab == 'course') {
            component.set("v.selTabId" , 'Billing');
        } else if(currentTab == 'summary') {
            component.set("v.selTabId" , 'course');  
        } 
    },
    handleOnSuccess : function(component, event, helper) {        
        var params = event.getParams();
        //alert('Registration created successfully');
        //component.set("v.regSuccessModalOpen", true);
        component.set("v.courseRegistrationId" , params.response.id);

        var buttonLabel = component.get('v.buttonlabel');         
        
        if(buttonLabel == 'Draft') {          
            helper.createLearnerFunding(component, event);
             // Attachment - start
             console.log(component.find("fileId").get("v.files") + 'file==');
            if (component.find("fileId").get("v.files").length > 0) {
                helper.uploadHelper(component, event);
            }
            // Attachment - end
        }
        if(buttonLabel == 'Submit') {            
            var member = component.find("isMemberValue");  
            var isMember = member.get("v.value");     
            var provider = component.get("v.courseRunRecord.Course__r.Provider__c");
            var courseRecordType = component.get("v.courseRunRecord.CourseRecordType__c");
            var fundingAvailed = $A.util.isEmpty(component.get("v.validFundingList")) == false;
            if (courseRecordType == 'Funded_Course') {
                //Do not allow direct payment for all funded course
                helper.createLearnerFunding(component, event); 
            }
            else {
                if (!isMember && provider == 'SIM' && !fundingAvailed) {
                    component.set("v.PaymentModalOpen", true);  
                }
                else if (provider == 'RMIT' && !fundingAvailed) {
                    component.set("v.PaymentModalOpen", true);  
                }
                else {
                    helper.createLearnerFunding(component, event); 
                }
            }
            /*
            if(isMember == true) { 
                if((provider == 'SIM' || provider == 'RMIT') 
                    && JSON.stringify(component.get("v.validFundingList")) != 'null') {
                   helper.createLearnerFunding(component, event); 
                } else if(provider == 'SIM' && $A.util.isEmpty(component.get("v.validFundingList"))) {
                    helper.createLearnerFunding(component, event);
                } 
                else if(provider == 'RMIT' && $A.util.isEmpty(component.get("v.validFundingList"))) {
                   component.set("v.PaymentModalOpen", true);  
                }
                
            } else {                   
                if(JSON.stringify(component.get("v.validFundingList")) != 'null') { 
                   helper.createLearnerFunding(component, event);
                } else {
                    component.set("v.PaymentModalOpen", true);                    
                } 
            }
            */
             // Attachment - start
            if (component.find("fileId").get("v.files").length > 0) {
                helper.uploadHelper(component, event);
            } /*else {
                    alert('Please Select a Valid File');
                } */
            // Attachment - end
        }
        
    },
    handleOnSubmit : function(component, event, helper) { 
       var buttonLabel = component.get('v.buttonlabel');        
        event.preventDefault(); //Prevent default submit
        var eventFields = event.getParam("fields"); //get the fields
        if(buttonLabel == 'Draft') {
            eventFields["Registration_Status__c"] = 'Draft';
            //<!--MVP1.1: added by Devender:14th April 2021 to set the promo code id in course registration object -->
            eventFields["Promo_Code__c"] = component.get("v.PromoCodeId");            
        } if(buttonLabel == 'Submit') {
            eventFields["Registration_Status__c"] = 'New';
            //<!--MVP1.1: added by Devender:14th April 2021 to set the promo code id in course registration object -->
            console.log("in submit PromoCodeId --> "+ component.get("v.PromoCodeId"));
            eventFields["Promo_Code__c"] = component.get("v.PromoCodeId");
        }
        eventFields["Sync_Learner_s_Record__c"] = true;
        eventFields["Course_Run_Id__c"] = component.get("v.courseRunRecord.Id");
        eventFields["Contact__c"] = component.get("v.contactRecord.Id"); 
        var accountRecordtype = component.get("v.contactRecord.Account.RecordType.DeveloperName");        
        if(accountRecordtype == 'B2B_Account') {
            eventFields["Company_UEN_No__c"] = component.get("v.contactRecord.Account.UEN_No__c"); 
        }
		// Poon Koon 2/24/2021: Populate Preferred Certificate Name with Last Name + First Name if empty        
        if(eventFields["Preferred_Certificate_Name__c"] == '') {
            eventFields["Preferred_Certificate_Name__c"] = eventFields["Last_Name__c"] + " " + eventFields["First_Name__c"];
        }        
        // Poon Koon 3/2/2021: Populate consent fields with checkbox values
        eventFields["Marketing_Consent_Clause__c"] = component.find("checkbox_marketing").get("v.value");
        eventFields["PDPA_Consent_Clause__c"] = component.find("checkbox_pdpa").get("v.value");
        
        var crCode = component.get("v.courseRunCode");
        var getCourseRun = component.get('c.getCourseRunRecord');
        getCourseRun.setParams({courseRunCode: crCode});
        getCourseRun.setCallback(this, function(response) {             
            if(response.getState() === "SUCCESS") {               
                var courseRun = response.getReturnValue(); 
                var cRunCapacity = courseRun.Capacity__c; 
                //var cRun_regCount = courseRun.No_of_Registrations__c;   
                var regChildRecs = courseRun.Course_Registrations__r;
                var cRun_regCount = 0;
                if(!$A.util.isEmpty(regChildRecs)) {                 
                	cRun_regCount = regChildRecs.length;
                }
                if(cRunCapacity == cRun_regCount || cRunCapacity < cRun_regCount) {
                    component.set("v.isOpen", true);
                } else {
                     console.log("eventFields ---> "+JSON.stringify(eventFields));
                	component.find('regForm').submit(eventFields); //Submit Form 
                }
            } else if(response.getState() == "ERROR"){
                var errors = response.getError();    
                alert(errors[0].message);
            }
        });
        $A.enqueueAction(getCourseRun);
    },
    handleAcceptClick : function(component, event, helper) {
        var checkVar = component.find("checkbox");
        if (checkVar.get("v.value") == true)  {
            var currentTab = component.get("v.selTabId");        
            component.set("v.selTabId" , 'particulars');
            //Get Contact Id for Record Edit Form
            var getContactAction = component.get('c.getContactRecord');
            
            getContactAction.setCallback(this, function(response) { 
                if(response.getState() === "SUCCESS") { 
                    var varContactInfowrapper =  response.getReturnValue();                    
                    component.set("v.contactRecord", varContactInfowrapper.objContact);     
                    //contactInfowrapper 
                    component.set("v.contactInfowrapper", response.getReturnValue());              
                    var contactRecord = component.get("v.contactRecord");
                    //component.set("v.memberCheckbox", contactRecord.Account.Membership_Active__c); //Changed to if Membership No is populated
                    var isMember = (contactRecord.Account.Membership_No__c != '' && 
                                    (contactRecord.Account.Membership_Payment_Status__c == 'ACTIVE PAID MEMBER' ||
                                    contactRecord.Account.Membership_Payment_Status__c == 'ACTIVE UNPAID MEMBER' ||
                                    contactRecord.Account.Membership_Payment_Status__c == ''));
                    component.set("v.memberCheckbox", isMember);
                    component.set("v.rmitCheckbox", contactRecord.RMIT_Alumni__c);
                    
                }}); 
            
            $A.enqueueAction(getContactAction);   
        } else {           
            component.set("v.acceptModalOpen", true);
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
    handleAlternativeCheck : function(component, event, helper) {
        component.set("v.alternativeIsOpen",event.getSource().get("v.value") );
    },
    handleCreateRegistration: function(component, event, helper) {
        alert('button click');      
        component.find("regForm").submit();
    },
    handleError: function(component, event) {
        var errors = event.getParams();         
        console.log("response", JSON.stringify(errors));
        component.find('ErrMessage').setError('Undefined error occured');
    },
    handleSaveAsDraft : function(component, event, helper) {
        component.set('v.buttonlabel','Draft');
        // Sanjay 2/22/2021: Set the disableButton class in the disableClass variable to prevent the multiple clicks
        component.set('v.disableClass','disableButton');

        //2101261130 Desmond Need to add so that cours reg can be created as draft
        var buttonLabel = component.get('v.buttonlabel');         
        
        if(buttonLabel == 'Draft') {          
            helper.createLearnerFunding(component, event);
             // Attachment - start
             console.log(component.find("fileId").get("v.files") + 'file==');
            if (component.find("fileId").get("v.files").length > 0) {
                helper.uploadHelper(component, event);
            }
            // Attachment - end
        }
        //2101252000 after save as draft and saved disabled the button
        //component.set('v.disabled', true);        
    },
    handleCustomSubmit : function(component, event, helper) {
        // Sanjay 2/22/2021: Set the disableButton class in the disableClass variable to prevent the multiple clicks
        component.set('v.disableClass','disableButton');
        component.set('v.buttonlabel','Submit');        
    },
    fundingListEventController: function(component, event, helper) {
        var fundingList = event.getParam("fundingList"); 
        //Set the handler attributes based on event data 
        component.set("v.fundingList", fundingList);
    },
    closeModelLater: function(component, event, helper) {
      component.set("v.PaymentModalOpen", false);
      component.set("v.isExecutiveModalOpen", true);
    },
    redirectToPayment: function(component, event, helper) {
      component.set("v.PaymentModalOpen", false);
      //  component.set("v.selTabId" , 'Payment');
       var regId = component.get("v.courseRegistrationId");        
        var getinvoice = component.get('c.returnInvoice');
        getinvoice.setParams({courseRegId: regId});
        getinvoice.setCallback(this, function(response) { 
            if(response.getState() === "SUCCESS") {
                var invoiceId = response.getReturnValue(); 
                //if(invoiceId != null || invoiceId != undefined) {
                   component.set("v.invoiceId" , invoiceId);  				                
            		component.set("v.selTabId" , 'Payment');   
                //}
				
            } else if(response.getState() == "ERROR"){
                var errors = response.getError();    
                console.log(errors[0].message);
            }
        }); 
        $A.enqueueAction(getinvoice);        
      
   },
    redirectToHome : function (component, event, helper) {
        var cRegId = component.get("v.courseRegistrationId");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/s/course-registration/" + cRegId
        });
        urlEvent.fire();
   },
   //Desmond 200115
   redirectHome : function (component, event, helper) {
    //var cRegId = component.get("v.courseRegistrationId");
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
        "url": "/s/"
    });
    urlEvent.fire();
   },
   redirectClose : function (component, event, helper) {
        component.set("v.isDeclareClose",false);
   },    
   redirectToHelpCenter : function (component) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/s/contactsupport"
        });
        urlEvent.fire();
   },
   handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
    },
    handleChange : function(component, event, helper) {
        var memberCheckbox = component.get("v.memberCheckbox");
        memberCheckbox = !memberCheckbox;
        component.set("v.memberCheckbox", memberCheckbox);
        var member = component.find("isMemberValue");
    },
    handleChangeRmit : function(component, event, helper) {
        var rmitCheckbox = component.get("v.rmitCheckbox");
        rmitCheckbox = !rmitCheckbox;
        component.set("v.rmitCheckbox", rmitCheckbox);        
    },
    redirectToMainHome : function (component, event, helper) {
        var cRegId = component.get("v.courseRegistrationId");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/s/"  
        });
        urlEvent.fire();
   },
   closeModel: function(component, event, helper) {
      component.set("v.acceptModalOpen", false);
   },
   closePDPAModel: function(component, event, helper) {
    component.set("v.acceptPDPAOpen", false);
    component.set("v.selTabId" , 'particulars');
   },
   closeDeclineModel: function(component, event, helper) {
      component.set("v.declineModalOpen", false);
   },
   closeFundingModel: function(component, event, helper) {      
       var fundingRec = component.get("v.InvalidFundingRecord");
       var amountMsg = component.get("v.InvalidAmountRecord");
       var duplicateRecMsg = component.get("v.duplicateFundingRecord");
       var amountWithFundedCourse = component.get("v.InvalidAmountFundedCourse");
       if(fundingRec == true) {
           component.set("v.InvalidFundingRecord", false);
       }
       if(amountMsg == true) {
           component.set("v.InvalidAmountRecord", false);
       }
       if(duplicateRecMsg == true) {
           component.set("v.duplicateFundingRecord", false);
       } 
       if(amountWithFundedCourse == true){
           component.set("v.InvalidAmountFundedCourse", false);
       }
       component.set("v.InvalidFundingModalOpen", false);
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
   //23Feb2021 - Poon Koon - Update Preferred Certificate Name When First Or Last Name Changed
   firstOrLastNameChange: function(component, event, helper) {     	
        console.log('firstOrLastNameChange');

        var fNameField = component.find("fNameId");
        var fNameValue = fNameField.get("v.value");
        var lNameField = component.find("lNameId");
        var lNameValue = lNameField.get("v.value");
        
        component.set("v.contactRecord.Preferred_Certificate_Name__c", lNameValue + " " + fNameValue);
    },
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
    applyPromocode:function(component, event, helper) {
         // MPV1.1 Added by Devender to Promo Code Proccess
        var PromoCode = component.find("PromoCode");
        console.log('PromoCode --> '+PromoCode.get("v.value"));
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