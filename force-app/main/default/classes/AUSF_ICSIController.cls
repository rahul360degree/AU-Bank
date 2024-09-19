/**
 * @author        Pradeep Sharma
 * Class :		 AUSF_ICAI_APIController
 * Test Class	 AUSF_ICAI_APITest
 * @date         01-Aug-2024
 * @description
 * Modification Log:
--------------------------------------------------------------------------------------------
    Developer             Date            Description
    --------------------------------------------------------------------------------------------
    Pradeep Sharma        01-Aug-2024    Initial Version
     */
public without sharing class AUSF_ICSIController {
    /*
    @description    : getICSIDetails - generate Response and update address and Employment details
    @param1         : applicantId - Id of the applicant
    @param2         : MembershipNo - MembershipNo to be passed from api
    @param3         : employmentDetailId
    @return         : Wrapper class contains return result
     */
    @AuraEnabled
    public static AUSF_INT_ICSIWrapper getICSIDetails(String applicantId,String MembershipNo,String employmentDetailId){
        AUSF_INT_ICSIWrapper objResponse = new AUSF_INT_ICSIWrapper();
        Integration_Master__c objIntMapper = AUSF_INT_IntegrationUtility.getIntegrationMasterRecord(AUSF_ApexConstants.AUSF_ICSI_API);
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
            inputData.dynamicInputs.put('MembershipNo', MembershipNo);
            inputData.dynamicInputs.put('Consent', 'Y');
            inputData.dynamicInputs.put('channel', objIntMapper.Channel__c);
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

            if (calloutResponseWrapper.statusCode < 200 || calloutResponseWrapper.statusCode > 299   || calloutResponseWrapper == NULL || calloutResponseWrapper.response == NULL || calloutResponseWrapper.response.startsWithIgnoreCase('<html>') || calloutResponseWrapper.response.startsWithIgnoreCase('<xml>') || calloutResponseWrapper.errorMessage!=null) {
                calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                strIntMessage = calloutResponseWrapper.errorMessage!=null ? 'Error Message -' + calloutResponseWrapper.errorMessage + ', ' : '';  
                strIntMessage += 'Error With Service - ' + objIntMapper.Name + ' and record reference - ';
            }
            else{
                Map<String,String> replacements = new Map<String,String>{'status-code'=>'statusCode','C/O'=>'Care_Of'};
                String mogrifiedJSON = AUSF_INT_IntegrationUtility.mogrifyJSON(calloutResponseWrapper.response,replacements);
                calloutResponseWrapper.response = mogrifiedJSON;
                AUSF_ICSIResponseWrapper res = (AUSF_ICSIResponseWrapper)JSON.deserialize(calloutResponseWrapper.response,AUSF_ICSIResponseWrapper.class);

                if(res != NULL && res.statusCode=='101' && res.result!= NULL && res.result.memberName != NULL){
                    objResponse.blnIntegrationSuccess = true;
                    calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED;
                    InnerWrapper objWrap = insertEmploymentDetails(applicant,res,employmentDetailId);
                    objResponse.addressId = objWrap.addressId;
                    objResponse.employmentDetailId = objwrap.employmentDetailId;
                    if(String.isNotBlank(res.result.memberImage)){
                        Id jobId = System.enqueueJob(new AUSF_DocumentCompressorQueueble(res.result.memberImage,'ICSI.pdf',applicantId,'',''));
                    }
                }
                else{
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
        }catch(Exception ex){
            objResponse.strMessage = ex.getMessage();
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium,applicantId,'Applicant','ICSI API');
        }
        return objResponse;
    }
    /*
    @description    : insertEmploymentDetails - insert employment details and address records
    @param1         : applicantId - Id of the applicant
    @param2         : response - ICSI Response
    @param3         : employmentId - employmentDetailId
    @return         : InnerWrapper
     */
    public static InnerWrapper insertEmploymentDetails(Applicant__c applicant, AUSF_ICSIResponseWrapper response, String employmentId){
        InnerWrapper objWrap = new InnerWrapper();
        Address__c addr = new Address__c();
        if(response.result.splitaddress!=null){
            addr = AUSF_AddressSplitUtilty.addressSplitOnSuccess(response.result.splitaddress,applicant.Id);
        }
        else{
            addr = AUSF_AddressSplitUtilty.addressSplitOnFailure(response.result.address,applicant.Id);
        }
        addr.Address_Source__c = AUSF_ApexConstants.AUSF_BusinessOwnerShipProof;
        addr.Address_Type__c = AUSF_ApexConstants.AUSF_AddrType_WORK;
        addr.Active__c = true;
        insert addr;

        objWrap.addressId = addr.Id;
        String icsiRecordTypeId = [SELECT Id,Name FROM RecordType WHERE SObjectType = 'Employment_Detail__c' AND DeveloperName = 'ICWAI' limit 1].Id;
        Employment_Detail__c employmentDetail = new Employment_Detail__c();
        employmentDetail.Id = String.isNotBlank(employmentId) ? employmentId : NULL;
        employmentDetail.Registered_Business_name__c = response.result.organization;
        employmentDetail.Owner_Name__c= response.result.memberName;
        employmentDetail.Document_Number__c = response.result.membershipNumber;
        employmentDetail.Applicant__c = String.isNotBlank(applicant.Id)?applicant.Id:NULL;
        employmentDetail.Address__c = addr.Id;
        employmentDetail.RecordTypeId = icsiRecordTypeId;
        employmentDetail.Owner_Name_Vintage_Verified__c = false;
        upsert employmentDetail;
        //check for employment record Null values
        if(String.IsNotBlank(employmentDetail.Owner_Name__c)){
            //check for applicant and employment record null values
            if(String.isNotBlank(applicant.Full_Name__c) && String.isNotBlank(employmentDetail.Owner_Name__c) && String.isNotBlank(applicant.Id)){
                Id JobId = System.enqueueJob(new AUSF_QueuableUtility(applicant,employmentDetail));
            }
        }else{
            employmentDetail.Owner_Name_Vintage_Verified__c = false;
        }
        objWrap.employmentDetailId = employmentDetail.Id;
        return objWrap;
    }
    public class InnerWrapper{
        public String addressId;
        public String employmentDetailId;
    }
    public class CustomException extends Exception {}
}