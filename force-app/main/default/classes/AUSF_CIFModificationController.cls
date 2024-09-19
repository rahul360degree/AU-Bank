/**
* @author        Tejendra
* @date          22-July-2024
* @description   CIF Modification Controller class
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Tejendra              22-July-2024    Initial Version - APL-226
*/
public without sharing class AUSF_CIFModificationController {
    public AUSF_CIFModificationController() {
        
    }

/*
@description    : doCIFModification - Generate CIF Modification service method
@param1         : loanId - Loan Application Record Id
@param2         : applicantId - Applicant Record Id
@return         : Wrapper class contains return result
*/
@AuraEnabled
public static CifModificationWrapper doCIFModification(String loanId, String applicantId){
    CifModificationWrapper objResponse = new CifModificationWrapper();
    Applicant__c objApplicant;
    Loan_Application__c loanApplicationObj;
    try{
        Map<String, String> paramValueMap = new Map<String, String>();
        for(Integration_Static_Param__mdt integrationStaticParamObj : [SELECT API_Name__c, Param_Name__c, Param_Value__c 
                                                                       FROM Integration_Static_Param__mdt 
                                                                       WHERE API_Name__c =: AUSF_ApexConstants.AUSF_CIF_MODIFICATION_INTEGRATION_MASTER]){
                                                                           paramValueMap.put(integrationStaticParamObj.Param_Name__c,integrationStaticParamObj.Param_Value__c);
                                                                       }
        loanApplicationObj = [SELECT Id, Name, Lead_reference_number__c FROM Loan_Application__c WHERE Id =: loanId];     
        objApplicant = [SELECT Id, Full_Name__c,PAN__c,Mobile_Number__c,Personal_email_ID__c,CIF__c,First_Name__c, Middle_Name__c, Last_Name__c, AML_verified__c,Birth_Date__c,Nationality__c FROM Applicant__c where Id =: applicantId limit 1];
        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = objApplicant.Id);
        Integration_Master__c objIntMapper = AUSF_INT_IntegrationUtility.getIntegrationMasterRecord(AUSF_ApexConstants.AUSF_CIF_MODIFICATION_INTEGRATION_MASTER);
        String referenceId = AUSF_INT_IntegrationUtility.getReferenceId();
        Integration_Checklist__c newChecklistInstance = new Integration_Checklist__c();
        newChecklistInstance.Integration_Master__c = objIntMapper.Id;
        newChecklistInstance.Applicant__c = applicantId;
        //newChecklistInstance.Request_id__c = referenceId;
        AUSF_INT_IntegrationUtility.InputWrapper inputData = new AUSF_INT_IntegrationUtility.InputWrapper();
        inputData.integrationChecklistRecord = newChecklistInstance;
        inputData.integrationMasterRecord = objIntMapper;
        inputData.applicantRecord = objApplicant;
        inputData.dynamicInputs = createRequestDynamicInputData(loanApplicationObj,objApplicant,referenceId,paramValueMap);                
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
        AUSF_INT_CIFModificationResponseWrapper objCifModificationResponse = new AUSF_INT_CIFModificationResponseWrapper(); 
        AUSF_INT_IntegrationResponseWrapper.ResponseWrapper calloutResponseWrapper;
        AUSF_INT_IntegrationRequestWrapper.RequestWrapper calloutRequestWrapper = new AUSF_INT_IntegrationRequestWrapper.RequestWrapper();
        calloutRequestWrapper.request = requestDetails.request;
        calloutRequestWrapper.masterRecord = objIntMapper;
        calloutRequestWrapper.checklistRecord = newChecklistInstance;
        calloutRequestWrapper.entityId = objApplicant.Id;
        calloutResponseWrapper = utilityInstance.initiateCallout(calloutRequestWrapper);
        if (calloutResponseWrapper.errorMessage!=null) {    
            objResponse.strIntMessage = calloutResponseWrapper.errorMessage;
            throw new CustomException (objResponse.strIntMessage);
        }
        // Check for HTTP Status Code
        if (calloutResponseWrapper.statusCode < 200 || calloutResponseWrapper.statusCode > 299) {
            calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
            upsert calloutResponseWrapper.checklistRecord;
            Integration_Checklist__c objChecklist = AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id);
            objResponse.strIntMessage = 'Error With Service - ' + objIntMapper.Name + ' and record reference - '+objChecklist.Name;
            throw new CustomException(objResponse.strIntMessage);
        }else  {
            objCifModificationResponse = (AUSF_INT_CIFModificationResponseWrapper)JSON.deserialize(calloutResponseWrapper.response,AUSF_INT_CIFModificationResponseWrapper.class);
            objCifModificationResponse.responseWrapper = calloutResponseWrapper; 
            calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED;
            upsert calloutRequestWrapper.checklistRecord;
            objResponse.blnIntegrationSuccess = true;
        }
        objResponse.cifModificationWrap = objCifModificationResponse;
        // Check for Integration Failure to populate Integration Checklist Name
        if (!objResponse.blnIntegrationSuccess && calloutResponseWrapper.checklistRecord != NULL && calloutResponseWrapper.checklistRecord.Id != NULL) {
            Integration_Checklist__c objChecklist = AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id);
            objResponse.strIntMessage = String.isNotBlank(objResponse.strIntMessage) ? objResponse.strIntMessage  + objChecklist.Name : '';
            throw new CustomException(objResponse.strIntMessage);
        }
    
    objResponse.blnSuccess = true;
}
catch (Exception ex) {
    System.debug('ex.getMessage()='+ex.getMessage());
    System.debug('ex.getLineNumber()='+ex.getLineNumber());
    objResponse.strMessage = ex.getMessage();
    AUSF_Log.error(ex, AUSF_Log.SeverityType.High,objApplicant.Id,'Applicant',AUSF_ApexConstants.AUSF_AML_INTEGRATION_MASTER);
}
return objResponse;
}
/*
@description    : createRequestDynamicInputData - Generate dynamic inputs data
@param1         : loanApplicationObj - Loan Application Record
@param2         : objApplicant - Applicant Record
@return         : Wrapper class contains return result
*/
public static Map<String,String> createRequestDynamicInputData(Loan_Application__c loanApplicationObj, Applicant__c objApplicant, String referenceId, Map<String,String> paramValueMap){
    Map<String,String> dynamicInputs = new Map<String,String>();
    dynamicInputs.put('RequestId', AUSF_INT_IntegrationUtility.getReferenceId());
    dynamicInputs.put('Channel', 'SFDC');
    dynamicInputs.put('TransactionBranch','2216');
    dynamicInputs.put('ReferenceNumber',AUSF_INT_IntegrationUtility.getReferenceId());
    dynamicInputs.put('Zip','');
    dynamicInputs.put('State','');
    dynamicInputs.put('Country','');
    dynamicInputs.put('City','');
    dynamicInputs.put('Line1','');
    dynamicInputs.put('Line2','');
    dynamicInputs.put('Line3','');
    dynamicInputs.put('Line4', '');
    dynamicInputs.put('InoperativePan', '');
    dynamicInputs.put('MobileNumber','');
    dynamicInputs.put('CustomerId',String.valueOf(objApplicant.CIF__c));
    dynamicInputs.put('EmailId',String.valueOf(objApplicant.Personal_email_ID__c));
    dynamicInputs.put('PAN','');
    dynamicInputs.put('Activity','');
    dynamicInputs.put('BusinessProfiler','');
    dynamicInputs.put('CustCategory','');
    dynamicInputs.put('IncomeProfiler','');
    dynamicInputs.put('Industry','');
    dynamicInputs.put('Sector','');
    dynamicInputs.put('SubIndustry','');
    
    return dynamicInputs; 
}
public class CifModificationWrapper {
    @AuraEnabled
    public AUSF_INT_CIFModificationResponseWrapper cifModificationWrap {get;set;}
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