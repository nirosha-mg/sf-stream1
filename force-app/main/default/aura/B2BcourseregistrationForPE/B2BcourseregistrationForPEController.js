({
    OnInit : function(component, event, helper) {
        
       // alert('isRedirectFromMainScreen --> '+component.get('v.isRedirectFromMainScreen'))
        //alert('courserunIdPE --> '+component.get('v.courserunIdPE'))
        
        helper.getCourserun(component, event);
    },
    closeAccountModel: function(component, event, helper) {
        component.set("v.AccountNullCheck", false);
        component.find("AccId").focus();
    },
    closeContactModel: function(component, event, helper) {
        component.set("v.ContactNullCheck", false);
        component.find("ConId").focus();
    },
    AccountItemsChange: function(component, event, helper) {
        //alert('searchAccountId -->'+ component.get('v.searchAccountId'));
        if(!$A.util.isEmpty(component.get('v.searchAccountId'))){
            component.set("v.accid",component.get('v.searchAccountId'));
        } 
       
    },
    ContactItemsChange: function(component, event, helper) {
       // alert('search ContactId -->'+ component.get('v.searchContactId'));
        if(!$A.util.isEmpty(component.get('v.searchContactId'))){
            component.set('v.SelectedUserId',component.get('v.searchContactId'));
            helper.getContactDetails(component, event);
        } 
    },
    handleNext : function(component, event, helper) {
         // alert('searchAccountId -->'+ component.get('v.searchAccountId'));
        if($A.util.isEmpty(component.get('v.searchAccountId')))
            component.set("v.AccountNullCheck", true);
        else{
            if($A.util.isEmpty(component.get('v.searchContactId'))){
                component.set("v.ContactNullCheck", true);
            }
            else{
                component.set("v.AccountNullCheck", false);
                component.set("v.ContactNullCheck", false);
                component.set("v.courseruncode",component.get("v.Dubcourseruncode"));
            }
        }
        
    }
})