/**
 * @author: Amit Mishra
 * @date: 18-June-2024
 * @description: NSDL PAN verification integration callout controller 
 * Test Class: AUSF_NsdlPanTest
 * History:
 * ====================================================================
 * <Date> 		<Authors Name> 		<Brief Description of Change>
 * ====================================================================
 * 06-19-2024 	Amit Mishra 		Initial Version
**/
public without sharing class AUSF_NsdlPanCalloutController {
	public class CustomException extends Exception {}
    
    /*
    @description    : mobileOtpVerificationHandler - validate PAN service method
    @param1         : loanApplicationId - Loan Application Id 
    @param2         : applicantId - Applicant Id
    @param3         : panNo - PAN No
    @param4         : name - Applicant or client Name
    @param5         : dob - Applicant Date of Birth
    @return         : AUSF_INT_ValidatePANResponseWrapper - Wrapper class contains return result
    */
	@AuraEnabled
    public static AUSF_INT_ValidatePANResponseWrapper validatePAN(String loanApplicationId, String applicantId, String panNo, String name, String dob){
        Integration_Master__c objIntMaster = AUSF_INT_IntegrationUtility.getIntegrationMasterRecord(AUSF_ApexConstants.NSDL_PAN_INTEGRATION_MASTER);
        Boolean IsCheckListNameRequired = false;
        String checklistId;
        if (objIntMaster == NULL || objIntMaster.Id == NULL) {
            throw new CustomException(AUSF_ApexConstants.INTEGRATION_MASTER_MISSING);
        }
        AUSF_INT_ValidatePANResponseWrapper returnResponse = new AUSF_INT_ValidatePANResponseWrapper();
        try{
            Applicant__c applicantRecord = [Select Id, Name from Applicant__c where Id =: applicantId];
        	Integration_Checklist__c checkListRecord = new Integration_Checklist__c();
            checkListRecord.Integration_Master__c = objIntMaster.Id;
            checkListRecord.Applicant__c = applicantRecord.Id;
            AUSF_INT_IntegrationUtility.InputWrapper inputData = new AUSF_INT_IntegrationUtility.InputWrapper();
            inputData.integrationChecklistRecord = checkListRecord;
            inputData.integrationMasterRecord = objIntMaster;
            inputData.applicantRecord = applicantRecord;
            inputData.dynamicInputs = new Map<String, Object>();
            inputData.dynamicInputs.put('Pan',panNo );
            inputData.dynamicInputs.put('Name',name);
            inputData.dynamicInputs.put('DateOfBirth',dob);
            AUSF_INT_IntegrationUtility utilityInstance = new AUSF_INT_IntegrationUtility();
            //generating request wrapper
            AUSF_INT_IntegrationRequestWrapper.HTTPRequestWrapper requestData = utilityInstance.constructRequest(inputData);
            if (String.isNotBlank(requestData.preRequisites)) {
                checkListRecord.Status__c = AUSF_ApexConstants.MISSING_PRE_REQUISITES;
                checkListRecord.Missing_Pre_requisites__c = requestData.preRequisites;
                upsert checkListRecord;
                IsCheckListNameRequired = true;
                checklistId = checkListRecord.Id;
                throw new CustomException(requestData.preRequisites);
            }
            //generating final request wrapper
            AUSF_INT_IntegrationRequestWrapper.RequestWrapper calloutRequestWrapper = new AUSF_INT_IntegrationRequestWrapper.RequestWrapper();
			calloutRequestWrapper.request = requestData.request;
            calloutRequestWrapper.masterRecord = objIntMaster;
            calloutRequestWrapper.checklistRecord = checkListRecord;
            calloutRequestWrapper.entityId = applicantRecord.Id;
            //Api callout
            AUSF_INT_IntegrationResponseWrapper.ResponseWrapper calloutResponseWrapper = utilityInstance.initiateCallout(calloutRequestWrapper);
            //handling error & validation
            if (calloutResponseWrapper.errorMessage != null) {
                throw new CustomException(calloutResponseWrapper.errorMessage);
            }
            if(calloutResponseWrapper == NULL || calloutResponseWrapper.statusCode != 200 ){
                calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                upsert calloutResponseWrapper.checklistRecord;
                IsCheckListNameRequired = true;
                checklistId = calloutResponseWrapper.checklistRecord.Id;
                throw new CustomException(AUSF_ApexConstants.NSDL_PAN_ERROR_MESSAGE);
            }
            //parsing api response & updating checkList
            //returnResponse.blnIntegrationSuccess = true;
            //calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED;
            //upsert calloutResponseWrapper.checklistRecord;
            returnResponse.responseWrapper = calloutResponseWrapper;
            
            AUSF_INT_ValidatePANResponseWrapper.LOSNsdlResponseWrapper respData = (AUSF_INT_ValidatePANResponseWrapper.LOSNsdlResponseWrapper)JSON.deserialize(calloutResponseWrapper.response, AUSF_INT_ValidatePANResponseWrapper.LOSNsdlResponseWrapper.class);
            AUSF_INT_ValidatePANResponseWrapper.Response respWrap = (respData != NULL && respData.response != NULL && respData.response.size()>0 && respData.response[0] != NULL) ? respData.response[0] : NULL;

            //validate pan business logic
            if (respWrap == NULL || respData.headers == NULL || respData.headers.responseCode == NULL || respData.headers.responseCode == NULL || respData.headers.responseCode != '0') {
                calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                upsert calloutResponseWrapper.checklistRecord;
                IsCheckListNameRequired = true;
                checklistId = calloutResponseWrapper.checklistRecord.Id;
                throw new CustomException(AUSF_ApexConstants.NSDL_PAN_ERROR_MESSAGE);
            }
            if (respWrap != NULL && respData.headers != NULL && respData.headers.responseCode != NULL && respData.headers.responseCode == '0'){
                calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED;
                upsert calloutResponseWrapper.checklistRecord;
                if(respData.response[0].Status != 'E'){
                    throw new CustomException(AUSF_ApexConstants.NSDL_PAN_INVALID_ERROR_MESSAGE);
                }
            }
            //update response Screen wrapper
            returnResponse.status = respWrap.Status;
            returnResponse.pan = respWrap.PAN;
            returnResponse.name = respWrap.Name;
            returnResponse.nameOnCard = respWrap.NameOnCard;
            returnResponse.fatherName = respWrap.FatherName;
            returnResponse.seedingStatus = respWrap.SeedingStatus;
            //Dml
			handleDml(applicantRecord.Id);
            returnResponse.blnSuccess = true;
        }
        catch (Exception ex) {
            String message = ex.getMessage();
            if(IsCheckListNameRequired){
                message += '-'+AUSF_INT_IntegrationUtility.getIntegrationChecklist(checklistId).Name;
            }
            returnResponse.strMessage = message;
            System.debug(LoggingLevel.Error,'Exception in AUPL_NsdlPanCalloutController ' + ex +ex.getMessage());
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium, applicantId, 'Applicant','NSDL_PAN_INTIGRATION_CALLOUT');// Params - Exception, Severity, RecordId, Object Label Name, Screen
        }
        return returnResponse;
    }
    /*
    @description    : handleDml - perform update in applicant object after Bre run
    @param1         : applicantId - Applicant Id
    */
    public static void handleDml(String applicantId){
        Applicant__c applicant = new Applicant__c(Id = applicantId);
        applicant.PAN_Verified_At__c = Datetime.now();
        applicant.PAN_Source__c = AUSF_ApexConstants.PAN_SOURCE_NSDL;
        applicant.Is_PAN_Verified__c = AUSF_ApexConstants.Is_PAN_VERIFIED_YES;
        upsert applicant;
	}
}