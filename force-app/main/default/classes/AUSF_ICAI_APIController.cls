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
public without sharing class AUSF_ICAI_APIController {
    /*
    @description    : getICSIDetails - generate Response and update address and Employment details
    @param1         : applicantId - Id of the applicant
    @param2         : membershipNo - MembershipNo to be passed from api
    @param3         : employmentDetailId
    @return         : Wrapper class contains return result
     */
    @AuraEnabled
    public static AUSF_INT_ICAI_APIWrapper getICAIDetails(String applicantId,String membershipNo,String employmentDetailId){
        AUSF_INT_ICAI_APIWrapper objResponse = new AUSF_INT_ICAI_APIWrapper();
        Integration_Master__c objIntMapper = AUSF_INT_IntegrationUtility.getIntegrationMasterRecord(AUSF_ApexConstants.AUSF_ICAI_API);
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
            inputData.dynamicInputs.put('MembershipNo', membershipNo);
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
            if (calloutResponseWrapper.statusCode < 200 || calloutResponseWrapper.statusCode > 299 || calloutResponseWrapper == NULL || calloutResponseWrapper.response == NULL || calloutResponseWrapper.response.startsWithIgnoreCase('<html>') || calloutResponseWrapper.response.startsWithIgnoreCase('<xml>') || calloutResponseWrapper.errorMessage!=null) {
                calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                strIntMessage = calloutResponseWrapper.errorMessage!=null ? 'Error Message -' + calloutResponseWrapper.errorMessage + ', ' : '';  
                strIntMessage += 'Error With Service - ' + objIntMapper.Name + ' and record reference - ';
            }
            else
            {
                    Map<String,String> replacements = new Map<String,String>{'status-code'=>'statusCode','C/O'=>'Care_Of'};
                    String mogrifiedJSON = AUSF_INT_IntegrationUtility.mogrifyJSON(calloutResponseWrapper.response,replacements);
                    calloutResponseWrapper.response = mogrifiedJSON;
                    AUSF_ICAI_APIResponseWrapper res = (AUSF_ICAI_APIResponseWrapper)JSON.deserialize(calloutResponseWrapper.response,AUSF_ICAI_APIResponseWrapper.class);

                    if(res != NULL && res.statusCode=='101' && res.result!= NULL && res.result.Name != NULL){
                        objResponse.blnIntegrationSuccess = true;
                        calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED;
                            InnerWrapper objWrap = upsertEmploymentDetails(applicant,res,employmentDetailId,membershipNo);  
                            objResponse.addressId = objWrap.addressId;
                            objResponse.employmentDetailId = objWrap.employmentDetailId;                          
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
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium,applicantId,'Applicant','ICAI API');
        }
        System.debug('ObjResponse-->'+objResponse);
        return objResponse;
    }
    /*
    @description    : insertEmploymentDetails - insert employment details and address records
    @param1         : applicantId - Id of the applicant
    @param2         : response - ICAI Response
    @param3         : employmentDetailId
    @return         : InnerWrapper
     */
    public static InnerWrapper upsertEmploymentDetails(Applicant__c applicant, AUSF_ICAI_APIResponseWrapper response, String employmentId, String membershipNo){
        InnerWrapper objWrap = new InnerWrapper();
        Employment_Detail__c empDetails = new Employment_Detail__c();
        Address__c addr = new Address__c();

        boolean isNameMatchCall = true;
        String icaiRecordTypeId = [SELECT Id,Name FROM RecordType WHERE SObjectType = 'Employment_Detail__c' AND DeveloperName = 'ICAI' limit 1].Id;
        
        if(String.isBlank(employmentId)){
            empDetails.Applicant__c = String.isNotBlank(applicant.Id)?applicant.Id:null;
        }
        else{
            // Id Assignment and Old Attach Address is making inactive.
            empDetails = [SELECT Id, Name, Address__c, Owner_Name__c from Employment_Detail__c where Id = :employmentId];
            if(empDetails.Address__c != null) {
                Address__c oldAdr = new Address__c(Id = empDetails.Address__c, Active__c = false);
                update oldAdr;
            }
            isNameMatchCall =  empDetails.Owner_Name__c == response.result.name ? false : true ; // if Exsiting Owner Name Is equal to Response Name Then we no need to call Name Match API.
        }

        if(response.result != NULL && response.result.splitaddress!=null){
            addr = AUSF_AddressSplitUtilty.addressSplitOnSuccess(response.result.splitaddress,applicant.Id);
        }
        else if (response.result != NULL && response.result.address!=NULL){
            addr = AUSF_AddressSplitUtilty.addressSplitOnFailure(response.result.address,applicant.Id);
        }
        

        addr.Address_Source__c = AUSF_ApexConstants.AUSF_BusinessOwnerShipProof;
        addr.Address_Type__c = AUSF_ApexConstants.AUSF_AddrType_WORK;
        addr.Active__c = true;
        if (addr.Applicant__c != NULL)
        {
            insert addr ;
        objWrap.addressId = addr.Id;
        }

        empDetails.Address__c = addr.Id;
        empDetails.RecordTypeId = icaiRecordTypeId;
        empDetails.Owner_Name__c = String.isNotBlank(response.result.name)?response.result.name:null;
        empDetails.Business_Address_Validity__c = response.result.memberStatus=='Active'?true:false;
        empDetails.Document_Number__c	=membershipNo;
        empDetails.Active__c = true;
        upsert empDetails;

        if(String.IsNotBlank(empDetails.Owner_Name__c) && isNameMatchCall && String.isNotBlank(applicant.Full_Name__c)){
            //check for applicant and employment record null values
            Id JobId = System.enqueueJob(new AUSF_QueuableUtility(applicant,empDetails));
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