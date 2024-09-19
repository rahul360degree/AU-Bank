/**
 * @author       Pradeep Sharma
 * Class :		 AUSF_ICAI_APIHandler
 * @date         05-Aug-2024
 * @description: Integration Handler for ICAI API
 * Modification Log:
--------------------------------------------------------------------------------------------
    Developer             Date            Description
--------------------------------------------------------------------------------------------
    Pradeep Sharma        05-Aug-2024    Initial Version
*/
public without sharing class AUSF_ICAI_APIHandler implements AUSF_INT_IntegrationHandlerInterface{
    public List < String > generateRequest(List < Object > inputWrappers) {
        List<String> lstRequestString = new List<String>();
        if (inputWrappers.isEmpty()) {
            return new List < String > ();
        }
        AUSF_INT_IntegrationUtility.InputWrapper inputWrapper = (AUSF_INT_IntegrationUtility.InputWrapper)inputWrappers.get(0);
        AUSF_ICAI_APIRequestWrapper objRequest = new AUSF_ICAI_APIRequestWrapper();
        objRequest.Consent = String.valueOf(inputWrapper.dynamicInputs.get('Consent'));
        objRequest.OriginatingChannel = String.valueOf(inputWrapper.dynamicInputs.get('channel'));
        objRequest.MembershipNo = String.valueOf(inputWrapper.dynamicInputs.get('MembershipNo'));
        objRequest.ContactDetails = String.valueOf(inputWrapper.dynamicInputs.get('ContactDetails'));
        objRequest.RequestId = String.valueOf(inputWrapper.dynamicInputs.get('SFRequestId'));
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