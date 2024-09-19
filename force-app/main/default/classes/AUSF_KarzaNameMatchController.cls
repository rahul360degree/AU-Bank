/**
* @author        Tejendra
* @date          25-June-2024
* @description   Karza Name Match Controller class
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Tejendra              25-June-2024    Initial Version
*/
public without sharing class AUSF_KarzaNameMatchController {

    /*
    @description    : nameMatch - Name Match service method
    @param1         : name1 - Applicant name 1
    @param2         : name2 - Applicant name 2
    @param3         : strApplicantId - Applicant Record Id
    @return         : Wrapper class contains return result
    */
    @AuraEnabled
    public static NameMatchWrapper nameMatch(String name1, String name2, String strApplicantId){
        NameMatchWrapper objResponse = new NameMatchWrapper();
        try{
        Map<String, String> paramValueMap = new Map<String, String>();
            for(Integration_Static_Param__mdt integrationStaticParamObj : [SELECT API_Name__c, Param_Name__c, Param_Value__c 
                                                                           FROM Integration_Static_Param__mdt 
                                                                           WHERE API_Name__c =: AUSF_ApexConstants.AUSF_KARZA_NAME_MATCH_INTEGRATION_MASTER]){
                paramValueMap.put(integrationStaticParamObj.Param_Name__c,integrationStaticParamObj.Param_Value__c);
            }    
        Applicant__c objApplicant = [SELECT Id, First_Name__c, Middle_Name__c, Last_Name__c, Name, RecordType.DeveloperName FROM Applicant__c where Id=:strApplicantId limit 1];
        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = strApplicantId);
        Integration_Master__c objIntMapper = AUSF_INT_IntegrationUtility.getIntegrationMasterRecord(AUSF_ApexConstants.AUSF_KARZA_NAME_MATCH_INTEGRATION_MASTER);
        Integration_Checklist__c newChecklistInstance = new Integration_Checklist__c();
            newChecklistInstance.Integration_Master__c = objIntMapper.Id;
            newChecklistInstance.Applicant__c = strApplicantId;

        AUSF_INT_IntegrationUtility.InputWrapper inputData = new AUSF_INT_IntegrationUtility.InputWrapper();
        inputData.integrationChecklistRecord = newChecklistInstance;
        inputData.integrationMasterRecord = objIntMapper;
        inputData.applicantRecord = objApplicant;
        inputData.dynamicInputs = new Map<String, Object>();
        inputData.dynamicInputs.put('channel',objIntMapper.Channel__c);
        inputData.dynamicInputs.put('type', paramValueMap.get('type'));
        inputData.dynamicInputs.put('preset', paramValueMap.get('preset'));
        inputData.dynamicInputs.put('name1', name1);
        if(inputData.dynamicInputs.get('name1')!=null && inputData.dynamicInputs.get('name1')!=''){
            inputData.dynamicInputs.put('name2',name2);
                        
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
            AUSF_NameMatchWrapper objNameMatchResponse = new AUSF_NameMatchWrapper();
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
                objNameMatchResponse.nameMatchResponse = (AUSF_NameMatchWrapper.NameMatchResponseWrapper)JSON.deserialize(calloutResponseWrapper.response,AUSF_NameMatchWrapper.NameMatchResponseWrapper.class);
                objNameMatchResponse.objIntResponse = calloutResponseWrapper;
                objResponse.nameMatchWrap = objNameMatchResponse;
                if(objNameMatchResponse.nameMatchResponse.result != NULL && (objNameMatchResponse.nameMatchResponse.result.score == NULL || objNameMatchResponse.nameMatchResponse.result.score == -1)){
                    calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                    upsert calloutRequestWrapper.checklistRecord;
                    Integration_Checklist__c objChecklist = AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id);
                    objResponse.strIntMessage = AUSF_ApexConstants.GENERIC_INTEGRATION_FAILUR_MSG_INTERNAL + ' - ' + objChecklist.Name;
                    throw new CustomException(objResponse.strIntMessage);
                }else if (objNameMatchResponse.nameMatchResponse.statusCode == 101) {         // Check for Service response code
                    calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED;
                    upsert calloutRequestWrapper.checklistRecord;
                    objResponse.blnIntegrationSuccess = true;
                }else if(objNameMatchResponse.nameMatchResponse.statusCode != 101){
                    if(String.isNotBlank(objNameMatchResponse.nameMatchResponse.statusMessage)){
                        objResponse.strIntMessage = objNameMatchResponse.nameMatchResponse.statusMessage;   
                    }else{
                        objResponse.strIntMessage = 'Error with Service - '  + objIntMapper.Name + ' and record reference';
                    }
                    calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                    upsert calloutRequestWrapper.checklistRecord;
                    Integration_Checklist__c objChecklist = AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id);
                    objResponse.strIntMessage = objResponse.strIntMessage + ' - ' + objChecklist.Name;
                    throw new CustomException(objResponse.strIntMessage);
                }                
            }
            objResponse.blnSuccess = true;
        }
   }
        catch (Exception ex) {
            objResponse.strMessage = ex.getMessage();
            AUSF_Log.error(ex, AUSF_Log.SeverityType.High,strApplicantId,'Applicant',AUSF_ApexConstants.AUSF_KARZA_NAME_MATCH_INTEGRATION_MASTER);
        }
        return objResponse;
    }

    public class NameMatchWrapper {
        @AuraEnabled
        public AUSF_NameMatchWrapper nameMatchWrap {get;set;}
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