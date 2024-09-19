/**
* @author        Mohit M.
* @date          18-June-2024
* @description   Mobile OTP Integration Handler class - use to generate request and validate the prerequisites
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Mohit M.              18-June-2024    Initial Version
*/
public without sharing class AUSF_MobileOTPIntegrationHandler  implements AUSF_INT_IntegrationHandlerInterface {
    
    public List < String > generateRequest(List < Object > inputWrappers) {
        List<String> lstRequestString = new List<String>();
        if (inputWrappers.isEmpty()) {
            return new List < String > ();
        }
        AUSF_INT_IntegrationUtility.InputWrapper inputWrapper = (AUSF_INT_IntegrationUtility.InputWrapper)inputWrappers.get(0);
        AUSF_OTPRequestWrapper objRequest = new AUSF_OTPRequestWrapper();
        String requestIntId = AUSF_INT_IntegrationUtility.getReferenceId();
        objRequest.mobile = String.valueOf(inputWrapper.dynamicInputs.get('mobileNumber'));
        objRequest.otptype = String.valueOf(inputWrapper.dynamicInputs.get('otptype'));
        objRequest.otplength = String.valueOf(inputWrapper.dynamicInputs.get('otplength')); 
        objRequest.otptimeout = String.valueOf(inputWrapper.dynamicInputs.get('otptimeout'));
        objRequest.msgContent = String.valueOf(inputWrapper.dynamicInputs.get('msgContent'));
        objRequest.requestId = requestIntId;
        objRequest.otp = inputWrapper.dynamicInputs.get('otp')!=null ? String.valueOf(inputWrapper.dynamicInputs.get('otp')) : '';
        system.debug('objRequest.otp -->'+objRequest.otp );
        if (objRequest.otp != '') {
            objRequest.custRef = String.valueOf(inputWrapper.dynamicInputs.get('custRef'));
            String strEncyptKey = String.valueOf(inputWrapper.dynamicInputs.get('encryptionKey'));
            String strIV = String.valueOf(inputWrapper.dynamicInputs.get('iv'));
            Blob body = AUSF_INT_IntegrationUtility.encryptData('AES256',Blob.valueOf(strEncyptKey),Blob.valueOf(strIV),Blob.valueOf(objRequest.otp));
            objRequest.otp = EncodingUtil.base64Encode(body);
        }
        objRequest.custRef = objRequest.otp != '' ? String.valueOf(inputWrapper.dynamicInputs.get('custRef')) : requestIntId.replace('_','');
        objRequest.channel = String.valueOf(inputWrapper.dynamicInputs.get('channel'));
        lstRequestString.add(JSON.serialize(objRequest));
        return lstRequestString;
    }

    public List < String > validateInputData(List < Object > inputWrappers) {
        if (inputWrappers.isEmpty()) {
            return new List < String > ();
        }
        List < String > validationErrorsList = new List < String > ();        
        return validationErrorsList;
    }

    public void beforeUpdateService(Integration_Checklist__c checklistRecord, ContentVersion responseFile) {
        // TODO
    }

    public void callbackService(List < Integration_Checklist__c > checklistRecords, List < ContentVersion > responseFiles) {
        // TODO
    }

    public List < sObject > generatePlatformEvents(List < Object > inputWrappers) {
        return null;
    }
}