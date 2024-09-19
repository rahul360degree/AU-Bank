/**
 * @author        Pradeep Sharma
 * Class :       AUSF_HunterAPIController
 * Test Class    AUSF_HunterAPITest
 * @date          5-July-2024
 * @description   controller for Hunter API
 * Modification Log:
--------------------------------------------------------------------------------------------
 * Developer             Date            Description
--------------------------------------------------------------------------------------------
 * Pradeep Sharma        5-July-2024    Initial Version
**/
public without sharing class AUSF_HunterAPIController {
    /*
    @description    : callHunterApi - generate Response
    @param1         : applicantId - Id of the applicant
    @return         : AUSF_INT_HunterAPIWrapper Wrapper contains return result
    */
    @AuraEnabled
    public static AUSF_INT_HunterAPIWrapper callHunterApi(String applicantId){
        AUSF_INT_HunterAPIWrapper objResponse = new AUSF_INT_HunterAPIWrapper();
        Integration_Master__c objIntMapper = AUSF_INT_IntegrationUtility.getIntegrationMasterRecord(AUSF_ApexConstants.AUSF_HUNTERAPI_INTEGRATION_MASTER);
        String respBody;
        String strIntMessage = '';
        Map<String,String> paramsValueMap = getParamsValue();
        if (objIntMapper == NULL || objIntMapper.Id == NULL) {
            throw new CustomException(AUSF_ApexConstants.GENERIC_MASTER_MISSING_ERROR_MSG);
        }
        try{
            Applicant__c applicant = [SELECT Id,Name,Full_Name__c,Mobile_Number__c,Loan_application__r.Name,(SELECT Id,Address_Type__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,City__c,State__c,Pincode__c FROM Addresses__r),Personal_Email_Id__c,CIF__c,PAN__c,Educational_Qualification__c,First_Name__c,Last_Name__c,Age__c,Birth_Date__c,Gender__c,Marital_Status__c, RecordType.DeveloperName FROM Applicant__c where Id=:applicantId limit 1];
            Integration_Checklist__c newChecklistInstance = new Integration_Checklist__c();
            newChecklistInstance.Integration_Master__c = objIntMapper.Id;
            newChecklistInstance.Applicant__c = applicantId;
            AUSF_INT_IntegrationUtility.InputWrapper inputData = new AUSF_INT_IntegrationUtility.InputWrapper();
            inputData.integrationChecklistRecord = newChecklistInstance;
            inputData.integrationMasterRecord = objIntMapper;
            inputData.applicantRecord = applicant;
            inputData.dynamicInputs = new Map<String, Object>();
            inputData.dynamicInputs.put('TransactionBranch', paramsValueMap.get('TransactionBranch'));
            inputData.dynamicInputs.put('CustomerId', paramsValueMap.get('CustomerId'));
            inputData.dynamicInputs.put('CustomerName', paramsValueMap.get('CustomerName'));
            inputData.dynamicInputs.put('SubmissionLoad', paramsValueMap.get('SubmissionLoad'));
            inputData.dynamicInputs.put('SuppressVersion', paramsValueMap.get('SuppressVersion'));
            inputData.dynamicInputs.put('PersistMatches', paramsValueMap.get('PersistMatches'));
            inputData.dynamicInputs.put('WorklistInsert', paramsValueMap.get('WorklistInsert'));
            inputData.dynamicInputs.put('ResultCode', paramsValueMap.get('ResultCode'));
            inputData.dynamicInputs.put('SchemeSetID', paramsValueMap.get('SchemeSetID'));
            inputData.dynamicInputs.put('ScoreType', paramsValueMap.get('ScoreType'));
            inputData.dynamicInputs.put('ResultType', paramsValueMap.get('ResultType'));
            inputData.dynamicInputs.put('Count', paramsValueMap.get('Count'));
            inputData.dynamicInputs.put('Originator', paramsValueMap.get('Originator'));
            inputData.dynamicInputs.put('ProductCode', paramsValueMap.get('ProductCode'));
            inputData.dynamicInputs.put('Classification', paramsValueMap.get('Classification'));
            inputData.dynamicInputs.put('LoanPurpose', paramsValueMap.get('LoanPurpose'));
            inputData.dynamicInputs.put('DocumentType', paramsValueMap.get('DocumentType'));
            inputData.dynamicInputs.put('Username', paramsValueMap.get('Username'));
            inputData.dynamicInputs.put('Password', paramsValueMap.get('Password'));
            inputData.dynamicInputs.put('channel', objIntMapper.Channel__c);
            if(!applicant.addresses__r.isEmpty()){
                for(Address__c addr:applicant.addresses__r){
                    if(addr.Address_Type__c == 'Permanent'){
                        inputData.dynamicInputs.put('PA_AddressLines',addr.Address_Line_1__c+','+addr.Address_Line_2__c+','+addr.Address_Line_3__c);
                        inputData.dynamicInputs.put('PA_City',addr.City__c);
                        inputData.dynamicInputs.put('PA_State',addr.State__c);
                        inputData.dynamicInputs.put('Country',paramsValueMap.get('Country'));
                        inputData.dynamicInputs.put('PA_Pincode',addr.Pincode__c);
                    }
                    if(addr.Address_Type__c == 'Current'){
                        inputData.dynamicInputs.put('RA_AddressLines',addr.Address_Line_1__c+','+addr.Address_Line_2__c+','+addr.Address_Line_3__c);
                        inputData.dynamicInputs.put('RA_City',addr.City__c);
                        inputData.dynamicInputs.put('RA_State',addr.State__c);
                        inputData.dynamicInputs.put('Country',paramsValueMap.get('Country'));
                        inputData.dynamicInputs.put('RA_Pincode',addr.Pincode__c);
                    }
                    
                }
            }
            AUSF_INT_IntegrationUtility utilityInstance = new AUSF_INT_IntegrationUtility();
            AUSF_INT_IntegrationRequestWrapper.HTTPRequestWrapper requestDetails = utilityInstance.constructRequest(inputData);
            if (String.isNotBlank(requestDetails.preRequisites)) {
                newChecklistInstance.Status__c = AUSF_ApexConstants.MISSING_PRE_REQUISITES;
                newChecklistInstance.Missing_Pre_requisites__c = requestDetails.preRequisites;
                upsert newChecklistInstance;
                throw new CustomException(requestDetails.preRequisites);
            }
            AUSF_INT_IntegrationResponseWrapper.ResponseWrapper calloutResponseWrapper;
            AUSF_INT_IntegrationRequestWrapper.RequestWrapper calloutRequestWrapper = new AUSF_INT_IntegrationRequestWrapper.RequestWrapper();
            calloutRequestWrapper.request = requestDetails.request;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = newChecklistInstance;
            calloutRequestWrapper.entityId = applicantId;
            calloutResponseWrapper = utilityInstance.initiateCallout(calloutRequestWrapper);
            objResponse.responseWrapper = calloutResponseWrapper;
            if (calloutResponseWrapper.errorMessage!=null) {
                throw new CustomException(calloutResponseWrapper.errorMessage);
            }
            if (calloutResponseWrapper.statusCode < 200 || calloutResponseWrapper.statusCode > 299) {
                calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                upsert calloutResponseWrapper.checklistRecord;
                strIntMessage = 'Error With Service - ' + objIntMapper.Name + ' and record reference - ';
                calloutResponseWrapper.errorMessage = strIntMessage;
            }
            else  {
                Map<String,String> replacements = new Map<String,String>{'Number'=>'NumberTemp','@totalRuleCount'=>'totalRuleCount','@matches'=>'matches'};
                String mogrifiedJSON = AUSF_INT_IntegrationUtility.mogrifyJSON(calloutResponseWrapper.response,replacements);
                calloutResponseWrapper.response = mogrifiedJSON;
                AUSF_HunterAPIResponseWrapper res = (AUSF_HunterAPIResponseWrapper)JSON.deserialize(calloutResponseWrapper.response,AUSF_HunterAPIResponseWrapper.class);
                if(res!=null && res.TransactionStatus!=null && res.TransactionStatus.ResponseCode!=null){
                    if (res.TransactionStatus.ResponseCode == '0') {
                        calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED;
                        if(res.MatchSummary.matches == '1'){
                            applicant.Hunter_Status__c = AUSF_ApexConstants.AUSF_HUNTERAPI_STATUS_MATCH_FOUND;
                        }
                        else if(res.MatchSummary.matches == '0'){
                            applicant.Hunter_Status__c = AUSF_ApexConstants.AUSF_HUNTERAPI_STATUS_MATCH_NOT_FOUND;
                        }
                        else{
                            applicant.Hunter_Status__c = AUSF_ApexConstants.AUSF_HUNTERAPI_STATUS_HOLD;
                        }
                        update applicant;
                        objResponse.hunterStatus = applicant.Hunter_Status__c;
                        objResponse.blnIntegrationSuccess = true;
                    }
                    else {
                        calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                        strIntMessage = 'Error with Service - '  + objIntMapper.Name + ' and record reference - ';
                        calloutResponseWrapper.errorMessage = strIntMessage;
                    }
                }
                upsert calloutResponseWrapper.checklistRecord;
            }
            objResponse.responseWrapper = calloutResponseWrapper;
            if (!objResponse.blnIntegrationSuccess && calloutResponseWrapper.checklistRecord != NULL && calloutResponseWrapper.checklistRecord.Id != NULL) {
                Integration_Checklist__c objChecklist = AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id);
                objResponse.strMessage = String.isNotBlank(strIntMessage) ? strIntMessage  + objChecklist.Name : '';
                throw new CustomException(objResponse.strMessage);
            }
            objResponse.blnSuccess = true;
        }
        catch (Exception ex) {
            objResponse.strMessage = ex.getMessage();
            System.debug(LoggingLevel.Error,'Exception in class ' + ex.getLineNumber()+ ''+ex.getCause());
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium,applicantId,'Applicant',AUSF_ApexConstants.AUSF_HUNTERAPI_INTEGRATION_MASTER);
        }
        return objResponse;
    }

    public static Map<String,String> getParamsValue(){
        Map<String,String> paramsValueMap = new Map<String,String>();
        for(Integration_Static_Param__mdt integrationStaticParamObj : [SELECT API_Name__c, Param_Name__c, Param_Value__c
                                                                           FROM Integration_Static_Param__mdt
                                                                           WHERE API_Name__c = :AUSF_ApexConstants.AUSF_HUNTERAPI_INTEGRATION_MASTER]){
            paramsValueMap.put(integrationStaticParamObj.Param_Name__c,integrationStaticParamObj.Param_Value__c);
        }
        return paramsValueMap;
    }
    
    
    public class CustomException extends Exception {}
}