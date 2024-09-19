/**
* @author        Rahul Yadav
* @date          29-June-2024
* Class :		 AUSF_INT_ElectricityBillController
* Test Class	 AUSF_INT_ElectricityBillTest
* @description   AUSF_INT_ElectricityBillHandler - use to generate request and validate the prerequisites
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Rahul Yadav           29-June-2024    Initial Version
*/
public  without sharing class AUSF_INT_ElectricityBillController {
    /*
    @description    : doElectricityBillCallOut - Electricity Bill Authentication
    @param1         : loanId        - Loan object id
    @param2         : applicantId   - Applicant record id 
    @param3         : consumer_id    - Comsumer id to send in request
    @param4         : service_provider      - service provider
    @return         : Wrapper class contains return result
    */
    @AuraEnabled
    public static AUSF_INT_ElectricityBillResponseWrapper doElectricityBillCallOut(string loanId, string applicantId, String consumer_id, String service_provider) {
        AUSF_INT_ElectricityBillResponseWrapper objResponse = new AUSF_INT_ElectricityBillResponseWrapper();
        String strIntMessage = '';
        Integration_Master__c objIntMapper = AUSF_INT_IntegrationUtility.getIntegrationMasterRecord(AUSF_ApexConstants.AUSF_ELECTRICITY_INTEGRATION_MASTER);
        if (objIntMapper == NULL || objIntMapper.Id == NULL) {
            throw new CustomException(AUSF_ApexConstants.GENERIC_MASTER_MISSING_ERROR_MSG);
        }
        try {
            Applicant__c applicant = [SELECT Id,Name,Is_Personal_Email_Id_Verified__c FROM Applicant__c WHERE Id =: applicantId limit 1];
            Integration_Checklist__c newChecklistInstance = new Integration_Checklist__c();
            newChecklistInstance.Integration_Master__c = objIntMapper.Id;
            newChecklistInstance.Applicant__c = applicant.Id;
            AUSF_INT_IntegrationUtility.InputWrapper inputData = new AUSF_INT_IntegrationUtility.InputWrapper();
            inputData.integrationChecklistRecord = newChecklistInstance;
            inputData.integrationMasterRecord = objIntMapper;
            inputData.applicantRecord = applicant;
            inputData.defaultData = new Map<String, string>();
            inputData.defaultData.put(AUSF_ApexConstants.AUSF_GENERIC_CONSENT, 'Y');
            inputData.defaultData.put(AUSF_ApexConstants.AUSF_EB_SERVICE_PROVIDER, service_provider);
            inputData.defaultData.put(AUSF_ApexConstants.AUSF_EB_CONSUMERID, consumer_id);
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
                strIntMessage = 'Error With Service - ' + objIntMapper.Name + ' and record reference ';
                if (!String.isBlank(calloutResponseWrapper.errorMessage)) {
                    strIntMessage = calloutResponseWrapper.errorMessage;
                }
                strIntMessage = strIntMessage + ' - ' + AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id).Name; 
                throw new CustomException(strIntMessage);
            }
            else  {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(calloutResponseWrapper.response);
                if (responseMap.containsKey('status-code') && String.valueOf(responseMap.get('status-code')) == AUSF_ApexConstants.AUSF_STATUS_CODE) {
                    calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED;
                    upsert calloutRequestWrapper.checklistRecord;
                    objResponse.blnIntegrationSuccess = true;
                    objResponse.responseWrapper = calloutResponseWrapper;
                    AUSF_INT_ElectricityBillResponseWrapper parseForResult = (AUSF_INT_ElectricityBillResponseWrapper) JSON.deserialize(calloutResponseWrapper.response,AUSF_INT_ElectricityBillResponseWrapper.class);
                    objResponse.result = parseForResult.result;
                } else if (responseMap.containsKey('status-code') && String.valueOf(responseMap.get('status-code')) != AUSF_ApexConstants.AUSF_STATUS_CODE){
                    calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                    upsert calloutRequestWrapper.checklistRecord;
                    strIntMessage = 'Error with Service - '  + objIntMapper.Name + ' and record reference - '+AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id).Name;
                    objResponse.responseWrapper = calloutResponseWrapper;
                    throw new CustomException(strIntMessage); 
                }
            }
            objResponse.blnSuccess = true;
        }
        catch (Exception ex) {
            objResponse.strMessage = ex.getMessage();
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium,applicantId,'Applicant','Electricity-Bill');
        }
        return objResponse;
    }
    public class CustomException extends Exception {}
}