({
	onInit : function(component, event, helper) {
		//0031s00000BUcb2AAD
		//get Id
		//
        var getRedirectURL = component.get("c.getProfileURL");
        getRedirectURL.setCallback(this, function(response) { 
			if(response.getState() === "SUCCESS") { 
                if (response.getReturnValue() != "") {
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                      "url": response.getReturnValue()
                    });
                    urlEvent.fire();
        			console.log(response.getReturnValue());
                }
		  	} 
        });
        $A.enqueueAction(getRedirectURL);
	}
})