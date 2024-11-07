({
    doInit: function(component, event, helper) {
        let action = component.get("c.getFieldSetFields");
        action.setParams({
            objectName: "Task_Template__c",
            fieldSetName: "Fields_To_Edit" 
        });
        
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.fields", response.getReturnValue());
            } else {
                console.error("Error fetching field set fields: " + response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    handleSuccess: function(component, event, helper) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: "Success",
            message: "Record has been updated successfully.",
            type: "success"
        });
        toastEvent.fire();
        
        $A.get("e.force:closeQuickAction").fire();
    },
    
    handleError: function(component, event, helper) {
        let error = event.getParam("error");
        console.error("Error updating record: ", error);
    },
    
    handleCancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})