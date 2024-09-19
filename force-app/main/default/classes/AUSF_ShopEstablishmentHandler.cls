/**
 * @author        Enuganti Ram
 * @date          07-July-2024
 * @description   Fetch Shop Establishment details Handler class
 * Modification Log:
--------------------------------------------------------------------------------------------
    Developer             Date            Description
    --------------------------------------------------------------------------------------------
    Enuganti Ram              07-July-2024    Initial Version - APL-204
*/

public without sharing class AUSF_ShopEstablishmentHandler implements AUSF_INT_IntegrationHandlerInterface {
public List<String> generateRequest(List <Object> inputWrappers){
        List<String> lstRequestString = new List<String>(); 
        if (inputWrappers.isEmpty()) {
            return new List <String> ();
        }
        AUSF_INT_IntegrationUtility.InputWrapper inputWrapper = (AUSF_INT_IntegrationUtility.InputWrapper)inputWrappers.get(0);
        AUSF_ShopEstablishmentRequestWrapper objRequest = new AUSF_ShopEstablishmentRequestWrapper();
        objRequest.requestid = String.valueOf(inputWrapper.dynamicInputs.get('requestid'));
        objRequest.channel = String.valueOf(inputWrapper.dynamicInputs.get('channel'));
        objRequest.regNo = String.valueOf(inputWrapper.dynamicInputs.get('regNo'));
        objRequest.pdfRequired = Boolean.valueOf(inputWrapper.dynamicInputs.get('pdfRequired'));
        objRequest.areaCode = String.valueOf(inputWrapper.dynamicInputs.get('areaCode'));
        objRequest.consent = String.valueOf(inputWrapper.dynamicInputs.get('consent'));
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