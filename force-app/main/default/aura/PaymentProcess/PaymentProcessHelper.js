({
    getURLParameterValue: function() {
        var urlParamsString = decodeURIComponent(window.location.search.substring(1));
        var paramsList = urlParamsString.split('=');
        if (paramsList[1].startsWith('?')) {
            return paramsList[1].substr(1);
        }
        else {
            return paramsList[1];
        }
    },
    handlePayment : function(component, event) {
        var action = component.get("c.handlePayment");
        action.setParams({  paymentRecordId : component.get("v.paymentRecordId")  });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                component.set("v.responseMsg" , response[0]);
                component.set("v.responseId" , response[1]);
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
})