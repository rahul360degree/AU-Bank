/**
* @author        Tejendra
* @date          28-June-2024
* @description   Aml Controller class
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Tejendra              28-June-2024    Initial Version
Mohit M.              05-Aug-2024     add AML_Action to strAMLStatus to check on UI
*/
public without sharing class AUSF_AMLController {
    /*
    @description    : doAML - Generate AML action service method
    @param1         : loanId - Loan Application Record Id
    @param2         : applicantId - Applicant Record Id
    @return         : Wrapper class contains return result
    */
    @AuraEnabled
    public static AMLWrapper doAML(String loanId, String applicantId){
        AMLWrapper objResponse = new AMLWrapper();
        Applicant__c objApplicant;
        Loan_Application__c loanApplicationObj;
        try{
            Map<String, String> paramValueMap = new Map<String, String>();
            for(Integration_Static_Param__mdt integrationStaticParamObj : [SELECT API_Name__c, Param_Name__c, Param_Value__c 
                                                                           FROM Integration_Static_Param__mdt 
                                                                           WHERE API_Name__c =: AUSF_ApexConstants.AUSF_AML_INTEGRATION_MASTER]){
                                                                               paramValueMap.put(integrationStaticParamObj.Param_Name__c,integrationStaticParamObj.Param_Value__c);
                                                                           }
            loanApplicationObj = [SELECT Id, Name, Lead_reference_number__c FROM Loan_Application__c WHERE Id =: loanId];     
            objApplicant = [SELECT Id, Full_Name__c,PAN__c,Mobile_Number__c,Personal_email_ID__c, First_Name__c, Middle_Name__c, Last_Name__c, AML_verified__c,Birth_Date__c,Nationality__c FROM Applicant__c where Id =: applicantId limit 1];
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = objApplicant.Id);
            Integration_Master__c objIntMapper = AUSF_INT_IntegrationUtility.getIntegrationMasterRecord(AUSF_ApexConstants.AUSF_AML_INTEGRATION_MASTER);
            String referenceId = AUSF_INT_IntegrationUtility.getReferenceId();
            Integration_Checklist__c newChecklistInstance = new Integration_Checklist__c();
            newChecklistInstance.Integration_Master__c = objIntMapper.Id;
            newChecklistInstance.Applicant__c = applicantId;
            newChecklistInstance.Request_id__c = referenceId;
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
            AUSF_INT_DOAMLResponseWrapper objAmlResponse = new AUSF_INT_DOAMLResponseWrapper(); 
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
            }
            else  {
                objAmlResponse = (AUSF_INT_DOAMLResponseWrapper)JSON.deserialize(calloutResponseWrapper.response,AUSF_INT_DOAMLResponseWrapper.class);
                objAmlResponse.responseWrapper = calloutResponseWrapper;
                // Check for Service response status
                if (objAmlResponse.status != NULL && objAmlResponse.status.status ==  'success') {
                    calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED;
                    upsert calloutRequestWrapper.checklistRecord;
                    objResponse.blnIntegrationSuccess = true;
                }
                else {
                    calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                    upsert calloutResponseWrapper.checklistRecord;
                    objResponse.strIntMessage = 'Error with Service - '  + objIntMapper.Name + ' and record reference - ';
                } 
            }
            objResponse.amlWrap = objAmlResponse;
            // Check for Integration Failure to populate Integration Checklist Name
            if (!objResponse.blnIntegrationSuccess && calloutResponseWrapper.checklistRecord != NULL && calloutResponseWrapper.checklistRecord.Id != NULL) {
                Integration_Checklist__c objChecklist = AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id);
                objResponse.strIntMessage = String.isNotBlank(objResponse.strIntMessage) ? objResponse.strIntMessage  + objChecklist.Name : '';
                throw new CustomException(objResponse.strIntMessage);
            }
            
            //Check for AML Action returned from service
            if(String.isNotBlank(objAmlResponse.MATCH) && objAmlResponse.MATCH == AUSF_ApexConstants.AUSF_AML_MATCH_NO){
                objApplicant.AML_verified__c = AUSF_ApexConstants.AUSF_AML_MATCH_NO;
                objResponse.strAMLStatus = AUSF_ApexConstants.AUSF_AML_ACTION_APPROVED;
            }else if(String.isNotBlank(objAmlResponse.MATCH) && objAmlResponse.MATCH == AUSF_ApexConstants.AUSF_AML_MATCH_YES) {
                objResponse.strAMLStatus = objAmlResponse.AML_ACTION;
                objApplicant.AML_verified__c = AUSF_ApexConstants.AUSF_AML_VERIFIED_HOLD;
                objResponse.strAMLStatus =  AUSF_ApexConstants.AUSF_AML_VERIFIED_HOLD;
            }
            objResponse.strAMLStatus = String.isNotBlank(objResponse.strAMLStatus) ? objResponse.strAMLStatus : objAmlResponse.AML_ACTION;
            if(String.isNotBlank(objAmlResponse.AML_ACTION)){ 
                update objApplicant;
            }
            objResponse.blnSuccess = true;
        }
        catch (Exception ex) {
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
        String dob;
        String nationality;
        if(String.isNotBlank(objApplicant.Nationality__c) && objApplicant.Nationality__c == 'IN'){
            nationality = 'India';
        }else{
            nationality = 'NIL';
        }
        if(objApplicant.Birth_Date__c != NULL){
            DateTime dateOfBirth = Date.valueOf(objApplicant.Birth_Date__c);
            dob = dateOfBirth.format('dd-MM-yyyy','Asia/Kolkata'); 
        }else{
            dob = 'NIL';  
        }
        Map<String,String> dynamicInputs = new Map<String,String>();
        dynamicInputs.put('batch_mode', paramValueMap.get('batch_mode'));
        dynamicInputs.put('callbackurl', paramValueMap.get('callbackurl'));
        dynamicInputs.put('name',String.isNotBlank(objApplicant.Full_Name__c)?objApplicant.Full_Name__c:'NIL');
        dynamicInputs.put('pan',String.isNotBlank(objApplicant.PAN__c)?objApplicant.PAN__c:'NIL');
        dynamicInputs.put('mobile',String.isNotBlank(objApplicant.Mobile_Number__c)?objApplicant.Mobile_Number__c:'NIL');
        dynamicInputs.put('email',String.isNotBlank(objApplicant.Personal_email_ID__c)?objApplicant.Personal_email_ID__c:'NIL');
        dynamicInputs.put('dob',dob);
        dynamicInputs.put('nationality',nationality);
        dynamicInputs.put('country','India');
        dynamicInputs.put('referenceid',referenceId);
        dynamicInputs.put('refid',loanApplicationObj.Lead_reference_number__c);
        dynamicInputs.put('systemname', paramValueMap.get('systemname'));
        dynamicInputs.put('userid', paramValueMap.get('userid'));
        return dynamicInputs; 
    }
    public class AMLWrapper {
        @AuraEnabled
        public AUSF_INT_DOAMLResponseWrapper amlWrap {get;set;}
        @AuraEnabled
        public Boolean blnIntegrationSuccess = false;
        @AuraEnabled
        public Boolean blnSuccess = false;
        @AuraEnabled
        public String strMessage {get;set;}
        @AuraEnabled
        public String strIntMessage {get;set;}
        @AuraEnabled
        public String strAMLStatus {get;set;}
    }
    
    public class CustomException extends Exception {}
}