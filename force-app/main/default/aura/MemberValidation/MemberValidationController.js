({
	onInit: function(component, event, helper) { 
        var sObjectType = component.get('v.sObjectName');
        var recordId = component.get('v.recordId');
        console.log(' recordId 1 >> ' + recordId + 'sObjectType >> ' +sObjectType);

        const empApi = component.find('empApi');
		//empApi.setDebugFlag(true);
        
        if (sObjectType == 'Contact') {
            const channel = '/topic/MemberContact';
            empApi.subscribe(channel, -1, $A.getCallback(eventReceived => {
                //console.log(' Contact eventReceived.sobject.Id >> ' + eventReceived.sobject.Id);
                if (recordId == eventReceived.data.sobject.Id) {
                    $A.get('e.force:refreshView').fire();
                }
            }));
        }
        else if (sObjectType == 'Account') {
                console.log('Subscribe to channel');
            const channel = '/topic/MemberAccount';
            empApi.subscribe(channel, -1, $A.getCallback(eventReceived => {
                console.log(eventReceived);
                if (recordId == eventReceived.data.sobject.Id) {
                    $A.get('e.force:refreshView').fire();
                }
            }));
        }
    }
})