({
    completeIntgManually : function(component) {
        let action = component.get("c.isRecordEditable");
        action.setParams({recordId: component.get("v.recordId")});
        action.setCallback(this, function (response) {
            let state = response.getState();
            if(state === 'SUCCESS'){
                var response = response.getReturnValue();
                if(response && component.get("v.responseVar").Status__c === "Failed"){
                    component.set("v.isFailed", true);
                }
            }
        });
        $A.enqueueAction(action);
    }
})