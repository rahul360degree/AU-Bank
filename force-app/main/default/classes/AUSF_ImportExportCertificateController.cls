/**
* @author        Tejendra
* @date          06-August-2024
* @description   Import Export Certificate Controller class
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Tejendra              06-August-2024    Initial Version - APL-202
*/
public without sharing class AUSF_ImportExportCertificateController {
    /*
@description    : fetchGstAuthenticationDetails - Fetch GST authentication details service method
@param1         : applicantId - Applicant Record Id
@param2         : importExportCode - import export code
@param3         : employmentId - Employment Id
@return         : Wrapper class contains return result
*/
@AuraEnabled
public static ImportExportCertificationWrapper doImportExportCertification(String applicantId, String importExportCode, String employmentId){
    ImportExportCertificationWrapper objResponse = new ImportExportCertificationWrapper();
    Applicant__c objApplicant;
    try{
        Map<String, String> paramValueMap = new Map<String, String>();
        for(Integration_Static_Param__mdt integrationStaticParamObj : [SELECT API_Name__c, Param_Name__c, Param_Value__c 
                                                                       FROM Integration_Static_Param__mdt 
                                                                       WHERE API_Name__c =: AUSF_ApexConstants.AUSF_IMPORT_EXPORT_CERTIFICATION]){
                                                                           paramValueMap.put(integrationStaticParamObj.Param_Name__c,integrationStaticParamObj.Param_Value__c);
                                                                       }
        objApplicant = [SELECT Id,PAN__c,Full_Name__c FROM Applicant__c where Id =: applicantId limit 1];
        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = objApplicant.Id);
        Integration_Master__c objIntMapper = AUSF_INT_IntegrationUtility.getIntegrationMasterRecord(AUSF_ApexConstants.AUSF_IMPORT_EXPORT_CERTIFICATION);
        Integration_Checklist__c newChecklistInstance = new Integration_Checklist__c();
        newChecklistInstance.Integration_Master__c = objIntMapper.Id;
        newChecklistInstance.Applicant__c = applicantId;
        newChecklistInstance.Request_Id__c = AUSF_INT_IntegrationUtility.getReferenceId();
        AUSF_INT_IntegrationUtility.InputWrapper inputData = new AUSF_INT_IntegrationUtility.InputWrapper();
        inputData.integrationChecklistRecord = newChecklistInstance;
        inputData.integrationMasterRecord = objIntMapper;
        inputData.applicantRecord = objApplicant;
        inputData.dynamicInputs = createRequestDynamicInputData(importExportCode,paramValueMap); 
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
        AUSF_INT_ImportExportCertResponseWrapper objImportExportCertificateResponse = new AUSF_INT_ImportExportCertResponseWrapper(); 
        AUSF_INT_IntegrationResponseWrapper.ResponseWrapper calloutResponseWrapper;
        AUSF_INT_IntegrationRequestWrapper.RequestWrapper calloutRequestWrapper = new AUSF_INT_IntegrationRequestWrapper.RequestWrapper();
        calloutRequestWrapper.request = requestDetails.request;
        calloutRequestWrapper.masterRecord = objIntMapper;
        calloutRequestWrapper.checklistRecord = newChecklistInstance;
        calloutRequestWrapper.entityId = objApplicant.Id;
        calloutResponseWrapper = utilityInstance.initiateCallout(calloutRequestWrapper);
        System.debug('calloutResponseWrapper=' +calloutResponseWrapper);
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
            calloutResponseWrapper.response = calloutResponseWrapper.response.replace('status-code','statuscode');
            objImportExportCertificateResponse = (AUSF_INT_ImportExportCertResponseWrapper)JSON.deserialize(calloutResponseWrapper.response,AUSF_INT_ImportExportCertResponseWrapper.class);
            objImportExportCertificateResponse.responseWrapper = calloutResponseWrapper; 
            objResponse.importExportCertificateResponseWrap = objImportExportCertificateResponse;
            //Check for api status code
            if(objImportExportCertificateResponse != NULL && objImportExportCertificateResponse.statuscode == '101' && objImportExportCertificateResponse.result.name!=null){
                calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED;
                upsert calloutRequestWrapper.checklistRecord;
                objResponse.blnIntegrationSuccess = true;
                InnerWrapper employmentDetailObjId = upsertEmploymentDetailRecord(employmentId,objApplicant,objImportExportCertificateResponse);
                objResponse.addressId = employmentDetailObjId.addressId;
                objResponse.employmentId = employmentDetailObjId.employmentDetailId;
            }else{
                calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                upsert calloutResponseWrapper.checklistRecord;
                Integration_Checklist__c objChecklist = AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id);
                objResponse.strIntMessage = 'Error With Service - ' + objIntMapper.Name + ' and record reference - '+objChecklist.Name;
                throw new CustomException(objResponse.strIntMessage);
            }
        }
        objResponse.blnSuccess = true;
    }catch (Exception ex) {
        objResponse.strMessage = ex.getMessage();
        System.debug('Exception : '+ ex.getMessage() + ' Line Number : '+ex.getLineNumber());
        AUSF_Log.error(ex, AUSF_Log.SeverityType.High,objApplicant.Id,'Applicant',AUSF_ApexConstants.AUSF_IMPORT_EXPORT_CERTIFICATION);
    }
    return objResponse;
}


/*
@description    : upsertEmploymentDetailRecord - upsert employment detail record
@param1         : employmentId - employment detail record id
@param2         : objApplicant - Applicant Record
@param3         : objImportExportCertificateResponse - AUSF_INT_ImportExportCertResponseWrapper wrapper object
@return         : String
*/
public static InnerWrapper upsertEmploymentDetailRecord(String employmentId, Applicant__c objApplicant, AUSF_INT_ImportExportCertResponseWrapper objImportExportCertificateResponse){
    InnerWrapper objWrap = new InnerWrapper();
    Employment_Detail__c employmentDetail = new Employment_Detail__c();
    Address__c addr = new Address__c();
    Employment_Detail__c existingEmpoymentDetail = null;
    String importExportRecordTypeId = [SELECT Id,Name FROM RecordType WHERE SObjectType = 'Employment_Detail__c' AND DeveloperName = 'IEC' limit 1].Id;
    System.debug('IEC Record Type ID :->'+importExportRecordTypeId);
    if(!String.isBlank(employmentId)){
        existingEmpoymentDetail = [Select Id, Owner_Name__c,Address__c FROM Employment_Detail__c WHERE ID=:employmentId];
        employmentDetail.Id = employmentId;
        if(existingEmpoymentDetail.Address__c != null){
            Address__c deactivateAddress = new Address__c(Id = existingEmpoymentDetail.Address__c, Active__c = false);
            update deactivateAddress;
        }
    }else{
        employmentDetail.Applicant__c = objApplicant.Id;
    }

    if(objImportExportCertificateResponse.result.splitaddress!=null){
        addr = AUSF_AddressSplitUtilty.addressSplitOnSuccess(objImportExportCertificateResponse.result.splitaddress,objApplicant.Id);
    }
    else{
        addr = AUSF_AddressSplitUtilty.addressSplitOnFailure(objImportExportCertificateResponse.result.address,objApplicant.Id);
    }
    addr.Address_Source__c = AUSF_ApexConstants.AUSF_BusinessOwnerShipProof;
    addr.Address_Type__c = AUSF_ApexConstants.AUSF_AddrType_WORK;
    addr.Active__c = true;
    if (addr.Applicant__c != NULL){
        insert addr ;
        objWrap.addressId = addr.Id;
    }


    employmentDetail.Address__c   = addr.Id;
    employmentDetail.RecordTypeId = importExportRecordTypeId;
    if(objImportExportCertificateResponse.result != NULL){
        employmentDetail.Registered_Business_name__c = objImportExportCertificateResponse.result.name;
        if(!objImportExportCertificateResponse.result.directors.isEmpty()){
            employmentDetail.Owner_Name__c = objImportExportCertificateResponse.result.directors[0].dir_name;
        }
        employmentDetail.Document_Number__c = objImportExportCertificateResponse.result.ie_code;
        if(objImportExportCertificateResponse.result.iec_status == 'Valid'){
            employmentDetail.Business_Proof_Validity__c = true;
        }else{
            employmentDetail.Business_Proof_Validity__c = false;
        }
        if(String.isNotBlank(objImportExportCertificateResponse.result.address)){
            employmentDetail.Business_Address_Validity__c = true;  
        }else{
            employmentDetail.Business_Address_Validity__c = false;    
        }
        if(String.isNotBlank(objImportExportCertificateResponse.result.date_of_establishment)){
            employmentDetail.Date_of_Incorporation__c = Date.parse(objImportExportCertificateResponse.result.date_of_establishment.replace('-','/'));    
            Date apiDate = date.parse(objImportExportCertificateResponse.result.date_of_establishment.replace('-','/'));
            Integer apiDateMonth = apiDate.month();
            Date currentDate = date.today();
            Integer currentDateMonth = currentDate.month();
            Integer monthDifference = apiDateMonth - currentDateMonth;
            Integer vintageYears = apiDate.monthsBetween(currentDate)/12;
            employmentDetail.Business_Vintage_Years__c = String.valueOf(vintageYears);
            employmentDetail.Business_Vintage_Months__c = String.valueOf(math.abs(monthDifference));
        }
        
        upsert employmentDetail;
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
    //objWrap.addressId = addr.Id;
    objWrap.employmentDetailId = employmentDetail.Id;
    return objWrap;  
} 
/*
@description    : createRequestDynamicInputData - Generate dynamic inputs data
@param1         : importExportCode - import export code
@param2         : paramValueMap - map of static api parameters
@return         : Map of string
*/
public static Map<String,String> createRequestDynamicInputData(String importExportCode, Map<String,String> paramValueMap){
    Map<String,String> dynamicInputs = new Map<String,String>();
    dynamicInputs.put('RequestId', AUSF_INT_IntegrationUtility.getReferenceId());
    dynamicInputs.put('OriginatingChannel', paramValueMap.get('OriginatingChannel'));
    dynamicInputs.put('Consent',paramValueMap.get('Consent'));
    dynamicInputs.put('Iec',importExportCode);
    return dynamicInputs; 
}
public class ImportExportCertificationWrapper {
    @AuraEnabled
    public AUSF_INT_ImportExportCertResponseWrapper importExportCertificateResponseWrap {get;set;}
    @AuraEnabled
    public String addressId {get;set;}
    @AuraEnabled
    public String employmentId {get;set;}
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