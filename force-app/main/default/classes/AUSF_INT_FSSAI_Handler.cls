/**
 * @author              : Amit Mishra
 * @date                : 05-Aug-2024
 * @description         : FSSAI API Integration Handler
 * Test Class           : AUSF_INT_FSSAI_Test
 * History              : 
 * ===========================================================================================================
 * <Date> 		<Authors Name> 		<Brief Description of Change>
 * ===========================================================================================================
 * 05-Aug-2024 	Amit Mishra 		Initial Version
**/
public without sharing class AUSF_INT_FSSAI_Handler implements AUSF_INT_IntegrationHandlerInterface{
    
    public List<Object> generateRequest(List<Object> inputWrappers){
        List<String> requestStringList = new List<String>();
        if (inputWrappers.isEmpty()) {
            return requestStringList;
        }
        AUSF_INT_IntegrationUtility.InputWrapper inputWrapper = (AUSF_INT_IntegrationUtility.InputWrapper)inputWrappers.get(0);
        String regNo = String.valueOf(inputWrapper.dynamicInputs.get('RegistrationNo'));
        AUSF_INT_FSSAI_RequestWrapper requestWrapper = new AUSF_INT_FSSAI_RequestWrapper();
        requestWrapper.RequestId = inputWrapper.integrationChecklistRecord.Request_Id__c;
        requestWrapper.OriginatingChannel = inputWrapper.integrationMasterRecord.Channel__c;
        requestWrapper.RegNo = regNo;
        requestWrapper.Consent = AUSF_ApexConstants.FSSAI_CONSENT;
        requestStringList.add(JSON.serialize(requestWrapper));
        return requestStringList;
    }

    public List<String> validateInputData(List<Object> inputWrappers){
        List<String> validationErrorsList = new List <String>();
        if(inputWrappers.isEmpty()){
            return validationErrorsList;
        }
        return validationErrorsList;
    }

    public List<sObject> generatePlatformEvents(List<Object> recordList){
        return NULL;
    }
    public void callbackService(List<Integration_Checklist__c> checklistRecords, List<ContentVersion> responseFiles){/*To Do*/}
    public void beforeUpdateService(Integration_Checklist__c checklistRecord, ContentVersion responseFile){/*To Do*/} 
}