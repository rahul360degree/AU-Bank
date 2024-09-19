({
    doInit: function (component, event, helper) {
        helper.getConfiguration(component);
    },
    handleToggle : function(component, event, helper) {
        helper.handleToggleChange(component);
	},
    /**
     * Method Name: handleSearch
     * Developer: Mohit M.
     * Description: handle integration checklist seatch based on Integration_Status_Label__c field.
     */
    handleSearch :function(component, event, helper) {
        helper.handleSearch(component);
	}
    
})