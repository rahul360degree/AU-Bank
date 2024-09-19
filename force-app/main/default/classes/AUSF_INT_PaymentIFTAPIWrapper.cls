public class AUSF_INT_PaymentIFTAPIWrapper {
    @AuraEnabled
    public AUSF_INT_IntegrationResponseWrapper.ResponseWrapper responseWrapper;
    @AuraEnabled
    public Boolean blnIntegrationSuccess = false;
    @AuraEnabled
    public Boolean blnSuccess = false;
    @AuraEnabled
    Public String strMessage;
    
}