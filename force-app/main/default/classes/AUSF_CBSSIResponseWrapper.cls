public class AUSF_CBSSIResponseWrapper{
    @AuraEnabled
    public TransactionStatus TransactionStatus;
    public class ValidationErrors{
        @AuraEnabled
        public String ErrorCode;
        @AuraEnabled
        public String ErrorMessage;
        @AuraEnabled
        public String AttributeName;
    }
    public class TransactionStatus{
        @AuraEnabled
        public ExtendedErrorDetails ExtendedErrorDetails;
        @AuraEnabled
        public String ResponseMessage;
        @AuraEnabled
        public list<ValidationErrors> ValidationErrors;
        @AuraEnabled
        public String ResponseCode;
    }
    public class messages{
        @AuraEnabled
        public String message;
        @AuraEnabled
        public Integer code;
    }
    public class ExtendedErrorDetails{
        @AuraEnabled
        public list<messages> messages;
    }
}