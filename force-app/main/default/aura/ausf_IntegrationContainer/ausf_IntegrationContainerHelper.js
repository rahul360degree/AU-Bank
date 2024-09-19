({
    // This method fetches the integration status details along with associated mapper information
    // The details are passed to each individual status entry instance to display in a timeline
    getConfiguration: function (component) {
        component.set("v.showAllRecords",false);
        component.set("v.filteredStatusRecords", []); 
        component.set("v.showFilteredRecords",false);
       
        let objMappingDetails = component.get("c.fetchIntegrationStatusRecords");
        objMappingDetails.setParams({recordId: component.get("v.recordId"), objectName: component.get("v.sObjectName")});
        objMappingDetails.setCallback(this, function (response) {
            let state = response.getState();
            console.log('response====',response);
            if (state === "SUCCESS") {
                var statusMap = new Map();
                var res = response.getReturnValue();
                console.log('res====',res);
                let defaultStatusList = [];
               
                for(let j in res.individualStatusRecords){
                    let statusRec = res.individualStatusRecords[j];
                    if(!statusMap.has(statusRec.Integration_Status_Label__c)){
                        statusMap.set(statusRec.Integration_Status_Label__c ,statusRec);
                    }
                    
                }

                for (const x of statusMap.values()) {
                  defaultStatusList.push(x);
                    console.log(x.Integration_Status_Label__c);
                }
                component.set('v.defaultStatusRecords',defaultStatusList);
                component.set('v.responseWrapper', response.getReturnValue());
                component.set('v.isOwner', response.getReturnValue().isOwner);
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
            }
        }
        });
        $A.enqueueAction(objMappingDetails);
    },
    handleToggleChange : function(component) {
        console.log('hiii');
        component.set("v.filteredStatusRecords", []); 
        component.set("v.showFilteredRecords",false);
           

        // get the toggleButton element and check its value

		if(component.get("v.showAllRecords")){
            console.log('hiii');
            component.set("v.showAllRecords",false);
        }
        else{
            component.set("v.showAllRecords",true);
        }
		

	},
    /**
     * Method Name: handleSearch
     * Developer: Mohit M
     * Description: handle integration checklist seatch based on Integration_Status_Label__c field.
     */
    handleSearch: function(component) {
        console.log('hiii handleSearch');
        var searchKey = component.get("v.filter");  
        console.log('hiii handleSearch searchKey',searchKey);
        if(searchKey !=''){  
            component.set("v.showFilteredRecords",true);
            var data;
            var allData = component.get("v.responseWrapper");  
            // get the toggleButton element and check its value

            if(component.get("v.showAllRecords")){
                data = allData.individualStatusRecords;
               }else{
                console.log('hiii showAllRecords');
                data = component.get("v.defaultStatusRecords");  
            }
            if(data!=undefined || data.length>0){  
                // filter method create a new array tha pass the test (provided as function)  
                var filtereddata = data.filter(word => (!searchKey) || word.Integration_Status_Label__c.toLowerCase().indexOf(searchKey.toLowerCase()) > -1);  
                console.log('** '+JSON.stringify(filtereddata));  
            
                component.set("v.filteredStatusRecords", filtereddata); 
            }
        }else{
            component.set("v.showFilteredRecords",false);
            component.set("v.filteredStatusRecords", []); 
           
        }
	}
})