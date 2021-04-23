({
    createModal : function(component, title, message, confirmHandler, showCancel) {
        $A.createComponent(
            "c:Modal_Confirmation",
            {
                "title": title,
                "message": message,
                "confirm": component.getReference(confirmHandler),
                "showCancel": showCancel
            },
            function(modalWindow, status, errorMessage){
                if (status === "SUCCESS") {
                    var modalBody = component.set("v.modalBody", modalWindow);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
            }
        );
    }
})