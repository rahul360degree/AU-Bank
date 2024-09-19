/**
* @author        Tejendra
* @date          31-July-2024
* @description   Fetch GST Authentication handler class - use to generate request and validate the prerequisites
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Tejendra              31-July-2024    Initial Version - APL-34
*/
public without sharing class AUSF_GstAuthenticationHandler implements AUSF_INT_IntegrationHandlerInterface{
    public List<String> generateRequest(List <Object> inputWrappers){
        List<String> lstRequestString = new List<String>(); 
        if (inputWrappers.isEmpty()) {
            return new List <String> ();
        }
        AUSF_INT_IntegrationUtility.InputWrapper inputWrapper = (AUSF_INT_IntegrationUtility.InputWrapper)inputWrappers.get(0);
        AUSF_GstAuthenticationRequestWrapper objRequest = new AUSF_GstAuthenticationRequestWrapper();
        objRequest.requestid = String.valueOf(inputWrapper.dynamicInputs.get('requestid'));
        objRequest.channel = String.valueOf(inputWrapper.dynamicInputs.get('channel'));
        objRequest.consent = String.valueOf(inputWrapper.dynamicInputs.get('consent'));
        objRequest.gstin = String.valueOf(inputWrapper.dynamicInputs.get('gstin'));
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