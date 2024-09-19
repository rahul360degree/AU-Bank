public class AUSF_INT_AddressSplitWrapper {
    @AuraEnabled
    public AUSF_INT_IntegrationResponseWrapper.ResponseWrapper objIntResponse;
    @AuraEnabled
    public Boolean blnSuccess = false;
    @AuraEnabled
    public String strMessage {get;set;}
    @AuraEnabled
    public Boolean blnIntegrationSuccess = false;
    @AuraEnabled
    public Address__c address;
    
}