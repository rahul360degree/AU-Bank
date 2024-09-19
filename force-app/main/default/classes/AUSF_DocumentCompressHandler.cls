/**
 * @author        Pradeep Sharma
 * Class :		 AUSF_DocumentCompressHandler
 * Test Class	 AUSF_DocumentCompressTest
 * @date          05-July-2024
 * @description   Document Compression api Handler
 * Modification Log:
--------------------------------------------------------------------------------------------
    Developer             Date            Description
    --------------------------------------------------------------------------------------------
    Pradeep Sharma        05-July-2024    Initial Version
     */
public without sharing class AUSF_DocumentCompressHandler implements AUSF_INT_IntegrationHandlerInterface {
    
    Public List < String > generateRequest(List < Object > inputWrappers) {
        List<String> lstRequestString = new List<String>();
        if (inputWrappers.isEmpty()) {
            return new List < String > ();
        }
        AUSF_INT_IntegrationUtility.InputWrapper inputWrapper = (AUSF_INT_IntegrationUtility.InputWrapper)inputWrappers.get(0);
        AUSF_DocumentCompressRequestWrappper objRequest = new AUSF_DocumentCompressRequestWrappper();
        objRequest.RequestId = AUSF_INT_IntegrationUtility.getReferenceId();
        objRequest.OriginatingChannel = String.valueOf(inputWrapper.dynamicInputs.get('channel'));
        objRequest.filename = String.valueOf(inputWrapper.dynamicInputs.get('file'));
        objRequest.base64string = String.valueOf(inputWrapper.dynamicInputs.get('base64string'));
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
        
    }

    public void callbackService(List < Integration_Checklist__c > checklistRecords, List < ContentVersion > responseFiles) {
        
    }

    public List < sObject > generatePlatformEvents(List < Object > inputWrappers) {
        return null;
    }
   
}