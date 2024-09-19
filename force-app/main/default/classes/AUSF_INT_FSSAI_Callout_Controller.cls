/**
 * @author              : Amit Mishra
 * @date                : 03-Aug-2024
 * @description         : FSSAI API Integration callout controller
 * Test Class           : AUSF_INT_FSSAI_Test
 * History              :
 * ===========================================================================================================
 * <Date> 		<Authors Name> 		<Brief Description of Change>
 * ===========================================================================================================
 * 03-Aug-2024 	Amit Mishra 		Initial Version
**/
public without sharing class AUSF_INT_FSSAI_Callout_Controller {
    /*
    @description    :   This main method to get final FSSAI response 
    @param1         :   applicantId - Applicant Id
    @param2         :   registrationNo - registration number
    @param3         :   employmentId - Employment Object Id
    @return         :   AUSF_INT_FSSAI_ResponseWrapper final reponse wrapper
    */
    @AuraEnabled
    public static AUSF_INT_FSSAI_ResponseWrapper getFssaiResponse(String applicantId, String registrationNo, String employmentId){
        //Response Wrapper
        AUSF_INT_FSSAI_ResponseWrapper finalResponseWrapper = new AUSF_INT_FSSAI_ResponseWrapper();
        Boolean isCheckListNameRequired = false;
        String checklistId;
        try {
            //Validating input parameters
            if(String.isBlank(registrationNo)){
                throw new AuraHandledException(AUSF_ApexConstants.REGISTRATION_NO_REQUIRED);
            }
            //Validating input parameters
            if(String.isBlank(applicantId)){
                throw new AuraHandledException(AUSF_ApexConstants.REGISTRATION_NO_REQUIRED);
            }
            Applicant__c applicant = new Applicant__c(Id = applicantId);
            //Integration Master query
            Integration_Master__c integrationMasterRecord = AUSF_INT_IntegrationUtility.getIntegrationMasterRecord(AUSF_ApexConstants.FSSAI);
            //Creting Integration Checklist 
            Integration_Checklist__c checkListRecord = new Integration_Checklist__c();
            checkListRecord.Integration_Master__c = integrationMasterRecord.Id;
            checkListRecord.Applicant__c = applicantId;
            checkListRecord.Request_Id__c = AUSF_INT_IntegrationUtility.getReferenceId();
            
            //Creating genric request wrapper to collect data
            AUSF_INT_IntegrationUtility.InputWrapper inputReqWrapper = new AUSF_INT_IntegrationUtility.InputWrapper();
            inputReqWrapper.integrationMasterRecord = integrationMasterRecord;
            inputReqWrapper.integrationChecklistRecord = checkListRecord;
            inputReqWrapper.applicantRecord = applicant;
            inputReqWrapper.dynamicInputs = new Map<String, Object>();
            inputReqWrapper.dynamicInputs.put('RegistrationNo',registrationNo);

            //Creating Integration Utility instance for generting  main request
            AUSF_INT_IntegrationUtility intUtility = new AUSF_INT_IntegrationUtility();
            AUSF_INT_IntegrationRequestWrapper.HTTPRequestWrapper requestData = intUtility.constructRequest(inputReqWrapper);
            
            //Checking that is any required value missing
            if (String.isNotBlank(requestData.preRequisites)) {
                checkListRecord.Status__c = AUSF_ApexConstants.MISSING_PRE_REQUISITES;
                checkListRecord.Missing_Pre_requisites__c = requestData.preRequisites;
                upsert checkListRecord Request_Id__c;
                isCheckListNameRequired = true;
                checklistId = checkListRecord.Id;
                throw new AuraHandledException(requestData.preRequisites);
            }

            //Synchronous callout
            AUSF_INT_IntegrationRequestWrapper.RequestWrapper calloutRequestWrapper = new AUSF_INT_IntegrationRequestWrapper.RequestWrapper();
            calloutRequestWrapper.request = requestData.request;
            calloutRequestWrapper.masterRecord = integrationMasterRecord;
            calloutRequestWrapper.checklistRecord = checkListRecord;
            calloutRequestWrapper.entityId = applicantId;
            //System.debug(LoggingLevel.Info,'callout Request Wrapper:'+calloutRequestWrapper);
            AUSF_INT_IntegrationResponseWrapper.ResponseWrapper calloutResponseWrapper = intUtility.initiateCallout(calloutRequestWrapper);
            //System.debug(LoggingLevel.Info,'Callout Response Wrapper:'+calloutResponseWrapper);
            
            //Validate API Limit resticrtion for user
            if (calloutResponseWrapper.errorMessage != NULL) {
                throw new AuraHandledException(calloutResponseWrapper.errorMessage);
            }
            //Check HTTP Status Code
            if(calloutResponseWrapper == NULL || calloutResponseWrapper.response == NULL || calloutResponseWrapper.statusCode != 200 || calloutResponseWrapper.response.startsWithIgnoreCase('<html>') || calloutResponseWrapper.response.startsWithIgnoreCase('<xml>')){
                calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                upsert calloutResponseWrapper.checklistRecord Request_Id__c;
                isCheckListNameRequired = true;
                checklistId = calloutResponseWrapper.checklistRecord.Id;
                throw new AuraHandledException(AUSF_ApexConstants.FSSAI_ERROR_MSG);
            }
            finalResponseWrapper.blnIntegrationSuccess = true;
            calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED;
            upsert calloutResponseWrapper.checklistRecord Request_Id__c;
            isCheckListNameRequired = true;
            checklistId = calloutResponseWrapper.checklistRecord.Id;
            finalResponseWrapper.responseWrapper = calloutResponseWrapper;
            //handle all DML and error handling from response
            Map<String, String> reponsedata = handleResponse(calloutResponseWrapper.response, applicant, employmentId);
            finalResponseWrapper.addressId = reponsedata.get('addressId');
            finalResponseWrapper.employmentId = reponsedata.get('employmentId');
            finalResponseWrapper.blnSuccess = true;
        } catch (Exception ex) {
            String message = ex.getMessage();
            if(isCheckListNameRequired){
                message += '-'+AUSF_INT_IntegrationUtility.getIntegrationChecklist(checklistId).Name;
            }
            finalResponseWrapper.strMessage = message;
            System.debug(LoggingLevel.Error,'===============================================================');
            System.debug(LoggingLevel.Error,'Exception: ' + ex);
            System.debug(LoggingLevel.Error,'===============================================================');
            System.debug(LoggingLevel.Error,'Exception type caught: ' + ex.getTypeName());
            System.debug(LoggingLevel.Error,'Message: ' + ex.getMessage());
            System.debug(LoggingLevel.Error,'Line number: ' + ex.getLineNumber());
            System.debug(LoggingLevel.Error,'Stack trace: ' + ex.getStackTraceString());
            System.debug(LoggingLevel.Error,'===============================================================');
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium,applicantId, 'Applicant','AUSF_INT_FSSAI_Callout_Controller');
        }
        return finalResponseWrapper;
    }
    /*
    @description    :   Handle response 
    @param1         :   response - FSSAI API response String
    @param2         :   applicantId - Applicant Sobject
    @param3         :   employmentId - Employment Object Id
    return          :   Map<String, String> - returning address Id and employment Id
    */
    public static Map<String, String> handleResponse(String response, Applicant__c applicant, String employmentId){
        //Modify json
        response = response.replace('status-code', 'statusCode');
        response = response.replace('C/O', 'Care_Of');
        //Deserialize the response
        AUSF_INT_FSSAI_ResponseWrapper.Response reposneWrapper = (AUSF_INT_FSSAI_ResponseWrapper.Response)JSON.deserialize(response, AUSF_INT_FSSAI_ResponseWrapper.Response.class);
        //System.debug(LoggingLevel.Info,'reposneWrapper:'+reposneWrapper);
        if(reposneWrapper == null || reposneWrapper.result == null ||  reposneWrapper.statusCode != '101'){//reposneWrapper.result.LicNO||reposneWrapper.result.Status || reposneWrapper.result.FirmName
            throw new AuraHandledException(AUSF_ApexConstants.FSSAI_ERROR_MSG);
        }
        //DML on address
        String addressId = handleAddressRecord(applicant, reposneWrapper,employmentId);
        //Update Employment Detail or Business Proof
        employmentId = upsertEmploymentDetailRecord(employmentId, addressId, applicant, reposneWrapper);
        Map<String, String> reponsedata = new Map<String, String>();
        reponsedata.put('addressId',addressId);
        reponsedata.put('employmentId', employmentId);
        return reponsedata;
    }
    
    /*
    @description    : Create or update employment detail record
    @param1         : employmentId - employment detail record id
    @param2         : addressId - addressId Record Id
    @param3         : applicant - Applicant Record
    @param3         : fassiResponseWrapper - AUSF_INT_FSSAI_ResponseWrapper class instance
    @return         : String
    */
    public static String upsertEmploymentDetailRecord(String employmentId, String addressId, Applicant__c applicant, AUSF_INT_FSSAI_ResponseWrapper.Response fassiResponseWrapper){
        AUSF_INT_FSSAI_ResponseWrapper.Result responseResult = fassiResponseWrapper.result; 
        String recordTypeId_FSSAI = [SELECT Id, Name, DeveloperName, SobjectType, IsActive FROM RecordType WHERE SobjectType ='Employment_Detail__c' AND DeveloperName =: AUSF_ApexConstants.FSSAI LIMIT 1][0].Id;//FSSAI 
        
        Employment_Detail__c employmentDetail = new Employment_Detail__c();
        if(String.isBlank(employmentId)){
            employmentDetail.Applicant__c = applicant.Id;
        }
        else{
            employmentDetail.Id = employmentId;
        }
        employmentDetail.RecordTypeId = recordTypeId_FSSAI;
        employmentDetail.Address__c = addressId;
        employmentDetail.Registered_Business_name__c = responseResult.FirmName; 
        employmentDetail.Document_Number__c = responseResult.LicNO;
        employmentDetail.Business_Proof_Validity__c = responseResult.Status == 'Active'? true : false;
        employmentDetail.Business_Address_Validity__c = true; /* If address received from API ,To be hardcoded as TRUE. If not received from API or if address changed or Address match less than threshold then to be made as false */
        employmentDetail.Owner_Name_Vintage_Verified__c = false; //To be defaulted as False
        upsert employmentDetail;
        return employmentDetail.Id;
    }

    /*
    @description    : handleAddressRecord - DML detail record
    @param1         : applicant - Applicant Record
    @param2         : response - to get Address from response wrapper
    @param3         : employmentId - employment detail record id
    @return         : String - Return address object Id
    */
    public static String handleAddressRecord(Applicant__c applicant, AUSF_INT_FSSAI_ResponseWrapper.Response response, String employmentId){
        //Updating existing address as Inactive
        List<Address__c> addressList = new List<Address__c>();
        if(String.isNotBlank(employmentId)){
            addressList = [SELECT Id, Active__c FROM Address__c WHERE Active__c = true AND Id IN (SELECT Address__c FROM Employment_Detail__c WHERE Id =: employmentId)];//AND RecordTypeId =: recordTypeId_FSSAI
            for(Address__c address : addressList){
                address.Active__c = false;
            }
        }
        //Creating new active address
        Address__c address = new Address__c();
        if(response.result.splitaddress!=null){
            //System.debug(LoggingLevel.Info,'address split :'+response.result.splitaddress);
            address = AUSF_AddressSplitUtilty.addressSplitOnSuccess(response.result.splitaddress, applicant.Id);
            //System.debug(LoggingLevel.Info,'address split :'+address);
        }
        else{
            address = AUSF_AddressSplitUtilty.addressSplitOnFailure(response.result.address, applicant.Id);
            //System.debug(LoggingLevel.Info,'address :'+address);
        }
        address.Applicant__c = applicant.Id;
        address.Address_Type__c = AUSF_ApexConstants.AUSF_ADDRTYPE_WORK;
        address.Address_Source__c = AUSF_ApexConstants.AUSF_BUSINESSOWNERSHIPPROOF;
        address.Active__c = true;
        addressList.add(address);
        if(!addressList.isEmpty()){
            upsert addressList;
        }
        return address.Id;
    }
}