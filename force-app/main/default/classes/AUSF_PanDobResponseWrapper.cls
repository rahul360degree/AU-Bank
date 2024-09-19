/**
* @author        Pradeep Sharma
* @date          21-June-2024
* @description   Wrapper to store Response body
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Pradeep Sharma        21-June-2024    Initial Version
*/
public class AUSF_PanDobResponseWrapper {
    public AUSF_PanDobResponseWrapper(){}
    @AuraEnabled
    public Result result;
    @AuraEnabled
    public String requestId;
    @AuraEnabled
    public ClientData clientData;
    @AuraEnabled
    public Integer statusCode;
    
    public class ClientData {
        @AuraEnabled
        public String caseId;
    }
    public class Result {
        @AuraEnabled
        public String dob;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String status;
    }
}