/**
* @author        Mohit M.
* @date          18-June-2024
* @description   Wrapper for Integration Request
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Mohit M.              18-June-2024    Initial Version
*/
public without sharing class AUSF_INT_IntegrationRequestWrapper {
    public class HTTPRequestWrapper {
        public String request {get;set;}
        public String preRequisites {get;set;}
    }

    public class RequestWrapper {
        public String request {get;set;}
        public Blob requestBlob {get;set;}
        public Map<String, String> headersMap {get;set;}
        public String contentType {get;set;}
        public Integer timeOut = 120000;
        public String method {get;set;}
        public Integration_Master__c masterRecord {get;set;}
        public Boolean captureResponseInAttachment = false;
        public Boolean captureRequestInAttachment = false;
        // use this when URL should include request parameters. If this is not set, the method will use URL in master
        public String endpointURL {get;set;}
        public Integration_Checklist__c checklistRecord {get;set;}
        public String certificateName {get;set;}
        public Boolean setCertificateName = true;
        public Boolean performDML = false;
        public Boolean isBasicAuth = false;
        public String userName {get;set;}
        public String password {get;set;}
        public String bearerAuthorizationHeader {get;set;}
        public Boolean encryptChecklistRequest = false;
        public Boolean encryptChecklistResponse = false;
        public String dataMaskingClass {get;set;}
        public Boolean returnHardcodedResponse = false;
        public Id entityId  {get;set;}
        public Map<String,String> urlParamsMap;
    }
}