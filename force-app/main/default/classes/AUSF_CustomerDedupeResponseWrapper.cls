/**
* @author        Pradeep Sharma
* @date          28-June-2024
* class          AUSF_CustomerDedupeResponseWrapper
* @description   Wrapper to store Response body
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Pradeep Sharma        28-June-2024    Initial Version
*/
public class AUSF_CustomerDedupeResponseWrapper{
    public AUSF_CustomerDedupeResponseWrapper(){}
    @AuraEnabled
    public TransactionStatus TransactionStatus;
    @AuraEnabled
    public list<MatchFound> MatchFound;
    public class ValidationErrors{
        @AuraEnabled
        public String AttributeName;
        @AuraEnabled
        public String AttributeValue;
        @AuraEnabled
        public String ApplicableAttributes;
        @AuraEnabled
        public String ErrorCode;
        @AuraEnabled
        public String ErrorMessage;
    }
    public class TransactionStatus{
        @AuraEnabled
        public ExtendedErrorDetails ExtendedErrorDetails;
        @AuraEnabled
        public String ResponseMessage;
        @AuraEnabled
        public ValidationErrors ValidationErrors;
        @AuraEnabled
        public String ResponseCode;
    }
    public class NPADPD{
        @AuraEnabled
        public String Filler_3;
        @AuraEnabled
        public String Filler_1;
        @AuraEnabled
        public String NPADate;
        @AuraEnabled
        public String Filler_2;
        @AuraEnabled
        public String CustID;
        @AuraEnabled
        public String NPAStatus;
        @AuraEnabled
        public String IsTWO;
        //public String Date;
        @AuraEnabled
        public Integer DPD;
        @AuraEnabled
        public String UCIF;
        @AuraEnabled
        public String AssetClass;
        @AuraEnabled
        public String ACID;
        @AuraEnabled
        public String OriginalProduct;
        @AuraEnabled
        public String Last30DaysUpg;
        @AuraEnabled
        public Decimal TotalProvision;
        @AuraEnabled
        public Integer GrossAdvance;
    }
    public class messages{
        @AuraEnabled
        public String message;
        @AuraEnabled
        public String code;
    }
    public class MatchFound{
        @AuraEnabled
        public list<NPADPD> NPADPD;
        @AuraEnabled
        public CustomerResponse CustomerResponse;
        @AuraEnabled
        public list<CRMQueryResults> CRMQueryResults;
        @AuraEnabled
        public list<CreditCardResponse> CreditCardResponse;
        @AuraEnabled
        public AccountDetails AccountDetails;
    }
    public class ExtendedErrorDetails{
        @AuraEnabled
        public messages messages;
    }
    public class CustomerResponse{
        @AuraEnabled
        public CustomerBasicInquiry CustomerBasicInquiry;
        @AuraEnabled
        public String CustomerMemo;
    }
    public class CustomerName{
        @AuraEnabled
        public String SingleFullName;
        @AuraEnabled
        public String LastName;
        @AuraEnabled
        public String ShortName;
        @AuraEnabled
        public String MidName;
        @AuraEnabled
        public String FormattedFullName;
        @AuraEnabled
        public String FirstName;
        @AuraEnabled
        public String FullName;
        @AuraEnabled
        public String Prefix;
    }
    public class CustomerBasicInquiry{
        @AuraEnabled
        public CustomerAddress CustomerAddress;
        @AuraEnabled
        public String Sex;
        @AuraEnabled
        public String CategoryType;
        @AuraEnabled
        public String IsImageAvailable;
        @AuraEnabled
        public String BirthDateText;
        @AuraEnabled
        public String IsSignatureAvailable;
        @AuraEnabled
        public String HomeBranch;
        @AuraEnabled
        public String MobileNumber;
        @AuraEnabled
        public AadhaarDetail AadhaarDetail;
        @AuraEnabled
        public String EmailAddress;
        @AuraEnabled
        public String AgeOfCustRel;
        @AuraEnabled
        public String IcType;
        @AuraEnabled
        public String CombWithdrawBal;
        @AuraEnabled
        public String IcTypeDesc;
        @AuraEnabled
        public String OfficerID;
        @AuraEnabled
        public String BankShortName;
        @AuraEnabled
        public String CustomerFullName;
        @AuraEnabled
        public String PAN;
        @AuraEnabled
        public CustomerName CustomerName;
        @AuraEnabled
        public String CustomerType;
        @AuraEnabled
        public String NationalIdentificationCode;
        @AuraEnabled
        public String AadharUpdateDate;
        @AuraEnabled
        public String CustomerId;
    }
    public class CustomerAddress{
        @AuraEnabled
        public String Zip;
        @AuraEnabled
        public String Line4;
        @AuraEnabled
        public String City;
        @AuraEnabled
        public String Line3;
        @AuraEnabled
        public String State;
        @AuraEnabled
        public String Line2;
        @AuraEnabled
        public String Country;
        @AuraEnabled
        public String Line1;
    }
    public class CustomerAccount{
        @AuraEnabled
        public String ModuleCode;
        @AuraEnabled
        public String FutureDatedAmount;
        @AuraEnabled
        public String LoanApplicationNumber;
        @AuraEnabled
        public String SafeDepositBoxId;
        @AuraEnabled
        public String ExternalAccountId;
        @AuraEnabled
        public String Iban;
        @AuraEnabled
        public String BranchName;
        @AuraEnabled
        public String DateAccountOpen;
        @AuraEnabled
        public String TotalLcyAmount;
        @AuraEnabled
        public String DateAccountActive;
        @AuraEnabled
        public String TotalAcyAmount;
        @AuraEnabled
        public String DateRelation;
        @AuraEnabled
        public String LcyAmount;
        @AuraEnabled
        public String MonthsSinceActive;
        @AuraEnabled
        public String AvailableBalance;
        @AuraEnabled
        public String BalUncollectedPrinc;
        @AuraEnabled
        public String AcyAmount;
        @AuraEnabled
        public String BalUncollectedInt;
        @AuraEnabled
        public String CurrentStatusDescription;
        @AuraEnabled
        public String TotalBalUncollecPrinc;
        @AuraEnabled
        public String CurrentStatus;
        @AuraEnabled
        public String TotalBalUncollecInt;
        @AuraEnabled
        public String OriginalBalance;
        @AuraEnabled
        public String TotalBalBook;
        @AuraEnabled
        public String BillAmount;
        @AuraEnabled
        public String DateValue;
        @AuraEnabled
        public String Reason;
        @AuraEnabled
        public String BalPrincipal;
        @AuraEnabled
        public String Classification;
        @AuraEnabled
        public String IntRate;
        @AuraEnabled
        public String UnclearFunds;
        @AuraEnabled
        public String DepositNo;
        @AuraEnabled
        public String BalanceBook;
        @AuraEnabled
        public String MaturityDate;
        @AuraEnabled
        public String CustomerRelationship;
        @AuraEnabled
        public String LienAmount;
        @AuraEnabled
        public String CurrencyShortName;
        @AuraEnabled
        public String InstallmentAmount;
        @AuraEnabled
        public String CurrencyCode;
        @AuraEnabled
        public String OtherArrear;
        @AuraEnabled
        public String CASAAccountName;
        @AuraEnabled
        public String DepositStatus;
        @AuraEnabled
        public String AccountId;
        @AuraEnabled
        public String BalCombinedAcy;
        @AuraEnabled
        public String ProductName;
        @AuraEnabled
        public String BalCombinedLcy;
        @AuraEnabled
        public String MaturityAmount;
        @AuraEnabled
        public String DepStat;
        @AuraEnabled
        public String IsTDLinkage;
        @AuraEnabled
        public String DisbursedAmount;
        @AuraEnabled
        public String IsMaturity;
        @AuraEnabled
        public String DraweeAccountNo;
        @AuraEnabled
        public String BranchCode;
        @AuraEnabled
        public String EmailId;
        @AuraEnabled
        public String CodGoalAcctStat;
        @AuraEnabled
        public String CodAcctNo;
        @AuraEnabled
        public String CodGoalAcctXfer;
        @AuraEnabled
        public String CodAcctCcy;
        @AuraEnabled
        public String CodGoalAcctXferTitle;
        @AuraEnabled
        public String AmtGoalNew;
        @AuraEnabled
        public String CodGoalName;
        @AuraEnabled
        public String AmtGoal;
        @AuraEnabled
        public String CodGoalRefNo;
        @AuraEnabled
        public CASARelationshipDetails CASARelationshipDetails;
        @AuraEnabled
        public String CtrGoalTermDays;
        @AuraEnabled
        public String TDAccountName;
        @AuraEnabled
        public String CtrGoalTermDaysNew;
        @AuraEnabled
        public String SmallClearingAccountNo;
        @AuraEnabled
        public String CtrGoalTermMon;
        @AuraEnabled
        public String OperationMode;
        @AuraEnabled
        public String CtrGoalTermMonNew;
        @AuraEnabled
        public String ODLimitUtilized;
        @AuraEnabled
        public String CtrGoalTermYear;
        @AuraEnabled
        public String ODLimitSactioned;
        @AuraEnabled
        public String CtrGoalTermYearNew;
        @AuraEnabled
        public String NomineeName;
        @AuraEnabled
        public String DatMaturityNew;
        @AuraEnabled
        public String MobileNumber;
        @AuraEnabled
        public String ProductCode;
        @AuraEnabled
        public String LoanAccountName;
        @AuraEnabled
        public String RatGoalInt;
        @AuraEnabled
        public String HoldAmount;
        @AuraEnabled
        public String Tenure;
        @AuraEnabled
        public String EmiTenure;
    }
    public class CRMQueryResults{
        @AuraEnabled
        public String Location;
        @AuraEnabled
        public String RepaymentMode;
        @AuraEnabled
        public String OfferIsActive;
        @AuraEnabled
        public String Mobile;
        @AuraEnabled
        public String CustomerId;
        @AuraEnabled
        public String CurrencyID;
        @AuraEnabled
        public String CustomerNameinBankAccount;
        @AuraEnabled
        public String MaxLoanTenureinMonths;
        @AuraEnabled
        public String MinLoanTenureinMonths;
        @AuraEnabled
        public String OfferName;
        @AuraEnabled
        public String Royale;
        @AuraEnabled
        public String Occupation;
        @AuraEnabled
        public String OfferDescription;
        @AuraEnabled
        public String IFSCcode;
        @AuraEnabled
        public String ValidFrom;
        @AuraEnabled
        public Integer RowNumber;
        @AuraEnabled
        public Integer RatingID;
        @AuraEnabled
        public Decimal FirstOfferAmount;
        @AuraEnabled
        public String OfferId;
        @AuraEnabled
        public String Employee;
        @AuraEnabled
        public String OfferType;
        @AuraEnabled
        public String BankBranch;
        @AuraEnabled
        public Integer ProductId;
        @AuraEnabled
        public String ValidTill;
        @AuraEnabled
        public String off_ex1_8;
        @AuraEnabled
        public String Image_Offers;
        @AuraEnabled
        public String Avail;
        @AuraEnabled
        public String TermsAndCondition;
        @AuraEnabled
        public String Scheme;
        @AuraEnabled
        public String RateofInterest;
        @AuraEnabled
        public String BankName;
        @AuraEnabled
        public String BankAccountNumber;
        @AuraEnabled
        public String Comments;
        @AuraEnabled
        public String TerritoryCode;
        @AuraEnabled
        public String loginid;
        @AuraEnabled
        public String OfferSource;
        @AuraEnabled
        public String remarks;
        @AuraEnabled
        public String CIBILScore;
    }
    public class CreditCardResponse{
        @AuraEnabled
        public String LastStatementBalance;
        @AuraEnabled
        public String AccountOpenDate;
        @AuraEnabled
        public String AccountStatus;
        @AuraEnabled
        public String Decode;
        @AuraEnabled
        public String SanctionedAmount;
        @AuraEnabled
        public String ProductCode;
        @AuraEnabled
        public String DPDValue;
        @AuraEnabled
        public String CustomerFullName;
        @AuraEnabled
        public String AccountNumber;
        @AuraEnabled
        public String CustomerAccountRelation;
        @AuraEnabled
        public String LoanStatus;
        @AuraEnabled
        public String CustomerID;
    }
    public class CASARelationshipDetails{
        @AuraEnabled
        public String CustomerId;
        @AuraEnabled
        public String JointHolderName;
        @AuraEnabled
        public String MobileNo;
        @AuraEnabled
        public String Emailid;
        @AuraEnabled
        public String Relationship;
    }
    public class AccountDetails{
        @AuraEnabled
        public list<CustomerAccount> CustomerAccount;
    }
    public class AadhaarDetail{
        @AuraEnabled
        public String AadhaarLinkAccount;
        @AuraEnabled
        public String AadhaarNumber;
    }
}