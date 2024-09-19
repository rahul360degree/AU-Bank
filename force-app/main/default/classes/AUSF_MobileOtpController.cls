public without sharing class AUSF_MobileOtpController {
    /*
    @description    : mobileOtpVerificationHandler - Generate OTP and Validate OTP service method
    @param1         : mobileNumber - mobile number
    @param2         : otp - contains OTP in case of OTP validation else will be blank
    @param3         : leadId - Lead Record Id
    @param4         : otpValue - Service Name
    @return         : Wrapper class contains return result
    */
    @AuraEnabled
    public static AUSF_INT_MobileOTPResponseWrapper mobileOtpVerificationHandler(String mobileNumber,String otp,String leadId,String otpValue) {
        AUSF_INT_MobileOTPResponseWrapper objResponse = new AUSF_INT_MobileOTPResponseWrapper();
        Integration_Master__c objIntMapper = AUSF_INT_IntegrationUtility.getIntegrationMasterRecord(otpValue);
        String respBody;
        String strIntMessage = '';
        String previousRequestId='';
        if (objIntMapper == NULL || objIntMapper.Id == NULL) {
            throw new CustomException(AUSF_ApexConstants.GENERIC_MASTER_MISSING_ERROR_MSG);
        }
        // Check Logic runs for OTP Validation
        if(otpValue == AUSF_ApexConstants.AUSF_MobileValidateOTP_INTEGRATION_MASTER){ // AUSF_ApexConstants.
            Integration_Checklist__c intCheckList = [SELECT id,name,Request__c,Integration_Master__r.Name
                                                     FROM Integration_Checklist__c
                                                     WHERE (Integration_Master__r.Name = :AUSF_ApexConstants.AUSF_MobileGenerateOTP_INTEGRATION_MASTER OR  Integration_Master__r.Name =:AUSF_ApexConstants.AUSF_MobileResendOTP_INTEGRATION_MASTER) AND Lead_Stage__c =: leadId ORDER BY CreatedDate DESC LIMIT 1];
            
            Map<String,Object> request = (Map<String,Object>) JSON.deserializeUntyped(intCheckList.Request__c);
            previousRequestId = String.valueOf(request.get('requestId'));
            previousRequestId = previousRequestId.replace('_','');
        }
        try {
            Lead_Stage__c lead = [SELECT Id,Name FROM Lead_Stage__c WHERE Id = : leadId LIMIT 1];
            Integration_Checklist__c newChecklistInstance = new Integration_Checklist__c();
            newChecklistInstance.Integration_Master__c = objIntMapper.Id;
            newChecklistInstance.Lead_Stage__c = lead.Id;
            AUSF_INT_IntegrationUtility.InputWrapper inputData = new AUSF_INT_IntegrationUtility.InputWrapper();
            inputData.integrationChecklistRecord = newChecklistInstance;
            inputData.integrationMasterRecord = objIntMapper;
            inputData.leadStageRecord = lead;
            inputData.dynamicInputs = new Map<String, Object>();
            inputData.dynamicInputs.put('mobileNumber', mobileNumber);
            inputData.dynamicInputs.put('encryptionKey',objIntMapper.Encryption_Key__c);
            inputData.dynamicInputs.put('iv',objIntMapper.IV__c);
            if(otpValue == 'Mobile Validate OTP'){
                inputData.dynamicInputs.put('otp',otp);
                inputData.dynamicInputs.put('custRef',previousRequestId);
            }
            Map<String, String> paramValueMap = new Map<String, String>();
            for(Integration_Static_Param__mdt integrationStaticParamObj : [SELECT API_Name__c, Param_Name__c, Param_Value__c
                                                                           FROM Integration_Static_Param__mdt
                                                                           WHERE API_Name__c = :otpValue]){
                paramValueMap.put(integrationStaticParamObj.Param_Name__c,integrationStaticParamObj.Param_Value__c);
            }
            inputData.dynamicInputs.put('channel',objIntMapper.Channel__c);
            inputData.dynamicInputs.put('otplength',paramValueMap.get('otplength'));
            inputData.dynamicInputs.put('otptimeout',paramValueMap.get('otptimeout'));
            inputData.dynamicInputs.put('msgContent',paramValueMap.get('msgContent'));
            inputData.dynamicInputs.put('otptype',paramValueMap.get('otptype'));
            AUSF_INT_IntegrationUtility utilityInstance = new AUSF_INT_IntegrationUtility();
            AUSF_INT_IntegrationRequestWrapper.HTTPRequestWrapper requestDetails = utilityInstance.constructRequest(inputData);
            // Check for Pre-Requisite Errors
            if (String.isNotBlank(requestDetails.preRequisites)) {
                newChecklistInstance.Status__c = AUSF_ApexConstants.MISSING_PRE_REQUISITES;
                newChecklistInstance.Missing_Pre_requisites__c = requestDetails.preRequisites;
                upsert newChecklistInstance;
                Integration_Checklist__c objINCChecl = AUSF_INT_IntegrationUtility.getIntegrationChecklist (newChecklistInstance.Id);
                throw new CustomException(requestDetails.preRequisites + ' - ' + objINCChecl.Name);
            }
            AUSF_INT_IntegrationResponseWrapper.ResponseWrapper calloutResponseWrapper;
            AUSF_INT_IntegrationRequestWrapper.RequestWrapper calloutRequestWrapper = new AUSF_INT_IntegrationRequestWrapper.RequestWrapper();
            calloutRequestWrapper.request = requestDetails.request;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = newChecklistInstance;
            calloutRequestWrapper.entityId = lead.Id;
            calloutResponseWrapper = utilityInstance.initiateCallout(calloutRequestWrapper);
            if (calloutResponseWrapper.errorMessage!=null) {
                throw new CustomException(calloutResponseWrapper.errorMessage);
            }
            // Check for HTTP Status Code
            if (calloutResponseWrapper.statusCode < 200 || calloutResponseWrapper.statusCode > 299) {
                calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                upsert calloutResponseWrapper.checklistRecord;
                strIntMessage = 'Error With Service - ' + objIntMapper.Name + ' and record reference - ';
                objResponse.objIntResponse = calloutResponseWrapper;
            }
            else  {
                AUSF_INT_MobileOTPResponseWrapper.MobileOtpResponseWrapper res = (AUSF_INT_MobileOTPResponseWrapper.MobileOtpResponseWrapper)JSON.deserialize(calloutResponseWrapper.response,AUSF_INT_MobileOTPResponseWrapper.MobileOtpResponseWrapper.class);
                objResponse.otpResponse = res;
                if(calloutResponseWrapper.statusCode == 200){
                if (res.statusCode == '100') {
                    calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED;
                    objResponse.blnIntegrationSuccess = true;
                    objResponse.objIntResponse = calloutResponseWrapper;
                }
                else {
                    calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                    strIntMessage = 'Error with Service - '  + objIntMapper.Name + ' and record reference - ';
                    calloutResponseWrapper.errorMessage = strIntMessage;
                    objResponse.objIntResponse = calloutResponseWrapper;
                }
            }
                objResponse.objIntResponse = calloutResponseWrapper;
                upsert calloutResponseWrapper.checklistRecord;
            }
            // Check for Integration Failure to populate Integration Checklist Name
            if (!objResponse.blnIntegrationSuccess && calloutResponseWrapper.checklistRecord != NULL && calloutResponseWrapper.checklistRecord.Id != NULL) {
                Integration_Checklist__c objChecklist = [Select Id, Name FROM Integration_Checklist__c WHERE Id =: calloutResponseWrapper.checklistRecord.Id LIMIT 1];
                objResponse.strMessage = String.isNotBlank(strIntMessage) ? strIntMessage  + objChecklist.Name : '';
                throw new CustomException (objResponse.strMessage);
            }
            objResponse.blnSuccess = true;
        }
        catch (Exception ex) {
            objResponse.strMessage = ex.getMessage();
            System.debug(LoggingLevel.Error,'Exception in class ' + ex);
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium,leadId,'Lead Stage','Mobile OTP');
        }
        return objResponse;
    }
    
    public class CustomException extends Exception {}
    
}