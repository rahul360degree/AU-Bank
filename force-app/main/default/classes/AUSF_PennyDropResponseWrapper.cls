/**
* @author        Rahul Yadav
* @date          04-July-2024
* @description   Wrapper response for Penny Drop - Account Verification
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Rahul Yadav        04-July-2024    Initial Version
*/
public without sharing class AUSF_PennyDropResponseWrapper {
    @AuraEnabled public AUSF_INT_IntegrationResponseWrapper.ResponseWrapper responseWrapper;
    @AuraEnabled public Boolean blnIntegrationSuccess = false;
    @AuraEnabled public Boolean blnSuccess = false;
    @AuraEnabled Public String strMessage;
    @AuraEnabled public string request_id;
    @AuraEnabled public Integer statusCode;
    public BankTransactionResult result;
    public class BankTransactionResult {
        public Boolean bankTxnStatus;
        public String accountNumber;
        public String ifsc;
        public String accountName;
        public String bankResponse;
    }
}