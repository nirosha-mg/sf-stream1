({
    onInit : function(component, event, helper) {
        var idParamValue = helper.getURLParameterValue();
        component.set("v.paymentRecordId" , idParamValue);
        //Retiring the code below to allow handling of existing receipts and avoid multiple receipts per payment record
        //console.log('idParamValue >> ' + idParamValue);
        //helper.createRecepitRecord(component, event);
        helper.handlePayment(component, event);
    },
    redirectToRecord : function (component) {
        var recordId = component.get('v.responseId');
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParam("recordId", recordId);
        navEvt.fire();
    }
})