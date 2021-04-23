({
	signup : function(component, event, helper) {
		var firstName = component.find("firstName").get("v.value");
		var allValid = component.find("firstName").get("v.validity").valid;
		var lastName = component.find("lastName").get("v.value");
		allValid = allValid && component.find("lastName").get("v.validity").valid;
		var email = component.find("email").get("v.value");
		allValid = allValid && component.find("email").get("v.validity").valid;
		var uenNo = "";
		var companyName = "";
		var corpAcct = component.get("v.corporateAccount");
		if (corpAcct) {
			uenNo = component.find("uenNo").get("v.value");
			allValid = allValid && component.find("uenNo").get("v.validity").valid;
			companyName = component.find("companyName").get("v.value");
			allValid = allValid && component.find("companyName").get("v.validity").valid;
		}
        if (allValid) {
            //Queue
			var createUser = component.get('c.createUser');
			createUser.setParams({firstName : firstName, lastName : lastName, email : email, corpAcct: corpAcct, uenNo : uenNo, companyName : companyName });
			createUser.setCallback(this, function(response) { 
				if(response.getState() === "SUCCESS") { 
					var result = response.getReturnValue();
					if (result == "Existing User") {
						component.set("v.result", result);
						helper.createModal(component, "Account already exists", "Your email address is currently in use", "c.handleConfirm", false);
					}
					else if (result == "Account Insert Error" || result == "Contact Insert Error" || result == "User Callout Error") {
						component.set("v.result", result);
						helper.createModal(component, "Error", "We encountered an unexpected error while creating an account for you. Please try again or reach out to us for assistance", "c.handleConfirm", false);
					}
					else {
						var userCallout = component.get('c.userCallout');
						userCallout.setParams({ userId : result });
						userCallout.setCallback(this, function(response) { 
							var resultCallout = response.getReturnValue();
							component.set("v.result", resultCallout);
							if (resultCallout == "Success") {
								helper.createModal(component, "Account created", "Your account has been created. An email will be sent to you with the login instructions.", "c.handleConfirm", false);
							}
							else {
								helper.createModal(component, "Error", "We encountered an unexpected error while creating an account for you. Please try again or reach out to us for assistance", "c.handleConfirm", false);
							}
						});
			
						$A.enqueueAction(userCallout);
					}
				}
				else {
					console.log(response.getError());
					console.log(response);
				}
			}); 
			
			$A.enqueueAction(createUser);
        } else {
			//Add Modal
			helper.createModal(component, "Error", "Please complete all of the fields in the Registration Form", "c.handleConfirm", false);
        }

		
	},
	handleOnChange : function (component, event) {
		var name = event.getSource().get("v.name");
		if (name == "chkCorpAcct") {
			var corpAcct = component.get("v.corporateAccount");
			component.set("v.corporateAccount", !corpAcct);
		}
	},
	handleConfirm : function (component) {
		var result = component.get("v.result");
		//Redirect to Login
		var address = '/s';
		var urlEvent = $A.get("e.force:navigateToURL");
		urlEvent.setParams({
			"url": address,
			"isredirect" :false
		});
		urlEvent.fire();
	}
})