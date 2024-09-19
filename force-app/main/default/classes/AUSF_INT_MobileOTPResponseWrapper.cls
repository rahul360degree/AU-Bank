/**
* @author        
* @date          18-June-2024
* @description   Wrapper for Mobile OTP Response
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Pradeep Sharma        18-June-2024    Initial Version
*/
public without sharing class AUSF_INT_MobileOTPResponseWrapper {
    public AUSF_INT_MobileOTPResponseWrapper(){}
    @AuraEnabled
    public AUSF_INT_IntegrationResponseWrapper.ResponseWrapper objIntResponse;
    @AuraEnabled
    public MobileOtpResponseWrapper otpResponse;
    public class MobileOtpResponseWrapper {
        @AuraEnabled
        public String requestStatus;
        @AuraEnabled
        public String statusCode;
        @AuraEnabled
        public String statusDesc;
        @AuraEnabled
        public String custRef;
    }
    @AuraEnabled
    public Boolean blnSuccess = false;
    @AuraEnabled
    public String strMessage {get;set;}
    @AuraEnabled
    public Boolean blnIntegrationSuccess = false;
}