/**
* @author        Tejendra
* @date          4-July-2024
* @description   Email Notification Request Handler class
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Tejendra              4-July-2024    Initial Version - APL-244
*/
public without sharing class AUSF_EmailNotificationIntegrationHandler implements AUSF_INT_IntegrationHandlerInterface {
    public AUSF_EmailNotificationIntegrationHandler() {

    }

    public static List<String> generateRequest(List<Object> inputWrappers){
        List<String> lstRequestString = new List<String>(); 
        if (inputWrappers.isEmpty()) {
            return new List <String> ();
        }
        AUSF_INT_IntegrationUtility.InputWrapper inputWrapper = (AUSF_INT_IntegrationUtility.InputWrapper)inputWrappers.get(0);
        AUSF_EmailNotificationRequestWrapper emailRequestWrapper = new AUSF_EmailNotificationRequestWrapper();
        emailRequestWrapper.RequestId = String.valueOf(inputWrapper.dynamicInputs.get('RequestId'));
        emailRequestWrapper.Channel = String.valueOf(inputWrapper.dynamicInputs.get('Channel'));
        emailRequestWrapper.TO =String.valueOf(inputWrapper.dynamicInputs.get('TO'));
        emailRequestWrapper.Subject = String.valueOf(inputWrapper.dynamicInputs.get('Subject'));
        emailRequestWrapper.Text = String.valueOf(inputWrapper.dynamicInputs.get('Text'));
        emailRequestWrapper.CC = '';
        emailRequestWrapper.BCC = '';
        emailRequestWrapper.Priority = '';
        AUSF_EmailNotificationRequestWrapper.Attachment_cls attachmentObj = new  AUSF_EmailNotificationRequestWrapper.Attachment_cls();
        attachmentObj.FileName = String.valueOf(inputWrapper.dynamicInputs.get('FileName'));
        attachmentObj.FileMimeType = String.valueOf(inputWrapper.dynamicInputs.get('FileMimeType'));
        attachmentObj.FileDataContent = String.valueOf(inputWrapper.dynamicInputs.get('FileDataContent'));
        emailRequestWrapper.Attachment = attachmentObj;
        lstRequestString.add(JSON.serialize(emailRequestWrapper));   
        return lstRequestString;
    }

    public List < String > validateInputData(List <Object> inputWrappers) {
        List<String> validationErrorsList = new List <String>();
        AUSF_INT_IntegrationUtility.InputWrapper inputWrapper = (AUSF_INT_IntegrationUtility.InputWrapper)inputWrappers.get(0);
        if(String.isBlank( String.valueOf(inputWrapper.dynamicInputs.get('TO')))){
            validationErrorsList.add(AUSF_ApexConstants.AUSF_EMAIL_MISSISNG);
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