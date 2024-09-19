/**
 * @author        Pradeep Sharma
 * @date          05-July-2024
 * @description   Wrapper to store Response body
 * Modification Log:
--------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Pradeep Sharma        05-July-2024    Initial Version
   */
public class AUSF_DocumentCompressResponseWrapper {
  public AUSF_DocumentCompressResponseWrapper(){}
  @AuraEnabled
  public String OutputFileBase64string;
  @AuraEnabled
  public String OutputStatus;
  @AuraEnabled
  public String Code;
}