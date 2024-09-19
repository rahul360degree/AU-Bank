/**
* @author       Ankit Bansal
* Class :		 AUSF_ICWAI_APIController
* Test Class	 AUSF_ICWAI_ApiTest
* @date         05-Aug-2024
* @description
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Ankit Bansal        05-Aug-2024    Initial Version
*/
public without sharing class AUSF_ICWAI_APIController {
    /*
@description    : getICWAIDetails - generate Response and Employment details
@param1         : applicantId - Id of the applicant
@param2         : membershipNo - membershipNo to be passed from api
@param3         : employmentDetailId
@return         : Wrapper class contains return result
*/
    @AuraEnabled
    public static AUSF_INT_ICWAI_APIWrapper getICWAIDetails(String applicantId,String membershipNo,String employmentDetailId){
        AUSF_INT_ICWAI_APIWrapper objResponse = new AUSF_INT_ICWAI_APIWrapper();
        Integration_Master__c objIntMapper = AUSF_INT_IntegrationUtility.getIntegrationMasterRecord(AUSF_ApexConstants.AUSF_ICWAI_API);
        String strIntMessage = '';
        if (objIntMapper == NULL || objIntMapper.Id == NULL) {
            throw new CustomException(AUSF_ApexConstants.GENERIC_MASTER_MISSING_ERROR_MSG);
        }
        try {
            Applicant__c applicant = [SELECT Id,Name,Mobile_Number__c,Birth_Date__c,Full_Name__c, RecordType.DeveloperName FROM Applicant__c where Id=:applicantId limit 1];
            Integration_Checklist__c newChecklistInstance = new Integration_Checklist__c();
            newChecklistInstance.Integration_Master__c = objIntMapper.Id;
            newChecklistInstance.Applicant__c = applicant.Id;
            newChecklistInstance.Request_Id__c = AUSF_INT_IntegrationUtility.getReferenceId();
            AUSF_INT_IntegrationUtility.InputWrapper inputData = new AUSF_INT_IntegrationUtility.InputWrapper();
            inputData.integrationChecklistRecord = newChecklistInstance;
            inputData.integrationMasterRecord = objIntMapper;
            inputData.applicantRecord = applicant;
            inputData.dynamicInputs = new Map<String, Object>();
            inputData.dynamicInputs.put('membershipNo', membershipNo);
            inputData.dynamicInputs.put('Consent', 'Y');
            inputData.dynamicInputs.put('channel', objIntMapper.Channel__c);
            inputData.dynamicInputs.put('ContactDetails',true);
            inputData.dynamicInputs.put('SFRequestId',newChecklistInstance.Request_Id__c);
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
            AUSF_INT_IntegrationResponseWrapper.ResponseWrapper response = calloutResponseWrapper;

            if (calloutResponseWrapper.statusCode < 200 || calloutResponseWrapper.statusCode > 299  || calloutResponseWrapper == NULL || calloutResponseWrapper.response == NULL || calloutResponseWrapper.response.startsWithIgnoreCase('<html>') || calloutResponseWrapper.response.startsWithIgnoreCase('<xml>') || calloutResponseWrapper.errorMessage!=null) {
                calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                strIntMessage = calloutResponseWrapper.errorMessage!=null ? 'Error Message -' + calloutResponseWrapper.errorMessage + ', ' : '';  
                strIntMessage += 'Error With Service - ' + objIntMapper.Name + ' and record reference - ';
            }
            else{
                    Map<String,String> replacements = new Map<String,String>{'status-code'=>'statusCode'};
                        String mogrifiedJSON = AUSF_INT_IntegrationUtility.mogrifyJSON(calloutResponseWrapper.response,replacements);
                    calloutResponseWrapper.response = mogrifiedJSON;
                    AUSF_ICWAI_APIResponseWrapper res = (AUSF_ICWAI_APIResponseWrapper)JSON.deserialize(calloutResponseWrapper.response,AUSF_ICWAI_APIResponseWrapper.class);

                    if(res.statusCode=='101'){
                        objResponse.blnIntegrationSuccess = true;
                        calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED;
                        if(res != NULL && res.statusCode=='101' && res.result!= NULL && (res.result.Fname != null || res.result.Mname != null || res.result.SrName != null)){
                            InnerWrapper objWrap =  insertEmployeeDetails(employmentDetailId, applicant, res, membershipNo);
                            objResponse.employmentDetailId = objWrap.employmentDetailId;  
                        }
                    }else {
                        calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                        strIntMessage = 'Error with Service - '  + objIntMapper.Name + ' and record reference - ';
                    }
            }
            objResponse.objIntResponse = calloutResponseWrapper;
            upsert calloutResponseWrapper.checklistRecord;
            if (!objResponse.blnIntegrationSuccess && calloutResponseWrapper.checklistRecord != NULL && calloutResponseWrapper.checklistRecord.Id != NULL) {
                Integration_Checklist__c objChecklist = AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id);
                objResponse.strMessage = String.isNotBlank(strIntMessage) ? strIntMessage  + objChecklist.Name : '';
                throw new CustomException (objResponse.strMessage);
            }
            objResponse.blnSuccess = true;
            
        }catch (Exception ex) {
            objResponse.strMessage = ex.getMessage();
            System.debug(LoggingLevel.Error,'Exception in class ' + ex);
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium,applicantId,'Applicant','ICWAI API');
        }
        System.debug('ObjResponse-->'+objResponse);
        return objResponse;
    }
    
    /*
@description    : getICWAIDetails - Employment details
@param1         : employmentDetailId
@param2         : applicantId
@param3         : res
@return         : Wrapper class contains return result
*/
    public static InnerWrapper insertEmployeeDetails(String employmentDetailId, Applicant__c objApplicant, AUSF_ICWAI_APIResponseWrapper res, String membershipNo)
    {
        InnerWrapper objWrap = new InnerWrapper();
        String icwaiRecordTypeId = [SELECT Id,Name FROM RecordType WHERE SObjectType = 'Employment_Detail__c' AND DeveloperName = 'ICWAI' limit 1].Id;
        Employment_Detail__c empDetails = new Employment_Detail__c();
        boolean isNameMatchCall = true;
        String responseOwnerName = (String.isNotBlank(res.result.Fname)?res.result.Fname+ ' ':'') + (String.isNotBlank(res.result.Mname)?res.result.Mname+' ':'') + (String.isNotBlank(res.result.SrName)?res.result.SrName+' ':'');
        if(!String.isBlank(employmentDetailId)){
            empDetails = [SELECT Id, Name, Address__c, Owner_Name__c from Employment_Detail__c where Id = :employmentDetailId];
            isNameMatchCall =  empDetails.Owner_Name__c == responseOwnerName? false : true ; // if Exsiting Owner Name Is equal to Response Name Then we no need to call Name Match API.
        }else{            
            empDetails.Applicant__c = objApplicant.Id;
        }

        empDetails.RecordTypeId = icwaiRecordTypeId;
        empDetails.Owner_Name__c = responseOwnerName;
        empDetails.Business_Proof_Validity__c = String.isNotBlank(res.result.ValidUpDt) ? ( date.parse(res.result.ValidUpDt) >  Date.today() ): false;
        empDetails.Business_Address_Validity__c = false;
        empDetails.Registered_Business_name__c = res.result.ProtFirmName;
        empDetails.Date_of_Incorporation__c =  String.isNotBlank(res.result.MemshipDt)?date.parse(res.result.MemshipDt):null;
        empDetails.Active__c = true;
        empDetails.Document_Number__c = membershipNo;
    
        upsert empDetails;

        //check for employment record Null values And check for applicant and employment record null values
        if(String.isNotBlank(objApplicant.Full_Name__c) && String.isNotBlank(empDetails.Owner_Name__c) && String.isNotBlank(objApplicant.Id) && String.isNotBlank(empDetails.Id))
        {
            if(isNameMatchCall)
            {
                Id JobId = System.enqueueJob(new AUSF_QueuableUtility(objApplicant,empDetails));
            }
        }

        objWrap.employmentDetailId = empDetails.Id;
        
        return objWrap;
    }

    public class InnerWrapper{
        public String addressId;
        public String employmentDetailId;
    }
    public class CustomException extends Exception {}
}