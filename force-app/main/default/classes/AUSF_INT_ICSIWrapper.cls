/**
 * @author       Pradeep Sharma
 * Class :		 AUSF_INT_ICSIWrapper
 * @date         05-Aug-2024
 * @description: return wrapper for ICAI API controller
 * Modification Log:
--------------------------------------------------------------------------------------------
    Developer             Date            Description
--------------------------------------------------------------------------------------------
    Pradeep Sharma        05-Aug-2024    Initial Version
*/
public class AUSF_INT_ICSIWrapper {
    @AuraEnabled
    public AUSF_INT_IntegrationResponseWrapper.ResponseWrapper objIntResponse;
    @AuraEnabled
    public Boolean blnSuccess = false;
    @AuraEnabled
    public String strMessage {get;set;}
    @AuraEnabled
    public Boolean blnIntegrationSuccess = false;
    @AuraEnabled
    public String addressId;
    @AuraEnabled
    public String employmentDetailId;
    
}