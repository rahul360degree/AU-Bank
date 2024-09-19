/**
* @author        Rahul Yadav
* @date          04-July-2024
* Class :        AUSF_PennyDropController
* Test Class     AUSF_PennyDropTest
* @description   
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Rahul Yadav           04-July-2024    Initial Version
*/
public without sharing class AUSF_PennyDropController {
    /*
    @description    : doAccountVerificationCallOut - Method to do callout to Account Verification services
    @param1         : loanId        - Loan object id
    @param2         : applicantId   - Applicant record id 
    @param3         : strIFSCCode        - store IFSC code
    @param4         : strAccNumber   - Applicant record id 
    @return         : Wrapper class contains return result
    */
    @AuraEnabled
    public static AUSF_PennyDropResponseWrapper doAccountVerificationCallOut(string loanId, string applicantId, String strIFSCCode, String strAccNumber) {
        AUSF_PennyDropResponseWrapper objResponse = new AUSF_PennyDropResponseWrapper();
        Integration_Master__c objIntMapper = AUSF_INT_IntegrationUtility.getIntegrationMasterRecord(AUSF_ApexConstants.AUSF_PENNY_DROP_INTEGRATION_MASTER);
        String strIntMessage = '';
        if (objIntMapper == NULL || objIntMapper.Id == NULL) {
            throw new CustomException(AUSF_ApexConstants.GENERIC_MASTER_MISSING_ERROR_MSG);
        }
        try {
            Applicant__c applicant = [SELECT Id,Name,Is_Personal_Email_Id_Verified__c FROM Applicant__c where Id =: applicantId limit 1];
            Integration_Checklist__c newChecklistInstance = new Integration_Checklist__c();
            newChecklistInstance.Integration_Master__c = objIntMapper.Id;
            newChecklistInstance.Applicant__c = applicant.Id;
            AUSF_INT_IntegrationUtility.InputWrapper inputData = new AUSF_INT_IntegrationUtility.InputWrapper();
            inputData.integrationChecklistRecord = newChecklistInstance;
            inputData.integrationMasterRecord = objIntMapper;
            inputData.applicantRecord = applicant;
            inputData.defaultData = new Map<String, string>();
            inputData.defaultData.put(AUSF_ApexConstants.AUSF_GENERIC_CONSENT, 'Y');
            inputData.defaultData.put(AUSF_ApexConstants.AUSF_EB_IFSC, strIFSCCode);
            inputData.defaultData.put(AUSF_ApexConstants.AUSF_PENNYDROP_ACCOUNTNUMBER, strAccNumber);
            inputData.defaultData.put(AUSF_ApexConstants.AUSF_GENERIC_REQID, AUSF_INT_IntegrationUtility.getReferenceId());
            inputData.defaultData.put(AUSF_ApexConstants.AUSF_GENERIC_CHANNEL, objIntMapper.Channel__c);
            AUSF_INT_IntegrationUtility utilityInstance = new AUSF_INT_IntegrationUtility();
            AUSF_INT_IntegrationRequestWrapper.HTTPRequestWrapper requestDetails = utilityInstance.constructRequest(inputData);
            if (String.isNotBlank(requestDetails.preRequisites)) {
                newChecklistInstance.Status__c = AUSF_ApexConstants.MISSING_PRE_REQUISITES;
                newChecklistInstance.Missing_Pre_requisites__c = requestDetails.preRequisites;
                upsert newChecklistInstance;
                String strErrMsg = requestDetails.preRequisites +' - '+AUSF_INT_IntegrationUtility.getIntegrationChecklist(newChecklistInstance.Id).Name;
                throw new CustomException(strErrMsg);
            }
            
            AUSF_INT_IntegrationResponseWrapper.ResponseWrapper calloutResponseWrapper = new AUSF_INT_IntegrationResponseWrapper.ResponseWrapper();
            AUSF_INT_IntegrationRequestWrapper.RequestWrapper calloutRequestWrapper = new AUSF_INT_IntegrationRequestWrapper.RequestWrapper();
            calloutRequestWrapper.request = requestDetails.request;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.urlParamsMap = inputData.defaultData;
            calloutRequestWrapper.checklistRecord = newChecklistInstance;
            calloutResponseWrapper = utilityInstance.initiateCallout(calloutRequestWrapper);
            AUSF_INT_IntegrationResponseWrapper.ResponseWrapper resp = calloutResponseWrapper;
            objResponse.responseWrapper = resp;
            if (calloutResponseWrapper.statusCode != 200 ) {
                calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                upsert calloutResponseWrapper.checklistRecord;
                String strErrMsg = AUSF_ApexConstants.GENERIC_INTEGRATION_FAILUR_MSG_INTERNAL+' - '+ AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id).Name;
                throw new CustomException(strErrMsg);
            }
            else  {
                map<string, object> responseMap = (map<string, object>) JSON.deserializeUntyped(calloutResponseWrapper.response);
                if (responseMap.containsKey('status-code') && String.valueOf(responseMap.get('status-code')) == AUSF_ApexConstants.AUSF_STATUS_CODE) {
                    calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED;
                    upsert calloutRequestWrapper.checklistRecord;
                    objResponse.blnIntegrationSuccess = true;
                    objResponse.responseWrapper = calloutResponseWrapper;
                } else if (responseMap.containsKey('status-code') && String.valueOf(responseMap.get('status-code')) != AUSF_ApexConstants.AUSF_STATUS_CODE){
                    calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED;
                    upsert calloutRequestWrapper.checklistRecord;
                    objResponse.strMessage = 'Error with Service - '  + objIntMapper.Name + ' and record reference - '+AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id).Name;
                    objResponse.responseWrapper = calloutResponseWrapper; 
                    throw new CustomException(objResponse.strMessage);
                }
                objResponse.blnSuccess = true;
            }
        }
        catch (Exception ex) {
            objResponse.strMessage = ex.getMessage();
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium,applicantId,'Applicant','Penny Drop');
        }
        return objResponse;
    }
    public class CustomException extends Exception {}
}