({
    init : function(component, event, helper) {
        component.set("v.columns", [
            { label: 'Name', fieldName: 'Name', type: 'text' },
            { label: 'First Name', fieldName: 'First_Name__c', type: 'text' },
            { label: 'Last Name', fieldName: 'Last_Name__c', type: 'text' },
            { label: 'Preferred Name', fieldName: 'Preferred_Certificate_Name__c', type: 'text' },
            { label: 'Registration Status', fieldName: 'Registration_Status__c', type: 'text' },
            { label: 'Certificate', type: 'button', initialWidth: 135, typeAttributes: { label: 'Preview', name: 'preview', title: 'Click to Preview Certificate'}}
        ]);

        var courseRunId = component.get("v.recordId");

        var getCourseRegistrations = component.get('c.getCourseRegistrations');
        getCourseRegistrations.setParams({courseRunId: courseRunId});
		getCourseRegistrations.setCallback(this, function(response) { 
			if(response.getState() === "SUCCESS") { 
			  component.set("v.data", response.getReturnValue()); 
		  }}); 
	  
        $A.enqueueAction(getCourseRegistrations);
        
        var getTemplates = component.get('c.getCertificateTemplates');

		getTemplates.setCallback(this, function(response) { 
			if(response.getState() === "SUCCESS") { 
                var templates = response.getReturnValue();
                var options = templates.map(function(template) { return { value: template, label: template } });
                component.set("v.emailTemplates", options);
		  }}); 
	  
		$A.enqueueAction(getTemplates);
    },
    handleRowSelection : function (component, event) {
        var selectedRows = event.getParam('selectedRows');
        var ids = [];
        for (var i = 0; i < selectedRows.length; i++){
            ids.push(selectedRows[i].Id);
        }
        component.set("v.selectedRows", ids);
    },
    handleRowAction : function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        var template = component.get('v.template');
        switch (action.name) {
            case 'preview':
                window.open('/apex/eCertPagePreview?id=' + row.Id + '&templateName=' + encodeURI(template));
                break;
        }
    },
    generateCertificates : function (component, event, helper) {
        var registrations = component.get("v.selectedRows");
        var templateName = component.get("v.template");
        if (registrations.length > 0 && templateName != undefined) {
            helper.createModal(component, "Generate Certificate?", "Do you want to proceed?", "c.handleConfirm", true);            
        }
        else {
            helper.createModal(component, "Error", "Please select a template and select registrations to generate certificates for", "c.emptyConfirm", false);
        }
    },
    templateChanged : function (component, event) {
        component.set("v.template", event.getParam("value"));
    },
    handleConfirm : function (component, helper) {
        component.set("v.generateCertificate", true);
        var registrations = component.get("v.selectedRows");
        var templateName = component.get("v.template");
        var generateCertificates = component.get('c.generateCertificate');
        generateCertificates.setParams({registrations: JSON.stringify(registrations), templateName: templateName});
        generateCertificates.setCallback(this, function(response) { 
            if(response.getState() === "SUCCESS") { 
                //$A.get("e.force:closeQuickAction").fire();
            }
            else {
                console.log(response.getError());
                console.log(response);
            }
        }); 
        
        $A.enqueueAction(generateCertificates);
    },
    emptyConfirm : function (component) {
        var generateCertificate = component.get("v.generateCertificate");
        if (generateCertificate) {
            component.set("v.generateCertificate", false);
            $A.get("e.force:closeQuickAction").fire();
        }
    },
    waiting: function(component, event, helper) {
        var generateCertificate = component.get("v.generateCertificate");
        if (generateCertificate) {
            helper.createModal(component, "In Progress", "Certificates are now being generated. Please check the files in each of the selected registrations", "c.emptyConfirm", false);
        }
    },
    doneWaiting: function(component, event, helper) {
    }
})