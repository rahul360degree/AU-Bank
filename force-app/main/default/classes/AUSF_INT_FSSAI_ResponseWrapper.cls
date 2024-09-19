/**
 * @author              : Amit Mishra
 * @date                : 03-Aug-2024
 * @description         : FSSAI API Response Wrapper Class
 * Test Class           : AUSF_INT_FSSAI_Test
 * History              :
 * ===========================================================================================================
 * <Date> 		<Authors Name> 		<Brief Description of Change>
 * ===========================================================================================================
 * 03-Aug-2024 	Amit Mishra 		Initial Version
**/
public without sharing class AUSF_INT_FSSAI_ResponseWrapper {
    public AUSF_INT_FSSAI_ResponseWrapper() {}
    
    @AuraEnabled    
    public Response response;
    @AuraEnabled    
    public String addressId;
    @AuraEnabled    
    public String employmentId;
    @AuraEnabled
    public AUSF_INT_IntegrationResponseWrapper.ResponseWrapper responseWrapper;
    @AuraEnabled
    public Boolean blnIntegrationSuccess = false;
    @AuraEnabled
    public Boolean blnSuccess = false;
    @AuraEnabled
    public String strMessage;

    public class Response{
        @AuraEnabled
        public Result result;
        @AuraEnabled
        public String statusCode;
        @AuraEnabled
        public String request_id;
    }
    
    public class Result{
        @AuraEnabled
        public String Status;
        @AuraEnabled
        public String LicType;
        @AuraEnabled
        public String FirmName;
        @AuraEnabled
        public String Address;
        @AuraEnabled
        public String LicNO;
        @AuraEnabled
        public AUSF_AddressSplitResponseWrapper.splitaddress splitaddress; //= new AUSF_AddressSplitResponseWrapper.splitaddress();
    }
}