/**
* @author        Pradeep Sharma
* @date          21-June-2024
* @description   Wrapper that will be return from the AUSF_PanDobController > getPANDOB Method
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Pradeep Sharma        21-June-2024    Initial Version
*/
public class AUSF_INT_getPANDOBResponseWrapper {
    public AUSF_INT_getPANDOBResponseWrapper(){}
    @AuraEnabled
    public AUSF_INT_IntegrationResponseWrapper.ResponseWrapper responseWrapper;
    @AuraEnabled
    Public String status;
    @AuraEnabled
    Public String statusCode;
    @AuraEnabled
    Public Date DOB;
    @AuraEnabled
    Public String name;   
    @AuraEnabled
    public Boolean blnIntegrationSuccess = false;
    @AuraEnabled
    public Boolean blnSuccess = false;
    @AuraEnabled
    Public String strMessage;
}