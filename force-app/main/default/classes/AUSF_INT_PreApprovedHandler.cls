/**
* @author        Rahul Yadav.
* @date          09-July-2024
* @description   
* Test Class     AUSF_INT_PreApprovedTest
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Rahul Yadav.          09-July-2024    Initial Version
*/
public without sharing class AUSF_INT_PreApprovedHandler implements AUSF_INT_IntegrationHandlerInterface {
    public List < String > generateRequest(List < Object > inputWrappers) {
        List<String> lstRequestString = new List<String>();
            if (inputWrappers.isEmpty()) {
                return new List < String > ();
            }
            AUSF_INT_IntegrationUtility.InputWrapper inputWrapper = (AUSF_INT_IntegrationUtility.InputWrapper)inputWrappers.get(0);
            AUSF_INT_PreApprovedRequestWrapper objRequest = new AUSF_INT_PreApprovedRequestWrapper();
            objRequest.RequestId = AUSF_INT_IntegrationUtility.getReferenceId();
            objRequest.OriginatingChannel = String.valueOf(inputWrapper.dynamicInputs.get('channel'));
            objRequest.OfferActive = AUSF_ApexConstants.AUSF_PREAPPROVED_OfferActive;
            objRequest.ItemType = AUSF_ApexConstants.AUSF_PREAPPROVED_OFFER;
            objRequest.ItemId = String.valueOf(inputWrapper.dynamicInputs.get('ItemId'));
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