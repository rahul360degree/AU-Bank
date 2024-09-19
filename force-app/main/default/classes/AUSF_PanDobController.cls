/**
 * @author        Pradeep Sharma
 * Class :		 AUSF_PanDobController
 * Test Class	 AUSF_PanDobTest
 * @date          21-June-2024
 * @description   Pan Dob API to get Dob and full name of the custommer by taking pannumber as input
 * Modification Log:
--------------------------------------------------------------------------------------------
    Developer             Date            Description
    --------------------------------------------------------------------------------------------
    Pradeep Sharma        21-June-2024    Initial Version
     */
public without sharing class AUSF_PanDobController {
    /*
    @description    : getPANDOB - generate Response and update dob and full name
    @param1         : applicantId - Id of the applicant
    @param2         : panNo - pan number of the applicant
    @return         : Wrapper class contains return result
    */
    @AuraEnabled
    public static AUSF_INT_getPANDOBResponseWrapper getPANDOB(String applicantId, String panNo){
        AUSF_INT_getPANDOBResponseWrapper objResponse = new AUSF_INT_getPANDOBResponseWrapper();
        Integration_Master__c objIntMapper = AUSF_INT_IntegrationUtility.getIntegrationMasterRecord(AUSF_ApexConstants.AUSF_PANDOB_INTEGRATION_MASTER);
        String respBody;
        String strIntMessage = '';
        if (objIntMapper == NULL || objIntMapper.Id == NULL) {
            throw new CustomException(AUSF_ApexConstants.GENERIC_MASTER_MISSING_ERROR_MSG);
        }
        try {
            Map<Integer,String> errorMessageMap = getErrorMessageMap();
            Applicant__c applicant = [SELECT Id,Name,Mobile_Number__c,Birth_Date__c,Full_Name__c, RecordType.DeveloperName FROM Applicant__c where Id=:applicantId limit 1];
            Integration_Checklist__c newChecklistInstance = new Integration_Checklist__c();
            newChecklistInstance.Integration_Master__c = objIntMapper.Id;
            newChecklistInstance.Applicant__c = applicant.Id;
            AUSF_INT_IntegrationUtility.InputWrapper inputData = new AUSF_INT_IntegrationUtility.InputWrapper();
            inputData.integrationChecklistRecord = newChecklistInstance;
            inputData.integrationMasterRecord = objIntMapper;
            inputData.applicantRecord = applicant;
            inputData.dynamicInputs = new Map<String, Object>();
            inputData.dynamicInputs.put('panNumber', panNo);
            inputData.dynamicInputs.put('consent', 'Y');
            inputData.dynamicInputs.put('channel', objIntMapper.Channel__c);
            AUSF_INT_IntegrationUtility utilityInstance = new AUSF_INT_IntegrationUtility();
            AUSF_INT_IntegrationRequestWrapper.HTTPRequestWrapper requestDetails = utilityInstance.constructRequest(inputData);
            // Check for Pre-Requisite Errors
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
            calloutRequestWrapper.entityId = applicant.Id;
            calloutResponseWrapper = utilityInstance.initiateCallout(calloutRequestWrapper);
            AUSF_INT_IntegrationResponseWrapper.ResponseWrapper resp = calloutResponseWrapper;
            // Check for HTTP Status Code
            if (calloutResponseWrapper.statusCode != 200) {
                calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                upsert calloutResponseWrapper.checklistRecord;
                if (calloutResponseWrapper.errorMessage != NULL) {
                    strIntMessage = 'Error with Service - '  + objIntMapper.Name +' '+calloutResponseWrapper.errorMessage+' and record reference - ';
                }
                else {
                    strIntMessage = 'Error with Service - '  + objIntMapper.Name + ' '+errorMessageMap.get(calloutResponseWrapper.statusCode)+ ' and record reference - ';
                }
                objResponse.blnIntegrationSuccess = false;
                objResponse.responseWrapper = calloutResponseWrapper;
            }
            else  {
                AUSF_INT_IntegrationResponseWrapper.ResponseWrapper intResponse = new AUSF_INT_IntegrationResponseWrapper.ResponseWrapper();
                AUSF_PanDobResponseWrapper res = (AUSF_PanDobResponseWrapper)JSON.deserialize(calloutResponseWrapper.response,AUSF_PanDobResponseWrapper.class);
                if (res != NULL && res.statusCode == 101 && String.isNotBlank(res.Result.name) && String.isNotBlank(res.Result.dob)) {
                    calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED;
                    objResponse.responseWrapper = calloutResponseWrapper;
                    objResponse.status = res.Result.status;
                    objResponse.Name = res.Result.name;
                    objResponse.DOB = String.isNotBlank(res.Result.dob)?Date.valueOf(res.Result.dob):NULL;
                    objResponse.statusCode = res.statusCode != NULL ? String.valueOf(res.statusCode):NULL;
                    objResponse.blnIntegrationSuccess = true;
                    applicant.Full_Name__c = res.Result.name;
                    applicant.Birth_Date__c = String.isNotBlank(res.Result.dob)?Date.valueOf(res.Result.dob):NULL;
                    objResponse.responseWrapper = calloutResponseWrapper;
                    update applicant;
                }
                else {
                    calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                    strIntMessage = 'Error with Service - '  + objIntMapper.Name + ' and record reference - ';
                    calloutResponseWrapper.errorMessage = strIntMessage;
                    objResponse.statusCode = String.valueOf(res.statusCode);
                    objResponse.blnIntegrationSuccess = false;
                    objResponse.responseWrapper = calloutResponseWrapper;
                }
                objResponse.responseWrapper = calloutResponseWrapper;
                upsert calloutResponseWrapper.checklistRecord;
            }
            // Check for Integration Failure to populate Integration Checklist Name
            if (!objResponse.blnIntegrationSuccess && calloutResponseWrapper.checklistRecord != NULL && calloutResponseWrapper.checklistRecord.Id != NULL) {
                Integration_Checklist__c objChecklist = AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id);
                objResponse.strMessage = String.isNotBlank(strIntMessage) ? strIntMessage  + objChecklist.Name : '';
                throw new CustomException (objResponse.strMessage);
            }
            objResponse.blnSuccess = true;
            
        }
        catch (Exception ex) {
            objResponse.strMessage = ex.getMessage();
            System.debug(LoggingLevel.Error,'Exception in class ' + ex);
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium,applicantId,'Applicant','pan-dob');
        }
        return objResponse;
    }
    public static Map<Integer,String> getErrorMessageMap(){
        
        Map<Integer,String> errorMessageMap = new Map<Integer,String>();
        errorMessageMap.put(102,'Invalid ID number or combination of inputs');
        errorMessageMap.put(103,'No records found for the given ID or combination of inputs');
        errorMessageMap.put(104,'Max retries exceeded');
        errorMessageMap.put(105,'Missing Consent');
        errorMessageMap.put(106,'Multiple Records Exist');
        errorMessageMap.put(107,'Not Supported');
        errorMessageMap.put(108,'Internal Resource Unavailable');
        errorMessageMap.put(109,'Too many records Found');
        errorMessageMap.put(400,'Bad Request');
        errorMessageMap.put(401,'Unauthorized Access');
        errorMessageMap.put(402,'Insufficient Credits');
        errorMessageMap.put(500,'Internal Server Error');
        errorMessageMap.put(503,'Source Unavailable');
        errorMessageMap.put(504,'Endpoint Request Timed Out');
        return errorMessageMap;
    }
    
    public class CustomException extends Exception {}
}