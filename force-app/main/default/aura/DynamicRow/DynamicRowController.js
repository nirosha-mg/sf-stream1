({
    onInit: function(component, event, helper) {
        
        var inputsel = component.find("InputSelectDynamic");
        var courseIdVar = component.get('v.courseId');
        var opts=[];
         var action = component.get('c.getLearnerFundingValues');
          action.setParams({courseId: courseIdVar});
            action.setCallback(this, function(response) { 
                if(response.getState() === "SUCCESS") {                   
                     component.set("v.options", response.getReturnValue());
                } else if(response.getState() == "ERROR"){
                    var errors = response.getError();    
                    console.log(errors[0].message);
                }
            }); 
            $A.enqueueAction(action); 
       // helper.addFundingRecord(component, event);
    },
    addRow: function(component, event, helper) {
        if (helper.validateFundingList(component, event)) {
            helper.addFundingRecord(component, event);
        } 
    },
    
    removeRow: function(component, event, helper) {
        //Get the account list
        var fundingList = component.get("v.fundingList");
        //Get the target object
        var selectedItem = event.currentTarget;
        //Get the selected item index
        var index = selectedItem.dataset.record;
        fundingList.splice(index, 1);
        component.set("v.fundingList", fundingList);
        var cmpEvent = component.getEvent("FundingListEvent"); 
        //Set event attribute value
        cmpEvent.setParams({"fundingList" : component.get('v.fundingList')}); 
        cmpEvent.fire(); 
    },
    
    save: function(component, event, helper) {
        alert(JSON.stringify(component.get('v.fundingList')));
        /*
        if (helper.validateFundingList(component, event)) {
            helper.saveAccountList(component, event);
        } */
    },
    sendFundingList: function(component, event, helper) {
        var cmpEvent = component.getEvent("FundingListEvent"); 
        var fundingList = component.get("v.fundingList");

        //Auto populate amount to 1 for other fundings 
        for (var i = 0; i < fundingList.length; i++) {
            if (fundingList[i].Funding__c != 'SkillsFuture Credit') {
                fundingList[i].Amount__c = 0;
            }
        }
        component.set("v.fundingList", fundingList);
        //Set event attribute value
        cmpEvent.setParams({"fundingList" : component.get('v.fundingList')}); 
        cmpEvent.fire(); 
    },
    closeFundingModel: function(component, event, helper) {
      component.set("v.FundingModalOpen", false);
   },
})