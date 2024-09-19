/**
* @author        Tejendra
* @date          29-July-2024
* @description   Fetch GST details Controller class
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Tejendra              29-July-2024    Initial Version - APL-150
*/
public without sharing class AUSF_GstPanController {
    
/*
@description    : fetchGST - Fetch GST details service method
@param1         : panNo - Applicant pan number
@param2         : applicantId - Applicant Record Id
@return         : Wrapper class contains return result
*/
@AuraEnabled
public static GstDetailsWrapper fetchGstDetails(String applicantId){
    GstDetailsWrapper objResponse = new GstDetailsWrapper();
    Applicant__c objApplicant;
    try{
        Map<String, String> paramValueMap = new Map<String, String>();
        for(Integration_Static_Param__mdt integrationStaticParamObj : [SELECT API_Name__c, Param_Name__c, Param_Value__c 
                                                                       FROM Integration_Static_Param__mdt 
                                                                       WHERE API_Name__c =: AUSF_ApexConstants.AUSF_GST_PAN]){
                                                                           paramValueMap.put(integrationStaticParamObj.Param_Name__c,integrationStaticParamObj.Param_Value__c);
                                                                       }
        objApplicant = [SELECT Id,PAN__c FROM Applicant__c where Id =: applicantId limit 1];
        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = objApplicant.Id);
        Integration_Master__c objIntMapper = AUSF_INT_IntegrationUtility.getIntegrationMasterRecord(AUSF_ApexConstants.AUSF_GST_PAN);
        Integration_Checklist__c newChecklistInstance = new Integration_Checklist__c();
        newChecklistInstance.Integration_Master__c = objIntMapper.Id;
        newChecklistInstance.Applicant__c = applicantId;
        newChecklistInstance.Request_Id__c =  AUSF_INT_IntegrationUtility.getReferenceId();
        AUSF_INT_IntegrationUtility.InputWrapper inputData = new AUSF_INT_IntegrationUtility.InputWrapper();
        inputData.integrationChecklistRecord = newChecklistInstance;
        inputData.integrationMasterRecord = objIntMapper;
        inputData.applicantRecord = objApplicant;
        inputData.dynamicInputs = createRequestDynamicInputData(objApplicant,paramValueMap,objIntMapper, newChecklistInstance.Request_Id__c);                
        AUSF_INT_IntegrationUtility utilityInstance = new AUSF_INT_IntegrationUtility();
        AUSF_INT_IntegrationRequestWrapper.HTTPRequestWrapper requestDetails = utilityInstance.constructRequest(inputData);
        // Check for Pre-Requisite Errors
        if (String.isNotBlank(requestDetails.preRequisites)) {
            newChecklistInstance.Status__c = AUSF_ApexConstants.MISSING_PRE_REQUISITES;
            newChecklistInstance.Missing_Pre_requisites__c = requestDetails.preRequisites;
            upsert newChecklistInstance;
            Integration_Checklist__c objChecklist = AUSF_INT_IntegrationUtility.getIntegrationChecklist(newChecklistInstance.Id);
            throw new CustomException(requestDetails.preRequisites+'-'+objChecklist.Name);
        }
        AUSF_INT_GstPanResponseWrapper objGstPanResponse = new AUSF_INT_GstPanResponseWrapper(); 
        AUSF_INT_IntegrationResponseWrapper.ResponseWrapper calloutResponseWrapper;
        AUSF_INT_IntegrationRequestWrapper.RequestWrapper calloutRequestWrapper = new AUSF_INT_IntegrationRequestWrapper.RequestWrapper();
        calloutRequestWrapper.request = requestDetails.request;
        calloutRequestWrapper.masterRecord = objIntMapper;
        calloutRequestWrapper.checklistRecord = newChecklistInstance;
        calloutRequestWrapper.entityId = objApplicant.Id;
        calloutResponseWrapper = utilityInstance.initiateCallout(calloutRequestWrapper);
        //Check for api hit limit restrictions for user
        if (calloutResponseWrapper.errorMessage!=null) {    
            objResponse.strIntMessage = calloutResponseWrapper.errorMessage;
            throw new CustomException (objResponse.strIntMessage);
        }
        // Check for HTTP Status Code
        if (calloutResponseWrapper.statusCode < 200 || calloutResponseWrapper.statusCode > 299 || calloutResponseWrapper.response == NULL || calloutResponseWrapper.response.startsWith('<html>')) {
            calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
            upsert calloutResponseWrapper.checklistRecord;
            Integration_Checklist__c objChecklist = AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id);
            objResponse.strIntMessage = 'Error With Service - ' + objIntMapper.Name + ' and record reference - '+objChecklist.Name;
            throw new CustomException(objResponse.strIntMessage);
        }else  {
            objGstPanResponse = (AUSF_INT_GstPanResponseWrapper)JSON.deserialize(calloutResponseWrapper.response,AUSF_INT_GstPanResponseWrapper.class);
            objGstPanResponse.responseWrapper = calloutResponseWrapper; 
            objResponse.gstPanResponseWrap = objGstPanResponse;
            //Check for api status code
            if(objGstPanResponse != NULL && objGstPanResponse.statusCode == 101){
                calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED;
                upsert calloutRequestWrapper.checklistRecord;
                objResponse.blnIntegrationSuccess = true;       
            }else{
                calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                upsert calloutResponseWrapper.checklistRecord;
                Integration_Checklist__c objChecklist = AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id);
                objResponse.strIntMessage = 'Error With Service - ' + objIntMapper.Name + ' and record reference - '+objChecklist.Name;
                throw new CustomException(objResponse.strIntMessage);
            }
        }
    objResponse.blnSuccess = true;
}
catch (Exception ex) {
    objResponse.strMessage = ex.getMessage();
    AUSF_Log.error(ex, AUSF_Log.SeverityType.High,objApplicant.Id,'Applicant',AUSF_ApexConstants.AUSF_GST_PAN);
}
return objResponse;
}
/*
@description    : createRequestDynamicInputData - Generate dynamic inputs data
@param1         : objApplicant - Applicant Record
@param2         : paramValueMap - map of static api parameters
@param3         : objIntMapper - Integration Master Record
@return         : Map of string
*/
public static Map<String,String> createRequestDynamicInputData(Applicant__c objApplicant, Map<String,String> paramValueMap,Integration_Master__c objIntMapper, String requestId){
    Map<String,String> dynamicInputs = new Map<String,String>();
    dynamicInputs.put('requestid', requestId);
    dynamicInputs.put('channel', objIntMapper.Channel__c);
    dynamicInputs.put('consent',paramValueMap.get('consent'));
    dynamicInputs.put('pan',objApplicant.PAN__c);
    return dynamicInputs; 
}
public class GstDetailsWrapper {
    @AuraEnabled
    public AUSF_INT_GstPanResponseWrapper gstPanResponseWrap {get;set;}
    @AuraEnabled
    public Boolean blnIntegrationSuccess = false;
    @AuraEnabled
    public Boolean blnSuccess = false;
    @AuraEnabled
    public String strMessage {get;set;}
    @AuraEnabled
    public String strIntMessage {get;set;}
}

public class CustomException extends Exception {}
}