/**
* @author        Tejendra
* @date          25-June-2024
* @description   Karza Name Match Handler class - use to generate request and validate the prerequisites
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Tejendra              25-June-2024    Initial Version
*/

public without sharing class AUSF_KarzaNameMatchHandler implements AUSF_INT_IntegrationHandlerInterface { 
    public List<String> generateRequest(List <Object> inputWrappers){
        List<String> lstRequestString = new List<String>(); 
        if (inputWrappers.isEmpty()) {
            return new List <String> ();
        }
        AUSF_INT_IntegrationUtility.InputWrapper inputWrapper = (AUSF_INT_IntegrationUtility.InputWrapper)inputWrappers.get(0);
        AUSF_NameMatchRequestWrapper objRequest = new AUSF_NameMatchRequestWrapper();
        objRequest.requestId = AUSF_INT_IntegrationUtility.getReferenceId();
        objRequest.channel = String.valueOf(inputWrapper.dynamicInputs.get('channel'));
        objRequest.name1 = String.valueOf(inputWrapper.dynamicInputs.get('name1'));
        objRequest.name2 = String.valueOf(inputWrapper.dynamicInputs.get('name2'));
        objRequest.type = String.valueOf(inputWrapper.dynamicInputs.get('type'));
        objRequest.preset = String.valueOf(inputWrapper.dynamicInputs.get('preset'));
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