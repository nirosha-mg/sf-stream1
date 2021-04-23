({
    addFundingRecord: function(component, event) {
        //get the account List from component  
        var fundingList = component.get("v.fundingList");
        //Add New Account Record
        fundingList.push({
            'sobjectType': 'Learner_Funding__c',
            'Funding__c': component.get("v.options")[0],
            'Amount__c': '',
        });

        //Auto populate amount to 1 for other fundings 
        for (var i = 0; i < fundingList.length; i++) {
            if (fundingList[i].Funding__c != 'SkillsFuture Credit') {
                fundingList[i].Amount__c = 1;
            }
        }

        component.set("v.fundingList", fundingList);
        var cmpEvent = component.getEvent("FundingListEvent"); 
        //Set event attribute value
        cmpEvent.setParams({"fundingList" : component.get('v.fundingList')}); 
        cmpEvent.fire(); 
    },
    
    validateFundingList: function(component, event) {
        //Validate all account records
        var isValid = true;
        var fundingList = component.get("v.fundingList");
        for (var i = 0; i < fundingList.length; i++) {
            if ((fundingList[i].Funding__c == 'SkillsFuture Credit' 
                && fundingList[i].Amount__c == '') ||
                fundingList[i].Funding__c == '') {
                isValid = false;
               component.set("v.FundingModalOpen", true);
            }
        }
        return isValid;
    },
    
   
})