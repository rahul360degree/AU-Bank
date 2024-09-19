/**
* @author        Rahul Yadav.
* @date          18-June-2024
* @description   This class describes the TU API Integration to Fetch Name based on Mobile Number
* Modification Log:
* Test Class     AUSF_EmailAuthenticationTest
--------------------------------------------------------------------------------------------
Developer               Date            Description
--------------------------------------------------------------------------------------------
Rahul Yadav.            26-June-2024    Initial Version
Mohit M.                08-JAug-2024    add logic for Re-Authenticate and Uncheck Verfified field
*/
public without sharing class AUSF_EmailAuthenticationController {
    /*
    @description    : doEmailAuthentication - verify email address
    @param1         : loanId - Loan record
    @param2         : applicantRecId - Applicant record
    @param3         : emailAddress - Getting email address to verify
    @return         : Wrapper class contains return result
    */
    @AuraEnabled
    public static AUSF_EmailAuthenticationWrapper doEmailAuthentication(string loanId, string applicantRecId,string emailAddress ){
        AUSF_EmailAuthenticationWrapper objResponse = new AUSF_EmailAuthenticationWrapper();
        Integration_Master__c objIntMapper = AUSF_INT_IntegrationUtility.getIntegrationMasterRecord(AUSF_ApexConstants.AUSF_EMAIL_VERIFICATION_INTEGRATION_MASTER);
        String strIntMessage = '';
        if (objIntMapper == NULL || objIntMapper.Id == NULL) {
            throw new CustomException(AUSF_ApexConstants.GENERIC_MASTER_MISSING_ERROR_MSG);
        }
        try {
            Map<Integer,String> errorMessageMap = AUSF_INT_CodeMessageMapController.getTUEmailErrorMessages();
            Applicant__c applicant = [SELECT Id,Name,Is_Personal_Email_Id_Verified__c FROM Applicant__c WHERE Id =: applicantRecId limit 1];
            Integration_Checklist__c newChecklistInstance = new Integration_Checklist__c();
            newChecklistInstance.Integration_Master__c = objIntMapper.Id;
            newChecklistInstance.Applicant__c = applicant.Id;
            AUSF_INT_IntegrationUtility.InputWrapper inputData = new AUSF_INT_IntegrationUtility.InputWrapper();
            inputData.integrationChecklistRecord = newChecklistInstance;
            inputData.integrationMasterRecord = objIntMapper;
            inputData.applicantRecord = applicant;
            inputData.dynamicInputs = new Map<String, Object>();
            inputData.dynamicInputs.put('emailAddress', emailAddress);
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
            Boolean blnIsFaile = false;
            String strFailureReason = '';
            if (calloutResponseWrapper.statusCode != 200 ) {
                calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                upsert calloutResponseWrapper.checklistRecord;
                strIntMessage = 'Error With Service - ' + objIntMapper.Name + ' and record reference - '+AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id).Name;
                blnIsFaile = true;
                if (calloutResponseWrapper.errorMessage != NULL) {
                    String strErrMsg = calloutResponseWrapper.errorMessage +' - '+AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id).Name;
                    strFailureReason = calloutResponseWrapper.errorMessage +' - '+AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id).Name;
                } else{
                    strFailureReason = errorMessageMap.containsKey(calloutResponseWrapper.statusCode) ? errorMessageMap.get(calloutResponseWrapper.statusCode) : strIntMessage;
                }
            }
            else  {
                AUSF_EmailAuthenticationWrapper res = NULL;
                res = calloutResponseWrapper.response.startsWith('<html>') ? NULL : (AUSF_EmailAuthenticationWrapper)JSON.deserialize(calloutResponseWrapper.response,AUSF_EmailAuthenticationWrapper.class);
                String rawResponse;
                // Check res and its nested properties for null
                if (res != null &&
                    res.Fields != null &&
                    res.Fields.Applicants != null &&
                    res.Fields.Applicants.Applicant != null &&
                    res.Fields.Applicants.Applicant.Services != null &&
                    res.Fields.Applicants.Applicant.Services.Service != null &&
                    !res.Fields.Applicants.Applicant.Services.Service.isEmpty() &&
                    res.Fields.Applicants.Applicant.Services.Service[0].Operations != null &&
                    res.Fields.Applicants.Applicant.Services.Service[0].Operations.Operation != null &&
                    !res.Fields.Applicants.Applicant.Services.Service[0].Operations.Operation.isEmpty() &&
                    res.Fields.Applicants.Applicant.Services.Service[0].Operations.Operation[0].Data != null &&
                    res.Fields.Applicants.Applicant.Services.Service[0].Operations.Operation[0].Data.Response != null) {
                        // Assign rawResponse if all checks pass
                        rawResponse = res.Fields.Applicants.Applicant.Services.Service[0].Operations.Operation[0].Data.Response.RawResponse;
                    }
                    AUSF_EmailAuthenticationWrapper.RawResponseWrap resultStatus = NULL;
                    if (rawResponse != NULL && rawResponse != '') {
                        resultStatus = (AUSF_EmailAuthenticationWrapper.RawResponseWrap)JSON.deserialize(rawResponse,AUSF_EmailAuthenticationWrapper.RawResponseWrap.class);
                    }
                    if(resultStatus != NULL && resultStatus.email_validation != null && resultStatus.email_validation.status_code != null && resultStatus.email_validation.status_code == 50 && resultStatus.email_validation.status == AUSF_ApexConstants.AUSF_EMAILTU_STATUS){
                        calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED;
                        upsert calloutRequestWrapper.checklistRecord;
                        objResponse.responseWrapper = calloutResponseWrapper;
                        objResponse.blnIntegrationSuccess = true;
                        applicant.Is_Personal_Email_Id_Verified__c = true;
                        objResponse.Status = AUSF_ApexConstants.AUSF_EMAILTU_STATUS;
                        update applicant;
                    } else if (resultStatus == NULL || resultStatus.email_validation == null || resultStatus.email_validation.status_code != 50){
                        blnIsFaile = true;
                        calloutResponseWrapper.checklistRecord.Status__c = (resultStatus != NULL && resultStatus.email_validation != null && resultStatus.email_validation != null) ? AUSF_ApexConstants.AUSF_IC_COMPLETED : AUSF_ApexConstants.AUSF_IC_FAILED;
                        upsert calloutRequestWrapper.checklistRecord;
                        objResponse.responseWrapper = calloutResponseWrapper;
                        String strIntChecklistName = AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id).Name;
                        objResponse.strMessage = resultStatus != NULL && resultStatus.email_validation != null && resultStatus.email_validation.status_code != NULL && errorMessageMap.containsKey(resultStatus.email_validation.status_code) ? errorMessageMap.get(resultStatus.email_validation.status_code) : '';
                        objResponse.strMessage = (String.isBlank(objResponse.strMessage) ? 'Error with Service - '  + objIntMapper.Name + ' and record reference ' : objResponse.strMessage) + ' - ' + strIntChecklistName;
                        strFailureReason = objResponse.strMessage;                        
                        if (applicant.Is_Personal_Email_Id_Verified__c) {
                            applicant.Is_Personal_Email_Id_Verified__c = false;
                            update applicant;
                        }
                    }
                    if (blnIsFaile) {
                        throw new CustomException (strFailureReason);
                    }
                    objResponse.blnSuccess = true;
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