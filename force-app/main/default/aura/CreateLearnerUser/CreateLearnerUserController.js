({
	initialize : function(component, event, helper) {
		var action=component.get("c.checkUserWithContact");
        action.setParams({
            'courseRegId':component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            console.log(response.getReturnValue());
            if(response.getState()=='SUCCESS'){
                component.set("v.responseWrapper",response.getReturnValue());
                if(response.getReturnValue().Result=='userExistWithContactId'){
                    component.set("v.isUserToBeCreated",true);
                    component.set("v.SuccessuserExistWithContactId",false);
                    component.set("v.MessageReturn",'There is already User with this Contact');     
                }else if(response.getReturnValue().Result=='userExistWithEmailAsUserName'){
                    component.set("v.SuccessuserExistWithContactId",false);
                    component.set("v.isUserToBeCreated",true);
                   // component.set("v.userName",response.getReturnValue().userName);
                   // component.set("v.Email",response.getReturnValue().Email);
                    component.set("v.MessageReturn",'There is Another user with same email exist'); 
                }else if(response.getReturnValue().Result=='userDoesNotExistWithEmailAsUserName'){
                    component.set("v.SuccessuserExistWithContactId",true);
                    component.set("v.isUserToBeCreated",false);
                    component.set("v.userName",response.getReturnValue().userName);
                    component.set("v.Email",response.getReturnValue().Email);
                    component.set("v.MessageReturn",'User Account is going to be created with below username and email. Please click on confirm to proceed'); 
                }   
            }else{
                component.set("v.Success",false);
            }
        });
        $A.enqueueAction(action);
	},
    handleExit:function(component,event,helper){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    handleSave:function(component,event,helper){
        var action=component.get("c.createUser");
        action.setParams({
            "wrp":JSON.stringify(component.get("v.responseWrapper"))
        });
        action.setCallback(this,function(response){
            component.set("v.SuccessuserExistWithContactId",false);
            component.set("v.isUserToBeCreated",false);
            if(response.getState()=='SUCCESS' && response.getReturnValue().includes('SUCCESS')){
                component.set("v.isError",'Fail');
                component.set("v.Msg",'User Account is created and user has been notified at the given email Address');
            }else{
                component.set("v.isError",'Success');
                component.set("v.Msg",response.getReturnValue() +':: Please Contact System Admin');
            }
        });
        $A.enqueueAction(action);
    }
})