public class AUSF_INT_ICWAI_APIWrapper {  
    public AUSF_INT_ICWAI_APIWrapper(){}
    @AuraEnabled
    public AUSF_INT_IntegrationResponseWrapper.ResponseWrapper objIntResponse;
    @AuraEnabled
    public Boolean blnSuccess = false;
    @AuraEnabled
    public String strMessage {get;set;}
    @AuraEnabled
    public Boolean blnIntegrationSuccess = false;
    @AuraEnabled
    public String employmentDetailId;
    @AuraEnabled
    public String addressId;

}