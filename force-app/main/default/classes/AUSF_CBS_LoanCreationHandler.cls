/**
* @author        Rahul Yadav.
* @date          25-July-2024
* @description   
* Modification Log:
* Test Class     AUSF_CBS_LoanCreationTest
--------------------------------------------------------------------------------------------
Developer               Date            Description
--------------------------------------------------------------------------------------------
Rahul Yadav.            25-July-2024    Initial Version
*/
public without sharing class AUSF_CBS_LoanCreationHandler {
    public List < String > generateRequest(List < Object > inputWrappers) {
        List<String> lstRequestString = new List<String>();
            if (inputWrappers.isEmpty()) {
                return new List < String > ();
            }
            AUSF_INT_IntegrationUtility.InputWrapper inputWrapper = (AUSF_INT_IntegrationUtility.InputWrapper)inputWrappers.get(0);
            AUSF_CBS_LoanCreationRequestWrapper objRequest = new AUSF_CBS_LoanCreationRequestWrapper();
            lstRequestString.add(JSON.serialize(objRequest));
            return lstRequestString;
    }
    public List < String > validateInputData(List < Object > inputWrappers) {
        if (inputWrappers.isEmpty()) {
            return new List < String > ();
        }
        List < String > validationErrorsList = new List < String > ();
        return validationErrorsList;
    }

    public void beforeUpdateService(Integration_Checklist__c checklistRecord, ContentVersion responseFile) {
        // TODO
    }

    public void callbackService(List < Integration_Checklist__c > checklistRecords, List < ContentVersion > responseFiles) {
        // TODO
    }

    public List < sObject > generatePlatformEvents(List < Object > inputWrappers) {
        return null;
    }
}