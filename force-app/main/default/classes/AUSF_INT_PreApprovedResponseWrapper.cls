/**
* @author        Rahul Yadav.
* @date          09-July-2024
* @description   This class will store response of the Pre Approved - Avail Offer API
* Test Class     AUSF_INT_PreApprovedTest
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Rahul Yadav.          09-July-2024    Initial Version
*/
public without sharing class AUSF_INT_PreApprovedResponseWrapper {
    @AuraEnabled public AUSF_INT_IntegrationResponseWrapper.ResponseWrapper responseWrapper;
    @AuraEnabled public Boolean blnIntegrationSuccess = false;
    @AuraEnabled public Boolean blnSuccess = false;
    @AuraEnabled Public String strMessage;
    @AuraEnabled public TransactionStatusWrapper TransactionStatus;
    @AuraEnabled public string OfferId;
    public AUSF_INT_PreApprovedResponseWrapper(){
        TransactionStatus = new TransactionStatusWrapper();
    }
    public class TransactionStatusWrapper{
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