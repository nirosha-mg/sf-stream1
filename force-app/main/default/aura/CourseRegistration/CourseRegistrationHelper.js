({	
    getJsonFromUrl : function () {
        var query = location.search.substr(1);
        var result = {};
        query.split("&").forEach(function(part) {
            var item = part.split("=");
            result[item[0]] = decodeURIComponent(item[1]);
        });
        return result;
    },
    
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb 
    
    uploadHelper: function(component, event) {        
        // get the selected files using aura:id [return array of files]
        var fileInput = component.find("fileId").get("v.files");
        // get the first file using array index[0]  
        var file = fileInput[0];
        var self = this;       
        if (file.size > self.MAX_FILE_SIZE) {            
            component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            return;
        }
        
        // create a FileReader object 
        var objFileReader = new FileReader();
        // set onload function of FileReader object   
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
            
            fileContents = fileContents.substring(dataStart);
            // call the uploadProcess method 
            self.uploadProcess(component, file, fileContents);
        });
        
        objFileReader.readAsDataURL(file);
    },
    
    uploadProcess: function(component, file, fileContents) {
        // set a default size or startpostiton as 0 
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value   
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
        
        // start with the initial chunk, and set the attachId(last parameter)is null in begin
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '');
    },
    
    
    uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId) {
        // call the apex method 'saveChunk'
        var getchunk = fileContents.substring(startPosition, endPosition);
        var action = component.get("c.saveChunk");
        action.setParams({
            parentId: component.get("v.courseRegistrationId"),
            fileName: file.name,
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type,
            fileId: attachId
        });
        
        // set call back 
        action.setCallback(this, function(response) {
            // store the response / Attachment Id   
            attachId = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                // update the start position with end postion
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);               
                if (startPosition < endPosition) {
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId);
                } else {
                    // alert('your File is uploaded successfully');
                }
                // handel the response errors        
            } else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        // enqueue the action
        $A.enqueueAction(action);
    },    
    
    createLearnerFunding : function(component, event) { 
        var buttonLabel = component.get('v.buttonlabel');
        var courseRegId = component.get("v.courseRegistrationId");
        if($A.util.isEmpty(component.get("v.validFundingList"))) {
            if(buttonLabel == 'Draft'){
                component.set("v.isDraftOpen", true);    
            } 
            if(buttonLabel == 'Submit') {
                component.set("v.isExecutiveModalOpen", true);               
                
            }
        }
        else {
            var action = component.get('c.insertFundingRecords');
            action.setParams({learnerFundList: component.get("v.validFundingList"),
                              courseRegId: courseRegId});
            action.setCallback(this, function(response) {
                if(response.getState() === "SUCCESS") {
                    // alert('Learner Funding records created successfully');
                    if(buttonLabel == 'Draft'){
                        component.set("v.isDraftOpen", true);    
                    } 
                    if(buttonLabel == 'Submit') {
                        component.set("v.isExecutiveModalOpen", true);               
                    }
                    
                } else if(response.getState() == "ERROR"){
                    var errors = response.getError();    
                    console.log(errors[0].message);
                }
            });
            $A.enqueueAction(action);
        }          
        
    },
    validateFields : function(component, event, validVar) {
        var errMsg = '';      
        component.set("v.reqMsgSection", false);
        var salutationField = component.find("salutationId");
        salutationField.reportValidity();
        var fNameField = component.find("fNameId");
        fNameField.reportValidity();
        var lNameField = component.find("lNameId");
        lNameField.reportValidity();
        /*var dobField = component.find("dobId");
            dobField.reportValidity();*/
        var genderField = component.find("genderId");
        genderField.reportValidity();
        /*var nricField = component.find("NricId");
            nricField.reportValidity();*/
        var emailField = component.find("emailId");
        emailField.reportValidity();
        /*var nricTypeField = component.find("NricTypeId");
            nricTypeField.reportValidity();  */
        /*var primaryEmailField = component.find("pEmailId");
            primaryEmailField.reportValidity(); */
        var nationalityField = component.find("NationalityId");
        nationalityField.reportValidity();
        var mbleField = component.find("MblenoId");
        mbleField.reportValidity();
        var raceField = component.find("raceId");
        raceField.reportValidity();
        var residencyStatusField = component.find("rStatus");
        residencyStatusField.reportValidity();
        var ofceNoField = component.find("ofceNoId");
        ofceNoField.reportValidity();
        var eduLevelField = component.find("eduLevelId");
        eduLevelField.reportValidity();
        /* Poon Koon 2/24/2021: Make Perferred Certificate Name optional
            var prefCertField = component.find("prefCertificateId");
            prefCertField.reportValidity();*/
        
        
        // var empStatusField = component.find("empStatusId");
        // empStatusField.reportValidity();
        var jobTitleField = component.find("jobTitleId");
        jobTitleField.reportValidity();           
        var dsgLevelField = component.find("designationLevelId");
        dsgLevelField.reportValidity();    
        //Nirosha - 04/24/2021: Added new required field(How did you get to know us?)
        var knowAboutUsField = component.find("knowAboutUsId");
        knowAboutUsField.reportValidity();
        // var designationField = component.find("designationId");
        // designationField.reportValidity();
        var courseRecType = component.get("v.courseRunRecord.CourseRecordType__c");
        var isDateError = component.get("v.dateValidationError");
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;  
        if(!$A.util.isEmpty(emailField.get("v.value"))) {
            var emailVal = emailField.get("v.value");
            if(!emailVal.match(regExpEmailformat)) {
                $A.util.addClass(emailField, 'slds-has-error');
                // emailField.setCustomValidity("Enter valid Email");
                emailField.set("v.errors", [{message: "Please Enter a Valid Email Address"}]); 
                emailField.reportValidity();
            }
        } 
        /*if(!$A.util.isEmpty(primaryEmailField.get("v.value"))) {
                var pEmailVal = primaryEmailField.get("v.value");
                if(!pEmailVal.match(regExpEmailformat)) {
                	primaryEmailField.setCustomValidity("Enter valid Email");
            		primaryEmailField.reportValidity();
                }
            }    */     	
        if(!$A.util.isEmpty(salutationField.get("v.value")) && 
           !$A.util.isEmpty(fNameField.get("v.value")) &&
           !$A.util.isEmpty(lNameField.get("v.value")) && 
           /*!$A.util.isEmpty(dobField.get("v.value")) &&*/
           //!$A.util.isEmpty(genderField.get("v.value")) &&               		
           !$A.util.isEmpty(emailField.get("v.value")) && 
           !$A.util.isEmpty(nationalityField.get("v.value")) &&
           !$A.util.isEmpty(mbleField.get("v.value")) && 
           !$A.util.isEmpty(raceField.get("v.value")) &&
           !$A.util.isEmpty(residencyStatusField.get("v.value")) && 
           !$A.util.isEmpty(ofceNoField.get("v.value")) &&
           //!$A.util.isEmpty(eduLevelField.get("v.value")) && 
           !$A.util.isEmpty(jobTitleField.get("v.value")) &&  
           !$A.util.isEmpty(knowAboutUsField.get("v.value")) && //Nirosha - 04/24/2021: Added new required field(How did you get to know us?)
           //!$A.util.isEmpty(prefCertField.get("v.value")) && Poon Koon 2/24/2021: Make Perferred Certificate Name optional
           validVar == "valid" /*&& isDateError != true*/) {
            // MVP1.1:isDateError and Funded_Course,nricTypeField,nricField condition commented by Ravi.. on 25th march as not needed in Particulars Section
            if(courseRecType == "Funded_Course" ) {
                if( /*!$A.util.isEmpty(nricField.get("v.value")) && 
                           !$A.util.isEmpty(nricTypeField.get("v.value")) &&*/
                              !$A.util.isEmpty(dsgLevelField.get("v.value")) ) {
                              //&& !$A.util.isEmpty(designationField.get("v.value"))
                              component.set("v.selTabId" , 'Billing'); 
                          }
                        } else {
                            component.set("v.selTabId" , 'Billing'); 
                        }
            } else {
                // If required fields missing - Show message at top 
                console.log(event.getParam('detail') + 'error==');               
                var scrollOptions = {
                    left: 0,
                    top: 0,
                    behavior: 'smooth'
                }
                window.scrollTo(scrollOptions);
                // component.find('requiredFieldMessages').setError('Missing Required Fields');
                
                if($A.util.isEmpty(salutationField.get("v.value"))) {
                    errMsg = 'Salutation is Required \n';
                }
                if($A.util.isEmpty(fNameField.get("v.value"))) {
                    errMsg += 'First Name is Required \n';
                }
                if($A.util.isEmpty(lNameField.get("v.value"))) {
                    errMsg += 'Last Name is Required \n';
                }
                /*if($A.util.isEmpty(dobField.get("v.value"))) {
                    errMsg += 'Date of birth is Required \n';
                }*/
                /*if($A.util.isEmpty(genderField.get("v.value"))) {
                    errMsg += 'Gender is Required \n';
                }*/
                if($A.util.isEmpty(emailField.get("v.value"))) {
                    errMsg += 'Email is Required \n';
                }
                /*if($A.util.isEmpty(primaryEmailField.get("v.value"))) {
                    errMsg += 'Primary Email is Required \n';
                } */
                if($A.util.isEmpty(nationalityField.get("v.value"))) {
                    errMsg += 'Nationality is Required \n';
                }
                if($A.util.isEmpty(mbleField.get("v.value"))) {
                    errMsg += 'Mobile is Required \n';
                }
                if($A.util.isEmpty(raceField.get("v.value"))) {
                    errMsg += 'Race is Required \n';
                }
                if($A.util.isEmpty(residencyStatusField.get("v.value"))) {
                    errMsg += 'Residency Status is Required \n';
                }
                if($A.util.isEmpty(ofceNoField.get("v.value"))) {
                    errMsg += 'Office Number is Required \n';
                }
                /*if($A.util.isEmpty(eduLevelField.get("v.value"))) {
                    errMsg += 'Education Level is Required \n';
                }*/
                /* if($A.util.isEmpty(empStatusField.get("v.value"))) {
                    errMsg += 'Employee Status is Required \n';
                } */
                if($A.util.isEmpty(jobTitleField.get("v.value"))) {
                    errMsg += 'Job Title Status is Required \n';
                }
                //Nirosha - 04/24/2021: Added new required field(How did you get to know us?)
                if($A.util.isEmpty(knowAboutUsField.get("v.value"))){
                    errMsg += 'How did you get to know us? is Required \n'; 
                }
                /* Poon Koon 2/24/2021: Make Perferred Certificate Name optional
                if($A.util.isEmpty(prefCertField.get("v.value"))) {
                    errMsg += 'Preferred Certificate Name is Required \n';
                }*/
                if(courseRecType == "Funded_Course" ) {
                    // MVP1.1:commented by Ravi on 25th march 2021 as it is required in case of course section
                    /*if($A.util.isEmpty(nricField.get("v.value"))) {
                    	errMsg += 'NRIC is Required \n';
                	}
                    if($A.util.isEmpty(nricTypeField.get("v.value"))) {
                    	errMsg += 'NRIC Type is Required \n';
                	}*/
                    if($A.util.isEmpty(dsgLevelField.get("v.value"))) {
                        errMsg += 'Designation Level is Required \n';
                    }
                }
                if(!$A.util.isEmpty(errMsg)) {
                    component.set("v.reqMsgSection", true);
                    component.set("v.ReqErrMsgs",errMsg);  
                    //component.find('rMsgs').setError('required fields are missing');
                }
                
            }
    },
    createModal : function(component, title, message, confirmHandler, showCancel) {
        $A.createComponent(
            "c:Modal_Confirmation",
            {
                "title": title,
                "message": message,
                "confirm": component.getReference(confirmHandler),
                "showCancel": showCancel
            },
            function(modalWindow, status, errorMessage){
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
    validatePIISection: function(component, event) {
        // mvp1.1 start: added by Ravi on 25th march 2021 
        var dobField = component.find("dobId");
        dobField.reportValidity();
        var courseRecType = component.get("v.courseRunRecord.CourseRecordType__c");
        var nricTypeField = component.find("NricTypeId");
        nricTypeField.reportValidity(); 
        var nricField = component.find("NricId");
        nricField.reportValidity();
        var nricIsValid = "valid";
        var errMsg = ''; 
        var isDateError = component.get("v.dateValidationError");
        if($A.util.isEmpty(dobField.get("v.value"))) {
            errMsg += 'Date of birth is Required \n';
        }
        if(isDateError){
            errMsg += 'Date should not be future date. \n';
        }
        //if(courseRecType == "Funded_Course" ) {
        if($A.util.isEmpty(nricField.get("v.value"))) {
            errMsg += 'NRIC is Required \n';
        }
        if($A.util.isEmpty(nricTypeField.get("v.value"))) {
            errMsg += 'NRIC Type is Required \n';
        }
        // }
        // NRIC validation - start  
        if(component.get("v.piiSection") && !$A.util.isEmpty(nricField.get("v.value")) && 
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
                            component.set("v.NricEndCharValidation", true);
                            component.set("v.NricModalOpen", true);
                            if(nricIsValid == "invalid") {
                                component.set("v.selTabId" , 'course');
                            }
                        } else {
                            nricIsValid = 'valid';                                 
                        }
                    } else if(response.getState() == "ERROR"){
                        nricIsValid = "invalid";
                        var errors = response.getError();    
                        console.log(errors[0].message);
                    }
                    if(!$A.util.isEmpty(errMsg)) {
                        //component.set("v.reqMsgSection", true);
                        //component.set("v.ReqErrMsgs",errMsg);  
                        component.set("v.selTabId" , 'course');
                    }
                    if(nricIsValid == "invalid") {
                        component.set("v.selTabId" , 'course');
                    }
                    if(nricIsValid=='valid' && $A.util.isEmpty(errMsg)){
                        component.set("v.selTabId" , 'summary');     
                    }
                });
                $A.enqueueAction(nricResult);  
            }
        }else{
            if(nricIsValid=='valid' && $A.util.isEmpty(errMsg)){
                component.set("v.selTabId" , 'summary');     
            }
        }
    },
    checkUserProfile:function(component,event,code){
        var action =component.get("c.checkUserProfile");
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS' && response.getReturnValue()){
                var communityURLlabel = $A.get("$Label.c.Community_URL");
                var redirectLinkForBulkRegistartion=communityURLlabel+"/s/bulk-registration?courseruncode="+code;
                window.open(redirectLinkForBulkRegistartion,"_self");
            }
        });
        $A.enqueueAction(action);
    },
    
    getPromoCode: function(component,event,promocode){
        console.log("courseRunStartDate --> "+component.get("v.courseRunStartDate"))
        var getPromocodeRecord = component.get('c.getPromoCode');
        getPromocodeRecord.setParams({promocode: promocode,courseId:component.get("v.courseId"),registrationStartDate:component.get("v.courseRunStartDate")});
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
                        var MemberPrice = component.find("MemberPrice");
                        if(promocodeRec.Discount_Type__c.trim().toUpperCase()==="AMOUNT" && !$A.util.isEmpty(promocodeRec.Discount_Amount__c)){ 
                            finalAmount=MemberPrice.get("v.value")-promocodeRec.Discount_Amount__c;
                            component.set("v.PromoCodeMemberValue",finalAmount.toString());
                            component.set("v.PromoCodeId",promocodeRec.Id);
                            component.set("v.PromoCodeApply",true);
                            component.set("v.PromoCodeNonMemberValue","");
                        }else if(promocodeRec.Discount_Type__c.trim().toUpperCase()==="PERCENT" && !$A.util.isEmpty(promocodeRec.Discount_Percentage__c)){ 
                            var discountedPrice=(MemberPrice.get("v.value")*promocodeRec.Discount_Percentage__c)/100;
                            finalAmount=MemberPrice.get("v.value")-discountedPrice;
                            component.set("v.PromoCodeMemberValue",finalAmount.toString());
                            component.set("v.PromoCodeId",promocodeRec.Id);
                            component.set("v.PromoCodeApply",true);
                            component.set("v.PromoCodeNonMemberValue","");
                        }else{
                            this.ShowToastEvent(component, event,$A.get("$Label.c.CourseRegistrationPromoCodeNullMsg"),'Warning','warning' ); 
                            component.set("v.PromoCodeMemberValue","");
                            component.set("v.PromoCode", "");
                            component.set("v.PromoCodeApply",false);
                        }
                    }
                    else if(promocodeRec.Applicable_on__c.trim().toUpperCase()==="NON-MEMBER PRICE" && !component.get("v.memberCheckbox")){
                        var NonMemberPrice = component.find("NonMemberPrice");
                        if(promocodeRec.Discount_Type__c.trim().toUpperCase()==="AMOUNT" && !$A.util.isEmpty(promocodeRec.Discount_Amount__c)){ 
                            finalAmount=NonMemberPrice.get("v.value")-promocodeRec.Discount_Amount__c;
                            component.set("v.PromoCodeNonMemberValue",finalAmount.toString());
                            component.set("v.PromoCodeId",promocodeRec.Id);
                            component.set("v.PromoCodeApply",true);
                            component.set("v.PromoCodeMemberValue","");
                        }else if(promocodeRec.Discount_Type__c.trim().toUpperCase()==="PERCENT" && !$A.util.isEmpty(promocodeRec.Discount_Percentage__c)){ 
                            var discountedPrice=(NonMemberPrice.get("v.value")*promocodeRec.Discount_Percentage__c)/100;
                            finalAmount=NonMemberPrice.get("v.value")-discountedPrice;
                            component.set("v.PromoCodeNonMemberValue",finalAmount.toString());
                            component.set("v.PromoCodeId",promocodeRec.Id);
                            component.set("v.PromoCodeApply",true);
                            component.set("v.PromoCodeMemberValue","");
                        }else{
                            this.ShowToastEvent(component, event,$A.get("$Label.c.CourseRegistrationPromoCodeNullMsg"),'Warning','warning' );
                            component.set("v.PromoCodeNonMemberValue","");
                            component.set("v.PromoCode", "");
                            component.set("v.PromoCodeApply",false);
                        }
                    }
                        else if(promocodeRec.Applicable_on__c.trim().toUpperCase()==="BOTH"){
                            
                            var MemberPrice = component.find("MemberPrice");
                            if(promocodeRec.Discount_Type__c.trim().toUpperCase()==="AMOUNT" && !$A.util.isEmpty(promocodeRec.Discount_Amount__c)){ 
                                finalAmount=MemberPrice.get("v.value")-promocodeRec.Discount_Amount__c;
                                component.set("v.PromoCodeMemberValue",finalAmount.toString());
                                component.set("v.PromoCodeId",promocodeRec.Id);
                                component.set("v.PromoCodeApply",true);
                            }else if(promocodeRec.Discount_Type__c.trim().toUpperCase()==="PERCENT" && !$A.util.isEmpty(promocodeRec.Discount_Percentage__c)){ 
                                var discountedPrice=(MemberPrice.get("v.value")*promocodeRec.Discount_Percentage__c)/100;
                                finalAmount=MemberPrice.get("v.value")-discountedPrice;
                                component.set("v.PromoCodeMemberValue",finalAmount.toString());
                                component.set("v.PromoCodeId",promocodeRec.Id);
                                component.set("v.PromoCodeApply",true);
                            }
                            
                            var NonMemberPrice = component.find("NonMemberPrice");
                            if(promocodeRec.Discount_Type__c.trim().toUpperCase()==="AMOUNT" && !$A.util.isEmpty(promocodeRec.Discount_Amount__c)){ 
                                finalAmount=NonMemberPrice.get("v.value")-promocodeRec.Discount_Amount__c;
                                component.set("v.PromoCodeNonMemberValue",finalAmount.toString());
                                component.set("v.PromoCodeId",promocodeRec.Id);
                                component.set("v.PromoCodeApply",true);
                            }else if(promocodeRec.Discount_Type__c.trim().toUpperCase()==="PERCENT" && !$A.util.isEmpty(promocodeRec.Discount_Percentage__c)){ 
                                var discountedPrice=(NonMemberPrice.get("v.value")*promocodeRec.Discount_Percentage__c)/100;
                                finalAmount=NonMemberPrice.get("v.value")-discountedPrice;
                                component.set("v.PromoCodeNonMemberValue",finalAmount.toString());
                                component.set("v.PromoCodeId",promocodeRec.Id);
                                component.set("v.PromoCodeApply",true);
                            }  
                        }else{
                            this.ShowToastEvent(component, event,$A.get("$Label.c.CourseRegistrationPromoCodeNullMsg"),'Warning','warning' );
                            component.set("v.PromoCodeNonMemberValue","");
                            component.set("v.PromoCode", "");
                            component.set("v.PromoCodeApply",false);
                        }
                    
                }else{
                    
                    this.ShowToastEvent(component, event,$A.get("$Label.c.CourseRegistrationPromoCodeNullMsg"),'Warning','warning' );
                    component.set("v.PromoCodeNonMemberValue","");
                    component.set("v.PromoCode", "");
                    component.set("v.PromoCodeApply",false);
                }
            }else if (state === "ERROR") {
                var errors = response.getError();
                console.log(" 532 Error message: " + errors);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        component.set("v.PromoCodeNonMemberValue","");
                        component.set("v.PromoCode", "");
                        this.createModal(component, "", "Error occured! Please contact the system admin.", "c.redirectToHome", false);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(getPromocodeRecord);
    },
    ShowToastEvent: function(component, event,Message,title,type){
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
    //2021-04-23 Poon Koon: Get Marketing Channels
    getMarketingChannels:function(component,event){
        var action =component.get("c.getMarketingChannels");
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS' && response.getReturnValue()){
                console.log(' getMarketingChannels response.getReturnValue() >> ' + JSON.stringify(response.getReturnValue()));
                component.set("v.marketingchanneloptions" , response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})