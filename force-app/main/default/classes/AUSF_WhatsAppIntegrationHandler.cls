/**
* @author        Tejendra
* @date          6-July-2024
* @description   WhatsApp Notification Request Handler class
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Tejendra              6-July-2024    Initial Version - APL-247
*/
public without sharing class AUSF_WhatsAppIntegrationHandler implements AUSF_INT_IntegrationHandlerInterface {
    public AUSF_WhatsAppIntegrationHandler() {

    }

    public static List<String> generateRequest(List<Object> inputWrappers){
        List<String> lstRequestString = new List<String>(); 
        if (inputWrappers.isEmpty()) {
            return new List <String> ();
        }
        AUSF_INT_IntegrationUtility.InputWrapper inputWrapper = (AUSF_INT_IntegrationUtility.InputWrapper)inputWrappers.get(0);
        AUSF_WhatsAppNotificationRequestWrapper whatsAppRequestWrapper = new AUSF_WhatsAppNotificationRequestWrapper();
        AUSF_WhatsAppNotificationRequestWrapper.cls_dynamic_data dynamicDataObj = new  AUSF_WhatsAppNotificationRequestWrapper.cls_dynamic_data();
        dynamicDataObj.key1 = String.valueOf(inputWrapper.dynamicInputs.get('key1'));
        dynamicDataObj.key2 = String.valueOf(inputWrapper.dynamicInputs.get('key2'));
        dynamicDataObj.key3 = String.valueOf(inputWrapper.dynamicInputs.get('key3'));
        dynamicDataObj.key4 = String.valueOf(inputWrapper.dynamicInputs.get('key4'));
        dynamicDataObj.key5 = String.valueOf(inputWrapper.dynamicInputs.get('key5'));
        AUSF_WhatsAppNotificationRequestWrapper.cls_client_data clientDataObj = new  AUSF_WhatsAppNotificationRequestWrapper.cls_client_data();
        clientDataObj.name = String.valueOf(inputWrapper.dynamicInputs.get('name'));
        clientDataObj.phone_number = String.valueOf(inputWrapper.dynamicInputs.get('phone_number'));
        clientDataObj.media_url = String.valueOf(inputWrapper.dynamicInputs.get('media_url'));
        clientDataObj.document_filename = String.valueOf(inputWrapper.dynamicInputs.get('document_filename'));
        clientDataObj.dynamic_data = dynamicDataObj;
        whatsAppRequestWrapper.authorization = String.valueOf(inputWrapper.dynamicInputs.get('authorization'));
        whatsAppRequestWrapper.client_data = clientDataObj;
        whatsAppRequestWrapper.RequestId = String.valueOf(inputWrapper.dynamicInputs.get('RequestId'));
        whatsAppRequestWrapper.whatsapp_bsp = String.valueOf(inputWrapper.dynamicInputs.get('whatsapp_bsp'));
        whatsAppRequestWrapper.Channel =String.valueOf(inputWrapper.dynamicInputs.get('Channel'));
        whatsAppRequestWrapper.campaign_id = String.valueOf(inputWrapper.dynamicInputs.get('campaign_id'));
        lstRequestString.add(JSON.serialize(whatsAppRequestWrapper));   
        return lstRequestString;
    }

    public List < String > validateInputData(List < Object > inputWrappers) {
        List<String> validationErrorsList = new List <String>();
        AUSF_INT_IntegrationUtility.InputWrapper inputWrapper = (AUSF_INT_IntegrationUtility.InputWrapper)inputWrappers.get(0);
        if(String.isBlank( String.valueOf(inputWrapper.dynamicInputs.get('phone_number')))){
            validationErrorsList.add(AUSF_ApexConstants.AUSF_MOBILE_MISSISNG);
        }
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