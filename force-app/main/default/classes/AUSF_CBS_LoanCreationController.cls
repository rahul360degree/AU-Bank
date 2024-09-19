/**
* @author        Rahul Yadav.
* @date          25-July-2024
* @description   
* Modification Log:
* Test Class     AUSF_CBS_LoanCreationTest
--------------------------------------------------------------------------------------------
Developer               Date            Description
--------------------------------------------------------------------------------------------
Rahul Yadav.            25-July-2024    Initial Version
*/
public without sharing class AUSF_CBS_LoanCreationController {
    /*
    @description    : doCSBLoanAccountCreationCallout - CBS-Loan Account Creation
    @param1         : loanId - Loan record
    @param2         : applicantRecId - Applicant record
    */
    @AuraEnabled
    public static AUSF_CBS_LoanCreationResponseWrapper doCSBLoanAccountCreationCallout(string loanId, string applicantRecId){
        AUSF_CBS_LoanCreationResponseWrapper objResponse = new AUSF_CBS_LoanCreationResponseWrapper();
        Integration_Master__c objIntMapper = AUSF_INT_IntegrationUtility.getIntegrationMasterRecord(AUSF_ApexConstants.AUSF_CBS_LOAN_CREATION_INTEGRATION_MASTER);
        String strIntMessage = '';
        if (objIntMapper == NULL || objIntMapper.Id == NULL) {
            throw new CustomException(AUSF_ApexConstants.GENERIC_MASTER_MISSING_ERROR_MSG);
        }
        try {
            Applicant__c applicant = [SELECT Id,Name,Is_Personal_Email_Id_Verified__c FROM Applicant__c WHERE Id =: applicantRecId limit 1];
            Integration_Checklist__c newChecklistInstance = new Integration_Checklist__c();
            newChecklistInstance.Integration_Master__c = objIntMapper.Id;
            newChecklistInstance.Applicant__c = applicant.Id;
            AUSF_INT_IntegrationUtility.InputWrapper inputData = new AUSF_INT_IntegrationUtility.InputWrapper();
            inputData.integrationChecklistRecord = newChecklistInstance;
            inputData.integrationMasterRecord = objIntMapper;
            inputData.applicantRecord = applicant;
            inputData.dynamicInputs = new Map<String, Object>();
            // inputData.dynamicInputs.put('emailAddress', emailAddress);
            inputData.dynamicInputs.put('channel', objIntMapper.Channel__c);
            AUSF_INT_IntegrationUtility utilityInstance = new AUSF_INT_IntegrationUtility();
            AUSF_INT_IntegrationRequestWrapper.HTTPRequestWrapper requestDetails = utilityInstance.constructRequest(inputData);
            if (String.isNotBlank(requestDetails.preRequisites)) {
                newChecklistInstance.Status__c = AUSF_ApexConstants.MISSING_PRE_REQUISITES;
                newChecklistInstance.Missing_Pre_requisites__c = requestDetails.preRequisites;
                upsert newChecklistInstance;
                throw new CustomException(requestDetails.preRequisites);
            }
            AUSF_INT_IntegrationResponseWrapper.ResponseWrapper calloutResponseWrapper = new AUSF_INT_IntegrationResponseWrapper.ResponseWrapper();
            AUSF_INT_IntegrationRequestWrapper.RequestWrapper calloutRequestWrapper = new AUSF_INT_IntegrationRequestWrapper.RequestWrapper();
            calloutRequestWrapper.request = requestDetails.request;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = newChecklistInstance;
            calloutResponseWrapper = utilityInstance.initiateCallout(calloutRequestWrapper);
            AUSF_INT_IntegrationResponseWrapper.ResponseWrapper resp = calloutResponseWrapper;
            objResponse.responseWrapper = resp;
            if (calloutResponseWrapper.statusCode != 200 ) {
                calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                upsert calloutResponseWrapper.checklistRecord;
                strIntMessage = 'Error With Service - ' + objIntMapper.Name + ' and record reference - '+AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id).Name;
                if (calloutResponseWrapper.errorMessage != NULL) {
                    String strErrMsg = calloutResponseWrapper.errorMessage +' - '+AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id).Name;
                    throw new CustomException(strErrMsg);
                } else{
                    // throw new CustomException(errorMessageMap.containsKey(calloutResponseWrapper.statusCode) ? errorMessageMap.get(calloutResponseWrapper.statusCode) : strIntMessage);
                }
            }
            else  {
                AUSF_EmailAuthenticationWrapper res = NULL;
                res = calloutResponseWrapper.response.startsWith('<html>') ? NULL : (AUSF_EmailAuthenticationWrapper)JSON.deserialize(calloutResponseWrapper.response,AUSF_EmailAuthenticationWrapper.class);
                // string rawResponse = res.Fields.Applicants.Applicant.Services.Service[0].Operations.Operation[0].Data.Response.RawResponse;
                String rawResponse;
                // Check res and its nested properties for null
            }
        }
        catch (Exception ex) {
            objResponse.strMessage = ex.getMessage();
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium,applicantRecId,'Applicant','Email Verification-TU');
        }
        return objResponse;
        
    }
    public class CustomException extends Exception {}
}