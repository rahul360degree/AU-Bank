/**
* @author        Pradeep Sharma
* @date          21-June-2024
* Class :		 AUSF_PanDobHandler
* Test Class	 AUSF_PanDobTest
* @description   Pan DOB Integration Handler class - use to generate request and validate the prerequisites
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Pradeep Sharma        21-June-2024    Initial Version
*/
public without sharing class AUSF_PanDobHandler implements AUSF_INT_IntegrationHandlerInterface{
    public List < String > generateRequest(List < Object > inputWrappers) {
        List<String> lstRequestString = new List<String>();
        if (inputWrappers.isEmpty()) {
            return new List < String > ();
        }
        AUSF_INT_IntegrationUtility.InputWrapper inputWrapper = (AUSF_INT_IntegrationUtility.InputWrapper)inputWrappers.get(0);
        AUSF_PanDobRequestWrapper objRequest = new AUSF_PanDobRequestWrapper();
        objRequest.RequestId = AUSF_INT_IntegrationUtility.getReferenceId();
        objRequest.OriginatingChannel = String.valueOf(inputWrapper.dynamicInputs.get('channel'));
        objRequest.pan = String.valueOf(inputWrapper.dynamicInputs.get('panNumber'));
        objRequest.consent = String.valueOf(inputWrapper.dynamicInputs.get('consent'));
        AUSF_PanDobRequestWrapper.ClientData cd = new AUSF_PanDobRequestWrapper.ClientData();
        cd.caseId = '';
        objRequest.clientData = cd;
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