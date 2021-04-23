({
    getPaymentGetwayMdt : function(component, event) {
        var action = component.get("c.getPaymentGateway");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.paymentGetwayRecord", response.getReturnValue());
                console.log('response.getReturnValue() >> ' + JSON.stringify(response.getReturnValue()));
                console.log('v.paymentGetwayRecord >> ' + component.get("v.paymentGetwayRecord"));
                var varCreateURL = component.get("v.paymentGetwayRecord.Payment_Gateway_Return_URL__c");
                console.log('1 varCreateURL >> ' + varCreateURL);
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    } ,
    //getInvoiceRecordInfo
    getInvoiceRecordInfo : function(component, event) {
        var action = component.get("c.getInvoiceRecordInformation");
        action.setParams({  strInvoiceId : component.get("v.recordId")  });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(' getInvoiceRecordInfo response.getReturnValue() >> ' + JSON.stringify(response.getReturnValue()));
                var  formInformationWrapper= response.getReturnValue();
                component.set("v.invoiceRecordInfo" , formInformationWrapper.objInvoice);
                component.set("v.paymentRecordInfo" , formInformationWrapper.objPayment);
                var varCreateURL = component.get("v.paymentGetwayRecord.Payment_Gateway_Return_URL__c");
                var paymentId = component.get("v.paymentRecordInfo.Id");
                var ePaymentAccountNo = component.get("v.paymentRecordInfo.ePayment_Account_No__c");
                var invoiceId = component.get("v.invoiceRecordInfo.Id");
                var invoiceAmount = component.get("v.invoiceRecordInfo.Final_Amount__c");
                var courseRegId = component.get("v.invoiceRecordInfo.Course_Registration__c");
                if (courseRegId != '') {
                    component.set("v.redirectRecordId", courseRegId);
                }
                else {
                        component.set("v.redirectRecordId", invoiceId);
                }
                //varCreateURL = varCreateURL+'paymentId='+paymentId+'&invoiceNo='+invoiceId;
                //varCreateURL = varCreateURL+'recordId='+paymentId+'&invoiceNo='+invoiceId;
                varCreateURL = varCreateURL+'recordId='+paymentId; //2021-04-01 Poon Koon: Only pass paymentId in return_url
                console.log(' 2 varCreateURL >> ' + varCreateURL);
                component.set("v.createURL" , varCreateURL);

                //2021-03-25 Poon Koon: Construct JSON Payload for ePayment V2
                var currentdate = new Date(); 
                var strDateTime = currentdate.getFullYear() + "-"  
                                + ("0" + (currentdate.getMonth() + 1)).slice(-2) + "-"  
                                + ("0" + (currentdate.getDate())).slice(-2) + "T" 
                                + ("0" + (currentdate.getHours())).slice(-2) + ":"
                                + ("0" + (currentdate.getMinutes())).slice(-2) + ":"
                                + ("0" + (currentdate.getSeconds())).slice(-2);

                var requestPayload = {
                    "accno": ePaymentAccountNo,
                    "txn_refno": invoiceId,
                    "txn_amt": invoiceAmount.toString(),
                    "emplid": paymentId,
                    "return_url": varCreateURL,
                    "req_time": strDateTime,
                };
                var strRequestPayload = JSON.stringify(requestPayload);
                component.set("v.requestMessage" , strRequestPayload);
                console.log("strRequestPayload >> " + strRequestPayload);

                var varCertName = component.get("v.paymentGetwayRecord.Self_Signed_Cert_Name__c");

                //2021-03-25 Poon Koon: Sign JSON String Request
                var action = component.get("c.generateSignature");
                action.setParams({  strJSONString : strRequestPayload, strCertName : varCertName  });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var varSignature = response.getReturnValue();
                        component.set("v.requestSignature" , varSignature);
                    }
                    else {
                        console.log("Failed with state: " + state);
                    }
                });
                $A.enqueueAction(action);
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    } ,
    
        //29Jan2021 - Rob - getCourseRecordInfoAndUpdatePaymentOptions
    getCourseRecordInfoAndUpdatePaymentOptions : function(component, event) {
        var action = component.get("c.getCourseRecordInformation");
        action.setParams({  strInvoiceId : component.get("v.recordId")  });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               	console.log(' getCourseRecordInformation response.getReturnValue() >> ' + JSON.stringify(response.getReturnValue()));
               	var  formInformationWrapper1= response.getReturnValue();
                component.set("v.courseRecordInfo" , formInformationWrapper1.objCourse);
                component.set("v.options" , formInformationWrapper1.paymentOptions);
                var defaultPaymentOption = component.get("v.courseRecordInfo.Payment_Option__c");
                component.set("v.value" , defaultPaymentOption);
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    }
})