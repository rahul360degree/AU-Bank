/**
* @author        Tejendra
* @date          25-June-2024
* @description   Wrapper for Karza Name Match Response
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Tejendra             25-June-2024    Initial Version
*/
public without sharing class AUSF_NameMatchWrapper {
    public AUSF_NameMatchWrapper(){}
    @AuraEnabled
    public AUSF_INT_IntegrationResponseWrapper.ResponseWrapper objIntResponse;
    @AuraEnabled
    public NameMatchResponseWrapper nameMatchResponse;
    
    public class NameMatchResponseWrapper{
        @AuraEnabled
        public String requestId;    //18012218-e46c-4aed-9b7e-55fe2d2f39b4
        @AuraEnabled
        public cls_result result;
        @AuraEnabled
        public Integer statusCode;  //101
        @AuraEnabled
        public String statusMessage;
        @AuraEnabled
        public String ServiceExecutionStatus;
    }
    
    public class cls_result {
        @AuraEnabled
        public Double score;    //0.961111111111111
        @AuraEnabled
        public boolean result;
    }
}