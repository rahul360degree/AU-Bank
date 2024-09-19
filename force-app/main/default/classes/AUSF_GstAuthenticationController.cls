/**
 * @author        Tejendra
 * @date          31-July-2024
 * @description   Fetch GST Authentication details Controller class
 * Modification Log:
--------------------------------------------------------------------------------------------
    Developer             Date            Description
    --------------------------------------------------------------------------------------------
    Tejendra              31-July-2024    Initial Version - APL-34
*/
public without sharing class AUSF_GstAuthenticationController {
    /*
    @description    : fetchGstAuthenticationDetails - Fetch GST authentication details service method
    @param1         : applicantId - Applicant Record Id
    @param2         : gstin - gst number
    @param3         : employmentId - Employment Id
    @return         : Wrapper class contains return result
     */
    @AuraEnabled
    public static GstAuthenticationWrapper fetchGstAuthenticationDetails(String applicantId, String gstin, String employmentId){
        GstAuthenticationWrapper objResponse = new GstAuthenticationWrapper();
        Applicant__c objApplicant;
        try{
            Map<String, String> paramValueMap = new Map<String, String>();
            for(Integration_Static_Param__mdt integrationStaticParamObj : [SELECT API_Name__c, Param_Name__c, Param_Value__c 
                                                                       FROM Integration_Static_Param__mdt 
                                                                       WHERE API_Name__c =: AUSF_ApexConstants.AUSF_GST_AUTHENTICATION]){
                paramValueMap.put(integrationStaticParamObj.Param_Name__c,integrationStaticParamObj.Param_Value__c);
            }
            objApplicant = [SELECT Id,PAN__c,Full_Name__c FROM Applicant__c where Id =: applicantId limit 1];
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = objApplicant.Id);
            Integration_Master__c objIntMapper = AUSF_INT_IntegrationUtility.getIntegrationMasterRecord(AUSF_ApexConstants.AUSF_GST_AUTHENTICATION);
            Integration_Checklist__c newChecklistInstance = new Integration_Checklist__c();
            newChecklistInstance.Integration_Master__c = objIntMapper.Id;
            newChecklistInstance.Applicant__c = applicantId;
            newChecklistInstance.Request_Id__c = AUSF_INT_IntegrationUtility.getReferenceId();
            AUSF_INT_IntegrationUtility.InputWrapper inputData = new AUSF_INT_IntegrationUtility.InputWrapper();
            inputData.integrationChecklistRecord = newChecklistInstance;
            inputData.integrationMasterRecord = objIntMapper;
            inputData.applicantRecord = objApplicant;
            inputData.dynamicInputs = createRequestDynamicInputData(gstin,paramValueMap,objIntMapper);
            inputData.dynamicInputs.put('SFRequestId',newChecklistInstance.Request_Id__c);
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
            AUSF_INT_GstAuthResponseWrapper objGstAuthenticationResponse = new AUSF_INT_GstAuthResponseWrapper();
            AUSF_INT_IntegrationResponseWrapper.ResponseWrapper calloutResponseWrapper;
            AUSF_INT_IntegrationRequestWrapper.RequestWrapper calloutRequestWrapper = new AUSF_INT_IntegrationRequestWrapper.RequestWrapper();
            calloutRequestWrapper.request = requestDetails.request;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = newChecklistInstance;
            calloutRequestWrapper.entityId = objApplicant.Id;
            calloutResponseWrapper = utilityInstance.initiateCallout(calloutRequestWrapper);
            System.debug('calloutResponseWrapper='+calloutResponseWrapper);
            //Check for api hit limit restrictions for user
            if (calloutResponseWrapper.errorMessage!=null) {
                objResponse.strIntMessage = calloutResponseWrapper.errorMessage;
                throw new CustomException (objResponse.strIntMessage);
            }
            // Check for HTTP Status Code
            if (calloutResponseWrapper.statusCode < 200 || calloutResponseWrapper.statusCode > 299 || calloutResponseWrapper == NULL || calloutResponseWrapper.response == NULL || calloutResponseWrapper.response.startsWithIgnoreCase('<html>') || calloutResponseWrapper.response.startsWithIgnoreCase('<xml>')) {
                calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                upsert calloutResponseWrapper.checklistRecord;
                Integration_Checklist__c objChecklist = AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id);
                objResponse.strIntMessage = 'Error With Service - ' + objIntMapper.Name + ' and record reference - '+objChecklist.Name;
                throw new CustomException(objResponse.strIntMessage);
            }else  {
                Map<String,String> replacements = new Map<String,String>{'status-code'=>'statusCode','C/O'=>'Care_Of'};
                String mogrifiedJSON = AUSF_INT_IntegrationUtility.mogrifyJSON(calloutResponseWrapper.response,replacements);
                calloutResponseWrapper.response = mogrifiedJSON;
                objGstAuthenticationResponse = (AUSF_INT_GstAuthResponseWrapper)JSON.deserialize(calloutResponseWrapper.response,AUSF_INT_GstAuthResponseWrapper.class);
                objGstAuthenticationResponse.responseWrapper = calloutResponseWrapper;
                objResponse.gstAuthenticationResponseWrap = objGstAuthenticationResponse;

                //Check for api status code
                if(objGstAuthenticationResponse != NULL && objGstAuthenticationResponse.statusCode == 101 && objGstAuthenticationResponse.result.lgnm!=null){//!results.isEmpty()){
                    InnerWrapper objWrap = upsertEmploymentDetailRecord(employmentId,objApplicant,objGstAuthenticationResponse);
                    calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED;
                    upsert calloutRequestWrapper.checklistRecord;
                    objResponse.blnIntegrationSuccess = true;
                    objResponse.addressId = objWrap.addressId ;
                    objResponse.employmentId = objWrap.employmentDetailId;
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
            System.debug('Exception : '+ ex.getMessage() + ' Line Number : '+ex.getLineNumber());
            objResponse.strMessage = ex.getMessage();
            AUSF_Log.error(ex, AUSF_Log.SeverityType.High,objApplicant.Id,'Applicant',AUSF_ApexConstants.AUSF_GST_AUTHENTICATION);
        }
        return objResponse;
    }

    /*
    @description    : upsertEmploymentDetailRecord - upsert employment detail record
    @param1         : employmentId - employment detail record id
    @param2         : objApplicant - Applicant Record
    @param3         : objGstAuthenticationResponse - AUSF_INT_GstAuthResponseWrapper wrapper object
    @return         : String
     */
    public static InnerWrapper upsertEmploymentDetailRecord(String employmentId, Applicant__c objApplicant, AUSF_INT_GstAuthResponseWrapper objGstAuthenticationResponse){
        InnerWrapper objWrap = new InnerWrapper();
        Address__c addr = new Address__c();
        String gstRecordTypeId = [SELECT Id,Name FROM RecordType WHERE SObjectType = 'Employment_Detail__c' AND DeveloperName = 'GST' limit 1].Id;
        System.debug('GST Record Type ID :->'+gstRecordTypeId);
        if(objGstAuthenticationResponse.result.splitaddress!=null){
            addr = AUSF_AddressSplitUtilty.addressSplitOnSuccess(objGstAuthenticationResponse.result.splitaddress,objApplicant.Id);
        }
        else{
            addr = AUSF_AddressSplitUtilty.addressSplitOnFailure(objGstAuthenticationResponse.result.adadr.adr,objApplicant.Id);
        }
        addr.Address_Type__c = AUSF_ApexConstants.AUSF_ADDRTYPE_WORK;
        addr.Address_Source__c = AUSF_ApexConstants.AUSF_BUSINESSOWNERSHIPPROOF;
        addr.Active__c = true;
        insert addr;
        objWrap.addressId = addr.Id;
        Employment_Detail__c employmentDetail = new Employment_Detail__c();
        Employment_Detail__c existingEmpoymentDetail = null;
        if(!String.isBlank(employmentId)){
            existingEmpoymentDetail = [Select Id,Owner_Name__c,Address__c FROM Employment_Detail__c WHERE ID=:employmentId];
            employmentDetail.Id = employmentId;
            if(existingEmpoymentDetail.Address__c != null){
                Address__c deactivateAddress = new Address__c(Id = existingEmpoymentDetail.Address__c, Active__c = false);
                update deactivateAddress;
            }

        }else{
            employmentDetail.Applicant__c = objApplicant.Id;
        }
        employmentDetail.Address__c = addr.Id;
        employmentDetail.RecordTypeId = gstRecordTypeId;
        if(objGstAuthenticationResponse.result != NULL){
            employmentDetail.Date_of_Incorporation__c = String.isNotbLANK(objGstAuthenticationResponse.result.rgdt) ? Date.parse(objGstAuthenticationResponse.result.rgdt) : NULL;
            employmentDetail.Registered_Business_name__c = objGstAuthenticationResponse.result.tradeNam;
            employmentDetail.Owner_Name__c = objGstAuthenticationResponse.result.lgnm;
            employmentDetail.Document_Number__c = objGstAuthenticationResponse.result.gstin;
            if(objGstAuthenticationResponse.result.sts == 'Active'){
                employmentDetail.Business_Proof_Validity__c = true;
            }else{
                employmentDetail.Business_Proof_Validity__c = false;
            }
            if(objGstAuthenticationResponse.result.pradr != NULL && String.isNotBlank(objGstAuthenticationResponse.result.pradr.adr)){
                employmentDetail.Business_Address_Validity__c = true;
            }else{
                employmentDetail.Business_Address_Validity__c = false;
            }
            if(String.isNotBlank(objGstAuthenticationResponse.result.rgdt)){
                Date apiDate = date.parse(objGstAuthenticationResponse.result.rgdt);
                Integer apiDateMonth = apiDate.month();
                Date currentDate = date.today();
                Integer currentDateMonth = currentDate.month();
                Integer monthDifference = apiDateMonth - currentDateMonth;
                Integer vintageYears = apiDate.monthsBetween(currentDate)/12;
                employmentDetail.Business_Vintage_Years__c = String.valueOf(vintageYears);
                employmentDetail.Business_Vintage_Months__c = String.valueOf(math.abs(monthDifference));
            }
            
            
            upsert employmentDetail;

            objWrap.employmentDetailId = employmentDetail.Id;
        }
        //check for employment record Null values
        if(employmentDetail.Date_of_Incorporation__c != NULL && String.IsNotBlank(employmentDetail.Owner_Name__c)){
            //check for applicant and employment record null values
            if(existingEmpoymentDetail!=null && existingEmpoymentDetail.Owner_Name__c==employmentDetail.Owner_Name__c){
                //If Employment record already exist and owner name not change respective to old record then avoid name match
            }else if(String.isNotBlank(objApplicant.Full_Name__c) && String.isNotBlank(employmentDetail.Owner_Name__c) && String.isNotBlank(objApplicant.Id)){
                Id JobId = System.enqueueJob(new AUSF_QueuableUtility(objApplicant,employmentDetail));
            }
        }
        return objWrap;
    }
    /*
    @description    : createRequestDynamicInputData - Generate dynamic inputs data
    @param1         : gstin - gst number
    @param2         : paramValueMap - map of static api parameters
    @param3         : objIntMapper - Integration Master Record
    @return         : Map of string
     */
    public static Map<String,String> createRequestDynamicInputData(String gstin, Map<String,String> paramValueMap,Integration_Master__c objIntMapper){
        Map<String,String> dynamicInputs = new Map<String,String>();
        dynamicInputs.put('requestid', AUSF_INT_IntegrationUtility.getReferenceId());
        dynamicInputs.put('channel', objIntMapper.Channel__c);
        dynamicInputs.put('consent',paramValueMap.get('consent'));
        dynamicInputs.put('gstin',gstin);
        return dynamicInputs;
    }
    public class GstAuthenticationWrapper {
        @AuraEnabled
        public AUSF_INT_GstAuthResponseWrapper gstAuthenticationResponseWrap {get;set;}
        @AuraEnabled
        public String employmentId {get;set;}
        @AuraEnabled
        public String addressId {get;set;}
        @AuraEnabled
        public Boolean blnIntegrationSuccess = false;
        @AuraEnabled
        public Boolean blnSuccess = false;
        @AuraEnabled
        public String strMessage {get;set;}
        @AuraEnabled
        public String strIntMessage {get;set;}
    }
    public class InnerWrapper{
        public String addressId;
        public String employmentDetailId;
    }
    public class CustomException extends Exception {}
}