/**
 * @author          : Amit Mishra
 * @date            : 24-June-2024
 * @description     : NSDL PAN API callout handler - use to generate request and validate the prerequisites
 * Test Class		: AUSF_NsdlPanTest
 * History:
 * ==========================================================================================================
 * <Date> 		<Authors Name> 		<Brief Description of Change>
 * ==========================================================================================================
 * 24-June-2024 	Amit Mishra 		Initial Version
**/
public without sharing class AUSF_NsdlPanHandler implements AUSF_INT_IntegrationHandlerInterface {

    public List<Object> generateRequest(List<Object> inputWrappers){
        List<String> requestStringList = new List<String>();
        if (inputWrappers.isEmpty()) {
            return requestStringList;
        }
        AUSF_INT_IntegrationUtility.InputWrapper inputWrapper = (AUSF_INT_IntegrationUtility.InputWrapper)inputWrappers.get(0);
        AUSF_NsdlPanRequestWrapper requestWrapper = new AUSF_NsdlPanRequestWrapper();
        requestWrapper.Pan = String.valueOf(inputWrapper.dynamicInputs.get('Pan'));
        requestWrapper.Name = String.valueOf(inputWrapper.dynamicInputs.get('Name'));
        requestWrapper.DateOfBirth = String.valueOf(inputWrapper.dynamicInputs.get('DateOfBirth'));
        requestWrapper.RequestId = inputWrapper.integrationMasterRecord.Channel__c;
        requestWrapper.OriginatingChannel = AUSF_INT_IntegrationUtility.getReferenceId();
        requestStringList.add(JSON.serialize(requestWrapper));
        return requestStringList;
    }
    public List<String> validateInputData(List<Object> inputWrappers){
        List<String> validationErrorsList = new List <String>();
        AUSF_INT_IntegrationUtility.InputWrapper inputWrapper = (AUSF_INT_IntegrationUtility.InputWrapper)inputWrappers.get(0);
        if(String.isBlank( String.valueOf(	inputWrapper.dynamicInputs.get('Pan')	) ) ){
            validationErrorsList.add(AUSF_ApexConstants.PAN_REQUIRED);
        }
        if(String.isBlank( String.valueOf(	inputWrapper.dynamicInputs.get('Name'))	) ){
            validationErrorsList.add(AUSF_ApexConstants.NAME_REQUIRED);
        }
        if(String.isBlank( String.valueOf(	inputWrapper.dynamicInputs.get('DateOfBirth')	) ) ){
            validationErrorsList.add(AUSF_ApexConstants.DATE_OF_BIRTH_REQUIRED);
        }
        return validationErrorsList;
    }
    public List<sObject> generatePlatformEvents(List<Object> recordList){
        return NULL;
    }
    public void callbackService(List<Integration_Checklist__c> checklistRecords, List<ContentVersion> responseFiles){/*To Do*/}
    public void beforeUpdateService(Integration_Checklist__c checklistRecord, ContentVersion responseFile){/*To Do*/}
}