/**
* @author        Rahul Yadav.
* @date          09-July-2024
* @description   
* Modification Log : System updates the PA Offer WHEN - Right before Case/Loan Application is disbursement THEN - System invokes PA Avail Offer API
* Test Class     AUSF_INT_PreApprovedTest
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Rahul Yadav.          09-July-2024    Initial Version
*/
public without sharing class AUSF_INT_PreApprovedController {
    /*
    @description    : doPreApprovedCallout - 
    @param1         : applicantId - Loan record
    @param2         : ItemId - Applicant record
    @return         : Wrapper class contains return result
    */
    @AuraEnabled
    public static AUSF_INT_PreApprovedResponseWrapper doPreApprovedCallout(string applicantId, string ItemId ){
        AUSF_INT_PreApprovedResponseWrapper objResponse = new AUSF_INT_PreApprovedResponseWrapper();
        String strIntMessage = '';
        Integration_Master__c objIntMapper = AUSF_INT_IntegrationUtility.getIntegrationMasterRecord(AUSF_ApexConstants.AUSF_PRE_APPROVED_INTEGRATION_MASTER);
        if (objIntMapper == NULL || objIntMapper.Id == NULL) {
            throw new CustomException(AUSF_ApexConstants.GENERIC_MASTER_MISSING_ERROR_MSG);
        }
        try {
            Applicant__c applicant = [SELECT Id FROM Applicant__c WHERE Id =: applicantId LIMIT 1];
            Integration_Checklist__c newChecklistInstance = new Integration_Checklist__c();
            newChecklistInstance.Integration_Master__c = objIntMapper.Id;
            newChecklistInstance.Applicant__c = applicant.Id;
            AUSF_INT_IntegrationUtility.InputWrapper inputData = new AUSF_INT_IntegrationUtility.InputWrapper();
            inputData.integrationChecklistRecord = newChecklistInstance;
            inputData.integrationMasterRecord = objIntMapper;
            inputData.applicantRecord = applicant;
            inputData.dynamicInputs = new Map<String, Object>();
            inputData.dynamicInputs.put(AUSF_ApexConstants.AUSF_PREAPPROVED_ITEMID, ItemId);
            inputData.dynamicInputs.put(AUSF_ApexConstants.AUSF_GENERIC_CHANNEL, objIntMapper.Channel__c);
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
                strIntMessage = 'Error With Service - ' + objIntMapper.Name + ' and record reference ';
                if (!String.isBlank(calloutResponseWrapper.errorMessage)) {
                    strIntMessage = calloutResponseWrapper.errorMessage;
                }
                strIntMessage = strIntMessage + ' - ' + AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id).Name; 
                throw new CustomException(strIntMessage);
            }
            else  {
                AUSF_INT_PreApprovedResponseWrapper res = (AUSF_INT_PreApprovedResponseWrapper)JSON.deserialize(calloutResponseWrapper.response,AUSF_INT_PreApprovedResponseWrapper.class);
                if(res.TransactionStatus.ResponseCode != null && res.TransactionStatus.ResponseCode == '0'){
                    calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED;
                    upsert calloutRequestWrapper.checklistRecord;
                    objResponse.responseWrapper = calloutResponseWrapper;
                    objResponse.blnIntegrationSuccess = true;
                } else if (res.TransactionStatus.ResponseCode != null && res.TransactionStatus.ResponseCode != '0'){
                    calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED;
                    calloutResponseWrapper.errorMessage = strIntMessage;
                    upsert calloutRequestWrapper.checklistRecord;
                    strIntMessage = 'Error with Service - '  + objIntMapper.Name + ' and record reference - '+AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id).Name;
                    objResponse.responseWrapper = calloutResponseWrapper; 
                    throw new CustomException(strIntMessage);
                }
                objResponse.blnSuccess = true;
            }
        } catch (Exception ex) {
            objResponse.strMessage = ex.getMessage();
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium,'','Applicant','Pre Approved - Avail Offer');
        }
        return objResponse;
    }
    public class CustomException extends Exception {}
}