public class AUSF_PaymentIFTAPIResponseWrapper{
    @AuraEnabled
    public TransactionStatus TransactionStatus;
    @AuraEnabled
    public String TransactionReferenceNo;
    @AuraEnabled
    public String ErrorCode;
    public class TransactionStatus{
        @AuraEnabled
        public String ResponseMessage;
        @AuraEnabled
        public String ResponseCode;
    }
}