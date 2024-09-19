/**
 * @author              : Amit Mishra
 * @date                : 19-June-2024
 * @description         : BRE UNDERWRITING API callout controller
 * Test Class           : 
 * History              :
 * ===========================================================================================================
 * <Date> 		<Authors Name> 		<Brief Description of Change>
 * ===========================================================================================================
 * 19-June-2024 	Amit Mishra 		Initial Version
**/
public without sharing class AUSF_INT_BRE_UNDERWRITING_Controller {

    public class CustomException extends Exception {}
    /*
    @description    : getBreResponse - main method to genrate request and publish bre Integration platform event
    @author         : Amit Mishra
    @date           : 03-July-2024
    @param1         : loanId - Loan Application Id
    @param2         : callType - Type of BRE callout
    @return         : BRE response wrapper
    */
    @AuraEnabled
    public static AUSF_INT_BRE_ResponseWrapper getBreResponse(String loanId, String callType){
        //Return response wrapper
        AUSF_INT_BRE_ResponseWrapper controllerResponseWrapper = new AUSF_INT_BRE_ResponseWrapper();
        Boolean runPlatformEvent = false;   //if platform event used mark true
        Boolean isCheckListNameRequired = false;
        String checklistId;
        try{    
            //Validating input parameters
            if(String.isBlank(loanId)){
                throw new CustomException(AUSF_ApexConstants.LOAN_APPLICATION_ID_REQUIRED);
            }
            if(String.isBlank(callType)){
                throw new CustomException(AUSF_ApexConstants.BRE_CALL_TYPE_REQUIRED);
            }
            //Integration Master query
            Integration_Master__c integrationMasterRecord = AUSF_INT_IntegrationUtility.getIntegrationMasterRecord(AUSF_INT_BRE_Constants.FICO_BRE_UNDERWRITTING_INTEGRATION_MASTER);
            //Creting Integration Checklist 
            Integration_Checklist__c checkListRecord = new Integration_Checklist__c();
            checkListRecord.Integration_Master__c = integrationMasterRecord.Id;
            checkListRecord.Loan_Application__c = loanId;
            checkListRecord.Request_Id__c = AUSF_INT_IntegrationUtility.getReferenceId();
            //Creating genric request wrapper
            AUSF_INT_IntegrationUtility.InputWrapper inputReqWrapper = new AUSF_INT_IntegrationUtility.InputWrapper();
            inputReqWrapper.integrationMasterRecord = integrationMasterRecord;
            inputReqWrapper.loanRecord = AUSF_INT_BRE_Utility.getLoanData(loanId)[0];
            inputReqWrapper.applicantRecord = AUSF_INT_BRE_Utility.getApplicantData(loanId)[0];
            inputReqWrapper.integrationChecklistRecord = checkListRecord;
            inputReqWrapper.dynamicInputs = new Map<String, Object>{AUSF_INT_BRE_Constants.BRE_CALLTYPE => callType};
            inputReqWrapper.dynamicInputs.put(AUSF_INT_BRE_Constants.LOCATION_MASTER,AUSF_INT_BRE_Utility.getLocationMaster(inputReqWrapper.applicantRecord));
            inputReqWrapper.dynamicInputs.put(AUSF_INT_BRE_Constants.BRE_REFERENCE_ID,checkListRecord.Request_Id__c);

            //Creating Integration Utility instance for generting  main request
            AUSF_INT_IntegrationUtility intUtility = new AUSF_INT_IntegrationUtility();
            AUSF_INT_IntegrationRequestWrapper.HTTPRequestWrapper requestData = intUtility.constructRequest(inputReqWrapper);
            //Checking validation i.e.if preRequisites exist
            if (String.isNotBlank(requestData.preRequisites)) {
                checkListRecord.Status__c = AUSF_ApexConstants.MISSING_PRE_REQUISITES;
                checkListRecord.Missing_Pre_requisites__c = requestData.preRequisites;
                upsert checkListRecord Request_Id__c;
                isCheckListNameRequired = true;
                checklistId = checkListRecord.Id;
                throw new CustomException(requestData.preRequisites);
            }
            //Platform event to publish request
            if(runPlatformEvent){
                AUSF_INT_BRE_Utility.handlePlatformEvent(callType, requestData.request, checkListRecord.Id);
                controllerResponseWrapper.blnIntegrationSuccess = true;
                controllerResponseWrapper.blnSuccess = true;
                checkListRecord.Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED;
                upsert checkListRecord Request_Id__c;
            }else{
                //Synchronous callout
                AUSF_INT_IntegrationRequestWrapper.RequestWrapper calloutRequestWrapper = new AUSF_INT_IntegrationRequestWrapper.RequestWrapper();
                calloutRequestWrapper.request = requestData.request;
                calloutRequestWrapper.masterRecord = integrationMasterRecord;
                calloutRequestWrapper.checklistRecord = checkListRecord;
                calloutRequestWrapper.entityId = loanId;
                System.debug(LoggingLevel.Info,'callout Request Wrapper:'+calloutRequestWrapper);
                AUSF_INT_IntegrationResponseWrapper.ResponseWrapper calloutResponseWrapper = intUtility.initiateCallout(calloutRequestWrapper);
                System.debug('Callout Response Wrapper:'+calloutResponseWrapper);
                System.debug('Callout Response Wrapper(response):'+calloutResponseWrapper.response);
                //Validate API limit resticrtion for user
                if (calloutResponseWrapper.errorMessage != null) {
                    throw new CustomException(calloutResponseWrapper.errorMessage);
                }
                if(calloutResponseWrapper == NULL || calloutResponseWrapper.statusCode != 200 ){
                    calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                    upsert calloutResponseWrapper.checklistRecord Request_Id__c;
                    isCheckListNameRequired = true;
                    checklistId = calloutResponseWrapper.checklistRecord.Id;
                    throw new CustomException(AUSF_ApexConstants.GENERIC_INTEGRATION_FAILUR_MSG_INTERNAL);
                }
                controllerResponseWrapper.blnIntegrationSuccess = true;
                calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED;
                upsert calloutResponseWrapper.checklistRecord Request_Id__c;
                controllerResponseWrapper.responseWrapper = calloutResponseWrapper;
                //handle all DML and error handling from response
                //handleBreResponse(calloutResponseWrapper.response, inputReqWrapper.loanRecord, calloutResponseWrapper.checklistRecord);
                controllerResponseWrapper.blnSuccess = true;
            }
        } catch (Exception ex) {
            String message = ex.getMessage();
            if(isCheckListNameRequired){
                message += '-'+AUSF_INT_IntegrationUtility.getIntegrationChecklist(checklistId).Name;
            }
            controllerResponseWrapper.strMessage = message;
            System.debug(LoggingLevel.Error,'Exception in AUSF_INT_BRE_Controller: ' + ex);
            System.debug('===============================================================');
            System.debug(LoggingLevel.Error,'Exception type caught: ' + ex.getTypeName());
            System.debug(LoggingLevel.Error,'Message: ' + ex.getMessage());
            System.debug(LoggingLevel.Error,'Line number: ' + ex.getLineNumber());
            System.debug(LoggingLevel.Error,'Stack trace: ' + ex.getStackTraceString());
            System.debug('===============================================================');
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium, loanId, 'Applicant','AUSF_INT_BRE_Controller');      
        }
        return controllerResponseWrapper;        
    }
    
}