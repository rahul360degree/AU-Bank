/**
* @author        Mohit M.
* @date          18-June-2024
* @description   Wrapper for Integration Response
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Mohit M.              18-June-2024    Initial Version
*/
public without sharing class AUSF_INT_IntegrationResponseWrapper {
    public class ResponseWrapper {
        @AuraEnabled
        public String response {get;set;}
        @AuraEnabled
        public Integer statusCode {get;set;}
        @AuraEnabled
        public Integration_Checklist__c checklistRecord {get;set;}
        public Boolean isRetryAllowed = false;
        @AuraEnabled
        public Boolean isReinitiateAllowed = false;
        @AuraEnabled
        public String errorMessage {get;set;}
    }
}