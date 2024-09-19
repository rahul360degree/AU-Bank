/**
* @author        Tejendra
* @date          9-July-2024
* @description   Wrapper for RTGS response
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Tejendra            9-July-2024     Initial Version
*/
public without sharing class AUSF_INT_doRTGSResponseWrapper {
    public AUSF_INT_doRTGSResponseWrapper() {

    }
    @AuraEnabled
    public AUSF_INT_IntegrationResponseWrapper.ResponseWrapper responseWrapper;
    @AuraEnabled public cls_SettlementResponse SettlementResponse{get;set;}
   
    public class cls_SettlementResponse {
        @AuraEnabled public String Status{get;set;}   
        @AuraEnabled public String ResponseCodeDescription{get;set;}  
        @AuraEnabled public String ResponseCode{get;set;} 
        @AuraEnabled public String Remarks{get;set;}  
        @AuraEnabled public String IPHREF{get;set;}   
        @AuraEnabled public String Code{get;set;} 
        @AuraEnabled public String TransactionReferenceNumber{get;set;}   
    }  
}