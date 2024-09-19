/**
* @author        Rahul Yadav.
* @date          25-July-2024
* @description   This class will store response of the 
* Modification Log:
* Test Class     AUSF_CBS_LoanCreationTest
--------------------------------------------------------------------------------------------
Developer               Date            Description
--------------------------------------------------------------------------------------------
Rahul Yadav.            25-July-2024    Initial Version
*/
public without sharing class AUSF_CBS_LoanCreationResponseWrapper {
    @AuraEnabled public AUSF_INT_IntegrationResponseWrapper.ResponseWrapper responseWrapper;
    @AuraEnabled public Boolean blnIntegrationSuccess = false;
    @AuraEnabled public Boolean blnSuccess = false;
    @AuraEnabled Public String strMessage;
    @AuraEnabled public string AccountId;
    @AuraEnabled public TransactionStatusWrapper TransactionStatus;

    public AUSF_CBS_LoanCreationResponseWrapper(){
        TransactionStatus = new TransactionStatusWrapper();
    }
    public class TransactionStatusWrapper {
        @AuraEnabled public string ResponseCode;
        @AuraEnabled public string ResponseMessage;
        @AuraEnabled public ExtendedErrorDetailsWrap ExtendedErrorDetails;
    }
    public class ExtendedErrorDetailsWrap{
        @AuraEnabled public List<messagesWrap> messages;
    }
    public class messagesWrap{
        @AuraEnabled public string code;
        @AuraEnabled public string message;
    }
}