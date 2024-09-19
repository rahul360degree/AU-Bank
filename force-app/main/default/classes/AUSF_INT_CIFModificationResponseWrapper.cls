/**
* @author        Tejendra
* @date          22-July-2024
* @description   Wrapper for CIF Modification Response
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Tejendra             22-July-2024    Initial Version - APL-226
*/
public without sharing class AUSF_INT_CIFModificationResponseWrapper {
    public AUSF_INT_CIFModificationResponseWrapper() {

    }
    @AuraEnabled
    public AUSF_INT_IntegrationResponseWrapper.ResponseWrapper responseWrapper;

    @AuraEnabled public TransactionStatusWrapper TransactionStatus{get;set;}
    @AuraEnabled public String CustomerId{get;set;}

    public class TransactionStatusWrapper{
        @AuraEnabled public String ResponseCode{get;set;}
        @AuraEnabled public String ResponseMessage{get;set;}
        @AuraEnabled public ExtendedErrorDetailsWrapper ExtendedErrorDetails{get;set;}
        @AuraEnabled public ValidationErrorsWrapper ValidationErrors{get;set;}
    }

    public class ExtendedErrorDetailsWrapper{
        @AuraEnabled public MessagesWrapper messages{get;set;}
    }
    

    public class MessagesWrapper{
        @AuraEnabled public String code{get;set;}
        @AuraEnabled public String message{get;set;}
    }

    public class ValidationErrorsWrapper{
        @AuraEnabled public String AttributeName{get;set;}
        @AuraEnabled public String AttributeValue{get;set;}
        @AuraEnabled public String ErrorCode{get;set;}
        @AuraEnabled public String ErrorMessage{get;set;}
    }
}