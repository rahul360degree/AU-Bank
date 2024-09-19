/**
* @author        Pradeep Sharma
* @date          05-July-2024
* @description   Wrapper that will be return from the AUSF_HunterAPIController > callHunterApi Method
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Pradeep Sharma        05-July-2024    Initial Version
*/
public class AUSF_INT_HunterAPIWrapper {
    public AUSF_INT_HunterAPIWrapper(){}
    @AuraEnabled
    public AUSF_INT_IntegrationResponseWrapper.ResponseWrapper responseWrapper;
    @AuraEnabled
    public Boolean blnIntegrationSuccess = false;
    @AuraEnabled
    public Boolean blnSuccess = false;
    @AuraEnabled
    Public String strMessage;
    @AuraEnabled
    Public String hunterStatus;
}