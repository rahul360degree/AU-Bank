/**
* @author        Tejendra
* @date          07-August-2024
* @description   Import Export Certificate handler class - use to generate request and validate the prerequisites
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Tejendra              07-August-2024    Initial Version - APL-202
*/
public without sharing class AUSF_ImportExportCertificateHandler implements AUSF_INT_IntegrationHandlerInterface{
    public List<String> generateRequest(List <Object> inputWrappers){
        List<String> lstRequestString = new List<String>(); 
        if (inputWrappers.isEmpty()) {
            return new List <String> ();
        }
        AUSF_INT_IntegrationUtility.InputWrapper inputWrapper = (AUSF_INT_IntegrationUtility.InputWrapper)inputWrappers.get(0);
        AUSF_ImportExportCrtificatRequestWrapper objRequest = new AUSF_ImportExportCrtificatRequestWrapper();
        objRequest.RequestId = String.valueOf(inputWrapper.dynamicInputs.get('RequestId'));
        objRequest.OriginatingChannel = String.valueOf(inputWrapper.dynamicInputs.get('OriginatingChannel'));
        objRequest.Consent = String.valueOf(inputWrapper.dynamicInputs.get('Consent'));
        objRequest.Iec = String.valueOf(inputWrapper.dynamicInputs.get('Iec'));
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