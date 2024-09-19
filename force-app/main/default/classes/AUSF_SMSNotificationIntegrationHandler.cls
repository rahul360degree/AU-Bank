/**
* @author        Tejendra
* @date          3-July-2024
* @description   SMS Notification Request Handler class
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Tejendra              3-July-2024    Initial Version - APL-240
*/

public without sharing class AUSF_SMSNotificationIntegrationHandler implements AUSF_INT_IntegrationHandlerInterface{
    public AUSF_SMSNotificationIntegrationHandler() {

    }

    public static List<String> generateRequest(List<Object> inputWrappers){
        List<String> lstRequestString = new List<String>(); 
        if (inputWrappers.isEmpty()) {
            return new List <String> ();
        }
        AUSF_INT_IntegrationUtility.InputWrapper inputWrapper = (AUSF_INT_IntegrationUtility.InputWrapper)inputWrappers.get(0);
        AUSF_SMSNotificationRequestWrapper smsRequestWrapper = new AUSF_SMSNotificationRequestWrapper();
        smsRequestWrapper.RequestId = String.valueOf(inputWrapper.dynamicInputs.get('RequestId'));
        smsRequestWrapper.Channel = String.valueOf(inputWrapper.dynamicInputs.get('Channel'));
        smsRequestWrapper.GroupID =String.valueOf(inputWrapper.dynamicInputs.get('GroupID'));
        smsRequestWrapper.ContentType = String.valueOf(inputWrapper.dynamicInputs.get('ContentType'));
        smsRequestWrapper.NationalorInternational = String.valueOf(inputWrapper.dynamicInputs.get('NationalorInternational'));
        smsRequestWrapper.MessageType = String.valueOf(inputWrapper.dynamicInputs.get('MessageType'));
        smsRequestWrapper.IsOTPMessage = String.valueOf(inputWrapper.dynamicInputs.get('IsOTPMessage'));
        smsRequestWrapper.LanguageId = String.valueOf(inputWrapper.dynamicInputs.get('LanguageId'));
        AUSF_SMSNotificationRequestWrapper.Message_cls messageObj = new  AUSF_SMSNotificationRequestWrapper.Message_cls();
        messageObj.MobileNumber = String.valueOf(inputWrapper.dynamicInputs.get('MobileNumber'));
        messageObj.MessageText = String.valueOf(inputWrapper.dynamicInputs.get('MessageText'));
        smsRequestWrapper.Message = messageObj;
        lstRequestString.add(JSON.serialize(smsRequestWrapper));   
        return lstRequestString;
    }

    public List < String > validateInputData(List<Object> inputWrappers) {
        List<String> validationErrorsList = new List <String>();
        AUSF_INT_IntegrationUtility.InputWrapper inputWrapper = (AUSF_INT_IntegrationUtility.InputWrapper)inputWrappers.get(0);
        if(String.isBlank( String.valueOf(inputWrapper.dynamicInputs.get('MobileNumber')))){
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