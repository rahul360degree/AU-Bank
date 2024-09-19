/**
 * @author        Pradeep Sharma
 * @date          05-July-2024
 * @description   Wrapper that will be return from the AUSF_DocumentCompressionController > getCompresssedDocument Method
 * Modification Log:
--------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Pradeep Sharma        05-July-2024    Initial Version
   */
public class AUSF_INT_DocumentCompressWrapper {
  public AUSF_INT_DocumentCompressWrapper(){}
  @AuraEnabled
  public AUSF_INT_IntegrationResponseWrapper.ResponseWrapper responseWrapper;
  @AuraEnabled
  public Boolean blnIntegrationSuccess = false;
  @AuraEnabled
  public Boolean blnSuccess = false;
  @AuraEnabled
  Public String strMessage;
  @AuraEnabled
  Public String Code;
  @AuraEnabled
  Public String OutputStatus;
  @AuraEnabled
  Public String OutputBase64String;
}