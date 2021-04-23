({
    onInit : function(component, event, helper) {
        helper.getPaymentGetwayMdt(component, event);
        helper.getInvoiceRecordInfo(component, event);
        helper.getCourseRecordInfoAndUpdatePaymentOptions(component,event); //rob - 29Jan2021
    },
    submitForm : function (component, event, helper) {
        var paymentOption = component.find('paymentOption');
        if (paymentOption.get('v.value') == 'MastercardVisa') {
            component.find('postEPayment').getElement().submit();
        }
        else {
            //Show Modal for Exec
            component.set('v.isExecutiveModalOpen', true);

        }
        
    },
    redirectToInvoice : function (component, event, helper) {
        var recordId = component.get("v.recordId");
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParam("recordId", recordId);
        navEvt.fire();
   },
   redirectBack : function (component, event, helper) {
       var recordId = component.get("v.redirectRecordId");
       var navEvt = $A.get("e.force:navigateToSObject");
       navEvt.setParam("recordId", recordId);
       navEvt.fire();
   }

})