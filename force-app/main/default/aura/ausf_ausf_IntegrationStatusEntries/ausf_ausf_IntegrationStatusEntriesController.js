({
    // To expand/collapse each individual status element
    expandCollapse: function(component, event, helper) {
    	component.set("v.isExpanded", !component.get("v.isExpanded"));
    },

    // Opens the modal popup for each component. Uses the component name listed in mapper record to create an instance
    // of the LWC component and pushes it to DOM. Additionally, for some components that need wider screen space, updates
    // CSS classes
    openPopup : function(component, event, helper) {
       
        console.log('openPopup called');
        try{
            component.set("v.isModalOpen", true);
            component.set("v.enableRetry", true);
            var reRunAllowedUsers = component.get("v.responseVar").Integration_Master__r.Allow_Rerun_For_Personas__c;
            var resultArray = (reRunAllowedUsers != null && reRunAllowedUsers != '') ? reRunAllowedUsers.toString().split(';') : []; //arshad 22 Apr 24
            const profileName = component.get('v.CurrentUser')['Profile'].Name;
            let componentName = component.get("v.responseVar").Integration_Master__r.Component_Reference__c;
            
            component.set("v.intgCheckListId", component.get("v.responseVar").Id);
            
            
            console.log('componentName~>'+componentName+' recordId~>'+component.get("v.recordId")+' integrationChecklistRecordId~>'+component.get("v.responseVar").Id);
            
            $A.createComponent(
                componentName,{
                    "aura:id": "componentContainer",
                    "recordId": component.get("v.recordId"),
                    "integrationChecklistRecordId": component.get("v.responseVar").Id,
                    "isOwner": component.get("v.isOwner")
                },
                function (modalComponent, status, errorMessage) {
                    console.log('status: '+status);
                    if (status === "SUCCESS") {
                        var body = component.get("v.componentContainer");
                        body = [];
                        body.push(modalComponent);
                        component.set("v.printURL", "/c/IntegrationResultsPrintView.app?componentName=" + componentName + "&recordId=" + component.get("v.recordId") + "&integrationStatusRecordId=" + component.get("v.responseVar").Id);
                        component.set("v.componentContainer", body);
                        component.set("v.displayPEButton", component.get("v.responseVar").Integration_Master__r.Allow_PE_Retry__c);
                        if (resultArray.includes(profileName)) {
                            component.set("v.enableRerunForProfile", true);
                        }else{
                            component.set("v.enableRerunForProfile", false);
                        }
                        
                        console.log('component container: '+ component.get("v.componentContainer"));
                        if (component.get("v.responseVar").Status__c === "In Progress" || component.get("v.responseVar").Status__c === "Missing Pre-requisites") {
                            let requestInitiatedAt = component.get("v.responseVar").Status__c === "In Progress" ?
                                component.get("v.responseVar").Request_Initiated_At__c : component.get("v.responseVar").CreatedDate;
                            let allowInitiateAfter = component.get("v.responseVar").Integration_Master__r.Allow_Manual_Initiate_After__c;
                            if (requestInitiatedAt !== null && allowInitiateAfter !== null && 
                                new Date(new Date(requestInitiatedAt).getTime() + allowInitiateAfter * 60000) < new Date()) {
                                component.set("v.buttonLabel", 'Reinitiate');
                            } else {
                                component.set("v.buttonLabel", 'Reinitiate');
                            }
                        } else if (component.get("v.responseVar").Status__c === "Completed") {
                            console.log(component.get("v.responseVar"));
                            let responseReceivedAt = component.get("v.responseVar").Response_Received_At__c;
                            let allowRefreshAfter = component.get("v.responseVar").Integration_Master__r.Allow_Refresh_After__c;
                            if (responseReceivedAt !== null && allowRefreshAfter !== null && allowRefreshAfter > 0 &&
                                new Date(new Date(responseReceivedAt).getTime() + allowRefreshAfter * 60000) < new Date() &&
                                component.get("v.responseVar").Integration_Master__r.Allow_Refresh__c) {
                                component.set("v.buttonLabel", 'Refresh');
                            } else if (allowRefreshAfter != -1 && component.get("v.responseVar").Integration_Master__r.Allow_Refresh__c) {
                                component.set("v.buttonLabel", 'Refresh');
                            }
                            helper.completeIntgManually(component);
                        } else if ((component.get("v.responseVar").Status__c === "Failed"  ||
                                    component.get("v.responseVar").Status__c === "Need Refresh" )
                                   && component.get("v.responseVar").Integration_Master__r.Allow_Retry__c) {
                            component.set("v.buttonLabel", 'Retry');
                            component.set("v.showRetry", true);
                            if(component.get("v.responseVar").Status__c === "Failed" && component.get("v.responseVar").Integration_Master__r.Allow_Override__c){
                                helper.completeIntgManually(component);
                            }
                        }else if(component.get("v.responseVar").Status__c === "Failed" && component.get("v.responseVar").Integration_Master__r.Allow_Override__c){
                            helper.completeIntgManually(component);
                        }
                        if(component.get("v.responseVar").Integration_Master__r.Allow_Refresh_After__c != undefined){
                            let allowRefreshAfter = component.get("v.responseVar").Integration_Master__r.Allow_Refresh_After__c;
                            let dt = new Date(component.get("v.responseVar").CreatedDate);
                            var newDate = $A.localizationService.formatDate(dt.setDate(dt.getDate() + allowRefreshAfter), "MMMM dd yyyy");
                            var today = $A.localizationService.formatDate(new Date(), "MMMM dd yyyy");
                            if(new Date(newDate) >= new Date(today) && component.get("v.responseVar").Status__c === "Completed")
                            {
                                component.set("v.enableRetry", false);
                            }
                        }
                        var modalComponent = component.find("modalContainer");
                        $A.util.removeClass(modalComponent, "fullDeviceWidth");
                        $A.util.addClass(modalComponent, "standardDeviceWidth");
                    }
                    else {
                        console.log('error~>'+errorMessage);
                        throw new Error(errorMessage);
                    }
                }
            );
        }catch(e){
            console.log("An error occurred: " + e.message); //arshad 22 Apr 24
        }
    },

    // Closes popup. Also used as event handler method when close popup event is published from child component
    closePopup : function(component, event, helper) {
        component.set("v.isModalOpen", false);
        $A.get('e.force:refreshView').fire();
        var event = component.getEvent("refreshEvent");
        event.fire();
    },

    // Retry/Reinitiate/Refresh buttons call this method to re-trigger the interface. Actual implementation to retrigger
    // is part of the child LWC component
    retry : function(component, event, helper) {
        //component.set("v.isModalOpen",false);
        component.set('v.disableRetry',true);
        component.get("v.componentContainer")[0].retry();
    },

    // Retry with PE buttons call this method to re-trigger the interface. Actual implementation to retrigger
    // is part of the child LWC component - specifically for BRE and CIBIL.
    retrywithpe : function(component, event, helper) {
        component.get("v.componentContainer")[0].retrywithpe();
    },

    // Updates the options once a new ID is received
    refreshOptions : function(component, message, helper) {
        if (message !== null && message.getParam("integrationStatusRecordId") !== null) {
            let componentName = component.get("v.responseVar").Integration_Master__r.Component_Reference__c;
            component.set("v.printURL", "/c/IntegrationResultsPrintView.app?componentName=" + componentName + "&recordId=" + component.get("v.recordId") + "&integrationStatusRecordId=" + message.getParam("integrationStatusRecordId"));
            let controllerInstance = component.get("c.fetchIntegrationStatusRecord");
            controllerInstance.setParams({recordId: message.getParam("integrationStatusRecordId")});
            controllerInstance.setCallback(this, function (response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    var responseVar = response.getReturnValue();
                    component.set("v.buttonLabel", null);
                    component.set("v.displayPEButton", responseVar.Integration_Master__r.Allow_PE_Retry__c);
                    console.log(' responseVar.Integration_Master__r.Allow_Retry__c: '+ responseVar.Integration_Master__r.Allow_Retry__c);
                    if (responseVar.Status__c === "In Progress" || responseVar.Status__c === "Pending") {
                        let requestInitiatedAt = responseVar.Status__c === "In Progress" ?
                            responseVar.Request_Initiated_At__c : responseVar.CreatedDate;
                        let allowInitiateAfter = responseVar.Integration_Master__r.Allow_Manual_Initiate_After__c;
                        if (requestInitiatedAt !== null && allowInitiateAfter !== null && 
                            new Date(new Date(requestInitiatedAt).getTime() + allowInitiateAfter * 60000) < new Date()
                            && responseVar.Is_Auto__c) {
                            component.set("v.buttonLabel", 'Reinitate');
                            component.set('v.disableRetry',false);
                        }
                    } else if (responseVar.Status__c === "Completed") {
                        let responseReceivedAt = responseVar.Response_Received_At__c;
                        let allowRefreshAfter = responseVar.Integration_Master__r.Allow_Refresh_After__c;
                        if (responseReceivedAt !== null && allowRefreshAfter !== null && 
                            new Date(new Date(responseReceivedAt).getTime() + allowRefreshAfter * 60000) < new Date() &&
                            responseVar.Integration_Master__r.Allow_Refresh__c) {
                            component.set("v.buttonLabel", 'Refresh');
                            component.set('v.disableRetry',false);
                        }
                    } else if ((responseVar.Status__c === "Failed"  || responseVar.Status__c === "Need Refresh")
                        && responseVar.Integration_Master__r.Allow_Retry__c) {
                        component.set("v.buttonLabel", 'Retry');
                        component.set('v.disableRetry',false);
                        component.set("v.showRetry", true);
                    }
                }
            });
            $A.enqueueAction(controllerInstance);
        }
    }


})