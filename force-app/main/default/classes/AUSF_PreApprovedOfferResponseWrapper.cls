public without sharing class AUSF_PreApprovedOfferResponseWrapper {
    @AuraEnabled
    public PreApprovedOfferResponseWrapper PreApprovedOfferResponse;
    public class PreApprovedOfferResponseWrapper{
        @AuraEnabled
        public cls_TransactionStatus TransactionStatus;
        @AuraEnabled
        public cls_CRMQueryResults[] CRMQueryResults;
    }
   
    public class cls_TransactionStatus {
        @AuraEnabled
        public String ResponseCode; //0
        @AuraEnabled
        public String ResponseMessage;  //Success
        @AuraEnabled
        public cls_ExtendedErrorDetails ExtendedErrorDetails;
    }
    
    public class cls_ExtendedErrorDetails {
        @AuraEnabled
        public cls_messages[] messages;
    }
    
    public class cls_messages {
        @AuraEnabled
        public Integer code;    //0
        @AuraEnabled
        public cls_message message;
    }
    
    public class cls_message {
    }
    
    public class cls_CRMQueryResults {
        @AuraEnabled
        public Integer RowNumber;   //1
        @AuraEnabled
        public String CustomerId;   //24083775
        @AuraEnabled
        public String OfferId;  //726254
        @AuraEnabled
        public String OfferName;    //Instant New Car Loan Rs 3500000 @7.99% p.a.
        @AuraEnabled
        public Integer ProductId;   //10204
        @AuraEnabled
        public Double FirstOfferAmount;    //40000
        @AuraEnabled
        public String ValidFrom;    //2022-03-03T18:30:00+05:30
        @AuraEnabled
        public String ValidTill;    //2029-12-16T18:30:00+05:30
        @AuraEnabled
        public Integer RatingID;    //2
        @AuraEnabled
        public String OfferDescription;
        @AuraEnabled
        public String Image_Offers;
        @AuraEnabled
        public String Avail;
        @AuraEnabled
        public String CurrencyID;   //INR
        @AuraEnabled
        public String TermsAndCondition;
        @AuraEnabled
        public String OfferIsActive;    //true
        @AuraEnabled
        public String MaxLoanTenureinMonths;    //36
        @AuraEnabled
        public String MinLoanTenureinMonths;    //12
        @AuraEnabled
        public String RateofInterest;   //21.000000
        @AuraEnabled
        public String Scheme;   //Scheme TT
        @AuraEnabled
        public String Royale;
        @AuraEnabled
        public String Employee;
        @AuraEnabled
        public String OfferType;
        @AuraEnabled
        public String Occupation;
        @AuraEnabled
        public String Location;
        @AuraEnabled
        public String RepaymentMode;
        @AuraEnabled
        public String CustomerNameinBankAccount;
        @AuraEnabled
        public String IFSCcode;
        @AuraEnabled
        public String BankBranch;
        @AuraEnabled
        public String BankName;
        @AuraEnabled
        public String off_ex1_8;    //ACC ACC ACC
        @AuraEnabled
        public String Mobile;   //6775677575
    }
}